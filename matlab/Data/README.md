# Experimental data

The raw MATLAB `.mat` files used by the laboratory scripts are intentionally not included in this public repository.

The original working layout expected by the scripts is:

```text
matlab/
├── Lab1_dados_Fase1.mat
├── Lab1_resultados_26_27.mat
├── Lab1_resultados_28.mat
└── Data/
    └── Lab2_*.mat
```

These files contain group-laboratory measurements and derived workspaces. They are retained privately. Their omission means that this repository documents the analysis code and verified outputs, but does not provide a self-contained reproduction of the original numerical results.

Acquisition blocks also require the course-provided `run_experiment_Matlab2023.m` and `plot_experiment_results.m` functions together with the Arduino-based laboratory platform. Those files are not redistributed here.
