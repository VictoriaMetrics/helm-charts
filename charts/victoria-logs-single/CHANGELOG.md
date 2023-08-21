# CHANGELOG for `victoria-logs-single` helm-chart

## Next Release 

**Release date:** TBD

![AppVersion: **APP_VERSION**](https://img.shields.io/static/v1?label=AppVersion&message=**APP_VERSION**&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- TODO

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
