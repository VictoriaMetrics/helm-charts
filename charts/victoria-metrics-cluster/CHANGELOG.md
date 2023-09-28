# CHANGELOG for `victoria-metrics-cluster` helm-chart

## Next release

- TODO

## 0.11.0

**Release date:** 2023-09-28

![AppVersion: v1.93.5](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add `extraObjects` which to allow deploying additional resources with the chart release (#689)

## 0.10.9

**Release date:** 2023-09-21

![AppVersion: v1.93.5](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Support `behavior` setting in horizontal pod autoscalers for vminsert and vmselect (#679)
- Bump version of VM components to [v1.93.5](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.5)

## 0.10.8

**Release date:** 2023-09-11

![AppVersion: v1.93.4](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of VM components to [v1.93.4](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.4)

## 0.10.7

**Release date:** 2023-09-04

![AppVersion: v1.93.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of Victoria Metrics Cluster to `v1.93.3`

## 0.10.5

**Release date:** 2023-08-23

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.93.0 to v1.93.1

## 0.10.4

**Release date:** 2023-08-12

![AppVersion: v1.93.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.92.1 to v1.93.0
* charts/victoria-metrics-cluster: remove incorrect comment (#607)
* vmstorage, vminsert: Add topoloogySpreadConstraints (#596)

## 0.10.3

**Release date:** 2023-07-28

![AppVersion: v1.92.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.92.0 to v1.92.1 (#599)

## 0.10.2

**Release date:** 2023-07-27

![AppVersion: v1.92.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Update VictoriaMetrics components from v1.91.3 to v1.92.0
* fix misused securityContext and podSecurityContext (#592)

## 0.10.1

**Release date:** 2023-07-25

![AppVersion: v1.91.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.91.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* fix typo in suppressStorageFQDNsRender, address #580 (#581)

## 0.10.0

**Release date:** 2023-07-13

![AppVersion: v1.91.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.91.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump version of agent, alert, auth, cluster, single
* charts/victoria-metrics-cluster: fix indent for vmselect statefulset (#576)
