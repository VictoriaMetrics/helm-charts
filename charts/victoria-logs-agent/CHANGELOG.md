## Next release

- added network policy configuration support. See [#2977](https://github.com/VictoriaMetrics/helm-charts/issues/2977)

## 0.2.9

**Release date:** 16 Jul 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.52.0](https://img.shields.io/badge/v1.52.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1520)

- bump vlagent version to [v1.52.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.52.0).
- added `global.extraLabels` and `global.extraAnnotations` to apply common labels and annotations to all workload resources and pod templates

## 0.2.8

**Release date:** 25 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.51.0](https://img.shields.io/badge/v1.51.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1510)

- added `runtimeClassName` option to the pod spec
- do not merge .Values.persistentVolume.extraLabels with default chart labels. See [#2460](https://github.com/VictoriaMetrics/helm-charts/issues/2460).

## 0.2.7

**Release date:** 17 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.51.0](https://img.shields.io/badge/v1.51.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1510)

- bump vlagent version to [v1.51.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.51.0).

## 0.2.6

**Release date:** 13 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- bump common chart version 0.3.8 -> 0.3.9

## 0.2.5

**Release date:** 03 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- `serviceMonitor` port now defaults to the primary `http` list item name; added explicit `port` field to override it without using `targetPort`.

## 0.2.4

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- bump common chart version 0.3.7 -> 0.3.8

## 0.2.3

**Release date:** 01 Jun 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- fixed rendering failure when an http list entry does not have the `primary` field set.
- fixed `syslog` args rendering: boolean `false` values (e.g. `tls: false`, `useLocalTimestamp: false`) are now correctly included; absent boolean fields are gap-filled with `false` instead of empty string.
- bump common chart version 0.3.5 -> 0.3.7

## 0.2.2

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- bump common chart version 0.3.4 -> 0.3.5

## 0.2.1

**Release date:** 30 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- bump common chart version 0.3.2 -> 0.3.4

## 0.2.0

**Release date:** 28 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

**Update note 1**: `.Values.extraArgs.httpListenAddr` was replaced by `.Values.http` array of HTTP listen address configuration. See [HTTP listen address](https://docs.victoriametrics.com/helm/victoria-logs-agent/#http-listen-address) for details.

**Update note 2**: `.Values.extraArgs["syslog.listenAddr.tcp"]` and `.Values.extraArgs["syslog.listenAddr.udp"]` were replaced by `.Values.syslog.tcp` and `.Values.syslog.udp` arrays of syslog listen address configuration. See [Syslog](https://docs.victoriametrics.com/helm/victoria-logs-agent/#syslog) for details.

- added `.Values.http` list of objects, where each item configures an HTTP listen address with optional TLS settings. Items are used for Pod ports, command line arguments and Service port generation. Has higher priority than `extraArgs`.
- support `.Values.syslog.tcp` and `.Values.syslog.udp` lists for configuring syslog TCP/UDP listen addresses with optional TLS settings. Has higher priority than `extraArgs`.

## 0.1.3

**Release date:** 21 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- Added ability to pass extra Service ports using service.extraPorts. See [#2922](https://github.com/VictoriaMetrics/helm-charts/issues/2922)

## 0.1.2

**Release date:** 30 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- fixed rendering of `.Values.topologySpreadConstraints` in the pod spec.

## 0.1.1

**Release date:** 20 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- fixed selector for scrape objects. See [#2827](https://github.com/VictoriaMetrics/helm-charts/issues/2827).

## 0.1.0

**Release date:** 16 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

- revert change in Deployment's matchLabels, that was introduced in release 0.0.16

## 0.0.16

**Release date:** 14 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.50.0](https://img.shields.io/badge/v1.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1500)

**Known issue:** this release contains changes in StatefulSet matchLabels, which requires StatefulSet recreation. Skip this release to avoid disruption.

- replace custom app label with app.kubernetes.io/component. See [#2785](https://github.com/VictoriaMetrics/helm-charts/issues/2785).
- bump vlagent version to [v1.50.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.50.0).

## 0.0.15

**Release date:** 03 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.49.0](https://img.shields.io/badge/v1.49.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1490)

- bump vlagent version to [v1.49.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.49.0).
- support volumeAttributesClassName PVC attribute. See [#2782](https://github.com/VictoriaMetrics/helm-charts/issues/2782).

## 0.0.14

**Release date:** 22 Mar 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.48.0](https://img.shields.io/badge/v1.48.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1480)

- URL with format=jsonline no longer incorrectly routes to /insert/native

## 0.0.13

**Release date:** 11 Mar 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.48.0](https://img.shields.io/badge/v1.48.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1480)

- bump vlagent version to [v1.48.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.48.0).

## 0.0.12

**Release date:** 25 Feb 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.47.0](https://img.shields.io/badge/v1.47.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1470)

- bump vlagent version to [v1.47.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.47.0).

## 0.0.11

**Release date:** 23 Feb 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.46.0](https://img.shields.io/badge/v1.46.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1460)

- bump vlagent version to [v1.46.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.46.0).
- support vertical pod autoscaler

## 0.0.10

**Release date:** 05 Feb 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.45.0](https://img.shields.io/badge/v1.45.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1450)

- bump vlagent version to [v1.45.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.45.0).

## 0.0.9

**Release date:** 29 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.44.0](https://img.shields.io/badge/v1.44.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1440)

- add an ability to configure number of replicas

## 0.0.8

**Release date:** 27 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.44.0](https://img.shields.io/badge/v1.44.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1440)

- bump vlagent version to [v1.44.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.44.0).

## 0.0.7

**Release date:** 12 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- add service and container ports, when syslog.listenAddr.tcp or syslog.listenAddr.udp flags are defined.

## 0.0.6

**Release date:** 12 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- support extraArgs parameter for additional command line arguments

## 0.0.5

**Release date:** 10 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- add ability to configure license for VictoriaLogs enterprise. See [#2649](https://github.com/VictoriaMetrics/helm-charts/issues/2649).

## 0.0.4

**Release date:** 03 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- add extraObjects support
- add HorizontalPodAutoscaler support
- add ServiceMonitor support

## 0.0.3

**Release date:** 26 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- bump vlagent version to [v1.43.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.43.1).

## 0.0.2

**Release date:** 26 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- allow overriding the default `remoteWrite.url` path by specifying a non-empty value other than `/` for the `remoteWrite.url` field

## 0.0.1

**Release date:** 25 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- charts/victoria-logs-agent: add new chart
