# Experimental DC Motor Control in MATLAB

Academic project on the experimental modelling, identification and closed-loop control of a DC motor. The work combines theoretical design, MATLAB simulation and laboratory validation using an Arduino-based experimental platform.

> This is a curated portfolio version of an academic project completed in the Control course of the BSc in Electrical and Computer Engineering at Instituto Superior Técnico. It contains the analysis and processing scripts developed by Rómulo Yan. The original laboratory acquisition helpers supplied with the course are deliberately not included.

## Project scope

The project follows the full control-design workflow:

1. identify a first-order DC-motor model from step and frequency-response experiments;
2. characterise the motor dead zone from positive and negative ramp experiments;
3. design and compare P, I and PI controllers for angular-velocity control;
4. design and compare PD and PID controllers for angular-position control;
5. validate the designs experimentally and quantify tracking error, settling time, overshoot and control effort.

The identified velocity model is:

\[
G_\omega(s) = \frac{0.1924}{s + 2.1119}
\]

The corresponding position model is:

\[
G_\theta(s) = \frac{0.1924}{s(s + 2.1119)}
\]

## Quantitative results

### Model identification

| Quantity | Result | Interpretation |
| --- | --- | --- |
| Time-domain static gain, `k0` | `0.0911 rad s⁻¹/PWM` | Selected for the linear model around the operating point. |
| Time-domain dynamic parameter, `a` | `2.1119 s⁻¹` | Corresponds to a first-order time constant of about `0.474 s`. |
| Frequency-response estimate | `k0 ≈ 0.0974`, `a ≈ 2.11 s⁻¹` | Independent Bode validation, consistent with the step-response model. |
| Dead-zone thresholds | `u− ≈ −26.17`, `u+ ≈ +33.27 PWM` | Nonlinearity observed before meaningful motor motion. |
| Mean dead-zone magnitude, `c` | `≈ 29.72 PWM` | Explains why the selected identification step avoids the zero-speed region. |

### Experimental velocity-control performance

Values are mean ± sample standard deviation across three laboratory runs. The criterion was `Ts20% < 0.3 s` with a final value close to one.

| Controller | Gains | `Ts20%` [s] | Overshoot [%] | Final value | `u_max` [PWM] | Assessment |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| P | `kω = 30` | `0.1507 ± 0.0110` | `4.19 ± 0.09` | `0.7618 ± 0.0107` | `161.67 ± 10.08` | Fast, but non-zero steady-state error. |
| I | `ki = 5.7956` | `2.4717 ± 0.0146` | `5.93 ± 2.13` | `0.9998 ± 0.0012` | `91.36 ± 2.83` | Zero steady-state error, but far too slow. |
| PI | `kω = 30`, `ki = 60` | `0.2231 ± 0.0148` | `4.21 ± 0.38` | `1.0009 ± 0.0003` | `158.80 ± 12.58` | Selected: meets the settling-time requirement and tracks the reference. |
| PI (reduced gains) | `kω = 20`, `ki = 40` | `0.3749 ± 0.0128` | `4.46 ± 0.70` | `1.0006 ± 0.0011` | `124.40 ± 7.16` | Lower effort, but fails the settling-time requirement. |

### Experimental position-tracking performance

Values are mean ± sample standard deviation across three ramp-tracking runs. Error metrics use the ramp-following phase only.

| Controller | Gains (`k1`, `k2`, `k3`) | `e_RMS` [rad] | `|e_f|` [rad] | `u_mean` [PWM] | `|u|_max` [PWM] | Assessment |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| PD | `(70, 35, 0)` | `0.6069 ± 0.0315` | `0.6096 ± 0.0297` | `104.61 ± 2.21` | `210.42 ± 10.25` | Stable and fast, but retains ramp-tracking error. |
| PID | `(70, 35, 20)` | `0.2634 ± 0.0148` | `0.0201 ± 0.0065` | `103.79 ± 2.52` | `205.52 ± 7.23` | Strong reduction of the final error. |
| PID | `(70, 35, 40)` | `0.1920 ± 0.0090` | `0.0056 ± 0.0013` | `103.62 ± 2.29` | `201.10 ± 2.76` | Best overall ramp tracking without increased control effort. |

## Repository structure

```text
matlab/
├── Lab1_analise.m          # system identification and frequency-response analysis
├── Lab2_analise.m          # velocity and position-control design/analysis
├── Lab3_analise.m          # position-control validation and metrics
├── Bode.m                  # asymptotic Bode plot
├── Bloco4b.m               # frequency-response acquisition/processing workflow
├── Data/
│   └── README.md            # expected data layout; raw datasets are private
└── Image/                  # output folder for generated figures
docs/
└── attribution.md          # authorship and dependency notes
```

## Source code

The MATLAB source is available directly in the [`matlab/`](matlab/) folder:

