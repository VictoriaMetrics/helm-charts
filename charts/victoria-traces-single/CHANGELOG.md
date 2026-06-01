## Next release

- fixed `HTTPRoute` backend template rendering where the `port` field was incorrectly joined onto the same line as `name`.
- fixed rendering failure when an http list entry does not have the `primary` field set.
- bump common chart version 0.3.5 -> 0.3.7

## 0.1.4

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.1](https://img.shields.io/badge/v0.9.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v091)

- bump version of VictoriaTraces components to [v0.9.1](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.9.1)

## 0.1.3

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump common chart version 0.3.4 -> 0.3.5

## 0.1.2

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump common chart version 0.3.2 -> 0.3.4

## 0.1.1

**Release date:** 28 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- fix invalid YAML rendered by `templates/route.yaml` when `.Values.server.route.enabled: true`. See [#2939](https://github.com/VictoriaMetrics/helm-charts/issues/2939).

## 0.1.0

**Release date:** 28 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

**Update note 1**: `.Values.server.extraArgs.httpListenAddr` was replaced by `.Values.server.http` array of HTTP listen address configuration. See [HTTP listen address](https://docs.victoriametrics.com/helm/victoria-traces-single/#http-listen-address) for details.

- added `.Values.server.http` list of objects, where each item configures an HTTP listen address with optional TLS settings. Items are used for Pod ports, command line arguments and Service port generation. Has higher priority than `extraArgs`.
- add ability to override container command.

## 0.0.9

**Release date:** 20 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump version of VictoriaTraces components to [v0.9.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.9.0)

## 0.0.8

**Release date:** 18 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.2](https://img.shields.io/badge/v0.8.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v082)

**Update node 1**: due to change in label name pods will be restarted.

- added `app.kubernetes.io/component` with value from custom `app` label. See [#2785](https://github.com/VictoriaMetrics/helm-charts/issues/2785).
- fix: rename `route.labels` to `route.extraLabels` in values.yaml to match the route template
- support volumeAttributesClassName PVC attribute. See [#2782](https://github.com/VictoriaMetrics/helm-charts/issues/2782).

## 0.0.7

**Release date:** 17 Mar 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.0](https://img.shields.io/badge/v0.8.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v080)

- bump version of VictoriaTraces components to [v0.8.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.8.0)
- support unhealthyPodEvictionPolicy for PodDisruptionBudget. See [#2747](https://github.com/VictoriaMetrics/helm-charts/issues/2747).
- expose otlp ports when otlpGRPCListenAddr extra arg is set. See [#2761](https://github.com/VictoriaMetrics/helm-charts/issues/2761).

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
- bump version of VictoriaTraces components to [v0.5.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.5.0)


## 0.0.2

**Release date:** 14 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.4.0](https://img.shields.io/badge/v0.4.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v040)

- add .Values.server.persistentVolume.extraLabels for PVC specific labels
- bump version of VictoriaTraces components to [v0.4.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.4.0)

## 0.0.1

**Release date:** 16 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.2.0](https://img.shields.io/badge/v0.2.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v020)

* charts/victoria-traces-single: add new chart
