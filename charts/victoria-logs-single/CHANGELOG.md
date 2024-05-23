# CHANGELOG for `victoria-logs-single` helm-chart

## Next release

- Update fluent-bit chart to 0.46.7 and fluentbit to 3.0.4
- Update VictoriaLogs version to 0.9.1

## 0.4.0

**Release date:** 2024-05-20

![AppVersion: v0.8.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.8.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Upgrade VictoriaLogs to [v0.8.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v0.8.0-victorialogs)
- Move `.Values.server.name`, `.Values.server.fullnameOverride` to `.Values.global.victoriaLogs.server`. This allows to avoid issues with Fluent Bit output definition. See the [pull request]() for the details.
- Include `kubernetes_namespace_name` field in the [stream fields](https://docs.victoriametrics.com/victorialogs/keyconcepts/#stream-fields) configuration of Fluent Bit output.

## 0.3.8

**Release date:** 2024-05-10

![AppVersion: v0.5.2-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.5.2-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- properly truncate value of `app.kubernetes.io/managed-by` and `app.kubernetes.io/instance` labels in case release name exceeds 63 characters.
- support disabling default securityContext to keep compatible with platform like openshift, see this [pull request](https://github.com/VictoriaMetrics/helm-charts/pull/995) by @Baboulinet-33 for details.

## 0.3.7

**Release date:** 2024-04-16

![AppVersion: v0.5.2-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.5.2-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of victorialogs to [0.5.2](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v0.5.2-victorialogs)

## 0.3.6

**Release date:** 2024-03-28

![AppVersion: v0.5.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.5.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- support adding `metricRelabelings` for server serviceMonitor (#946)

## 0.3.5

**Release date:** 2024-03-05

![AppVersion: v0.5.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.5.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of vlogs single to [0.5.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v0.5.0-victorialogs)

## 0.3.4

**Release date:** 2023-11-15

![AppVersion: v0.4.2-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.4.2-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of vlogs single to [0.4.2](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v0.4.2-victorialogs)

## 0.3.3

**Release date:** 2023-10-10

![AppVersion: v0.4.1-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.4.1-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add `kubernetes_container_name` into default [stream fields](https://docs.victoriametrics.com/VictoriaLogs/keyConcepts.html#stream-fields) configuration `fluent-bit`.

## 0.3.2

**Release date:** 2023-10-04

![AppVersion: v0.4.1-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.4.1-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of vlogs single to [0.4.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v0.4.1-victorialogs)

## 0.3.1

**Release date:** 2023-09-13

![AppVersion: v0.3.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.3.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* added: extraObjects: [] for dynamic supportive objects configuration

## 0.3.0

**Release date:** 2023-08-15

![AppVersion: v0.3.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.3.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* vlogs-single: update to 0.3.0 (#598)
* Remove repeated volumeMounts section (#610)

## 0.1.3

**Release date:** 2023-07-27

![AppVersion: v0.3.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.3.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* vlogs-single: fix podSecurityContext and securityContext usage (#597)
* charts/victoria-logs-single: fix STS render when using statefulset is disabled (#585)
* charts/victoria-logs-single: add imagePullSecrets (#586)

## 0.1.2

**Release date:** 2023-06-23

![AppVersion: v0.1.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump version of logs single
* Fix wrong condition on fluent-bit dependency (#568)

### Default value changes

```diff
# No changes in this release
```

## 0.1.1

**Release date:** 2023-06-22

![AppVersion: v0.1.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* charts/victoria-logs-single: template Host field (#566)

## 0.1.0

**Release date:** 2023-06-22

![AppVersion: v0.1.0-victorialogs](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.0-victorialogs&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* fix the chart image and jsonline endpoint
* add victoria-logs to build process, make package
* charts/victoria-logs-single: add fluentbit setup (#563)

## 0.0.1

**Release date:** 2023-06-12

![AppVersion: v0.0.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.0.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* charts/victoria-logs-single: add new chart (#560)