- [`Lab1_analise.m`](matlab/Lab1_analise.m) — dead-zone identification, step-response identification and frequency-response analysis.
- [`Lab2_analise.m`](matlab/Lab2_analise.m) — design and analysis of P, I, PI, PD and PID controllers, including experimental velocity-control processing.
- [`Lab3_analise.m`](matlab/Lab3_analise.m) — dedicated position-control validation, experimental comparison and tracking-error metrics.
- [`Bode.m`](matlab/Bode.m) — asymptotic Bode plot for the identified model.
- [`Bloco4b.m`](matlab/Bloco4b.m) — frequency-response acquisition and post-processing workflow.

See [`matlab/README.md`](matlab/README.md) for the execution order, dependencies and expected data layout.

## Requirements

- MATLAB (tested in the 2025/2026 course environment);
- Control System Toolbox;
- access to the original experimental data placed in `matlab/` and `matlab/Data/`.

The raw MATLAB datasets are retained privately in this public release because they originate from an academic group-laboratory environment. The expected data layout is documented in [`matlab/Data/README.md`](matlab/Data/README.md). The repository documents the full analysis workflow and the measured results. Sections that start a new physical experiment require the course-provided acquisition functions and the Arduino-based setup; these functions are not redistributed here.

## Running the analysis with access to the dataset

1. Obtain or prepare the experimental files in the layout shown under `matlab/` and `matlab/Data/`.
2. Open MATLAB and set the current folder to `matlab/`.
3. Run `Lab1_analise.m` for identification and frequency-response analysis.
4. Run `Lab2_analise.m` for controller design and velocity-control analysis.
5. Run `Lab3_analise.m` for the dedicated position-control validation and metrics.

These are preserved laboratory working scripts, not a packaged one-click application. The processing blocks require the original data; acquisition blocks additionally require the course-provided functions and the Arduino-based setup. The legacy MATLAB comments remain in Portuguese because they are part of the original academic working scripts. This README and all new documentation are in English.

## Selected results and experimental evidence

This section presents the results in the same order as the technical workflow, rather than showing only the final controller comparison.

### 1. Experimental identification

| Applied ramps and measured motor speed | Dead-zone characterisation |
| --- | --- |
| ![Raw positive and negative ramp experiments](matlab/Image/Fig21_RampasBrutas.png) | ![Measured dead-zone thresholds](matlab/Image/Fig22_ZonaMorta.png) |

| First-order step-response identification | Frequency-response measurement |
| --- | --- |
| ![Identification of the time constant using the 63.2 percent method](matlab/Image/Fig32_Degrau632.png) | ![Experimental Bode diagram](matlab/Image/Fig40_BodeExperimental.png) |

The ramp tests provide the measured dead-zone thresholds, approximately `-26.17` and `+33.27` PWM units. The step response identifies the first-order dynamics, while the Bode result independently checks the frequency-domain behaviour.

### 2. Velocity-control design and validation

| Closed-loop design comparison | Experimental P, I and PI comparison |
| --- | --- |
| ![P I and PI closed-loop response comparison](matlab/Image/Fig36_Comparacao_P_I_PI.png) | ![Experimental comparison of P I and PI velocity controllers](matlab/Image/Fig37_Exp_Comparacao_Step_P_I_PI.png) |

| PI model-versus-experiment validation |
| --- |
| ![Comparison between experimental and simulated PI velocity response](matlab/Image/Fig39_Exp_vs_Sim_PI.png) |

The selected PI controller (`kω = 30`, `ki = 60`) was assessed against the measured response. The figures use the representative second laboratory run, which yielded a settling time of `0.2314 s` and overshoot of `4.42%`; the table above reports mean ± sample standard deviation across all three runs.

### 3. Position-control design and experimental validation

| PD/PID ramp tracking (simulation) | Experimental angular-position response (representative run 2) |
| --- | --- |
| ![PD and PID ramp-tracking comparison](matlab/Image/Fig44_Rampa_PD_PID_Posicao.png) | ![Experimental angular-position comparison](matlab/Image/Fig435_PosicaoComparacao_exp2.png) |

| Position-tracking error (representative run 2) | Control effort (representative run 2) |
| --- | --- |
| ![Experimental PD and PID position-tracking error](matlab/Image/Fig434_ErroComparacao_exp2.png) | ![Experimental comparison of control effort](matlab/Image/Fig436_AtuacaoComparacao_exp2.png) |

The position-control comparisons cover tracking accuracy and the corresponding actuation signal, so the controller is assessed on both output performance and control effort.

The plots retain their original Portuguese labels as generated by the academic MATLAB scripts. They are included as unmodified script outputs: some document controller-design simulations and others document experimental measurements. The surrounding documentation is in English.

## Authorship and academic context

See [docs/attribution.md](docs/attribution.md). This repository is intended to document technical work and results; it is not a replacement for the original academic submission.
