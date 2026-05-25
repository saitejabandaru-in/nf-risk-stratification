from pathlib import Path

from nf_risk_stratification import (
    bootstrap_ci,
    descriptive_stats,
    npc_analysis,
    rank_patients,
    read_nf_data,
    run_nf_pipeline,
)


FIXTURE = Path("python/nf_risk_stratification/data/nf_clinical_data_example.csv")


def test_pipeline_returns_expected_sections():
    data = read_nf_data(FIXTURE)
    result = run_nf_pipeline(data, bootstrap_reps=100)

    assert set(result) == {"descriptive", "npc", "bootstrap", "ranking"}
    assert len(result["descriptive"]) == 2
    assert set(result["npc"]["global_p_values"]) == {"fisher", "tippett", "liptak"}
    assert len(result["bootstrap"]) == 2
    assert len(result["ranking"]) == len(data)


def test_ranking_orders_high_severity_first():
    data = [
        {"PATIENT_ID": "low", "HBA1C": 6.5, "ALBUMINA": 3.5, "MORTO": 0, "AMPUTAZIONE": 0},
        {"PATIENT_ID": "high", "HBA1C": 9.5, "ALBUMINA": 2.0, "MORTO": 1, "AMPUTAZIONE": 1},
    ]

    ranked = rank_patients(data)

    assert ranked[0]["PATIENT_ID"] == "high"


def test_analysis_functions_are_callable():
    data = read_nf_data(FIXTURE)

    assert descriptive_stats(data)
    assert npc_analysis(data)
    assert bootstrap_ci(data, reps=100)
