# CHANGELOG for `victoria-metrics-anomaly` helm-chart

## Next release

- TODO

## 0.5.0

**Release date:** 2023-10-31

![AppVersion: v1.6.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.6.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add options to use `bearer_token` for reader and writer authentication.
- Add `verify_tls` option to bypass TLS verification for reader and writer.
- Add `extra_filters` option to supply additional filters to enforce for reader queries.

## 0.4.1

**Release date:** 2023-10-10

![AppVersion: v1.5.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.5.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add an options to override default `metric_format` for remote write configuration of vmanomaly.

## 0.4.0

**Release date:** 2023-08-21

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* add ability to provide license key

## 0.3.5

**Release date:** 2023-06-22

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump version of vmanomaly
* charts/victoria-metrics-anomaly: fix monitoring config indentation (#567)

## 0.3.4

**Release date:** 2023-06-22

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump vmanomaly remove tricky make command
* charts/victoria-metrics-anomaly: make monitoring config more configurable (#562)

## 0.3.3

**Release date:** 2023-06-07

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump anomaly chart, make package make merge

## 0.3.2

**Release date:** 2023-06-06

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Anomaly: change defaults (#518)
* charts/operator: update version to 0.30.4 adds extraArgs and serviceMonitor options for operator
* vmanomaly re-release

## 0.3.1

**Release date:** 2023-01-26

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* vmanomaly: fix monitoring part of config (#457)

## 0.3.0

**Release date:** 2023-01-24

![AppVersion: v1.1.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.1.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* relase vmanomaly v1.1.0 (#454)
* vmanomaly: fix config for pull-based monitoring (#446)
