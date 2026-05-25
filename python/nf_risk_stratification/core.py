"""Pure-Python NF risk stratification routines.

The statistical tests intentionally avoid heavyweight runtime dependencies so
the package remains easy to install. Partial one-sample tests use a normal
approximation for the two-sided p-value; the global NPC combination methods and
bootstrap intervals are deterministic and dependency-free.
"""

from __future__ import annotations

import csv
import math
import random
from pathlib import Path
from statistics import mean, median, stdev
from typing import Iterable, Mapping, Sequence

ClinicalRow = dict[str, object]
ClinicalData = list[ClinicalRow]

REQUIRED_COLUMNS = ("HBA1C", "ALBUMINA")
DEFAULT_REFERENCE_VALUES = {"HBA1C": 7.0, "ALBUMINA": 2.8}
DEFAULT_RANK_DIRECTIONS = {
    "HBA1C": "desc",
    "ALBUMINA": "asc",
    "MORTO": "desc",
    "AMPUTAZIONE": "desc",
}


def read_nf_data(path: str | Path = "data/nf_clinical_data.csv") -> ClinicalData:
    """Read and validate an anonymized NF clinical CSV file."""

    csv_path = Path(path)
    if not csv_path.exists():
        raise FileNotFoundError(f"Dataset not found at: {csv_path}")

    with csv_path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))

    return validate_nf_data(rows)


def validate_nf_data(
    data: Iterable[Mapping[str, object]],
    required: Sequence[str] = REQUIRED_COLUMNS,
) -> ClinicalData:
    """Validate required clinical columns and normalize numeric values."""

    rows = [dict(row) for row in data]
    if not rows:
        raise ValueError("data must contain at least one row")

    missing = [column for column in required if column not in rows[0]]
    if missing:
        raise ValueError(f"Missing required column(s): {', '.join(missing)}")

    numeric_columns = set(REQUIRED_COLUMNS) | {"MORTO", "AMPUTAZIONE"}
    for row in rows:
        for column in numeric_columns.intersection(row):
            row[column] = _to_float(row[column])

    empty_required = [
        column
        for column in required
        if all(row.get(column) is None for row in rows)
    ]
    if empty_required:
        raise ValueError(
            "Required column(s) contain only missing or non-numeric values: "
            + ", ".join(empty_required)
        )

    return rows


def descriptive_stats(
    data: Iterable[Mapping[str, object]],
    variables: Sequence[str] = REQUIRED_COLUMNS,
) -> list[dict[str, float | int | str | None]]:
    """Compute descriptive statistics for clinical variables."""

    rows = validate_nf_data(data, required=tuple(c for c in REQUIRED_COLUMNS if c in variables))
    summaries: list[dict[str, float | int | str | None]] = []

    for variable in variables:
        values = _finite_values(row.get(variable) for row in rows)
        summaries.append(
            {
                "variable": variable,
                "n": len(values),
                "mean": mean(values) if values else None,
                "median": median(values) if values else None,
                "sd": stdev(values) if len(values) > 1 else None,
                "min": min(values) if values else None,
                "max": max(values) if values else None,
            }
        )

    return summaries


def npc_analysis(
    data: Iterable[Mapping[str, object]],
    reference_values: Mapping[str, float] = DEFAULT_REFERENCE_VALUES,
) -> dict[str, object]:
    """Run partial tests and NPC-style p-value combinations."""

    rows = validate_nf_data(data, required=tuple(reference_values))
    partial = {
        variable: _one_sample_p_value(
            _finite_values(row.get(variable) for row in rows),
            reference,
        )
        for variable, reference in reference_values.items()
    }

    valid = [p for p in partial.values() if p is not None and math.isfinite(p)]
    global_p = _combine_p_values(valid)

    return {
        "partial_p_values": partial,
        "bonferroni_p_values": {
            variable: min(p * len(valid), 1.0) if p is not None else None
            for variable, p in partial.items()
        },
        "global_p_values": global_p,
        "reference_values": dict(reference_values),
    }


