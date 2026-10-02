## Next release

- TODO

## v0.2.0

**Release date:** 02 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.5.0](https://img.shields.io/badge/v1.5.0-success?logo=VictoriaMetrics&labelColor=gray)

**Update note**: resource labels were aligned with the VictoriaMetrics operator convention: `app.kubernetes.io/name: vtmcp`, `app.kubernetes.io/instance: <release>` and `app.kubernetes.io/component: monitoring`. The Deployment selector is immutable, so delete the Deployment before upgrading: `kubectl delete deployment vtmcp-<release> -n <namespace>` (use the actual Deployment name if `fullnameOverride` is set).

- updated common dependency 0.4.3

## v0.1.0

**Release date:** 30 Sep 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.5.0](https://img.shields.io/badge/v1.5.0-success?logo=VictoriaMetrics&labelColor=gray)

- initial release
