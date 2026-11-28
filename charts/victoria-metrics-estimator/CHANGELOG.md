## Next release

**Update note 1**: `mode` and `single` values are removed, rendering fails if they're set. Storage nodes always run as the `vmestimator-storage-<release>` StatefulSet behind the headless `vmestimator-storage-<release>` Service, which accepts remote write data. Select nodes run only if `select.enabled: true` is set. If `single` mode was used before, move `single.*` values to `storage.*`, then send remote write data to `vmestimator-storage-<release>` and scrape estimations from it instead of the removed `vmestimator-single-<release>` Deployment and Service. If `cluster` mode was used before, replace `mode: cluster` with `select.enabled: true`, set `storage.replicaCount` explicitly since it is `1` by default now, and send remote write data to `vmestimator-storage-<release>` instead of the removed `vmestimator-storage-<release>-insert` Service.

- remove `mode` support and align chart components with the `VMEstimator` resource of the VictoriaMetrics operator: storage nodes always run, select nodes are optional and enabled with `select.enabled`.
- expose local estimations of storage nodes at `/cardinality/metrics` only if select is enabled and has replicas, unless `storage.extraArgs.cardinalityMetrics.exposeAt` is set.
- remove `storage.service.type`, storage Service is always headless.
- rename containers to `storage` and `select`, the same as in the `VMEstimator` resource.
- add `VMServiceScrape` for storage nodes if select is enabled. Without select `VMServiceScrape` is renamed to `vmestimator-storage-<release>`.

## v0.2.2

**Release date:** 02 Nov 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.18](https://img.shields.io/badge/v0.1.18-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fvmestimator%2Freleases%23v0118)

- bump version of VMEstimator to [v0.1.18](https://github.com/VictoriaMetrics/vmestimator/releases/tag/v0.1.18)

## v0.2.1

**Release date:** 25 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.17](https://img.shields.io/badge/v0.1.17-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0117)

- bump version of VMEstimator to [v0.1.17](https://github.com/VictoriaMetrics/vmestimator/releases/tag/v0.1.17)

## v0.2.0

**Release date:** 02 Oct 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.16](https://img.shields.io/badge/v0.1.16-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0116)

**Update note 1**: resource labels were aligned with the VictoriaMetrics operator convention: `app.kubernetes.io/name: vmestimator-<component>`, `app.kubernetes.io/instance: <release>` and `app.kubernetes.io/component: monitoring`. Workload selectors are immutable, so delete the workloads together with their pods before upgrading: `kubectl delete deployment vmestimator-single-<release> -n <namespace>` in `single` mode, or `kubectl delete deployment vmestimator-select-<release> -n <namespace>` and `kubectl delete statefulset vmestimator-storage-<release> -n <namespace>` in `cluster` mode (use the actual workload names if `fullnameOverride` is set).

- update common dependency 0.4.3
- render a NetworkPolicy per component (`vmestimator-<component>-<release>`) with the same selector as the component workload, instead of a single `vmestimator-<release>` policy.

## v0.1.0

**Release date:** 30 Sep 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.1.16](https://img.shields.io/badge/v0.1.16-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fvmestimator%2Fchangelog%2F%23v0116)

- add the `victoria-metrics-estimator` chart with single-node and clustered deployment modes
- add `dnsConfig` option to set a custom DNS config for the pod. See [#3174](https://github.com/VictoriaMetrics/helm-charts/issues/3174)
