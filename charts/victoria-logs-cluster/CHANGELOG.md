## Next release

- feature: support `tpl` in `envFrom` and `env` fields. See [#2690](https://github.com/VictoriaMetrics/helm-charts/issues/2690)

## 0.0.27

**Release date:** 05 Feb 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.45.0](https://img.shields.io/badge/v1.45.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1450)

- bump VictoriaLogs version to [v1.45.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.45.0).

## 0.0.26

**Release date:** 27 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.44.0](https://img.shields.io/badge/v1.44.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1440)

- bump VictoriaLogs version to [v1.44.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.44.0).
- `nodes/proxy` permission was removed from default clusterrole. This permission may be used to [raise privileges](https://grahamhelton.com/blog/nodes-proxy-rce). In case the vmagent will be used to scrape Kubelet's proxy endpoint, it is recommended to create a custom role with the necessary permissions.

## 0.0.25

**Release date:** 10 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- add ability to configure license for VictoriaLogs enterprise. See [#2649](https://github.com/VictoriaMetrics/helm-charts/issues/2649).

## 0.0.24

**Release date:** 26 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1431)

- bump VictoriaLogs version to [v1.43.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.43.1).

## 0.0.23

**Release date:** 23 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1430)

- bump common chart version 0.0.45 -> 0.0.46

## 0.0.22

**Release date:** 22 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1430)

- bump VictoriaLogs version to [v1.43.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.43.0).

## 0.0.21

**Release date:** 20 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.42.0](https://img.shields.io/badge/v1.42.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1420)

- bump VictoriaLogs version to [v1.42.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.42.0).

## 0.0.20

**Release date:** 17 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.41.1](https://img.shields.io/badge/v1.41.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1411)

- bump VictoriaLogs version to [v1.41.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.41.1).

## 0.0.19

**Release date:** 02 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.39.0](https://img.shields.io/badge/v1.39.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1390)

- bump common chart version 0.0.42 -> 0.0.45
- add support of k8s service traffic distribution. See [#2580](https://github.com/VictoriaMetrics/helm-charts/issues/2580).
- bump VictoriaLogs version to [v1.39.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.39.0).

## 0.0.18

**Release date:** 20 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.36.1](https://img.shields.io/badge/v1.36.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1361)

- support HTTPRoute for chart components, where ingress is available. See [#2492](https://github.com/VictoriaMetrics/helm-charts/issues/2492).

## 0.0.17

**Release date:** 14 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.36.1](https://img.shields.io/badge/v1.36.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1361)

- fixed template typo in vector config

## 0.0.16

**Release date:** 14 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.36.1](https://img.shields.io/badge/v1.36.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1361)

- add .Values.vector.customConfigName variable for managed by chart vector custom config map name. See [#2482](https://github.com/VictoriaMetrics/helm-charts/issues/2482).

## 0.0.15

**Release date:** 08 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.36.1](https://img.shields.io/badge/v1.36.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1361)

- do not merge .Values.vlstorage.persistentVolume.extraLabels with default chart labels. See [#2460](https://github.com/VictoriaMetrics/helm-charts/issues/2460).

## 0.0.14

**Release date:** 08 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.36.1](https://img.shields.io/badge/v1.36.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1361)

- Bump VictoriaLogs version to [v1.36.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.36.1).
- replaced .Values.vlstorage.persistentVolume.labels with .Values.vlstorage.persistentVolume.extraLabels

## 0.0.13

**Release date:** 27 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.35.0](https://img.shields.io/badge/v1.35.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1350)

- Bump VictoriaLogs version to [v1.35.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.35.0).

## 0.0.12

**Release date:** 22 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.34.0](https://img.shields.io/badge/v1.34.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1340)

- Add vmauth-sha256sum annotation to vmauth-server template. See [#2434](https://github.com/VictoriaMetrics/helm-charts/pull/2434) for details.
- Bump VictoriaLogs version to [v1.34.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.34.0).

## 0.0.11

**Release date:** 10 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.33.0](https://img.shields.io/badge/v1.33.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1330)

- Bump VictoriaLogs version to [v1.33.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.33.0).

## 0.0.10

**Release date:** 30 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.31.0](https://img.shields.io/badge/v1.31.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1310)

- Bump VictoriaLogs version to [v1.31.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.31.0).

## 0.0.9

**Release date:** 13 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.28.0](https://img.shields.io/badge/v1.28.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1280)

- Bump VictoriaLogs version to [v1.28.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.28.0).

## 0.0.8

**Release date:** 14 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.25.1](https://img.shields.io/badge/v1.25.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1251)

- Bump VictoriaLogs version to [v1.25.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.25.1).

## 0.0.7

**Release date:** 07 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.25.0](https://img.shields.io/badge/v1.25.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1250)

- Remove `-victorialogs` suffix from the tag rendered by chart. This is no longer needed after moving VictoriaLogs to its [own repository](https://github.com/victoriaMetrics/victorialogs).

## 0.0.6

**Release date:** 07 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.25.0](https://img.shields.io/badge/v1.25.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1250)

- Add default label selector to all `.Values.*.topologySpreadConstraints` properties. See [#2219](https://github.com/VictoriaMetrics/helm-charts/issues/2219)
- Bump VictoriaLogs version to [v1.25.0](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.25.0).

## 0.0.5

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.24.0](https://img.shields.io/badge/v1.24.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1240)

- Set app version to existing one

## 0.0.4

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.23.4](https://img.shields.io/badge/v1.23.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1234)

- Bump VictoriaLogs version to [v1.24.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.24.0-victorialogs).

## 0.0.3

**Release date:** 10 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.23.3](https://img.shields.io/badge/v1.23.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1233)

- Reduce components readiness probe failureThreshold from 10 to 3 and add `-http.shutdownDelay=15s` cmd-line flag, for graceful shutdown during rolling restarts.

## 0.0.2

**Release date:** 01 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.21.0](https://img.shields.io/badge/v1.21.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1210)

- Disable vlinsert HPA by default.
- Bump VictoriaLogs version to [v1.21.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.21.0-victorialogs).

## 0.0.1

**Release date:** 30 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.20.0](https://img.shields.io/badge/v1.20.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%2F%23v1200)

- add victoria-logs-cluster chart
