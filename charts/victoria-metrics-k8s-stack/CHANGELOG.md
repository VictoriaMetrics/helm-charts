# CHANGELOG for `victoria-metrics-k8s-stack` helm-chart

## Next release

**Release date:** TBD

![AppVersion: **APP_VERSION**](https://img.shields.io/static/v1?label=AppVersion&message=**APP_VERSION**&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Move `cleanupCRD` option to victoria-metrics-operator chart (#593)
* Disable `honorTimestamps` for cadvisor scrape job by default (#617)
* For vmalert all replicas of alertmanager are added to notifiers (only if alertmanager is enabled) (#619)
* Add `grafanaOperatorDashboardsFormat` option (#615)
* Fix query expression for memory calculation in `k8s-views-global` dashboard (#636)

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