def bootstrap_ci(
    data: Iterable[Mapping[str, object]],
    variables: Sequence[str] = REQUIRED_COLUMNS,
    reps: int = 1000,
    conf: float = 0.95,
    seed: int | None = 2026,
) -> list[dict[str, float | int | str | None]]:
    """Compute percentile bootstrap confidence intervals for variable means."""

    if reps < 100:
        raise ValueError("reps must be at least 100")
    if not 0 < conf < 1:
        raise ValueError("conf must be between 0 and 1")

    rows = validate_nf_data(data, required=tuple(c for c in REQUIRED_COLUMNS if c in variables))
    intervals: list[dict[str, float | int | str | None]] = []
    alpha = 1 - conf

    for index, variable in enumerate(variables):
        values = _finite_values(row.get(variable) for row in rows)
        if len(values) < 2:
            intervals.append(
                {
                    "variable": variable,
                    "mean": mean(values) if values else None,
                    "conf_low": None,
                    "conf_high": None,
                    "conf_level": conf,
                    "reps": reps,
                }
            )
            continue

        rng = random.Random(None if seed is None else seed + index)
        draws = [
            mean(rng.choice(values) for _ in range(len(values)))
            for _ in range(reps)
        ]
        draws.sort()
        intervals.append(
            {
                "variable": variable,
                "mean": mean(values),
                "conf_low": _percentile(draws, alpha / 2),
                "conf_high": _percentile(draws, 1 - alpha / 2),
                "conf_level": conf,
                "reps": reps,
            }
        )

    return intervals


def rank_patients(
    data: Iterable[Mapping[str, object]],
    variables: Sequence[str] | None = None,
    directions: Mapping[str, str] = DEFAULT_RANK_DIRECTIONS,
    id_col: str = "PATIENT_ID",
) -> ClinicalData:
    """Rank patients from highest to lowest aggregate severity."""

    rows = validate_nf_data(data)
    if variables is None:
        variables = [column for column in DEFAULT_RANK_DIRECTIONS if column in rows[0]]
    if not variables:
        raise ValueError("No ranking variables were found in data")

    ranks_by_variable: dict[str, list[float | None]] = {}
    for variable in variables:
        direction = directions.get(variable, "desc")
        if direction not in {"asc", "desc"}:
            raise ValueError(f"Ranking direction for {variable!r} must be 'asc' or 'desc'")

        values = [_to_float(row.get(variable)) for row in rows]
        rank_input = [
            (-value if direction == "asc" and value is not None else value)
            for value in values
        ]
        ranks_by_variable[variable] = _average_ranks(rank_input)

    ranked: ClinicalData = []
    for index, row in enumerate(rows):
        out = dict(row)
        score = 0.0
        for variable in variables:
            rank_value = ranks_by_variable[variable][index]
            out[f"RANK_{variable}"] = rank_value
            score += rank_value or 0.0
        out["SEVERITY_SCORE"] = score
        ranked.append(out)

    ranked.sort(key=lambda row: float(row["SEVERITY_SCORE"]), reverse=True)
    for index, row in enumerate(ranked, start=1):
        row["SEVERITY_RANK"] = index

    if id_col and id_col in ranked[0]:
        return [_move_first(row, id_col) for row in ranked]
    return ranked


def run_nf_pipeline(
    path_or_data: str | Path | Iterable[Mapping[str, object]] = "data/nf_clinical_data.csv",
    bootstrap_reps: int = 1000,
    seed: int | None = 2026,
) -> dict[str, object]:
    """Run the complete NF risk stratification workflow."""

    data = read_nf_data(path_or_data) if isinstance(path_or_data, (str, Path)) else validate_nf_data(path_or_data)
    return {
        "descriptive": descriptive_stats(data),
        "npc": npc_analysis(data),
        "bootstrap": bootstrap_ci(data, reps=bootstrap_reps, seed=seed),
        "ranking": rank_patients(data),
    }


