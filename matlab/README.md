# MATLAB source code

This folder contains the MATLAB scripts used to identify the DC motor, design controllers and process the laboratory results.

## Recommended execution order

1. `Lab1_analise.m` — identifies the motor model from ramp, step and frequency-response experiments.
2. `Lab2_analise.m` — designs and evaluates P, I and PI velocity controllers; it also includes the wider control-design workflow.
3. `Lab3_analise.m` — performs dedicated PD/PID position-control validation and calculates experimental tracking metrics.

`Bode.m` is a compact script that generates the asymptotic Bode plot. `Bloco4b.m` contains the frequency-response acquisition and processing workflow.

## Data layout

The scripts expect the following structure:

```text
matlab/
├── Lab1_dados_Fase1.mat
├── Lab1_resultados_26_27.mat
├── Lab1_resultados_28.mat
├── Data/
│   ├── README.md
│   └── Lab2_*.mat
└── Image/
```

Raw experimental datasets are not part of the public repository. `Data/README.md` describes their expected role. They are required only to reproduce the original numerical results.

## External course dependencies

The original laboratory work used `run_experiment_Matlab2023.m` and `plot_experiment_results.m` to communicate with the Arduino-based platform. Those files were supplied within the course framework and are intentionally not redistributed or claimed as original work.

## Note on source language

The scripts preserve their original Portuguese comments, variable names and working structure. This avoids presenting a rewritten version as though it were the source used in the academic work. All portfolio documentation added to the repository is in English.
