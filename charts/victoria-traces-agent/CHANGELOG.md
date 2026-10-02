## Next release

**Update note**: resource labels were aligned with the VictoriaMetrics operator convention: `app.kubernetes.io/name: vtagent`, `app.kubernetes.io/instance: <release>` and `app.kubernetes.io/component: monitoring`. The StatefulSet selector is immutable, so delete the StatefulSet together with its pods before upgrading: `kubectl delete statefulset vtagent-<release> -n <namespace>` (use the actual StatefulSet name if `fullnameOverride` is set). With `persistentVolume.enabled: true` the PersistentVolumeClaims are kept and reused by the new pods; with the default `emptyDir` the on-disk buffer is lost.

- updated common dependency 0.4.3

## v0.1.0

**Release date:** 01 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.12.0](https://img.shields.io/badge/v0.12.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriatraces%2Fchangelog%2F%23v0120)

- initial release
