## Next release

**Update note**: the query-facing `Service`/`Ingress`/`VMServiceScrape` are now named `vmestimator-<release>` and the remote-write `Service` is now named `vmestimator-insert-<release>` in both `single` and `cluster` mode (previously `vmestimator-single-<release>` in `single` mode and `vmestimator-select-<release>`/`vmestimator-storage-<release>-insert` in `cluster` mode). In `cluster` mode, `vmestimator-insert-<release>` also replaces `vmestimator-storage-<release>` as the `storage` StatefulSet's governing headless Service. `StatefulSet.spec.serviceName` is immutable, so upgrading an existing `cluster` mode install needs `kubectl delete statefulset vmestimator-storage-<release> -n <namespace> --cascade=orphan` (use the actual name if `fullnameOverride` is set) before `helm upgrade`. `single` mode isn't affected, since Services aren't immutable.

- `mode: single` now reads its configuration from `storage.*` by default instead of a separate `single.*` section; existing `single.*` overrides still take precedence. Exceptions: `single.replicaCount` is now ignored (single mode always runs 1 replica), and `cardinalityMetrics.exposeAt` defaults to `/metrics` for `single` even though `storage` itself still defaults to `/cardinality/metrics`.
- `cluster` mode now also gets a `VMServiceScrape` for `storage` (`/metrics` only); previously only `select` was scraped, so `storage` went unmonitored entirely.

## v0.2.1

**Release date:** 25 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.17](https://img.shields.io/badge/v0.1.17-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0117)

- bump version of VMEstimator to [v0.1.17](https://github.com/VictoriaMetrics/vmestimator/releases/tag/v0.1.17)

## v0.2.0

**Release date:** 02 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.16](https://img.shields.io/badge/v0.1.16-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0116)

**Update note**: resource labels were aligned with the VictoriaMetrics operator convention: `app.kubernetes.io/name: vmestimator-<component>`, `app.kubernetes.io/instance: <release>` and `app.kubernetes.io/component: monitoring`. Workload selectors are immutable, so delete the workloads together with their pods before upgrading: `kubectl delete deployment vmestimator-single-<release> -n <namespace>` in `single` mode, or `kubectl delete deployment vmestimator-select-<release> -n <namespace>` and `kubectl delete statefulset vmestimator-storage-<release> -n <namespace>` in `cluster` mode (use the actual workload names if `fullnameOverride` is set).

- update common dependency 0.4.3
- render a NetworkPolicy per component (`vmestimator-<component>-<release>`) with the same selector as the component workload, instead of a single `vmestimator-<release>` policy.

## v0.1.0

**Release date:** 30 Sep 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.16](https://img.shields.io/badge/v0.1.16-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0116)

- add the `victoria-metrics-estimator` chart with single-node and clustered deployment modes
- add `dnsConfig` option to set a custom DNS config for the pod. See [#3174](https://github.com/VictoriaMetrics/helm-charts/issues/3174)