def _to_float(value: object) -> float | None:
    if value in (None, ""):
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    return number if math.isfinite(number) else None


def _finite_values(values: Iterable[object]) -> list[float]:
    converted = [_to_float(value) for value in values]
    return [value for value in converted if value is not None]


def _one_sample_p_value(values: Sequence[float], reference: float) -> float | None:
    if len(values) < 2:
        return None
    sd = stdev(values)
    if sd == 0:
        return None
    statistic = (mean(values) - reference) / (sd / math.sqrt(len(values)))
    return min(math.erfc(abs(statistic) / math.sqrt(2)), 1.0)


def _combine_p_values(p_values: Sequence[float]) -> dict[str, float | None]:
    if not p_values:
        return {"fisher": None, "tippett": None, "liptak": None}

    clipped = [min(max(p, 1e-15), 1 - 1e-15) for p in p_values]
    fisher_stat = -2 * sum(math.log(p) for p in clipped)
    half = fisher_stat / 2
    fisher = math.exp(-half) * sum(
        half**i / math.factorial(i)
        for i in range(len(clipped))
    )
    tippett = 1 - (1 - min(clipped)) ** len(clipped)
    z_score = sum(_inverse_normal_cdf(1 - p) for p in clipped) / math.sqrt(len(clipped))
    liptak = 0.5 * math.erfc(z_score / math.sqrt(2))
    return {"fisher": fisher, "tippett": tippett, "liptak": liptak}


def _percentile(sorted_values: Sequence[float], probability: float) -> float:
    if not sorted_values:
        raise ValueError("sorted_values must not be empty")
    position = probability * (len(sorted_values) - 1)
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return sorted_values[lower]
    weight = position - lower
    return sorted_values[lower] * (1 - weight) + sorted_values[upper] * weight


def _average_ranks(values: Sequence[float | None]) -> list[float | None]:
    indexed = sorted(
        (value, index)
        for index, value in enumerate(values)
        if value is not None
    )
    ranks: list[float | None] = [None] * len(values)
    start = 0
    while start < len(indexed):
        end = start + 1
        while end < len(indexed) and indexed[end][0] == indexed[start][0]:
            end += 1
        average_rank = (start + 1 + end) / 2
        for _, original_index in indexed[start:end]:
            ranks[original_index] = average_rank
        start = end
    return ranks


def _move_first(row: Mapping[str, object], key: str) -> ClinicalRow:
    return {key: row[key], **{k: v for k, v in row.items() if k != key}}


def _inverse_normal_cdf(probability: float) -> float:
    """Approximate inverse standard-normal CDF using Acklam's algorithm."""

    if not 0 < probability < 1:
        raise ValueError("probability must be between 0 and 1")

    a = [
        -3.969683028665376e01,
        2.209460984245205e02,
        -2.759285104469687e02,
        1.383577518672690e02,
        -3.066479806614716e01,
        2.506628277459239e00,
    ]
    b = [
        -5.447609879822406e01,
        1.615858368580409e02,
        -1.556989798598866e02,
        6.680131188771972e01,
        -1.328068155288572e01,
    ]
    c = [
        -7.784894002430293e-03,
        -3.223964580411365e-01,
        -2.400758277161838e00,
        -2.549732539343734e00,
        4.374664141464968e00,
        2.938163982698783e00,
    ]
    d = [
        7.784695709041462e-03,
        3.224671290700398e-01,
        2.445134137142996e00,
        3.754408661907416e00,
    ]

    plow = 0.02425
    phigh = 1 - plow
    if probability < plow:
        q = math.sqrt(-2 * math.log(probability))
        return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) / (
            (((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1
        )
    if probability > phigh:
        q = math.sqrt(-2 * math.log(1 - probability))
        return -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) / (
            (((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1
        )

    q = probability - 0.5
    r = q * q
    return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * q / (
        ((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1
    )
