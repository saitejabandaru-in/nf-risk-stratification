# NF Risk Stratification

`nf-risk-stratification` provides a lightweight Python API for reproducible
clinical risk stratification in necrotizing fasciitis.

It mirrors the repository's R package workflow with:

* clinical descriptive summaries
* approximate one-sample partial tests
* Fisher, Tippett, and Liptak NPC-style p-value combinations
* Bonferroni correction
* bootstrap confidence intervals
* patient severity ranking
* a complete pipeline runner

## Install

```bash
python -m pip install nf-risk-stratification
```

## Quick Start

```python
from nf_risk_stratification import (
    bootstrap_ci,
    descriptive_stats,
    npc_analysis,
    rank_patients,
    read_nf_data,
    run_nf_pipeline,
)

data = read_nf_data("data/nf_clinical_data.csv")

print(descriptive_stats(data))
print(npc_analysis(data))
print(bootstrap_ci(data))
print(rank_patients(data)[:10])

results = run_nf_pipeline("data/nf_clinical_data.csv")
```

## Data

Required CSV columns:

| Column | Meaning |
| --- | --- |
| `HBA1C` | Glycemic control |
| `ALBUMINA` | Nutritional status |

Optional columns:

| Column | Meaning |
| --- | --- |
| `MORTO` | Mortality outcome |
| `AMPUTAZIONE` | Major amputation outcome |
| `PATIENT_ID` | Patient identifier |

The real clinical dataset is not included for privacy and ethics reasons.

## Citation

Permutation-Based Analysis of Clinical Variables in Necrotizing Fasciitis Using
NPC and Bootstrap. Piscopo, G., Bandaru, S. T., Giacalone, M., & Longobardi, M.
(2025). Mathematics, 13(17), 2869. https://doi.org/10.3390/math13172869
