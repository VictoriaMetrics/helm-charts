# CHANGELOG for `victoria-metrics-k8s-stack` helm-chart

## Next release

- TODO

## 0.18.6

**Release date:** 2023-11-01

![AppVersion: v1.94.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.94.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix kube scheduler default scraping port from 10251 to 10259, Kubernetes changed it since 1.23.0. See [this pr](https://github.com/VictoriaMetrics/helm-charts/pull/736) for details.
- Bump version of operator chart to [0.27.4](https://github.com/VictoriaMetrics/helm-charts/releases/tag/victoria-metrics-operator-0.27.4)

## 0.18.5

**Release date:** 2023-10-08

![AppVersion: v1.94.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.94.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update operator chart to [v0.27.3](https://github.com/VictoriaMetrics/helm-charts/releases/tag/victoria-metrics-operator-0.27.3) for fixing [#708](https://github.com/VictoriaMetrics/helm-charts/issues/708)

## 0.18.4

**Release date:** 2023-10-04

![AppVersion: v1.94.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.94.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update dependencies: [victoria-metrics-operator -> 0.27.2](https://github.com/VictoriaMetrics/helm-charts/releases/tag/victoria-metrics-operator-0.27.2), prometheus-node-exporter -> 4.23.2, grafana -> 6.59.5.

## 0.18.3

**Release date:** 2023-10-04

![AppVersion: v1.94.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.94.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.94.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.94.0)

## 0.18.2

**Release date:** 2023-09-28

![AppVersion: v1.93.5](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix behavior of `vmalert.remoteWriteVMAgent` - remoteWrite.url for VMAlert is correctly generated considering endpoint, name, port and http.pathPrefix of VMAgent

## 0.18.1

**Release date:** 2023-09-21

![AppVersion: v1.93.5](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of VM components to [v1.93.5](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.5)

## 0.18.0

**Release date:** 2023-09-12

![AppVersion: v1.93.4](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of `grafana` helm-chart to `6.59.*`
- Bump version of `prometheus-node-exporter` helm-chart to `4.23.*`
- Bump version of `kube-state-metrics` helm-chart to `0.59.*`
- Update alerting rules
- Update grafana dashboards
- Add `make` commands `sync-rules` and `sync-dashboards`
- Add support of VictoriaMetrics datasource

## 0.17.8

**Release date:** 2023-09-11

![AppVersion: v1.93.4](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of VM components to [v1.93.4](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.4)
- Bump version of operator chart to [0.27.0](https://github.com/VictoriaMetrics/helm-charts/releases/tag/victoria-metrics-operator-0.27.0)

## 0.17.7

**Release date:** 2023-09-07

![AppVersion: v1.93.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of operator helm-chart to `0.26.2`

## 0.17.6

**Release date:** 2023-09-04

![AppVersion: v1.93.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Move `cleanupCRD` option to victoria-metrics-operator chart (#593)
- Disable `honorTimestamps` for cadvisor scrape job by default (#617)
- For vmalert all replicas of alertmanager are added to notifiers (only if alertmanager is enabled) (#619)
- Add `grafanaOperatorDashboardsFormat` option (#615)
- Fix query expression for memory calculation in `k8s-views-global` dashboard (#636)
- Bump version of Victoria Metrics components to `v1.93.3`
- Bump version of operator helm-chart to `0.26.0`

## 0.17.5

**Release date:** 2023-08-23

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.93.0 to v1.93.1

## 0.17.4

**Release date:** 2023-08-12

![AppVersion: v1.93.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.92.1 to v1.93.0
* delete an obsolete parameter remaining by mistake (see https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack#upgrade-to-0130) (#602)

## 0.17.3

**Release date:** 2023-07-28

![AppVersion: v1.92.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.92.0 to v1.92.1 (#599)

## 0.17.2

**Release date:** 2023-07-27

![AppVersion: v1.92.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.91.3 to v1.92.0
