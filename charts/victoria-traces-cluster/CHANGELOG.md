## Next release

- fix: rename `route.labels` to `route.extraLabels` in values.yaml to match the route template

## 0.0.7

**Release date:** 17 Mar 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.0](https://img.shields.io/badge/v0.8.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v080)

- support vertical pod autoscaler
- bump version of VictoriaTraces components to [v0.8.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.8.0)
- support unhealthyPodEvictionPolicy for PodDisruptionBudget. See [#2747](https://github.com/VictoriaMetrics/helm-charts/issues/2747).
- expose otlp ports when otlpGRPCListenAddr extra arg for vtinsert is set. See [#2761](https://github.com/VictoriaMetrics/helm-charts/issues/2761).

## 0.0.6

**Release date:** 21 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.7.0](https://img.shields.io/badge/v0.7.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v070)

- bump version of VictoriaTraces components to [v0.7.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.7.0)

## 0.0.5

**Release date:** 07 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.6.0](https://img.shields.io/badge/v0.6.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v060)

- bump version of VictoriaTraces components to [v0.6.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.6.0)

## 0.0.4

**Release date:** 23 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.5.1](https://img.shields.io/badge/v0.5.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v051)

- bump operator chart version 0.0.42 -> 0.0.46
- add support of k8s service traffic distribution. See [#2580](https://github.com/VictoriaMetrics/helm-charts/issues/2580).
- bump version of VictoriaTraces components to [v0.5.1](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.5.1)

## 0.0.3

**Release date:** 08 Nov 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.5.0](https://img.shields.io/badge/v0.5.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v050)

- support HTTPRoute for chart components, where ingress is available. See [#2492](https://github.com/VictoriaMetrics/helm-charts/issues/2492).

## 0.0.2

**Release date:** 14 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.4.0](https://img.shields.io/badge/v0.4.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v040)

- replaced .Values.vtstorage.persistentVolume.labels with .Values.vtstorage.persistentVolume.extraLabels
- bump version of VictoriaTraces components to [v0.4.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.4.0)

## 0.0.1

**Release date:** 16 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.2.0](https://img.shields.io/badge/v0.2.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v020)

- add victoria-traces-cluster chart
