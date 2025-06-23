## Next release

- Bump VictoriaLogs version to [v1.24.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.24.0-victorialogs).

## 0.0.3

**Release date:** 10 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.23.3](https://img.shields.io/badge/v1.23.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%23v1233)

- Reduce components readiness probe failureThreshold from 10 to 3 and add `-http.shutdownDelay=15s` cmd-line flag, for graceful shutdown during rolling restarts.

## 0.0.2

**Release date:** 01 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.21.0](https://img.shields.io/badge/v1.21.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%23v1210)

- Disable vlinsert HPA by default.
- Bump VictoriaLogs version to [v1.21.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.21.0-victorialogs).

## 0.0.1

**Release date:** 30 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.20.0](https://img.shields.io/badge/v1.20.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictorialogs%2Fchangelog%23v1200)

- add victoria-logs-cluster chart
