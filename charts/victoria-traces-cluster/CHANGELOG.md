## Next release

- add `nodePort` support for `Service` resources
- bump version of VictoriaTraces components to [v0.9.3](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.9.3)

## 0.2.7

**Release date:** 13 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.2](https://img.shields.io/badge/v0.9.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-traces-cluster%2Fchangelog%2F%23v092)

- bump common chart version 0.3.8 -> 0.3.9

## 0.2.6

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.2](https://img.shields.io/badge/v0.9.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v092)

- bump common chart version 0.3.7 -> 0.3.8

## 0.2.5

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.2](https://img.shields.io/badge/v0.9.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v092)

- fixed `HTTPRoute` backend template rendering where the `port` field was incorrectly joined onto the same line as `name`.
- fixed rendering failure when an http list entry does not have the `primary` field set.
- bump common chart version 0.3.5 -> 0.3.7

## 0.2.4

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.1](https://img.shields.io/badge/v0.9.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v091)

- bump version of VictoriaTraces components to [v0.9.1](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.9.1)

## 0.2.3

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump common chart version 0.3.4 -> 0.3.5

## 0.2.2

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump common chart version 0.3.2 -> 0.3.4

## 0.2.1

**Release date:** 28 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- fix invalid YAML rendered by `templates/route.yaml` when route is enabled on `vtinsert`/`vtselect`/`vtstorage`/`vmauth`. See [#2939](https://github.com/VictoriaMetrics/helm-charts/issues/2939).

## 0.2.0

**Release date:** 28 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

**Update note 1**: `.Values.<component>.extraArgs.httpListenAddr` was replaced by `.Values.<component>.http` array of HTTP listen address configuration, where `<component>` is one of `vtinsert`, `vtselect`, `vtstorage`, `vmauth`. See [HTTP listen address](https://docs.victoriametrics.com/helm/victoria-traces-cluster/#http-listen-address) for details.

- added `.Values.<component>.http` list of objects, where each item configures an HTTP listen address with optional TLS settings. Items are used for Pod ports, command line arguments and Service port generation. Item with `primary: true` on `vtstorage` is used for storageNode address resolution. Has higher priority than `extraArgs`.
- add ability to override container command.

## 0.1.3

**Release date:** 20 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.9.0](https://img.shields.io/badge/v0.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v090)

- bump version of VictoriaTraces components to [v0.9.0](https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/v0.9.0)

## 0.1.2

**Release date:** 18 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.2](https://img.shields.io/badge/v0.8.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v082)

- fixed `HTTPRoute` backend template rendering where the `port` field was incorrectly joined onto the same line as `name`.
- fixed rendering failure when an http list entry does not have the `primary` field set.

## 0.1.1

**Release date:** 30 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.1](https://img.shields.io/badge/v0.8.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v081)

- properly render topologySpreadConstraints for vlinsert pods. See [#2861](https://github.com/VictoriaMetrics/helm-charts/issues/2861).

## 0.1.0

**Release date:** 30 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.8.1](https://img.shields.io/badge/v0.8.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v081)

**Update node 1**: due to change in label name pods will be restarted.

- added `app.kubernetes.io/component` with value from custom `app` label. See [#2785](https://github.com/VictoriaMetrics/helm-charts/issues/2785).
- fix: rename `route.labels` to `route.extraLabels` in values.yaml to match the route template
- support volumeAttributesClassName PVC attribute. See [#2782](https://github.com/VictoriaMetrics/helm-charts/issues/2782).
- properly render topologySpreadConstraints for vminsert pods. See [#2861](https://github.com/VictoriaMetrics/helm-charts/issues/2861).

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
