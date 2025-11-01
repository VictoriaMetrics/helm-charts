## Next release

- patch all expression `on` and `by` modifiers. See [#2524](https://github.com/VictoriaMetrics/helm-charts/issues/2524).
- updates operator to [v0.65.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.65.0) version.

## 0.62.2

**Release date:** 30 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- updates operator to [v0.64.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.64.1) version.
- bump grafana dependency chart to version 10.1.4

## 0.62.1

**Release date:** 29 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- allow setting `.Values.victoria-metrics-operator.operator.useCustomConfigReloader` to `false`. This is required to continue using 3rd party config reloaders, which were [deprecated in operator](https://docs.victoriametrics.com/operator/changelog/#v0640).

## 0.62.0

**Release date:** 29 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- operator: use VM config reloader by default
- prometheus-node-exporter: 4.48.0 -> 4.49.1

## 0.61.13

**Release date:** 29 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- Fixed etcd rules rendering

## 0.61.12

**Release date:** 29 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- add cluster to query arguments list of default rule's `dashboard` annotation value.
- updates operator to [v0.64.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.64.0) version.

## 0.61.11

**Release date:** 27 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- synced rules and dashboards with a fix for [#2493](https://github.com/VictoriaMetrics/helm-charts/issues/2493) and with outdated scheduler metrics removed.

## 0.61.10

**Release date:** 21 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11280)

- bump version of VM components to [v1.128.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.128.0)

## 0.61.9

**Release date:** 20 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- support HTTPRoute for chart components, where ingress is available. See [#2492](https://github.com/VictoriaMetrics/helm-charts/issues/2492).

## 0.61.8

**Release date:** 17 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- updated dashboards. See [#2487](https://github.com/VictoriaMetrics/helm-charts/issues/2487).

## 0.61.7

**Release date:** 16 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- bump grafana dependency chart to version 10.1.0
- bump operator dependency chart to version 0.54.0
- move common namespace configuration for extra scrapes to `.Values.defaultScrapeService.namespace`

## 0.61.6

**Release date:** 10 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- compact expression for all rules

## 0.61.5

**Release date:** 10 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- updated ETA panels in VictoriaMetrics dashboards. See [#2474](https://github.com/VictoriaMetrics/helm-charts/issues/2474).

## 0.61.4

**Release date:** 10 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- fixed conditions conditions generations for rules and dashboards. See [#2472](https://github.com/VictoriaMetrics/helm-charts/issues/2472).

## 0.61.3

**Release date:** 09 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- fixed `cluster` variable for dashboards, when `.Values.grafana.sidecar.dashboards.multicluster: false`. See [#2468](https://github.com/VictoriaMetrics/helm-charts/issues/2468).

## 0.61.2

**Release date:** 09 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- fixed metricsql expressions filter update in a hack tool.

## 0.61.1

**Release date:** 09 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- Added vmalert rules. See [#2465](https://github.com/VictoriaMetrics/helm-charts/issues/2465).

## 0.61.0

**Release date:** 08 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%23v11270)

- bump KSM chart version 6.0.* -> 6.3.*
- bump node-exporter chart version 4.47.* -> 4.48.*
- bump grafana chart version 9.2.* -> 9.4.*
- upgrade dashboards
- allow optional scheme at `.Values.external.grafana.host`. Thanks to @a-bali for [initial implementation](https://github.com/VictoriaMetrics/helm-charts/pull/2439).
- allow overriding service labels for `kubedns`, `coredns`, `kube-controller-manager`, `kube-proxy`, `kube-scheduler`, `etcd`.
- bump version of VM components to [v1.127.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.127.0)
- replaced python scripts for dashboards and rules templates generation with golang tool, that uses metricsql library instead of regexp to properly update all expressions with additional labels and produces more compact output.

## 0.60.1

**Release date:** 15 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.126.0](https://img.shields.io/badge/v1.126.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11260)

- bump version of VM components to [v1.126.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.126.0)

## 0.60.0

**Release date:** 12 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.1](https://img.shields.io/badge/v1.125.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11251)

**Update note 1**: This release contains new CRDs VTCluster and VTSingle. It requires to perform CRD versions update.

- updates operator to [v0.63.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.63.0) version.

## 0.59.5

**Release date:** 03 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.1](https://img.shields.io/badge/v1.125.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11251)

- bump version of VM components to [v1.125.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.125.1)

## 0.59.4

**Release date:** 01 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.0](https://img.shields.io/badge/v1.125.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11250)

- bump version of VM components to [v1.125.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.125.0)

## 0.59.3

**Release date:** 21 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.124.0](https://img.shields.io/badge/v1.124.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11240)

- updated rules. See [#2350](https://github.com/VictoriaMetrics/helm-charts/issues/2350).

## 0.59.2

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.124.0](https://img.shields.io/badge/v1.124.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11240)

- bump version of VM components to [v1.124.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.124.0)

## 0.59.1

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.123.0](https://img.shields.io/badge/v1.123.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11230)

- updates operator to [v0.62.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.62.0) version. See issue [#2357](https://github.com/VictoriaMetrics/helm-charts/issues/2357).

## 0.59.0

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.123.0](https://img.shields.io/badge/v1.123.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11230)

- vmcluster: set chart's app version to spec.clusterVersion instead of setting tag for each component. See [#2348](https://github.com/VictoriaMetrics/helm-charts/issues/2348).
- fixed bug, when explicitly defined tag for vminsert appears in vmagent spec. See [#2349](https://github.com/VictoriaMetrics/helm-charts/issues/2349).
- updated dashboards and rules
- use `.Values.prometheus-node-exporter.service.labels.jobLabel` as a value for `job` label in node exporter rules. See [#2340](https://github.com/VictoriaMetrics/helm-charts/pull/2340).
- updates operator to [v0.62.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.62.0) version

## 0.58.3

**Release date:** 05 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.123.0](https://img.shields.io/badge/v1.123.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11230)

**Update note 1**: In this release default VMSingle port was changed from 8429 to 8428. To prevent unwanted VMSingle restart please set it to old value using `.Values.vmsingle.spec.port: 8429`.

- Changed default VMSingle port 8429 -> 8428. Related issue [#1345](https://github.com/VictoriaMetrics/operator/issues/1345).

## 0.58.2

**Release date:** 23 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.122.0](https://img.shields.io/badge/v1.122.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11220)

- updates operator to [v0.61.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.2) version

## 0.58.1

**Release date:** 21 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.122.0](https://img.shields.io/badge/v1.122.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11220)

- Replaced error with warning for a cased described in [#2285](https://github.com/VictoriaMetrics/helm-charts/issues/2285).

## 0.58.0

**Release date:** 21 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.122.0](https://img.shields.io/badge/v1.122.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11220)

- bump version of VM components to [v1.122.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/victoriametrics/changelog/CHANGELOG.md#v11220)

## 0.57.1

**Release date:** 21 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.121.0](https://img.shields.io/badge/v1.121.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11210)

- updates operator to [v0.61.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.1) version

## 0.57.0

**Release date:** 16 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.121.0](https://img.shields.io/badge/v1.121.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11210)

**Update note 1**: This release contains new CRD VLAgent. It requires to perform CRD versions update.

- updates operator to [v0.61.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.0) version

## 0.56.0

**Release date:** 07 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.121.0](https://img.shields.io/badge/v1.121.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11210)

- force storage nodes count be more than 2 * replicationFactor - 1. See [#2285](https://github.com/VictoriaMetrics/helm-charts/issues/2285).
- bump version of VM components to [v1.121.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/victoriametrics/changelog/CHANGELOG.md#v11210)

## 0.55.2

**Release date:** 27 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

- updates operator to [v0.60.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.2) version

## 0.55.1

**Release date:** 27 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

- Allow overriding default labels for managed in chart operator CRs using `.Values.<resource>.labels` property. Related issue [#2255](https://github.com/VictoriaMetrics/helm-charts/issues/2255)

## 0.55.0

**Release date:** 26 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

- Synced rules and dashboards
- upgrade dependency KSM chart 5.31.2 -> 6.0.0
- upgrade dependency node-exporter chart 4.45.3 -> 4.47.0
- updates operator to [v0.60.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.1) version

## 0.54.0

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

**Update note 1**: This release contains new CRD VMAnomaly. It requires to perform CRD versions update.
**Update note 2**: This release contains changes to validation webhooks and it requires operator version v0.60.0 or above

- updates operator to [v0.60.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.0) version

## 0.53.0

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

- bump version of VM components to [v1.120.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.120.0)

## 0.52.0

**Release date:** 12 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.119.0](https://img.shields.io/badge/v1.119.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11190)

**Update note**: This release contains changes to validation webhooks and it requires operator version v0.59.2 or above

- Merge default image params for VMAuth with custom ones. See issue [#2236](https://github.com/VictoriaMetrics/helm-charts/issues/2236).
- updates operator to [v0.59.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.59.2) version

## 0.51.0

**Release date:** 10 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.119.0](https://img.shields.io/badge/v1.119.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11190)

- bump version of VM components to [v1.119.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.119.0)

## 0.50.1

**Release date:** 02 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.118.0](https://img.shields.io/badge/v1.118.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11180)

- Fix incorrect configuration of `image.tag` for `VMAgent` component.

## 0.50.0

**Release date:** 30 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.118.0](https://img.shields.io/badge/v1.118.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11180)

**Update note 1**: This release contains new CRDs VLCluster and VLSingle. It requires to perform CRD versions update.
Please follow this doc https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/
**Update note 2**: This release contains changes to validation webhooks and it requires operator version v0.59.2 or above

- Support scrape and probe CRs validation webhooks
- updates operator to [v0.59.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.59.0) version

- Updated rules and dashboards
- Allow overriding default vmagent remoteWrite options
- upgrade dependency Grafana chart 8.11.x -> 9.2.x, Grafana v11.y.z -> v12.y.z

## 0.49.0

**Release date:** 26 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.118.0](https://img.shields.io/badge/v1.118.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11180)

- Updated dashboards and rules
- bump version of VM components to [v1.118.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.118.0)

## 0.48.1

**Release date:** 16 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.117.1](https://img.shields.io/badge/v1.117.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11171)

- bump version of VM components to [v1.117.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.117.1)
- consider datasource as built-in if it has no `version` set. See [#2185](https://github.com/VictoriaMetrics/helm-charts/issues/2185).

## 0.47.1

**Release date:** 13 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.117.0](https://img.shields.io/badge/v1.117.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11170)

- add plugin version while using GrafanaDatasource CRD

## 0.47.0

**Release date:** 12 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.117.0](https://img.shields.io/badge/v1.117.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11170)

- bump version of VM components to [v1.117.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.117.0)

## 0.46.0

**Release date:** 09 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.116.0](https://img.shields.io/badge/v1.116.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11160)

- bump version of VM components to [v1.123.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/victoriametrics/changelog/CHANGELOG.md#v11230)

## 0.45.1

**Release date:** 09 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.116.0](https://img.shields.io/badge/v1.116.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11160)

- Add plugins section to GrafanaDatasource CR. See [issue #2168](https://github.com/VictoriaMetrics/helm-charts/issues/2168) for details.
- updates operator to [v0.56.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.56.0) version

## 0.45.0

**Release date:** 29 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.116.0](https://img.shields.io/badge/v1.116.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11160)

- bump version of VM components to [v1.116.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.116.0)

## 0.44.0

**Release date:** 22 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- Synced dashboards and rules
- Support wildcard in ingress hostname. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2134).
- Do not replace VMCluster URL with VMAuth one, when it's enabled, for VMAlert, Grafana datasources and VMAgent write endpoint. Consider using [`vmcluster.requestsLoadBalancer`](https://docs.victoriametrics.com/operator/resources/vmcluster/#requests-load-balancing) for balancing read and write requests to VMCluster. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2136).

## 0.43.0

**Release date:** 17 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- use `.Values.vmcluster.spec.clusterVersion` for `app.kubernetes.io/version` label value. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2120).
- fix VMSingle image tag, when custom VMAlert image tag set.
- upgrade Grafana chart 8.9.x -> 8.11.x
- updates operator to [v0.56.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.56.0) version

## 0.42.0

**Release date:** 07 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- bump version of VM components to [v1.115.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.115.0)

## 0.41.4

**Release date:** 07 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- Set default image tag requestsLoadBalancer

## 0.41.3

**Release date:** 04 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- Do not override alertmanager templates defined in `.Values.alertmanager.spec.templates`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2101).

## 0.41.2

**Release date:** 03 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- proxy requests from VMAgent to VMInsert through VMAuth, when it's enabled. Related [issue](https://github.com/VictoriaMetrics/helm-charts/issues/2024).

## 0.41.1

**Release date:** 03 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- override external grafana datasource name. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2092).
- sync rules and dashboards

## 0.41.0

**Release date:** 02 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- updates operator to [v0.55.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.55.0) version

## 0.40.0

**Release date:** 02 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- bump kube-state-metrics chart 5.29.x -> 5.31.x

## 0.39.4

**Release date:** 26 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- bump version of VM components to [v1.114.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.114.0)

## 0.39.3

**Release date:** 25 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- fixed `vm.write.endpoint` template. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2083).

## 0.39.2

**Release date:** 24 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- add external.alert.source and external.url vmalert args when either built-in grafana is enabled or `.Values.external.grafana.host` is set. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1994).

## 0.39.1

**Release date:** 24 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- update dashboards and rules
- update common dependency 0.0.39 -> 0.0.42
- set default vmalertmanager image to 0.28.1
- fix additional notifier config rendering. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2075).
- add default external.alert.source. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1994).
- add .Values.vmcluster.spec.vmselect.enabled and .Values.vmcluster.spec.vminsert.enabled flags to disable vmselect or vminsert. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2059).

## 0.39.0

**Release date:** 13 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

**Update note**: This release contains breaking change. Chart no longer includes `prometheus-operator-crds` subchart. Consider installing this chart independently.

- Removed `prometheus-operator-crds`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2042).
- updates operator to [v0.54.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.54.1) version
- bump version of VM components to [v1.113.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.113.0)

## 0.38.3

**Release date:** 03 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- fix image tags for VMCluster components. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2034).

## 0.38.2

**Release date:** 03 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- added `.Values.vmauth.unauthorizedUserAccessSpec.disabled` flag to generate VMAuth without unauthorized user section. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1981).

## 0.38.1

**Release date:** 03 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- Upgraded dashboard and rules
- Use enterprise images for VM components if license is set. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2023).
- updated common dependency 0.0.39 -> 0.0.41


## 0.38.0

**Release date:** 24 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- add `.Values.defaultRules.additionalGroupByLabels`, which are added to all by expression labels list. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2000).
- bump version of VM components to [v1.112.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.112.0)

## 0.36.2

**Release date:** 17 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.111.0](https://img.shields.io/badge/v1.111.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11110)

- set default VMAlertManager `spec.disableNamespaceMatcher: true` when `alertmanager.userManagedConfig: true`. See [this issue](https://github.com/VictoriaMetrics/VictoriaMetrics/issues/8285).
- grafana chart 8.9.0 -> 8.9.1

## 0.36.1

**Release date:** 10 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.111.0](https://img.shields.io/badge/v1.111.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11110)

- bump version of VM components to [v1.111.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.111.0)

## 0.36.0

**Release date:** 07 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- updates operator to [v0.53.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.53.0) version

## 0.35.7

**Release date:** 06 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- Added .Values.alertmanager.useManagedConfig to switch storing Alertmanager config in VMAlertmanagerConfig CR instead of k8s Secret. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1968).
- updated common dependency 0.0.37 -> 0.0.39

## 0.35.6

**Release date:** 05 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- Use GrafanaDatasource name sanitizing to fix plugin import

## 0.35.5

**Release date:** 04 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- added `access` property to all default datasources

## 0.35.4

**Release date:** 04 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- add `.Values.defaultDatasources.grafanaOperator` section to manage datasources using Grafana operator. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1964) for details.
- grafana chart 8.6.x -> 8.9.x
- prometheus CRDs chart 16.x -> 17.x
- kube-state-metrics chart 5.27.x -> 5.29.x
- prometheus-node-exporter chart 4.42.x -> 4.43.x

## 0.35.3

**Release date:** 04 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- Use .Values.global.clusterLabel in rules annotations instead of `.cluster`

## 0.35.2

**Release date:** 31 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- Grafana datasource: do not verify allow_loading_unsigned_plugins in k8s-stack
- Fixed configmap rendering for vmalert.templateFiles

## 0.35.1

**Release date:** 30 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- add `defaultDashboards.annotations` to `GrafanaDashboard`s resources.

## 0.35.0

**Release date:** 27 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

**Update note**: This release contains breaking change. `.Values.externalVM` was renamed to `.Values.external.vm`

- add `.Values.external.grafana.host` to configure grafana host for alerts, when `.Values.grafana.enabled: false`
- rename `.Values.externalVM` to `.Values.external.vm` for consistency
- bump version of VM components to [v1.110.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.110.0)

## 0.34.0

**Release date:** 22 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.109.1](https://img.shields.io/badge/v1.109.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11091)

- updates operator to [v0.52.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.52.0) version

## 0.33.5

**Release date:** 17 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.109.1](https://img.shields.io/badge/v1.109.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11091)

- bump version of VM components to [v1.109.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.109.1)

## 0.33.4

**Release date:** 14 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.109.0](https://img.shields.io/badge/v1.109.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11090)

- bump version of VM components to [v1.109.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.109.0)

## 0.33.3

**Release date:** 13 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- updates operator to [v0.51.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.3) version

## 0.33.2

**Release date:** 06 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- updated common dependency 0.0.36 -> 0.0.37
- support templating in `.Values.extraObjects`

## 0.33.1

**Release date:** 24 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- updated common dependency 0.0.35 -> 0.0.36
- updates operator to [v0.51.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.2) version

## 0.33.0

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- Replaced deprecated `.Values.vmauth.spec.unauthorizedAccessConfig` with `.Values.vmauth.spec.unauthorizedUserAccessSpec`
- Replaced deprecated `.Values.vmauth.spec.discover_backend_ips` with `.Values.vmauth.spec.unauthorizedUserAccessSpec.discover_backend_ips`
- Exclude markdown files from package

## 0.32.0

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- updates operator to [v0.51.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.1) version

## 0.31.4

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- bump version of VM components to [v1.108.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.108.1)

## 0.31.3

**Release date:** 2024-12-18

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.0](https://img.shields.io/badge/v1.108.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11080)

- added default value for `.Values.grafana.sidecar.datasources.label` for case when `grafana.enabled: false` but datasource provision is still enabled. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1875).

## 0.31.2

**Release date:** 2024-12-17

![AppVersion: v1.108.0](https://img.shields.io/badge/v1.108.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11080)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.34 -> 0.0.35

## 0.31.1

**Release date:** 2024-12-17

![AppVersion: v1.108.0](https://img.shields.io/badge/v1.108.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11080)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added explicit defaultRules toggles

## 0.31.0

**Release date:** 2024-12-16

![AppVersion: v1.108.0](https://img.shields.io/badge/v1.108.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11080)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added ability to override namespace for scrape config endpoints. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1859).
- Synced dashboards and rules
- Kube state metrics chart: 5.26.0 -> 5.27.0
- Prometheus node exporter chart: 4.41.0 -> 4.42.0
- Grafana chart: 8.5.12 -> 8.6.4
- Prometheus operator chart: 15.0.0 -> 16.0.1
- bump version of VM components to [v1.108.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.108.0)

## 0.30.3

**Release date:** 2024-12-05

![AppVersion: v1.107.0](https://img.shields.io/badge/v1.107.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11070)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Set higher priority for `defaultDashboards.dashboards.<name>.enabled` flag comparing to default dashboard conditions to allow install or ignore dashboards regardless of whether component it's for is installed or monitored. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1851).

## 0.30.2

**Release date:** 2024-12-03

![AppVersion: v1.107.0](https://img.shields.io/badge/v1.107.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11070)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- synced rules

## 0.30.1

**Release date:** 2024-12-03

![AppVersion: v1.107.0](https://img.shields.io/badge/v1.107.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11070)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fail template if both vmcluster and vmsingle are enabled
- synced rules and dashboards

## 0.30.0

**Release date:** 2024-12-02

![AppVersion: v1.107.0](https://img.shields.io/badge/v1.107.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11070)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- synced rules and dashboards
- updated common dependency 0.0.32 -> 0.0.33
- bump version of VM components to [v1.107.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.107.0)

## 0.29.1

**Release date:** 2024-11-25

![AppVersion: v1.106.1](https://img.shields.io/badge/v1.106.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11061)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.31 -> 0.0.32
- updated operator dependency 0.39.0 -> 0.39.1
- fixed alertmanager config name. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1805)

## 0.29.0

**Release date:** 2024-11-25

![AppVersion: v1.106.1](https://img.shields.io/badge/v1.106.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11061)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: This release contains breaking changes. please follow [upgrade guide](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/#upgrade-to-0290)

- fixed ability to override CR names using `<component>.name`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1778)
- updated common dependency 0.0.28 -> 0.0.29
- bump operator chart version to 0.38.0
- replaced all `<component>.vmauth` params to `vmauth.spec` to provide more flexibility in vmauth configuration. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1793)
- synced dashboards
- updates operator to [v0.50.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.49.0) version

## 0.28.4

**Release date:** 2024-11-18

![AppVersion: v1.106.1](https://img.shields.io/badge/v1.106.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11061)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.21 -> 0.0.28
- bump version of VM components to [v1.106.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.106.1)

## 0.28.3

**Release date:** 2024-11-08

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated dashboards
- set default DNS domain to `cluster.local.`
- fixed disabling recording rules in `.Values.defaultRules`
- updated common dependency 0.0.19 -> 0.0.21
- fixed cluster variable in etcd dashboard

## 0.28.2

**Release date:** 2024-11-06

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Updated dashboards
- Fixed vmauth spec context

## 0.28.1

**Release date:** 2024-11-05

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fix templating of labels for `VMAlertmanager` CRD.

## 0.28.0

**Release date:** 2024-11-05

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Update vm-operator to v0.49.0 release

## 0.27.7

**Release date:** 2024-11-05

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added alertmanager datasource. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1592)
- Renamed `grafana.sidecar.dashboards.additionalDashboardLabels` to `defaultDashboards.labels`
- Renamed `grafana.sidecar.dashboards.additionalDashboardAnnotations` to `defaultDashboards.annotations`
- Renamed `grafana.sidecar.datasources.default` to `defaultDatasources.victoriametrics.datasources`
- Renamed `grafana.additionalDataSources` to `defaultDatasources.extra`
- Renamed `grafana.defaultDashboardsTimezone` to `defaultDashboards.defaultTimezone`
- Removed `grafana.defaultDatasourceType` and default datasource type is picked from `defaultDatasources.victoriametrics.datasources[*].isDefault: true`
- Removed crds subchart as it's now included in operator
- Fixed additionalNotifiersConfig
- Added `vmcluster.vmauth.<vminsert/vmselect>` and `externalVM.vmauth.<read/write>` to provide ability to override vmauth configs
- Removed unused serviceaccount
- bump version of VM components to [v1.106.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.106.0)

## 0.27.6

**Release date:** 2024-10-21

![AppVersion: v1.105.0](https://img.shields.io/badge/v1.105.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11050)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Add an explicit fail in case both Grafana dashboard via sidecar and `grafana.dashboards` are enabled. Previously, this configuration would be accepted and sidecar configuration would silently override `.grafana.dashboards` configuration. See [these docs](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/#adding-external-dashboards) for information about adding external dashboards.
- bump version of VM components to [v1.105.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.105.0)

## 0.27.5

**Release date:** 2024-10-15

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fixed templates context issues
- Added ability to disable alertmanager rules if alertmanager.enabled: false
- Updated vm-operator to v0.48.4 release

## 0.27.4

**Release date:** 2024-10-12

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fixed default image tags template. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1587)

## 0.27.3

**Release date:** 2024-10-11

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Grafana chart: 8.4.9 -> 8.5.2
- Prometheus operator chart: 11.0 -> 15.0
- Human-readable error about Helm version requirement
- Updated rules template context structure

## 0.27.2

**Release date:** 2024-10-10

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fixed dashboards variable queries

## 0.27.1

**Release date:** 2024-10-10

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Generate VM components tag version from chart app name by default
- Added k8s apiserver, kube-proxy, controller-manager and kubelet dashboards
- Moved `dashboards.<dashboard>` to `defaultDashboards.dashboards.<dashboard>.enabled`
- Moved `defaultDashboardsEnabled` to `defaultDashboards.enabled`
- Moved `grafanaOperatorDashboardsFormat` to `defaultDashboards.grafanaOperator`
- Added condition for `grafana-overview`, `alertmanager-overview` and `vmbackupmanager` dashboards. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1564)
- Removed `experimentalDashboardsEnabled` param
- Upgraded default Alertmanager tag 0.25.0 -> 0.27.0
- Upgraded operator chart 0.35.2 -> 0.35.3

## 0.27.0

**Release date:** 2024-10-02

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.104.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.104.0)

## 0.26.0

**Release date:** 2024-09-29

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.48.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.48.3)

## 0.25.17

**Release date:** 2024-09-20

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added VMAuth to k8s stack. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/829)
- Fixed ETCD dashboard
- Use path prefix from args as a default path prefix for ingress. Related [issue](https://github.com/VictoriaMetrics/helm-charts/issues/1260)
- Allow using vmalert without notifiers configuration. Note that it is required to use `.vmalert.spec.extraArgs["notifiers.blackhole"]: true` in order to start vmalert with a blackhole configuration.

## 0.25.16

**Release date:** 2024-09-10

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Do not truncate servicemonitor, datasources, rules, dashboard, alertmanager & vmalert templates names
- Use service label for node-exporter instead of podLabel. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1458)
- Added common chart to a k8s-stack. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1456)
- Fixed value of custom alertmanager configSecret. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1461)

## 0.25.15

**Release date:** 2024-09-05

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Drop empty endpoints param from scrape configuration
- Fixed proto when TLS is enabled. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1449)

## 0.25.14

**Release date:** 2024-09-04

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed alertmanager templates

## 0.25.13

**Release date:** 2024-09-04

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Use operator's own service monitor

## 0.25.12

**Release date:** 2024-09-03

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fixed dashboards rendering. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1414)
- Fixed service monitor label name.

## 0.25.11

**Release date:** 2024-09-03

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Merged ingress templates
- Removed custom VMServiceScrape for operator
- Added ability to override default Prometheus-compatible datatasources with all available parameters. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/860).
- Do not use `grafana.dashboards` and `grafana.dashboardProviders`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1312).
- Migrated Node Exporter dashboard into chart
- Deprecated `grafana.sidecar.jsonData`, `grafana.provisionDefaultDatasource` in a favour of `grafana.sidecar.datasources.default` slice of datasources.
- Fail if no notifiers are set, do not set `notifiers` to null if empty

## 0.25.10

**Release date:** 2024-08-31

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed ingress extraPaths and externalVM urls rendering

## 0.25.9

**Release date:** 2024-08-31

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed vmalert ingress name typo
- Added ability to override default Prometheus-compatible datatasources with all available parameters. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/860).
- Do not use `grafana.dashboards` and `grafana.dashboardProviders`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1312).

## 0.25.8

**Release date:** 2024-08-30

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed external notifiers rendering, when alertmanager is disabled. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1378)

## 0.25.7

**Release date:** 2024-08-30

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed extra rules template context

## 0.25.6

**Release date:** 2024-08-29

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: Update `kubeProxy.spec` to `kubeProxy.vmScrape.spec`

**Update note**: Update `kubeScheduler.spec` to `kubeScheduler.vmScrape.spec`

**Update note**: Update `kubeEtcd.spec` to `kubeEtcd.vmScrape.spec`

**Update note**: Update `coreDns.spec` to `coreDns.vmScrape.spec`

**Update note**: Update `kubeDns.spec` to `kubeDns.vmScrape.spec`

**Update note**: Update `kubeProxy.spec` to `kubeProxy.vmScrape.spec`

**Update note**: Update `kubeControllerManager.spec` to `kubeControllerManager.vmScrape.spec`

**Update note**: Update `kubeApiServer.spec` to `kubeApiServer.vmScrape.spec`

**Update note**: Update `kubelet.spec` to `kubelet.vmScrape.spec`

**Update note**: Update `kube-state-metrics.spec` to `kube-state-metrics.vmScrape.spec`

**Update note**: Update `prometheus-node-exporter.spec` to `prometheus-node-exporter.vmScrape.spec`

**Update note**: Update `grafana.spec` to `grafana.vmScrape.spec`

- bump version of VM components to [v1.103.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.103.0)
- Added `dashboards.<dashboardName>` bool flag to enable dashboard even if component it is for is not installed.
- Allow extra `vmalert.notifiers` without dropping default notifier if `alertmanager.enabled: true`
- Do not drop default notifier, when vmalert.additionalNotifierConfigs is set
- Replaced static url proto with a template, which selects proto depending on a present tls configuration
- Moved kubernetes components monitoring config from `spec` config to `vmScrape.spec`
- Merged servicemonitor templates

## 0.25.5

**Release date:** 2024-08-26

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- TODO

## 0.25.4

**Release date:** 2024-08-26

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.47.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.47.2)
- kube-state-metrics - 5.16.4 -> 5.25.1
- prometheus-node-exporter - 4.27.0 -> 4.29.0
- grafana - 8.3.8 -> 8.4.7
- added configurable `.Values.global.clusterLabel` to all alerting and recording rules `by` and `on` expressions

## 0.25.3

**Release date:** 2024-08-23

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated operator to v0.47.1 release
- Build `app.kubernetes.io/instance` label consistently. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1282)

## 0.25.2

**Release date:** 2024-08-21

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixed vmalert ingress name. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1271)
- fixed alertmanager ingress host template rendering. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1270)

## 0.25.1

**Release date:** 2024-08-21

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added `.Values.global.license` configuration
- Fixed extraLabels rendering. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1248)
- Fixed vmalert url to alertmanager by including its path prefix
- Removed `networking.k8s.io/v1beta1/Ingress` and `extensions/v1beta1/Ingress` support
- Fixed kubedns servicemonitor template. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1255)

## 0.25.0

**Release date:** 2024-08-16

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: it requires to update CRD dependency manually before upgrade

**Update note**: requires Helm 3.14+

- Moved dashboards templating logic out of sync script to Helm template
- Allow to disable default grafana datasource
- Synchronize Etcd dashboards and rules with mixin provided by Etcd
- Add alerting rules for VictoriaMetrics operator.
- Updated alerting rules for VictoriaMetrics components.
- Fixed exact rule annotations propagation to other rules.
- Set minimal kubernetes version to 1.25
- updates operator to v0.47.0 version

## 0.24.5

**Release date:** 2024-08-01

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.102.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.102.1)

## 0.24.4

**Release date:** 2024-08-01

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Update dependencies: grafana -> 8.3.6.
- Added `.Values.defaultRules.alerting` and `.Values.defaultRules.recording` to setup common properties for all alerting an recording rules

## 0.24.3

**Release date:** 2024-07-23

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.102.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.102.0)

## 0.24.2

**Release date:** 2024-07-15

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix vmalertmanager configuration when using `.VMAlertmanagerSpec.ConfigRawYaml`. See [this pull request](https://github.com/VictoriaMetrics/helm-charts/pull/1136).

## 0.24.1

**Release date:** 2024-07-10

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to v0.46.4

## 0.24.0

**Release date:** 2024-07-10

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- added ability to override alerting rules labels and annotations:
- globally - `.Values.defaultRules.rule.spec.labels` (before it was `.Values.defaultRules.additionalRuleLabels`) and `.Values.defaultRules.rule.spec.annotations`
- for all rules in a group  - `.Values.defaultRules.groups.<groupName>.rules.spec.labels` and `.Values.defaultRules.groups.<groupName>.rules.spec.annotations`
- for each rule individually - `.Values.defaultRules.rules.<ruleName>.spec.labels` and `.Values.defaultRules.rules.<ruleName>.spec.annotations`
- changed `.Values.defaultRules.rules.<groupName>` to `.Values.defaultRules.groups.<groupName>.create`
- changed `.Values.defaultRules.appNamespacesTarget` to `.Values.defaultRules.groups.<groupName>.targetNamespace`
- changed `.Values.defaultRules.params` to `.Values.defaultRules.group.spec.params` with ability to override it at `.Values.defaultRules.groups.<groupName>.spec.params`

## 0.23.6

**Release date:** 2024-07-08

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- added ability to override alerting rules labels and annotations:
- globally - `.Values.defaultRules.rule.spec.labels` (before it was `.Values.defaultRules.additionalRuleLabels`) and `.Values.defaultRules.rule.spec.annotations`
- for all rules in a group  - `.Values.defaultRules.groups.<groupName>.rules.spec.labels` and `.Values.defaultRules.groups.<groupName>.rules.spec.annotations`
- for each rule individually - `.Values.defaultRules.rules.<ruleName>.spec.labels` and `.Values.defaultRules.rules.<ruleName>.spec.annotations`
- changed `.Values.defaultRules.rules.<groupName>` to `.Values.defaultRules.groups.<groupName>.create`
- changed `.Values.defaultRules.appNamespacesTarget` to `.Values.defaultRules.groups.<groupName>.targetNamespace`
- changed `.Values.defaultRules.params` to `.Values.defaultRules.group.spec.params` with ability to override it at `.Values.defaultRules.groups.<groupName>.spec.params`

## 0.23.5

**Release date:** 2024-07-04

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Support configuring vmalert `-notifier.config` with `.Values.vmalert.additionalNotifierConfigs`.

## 0.23.4

**Release date:** 2024-07-02

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add `extraObjects` to allow deploying additional resources with the chart release.

## 0.23.3

**Release date:** 2024-06-26

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Enable [conversion of Prometheus CRDs](https://docs.victoriametrics.com/operator/integrations/prometheus/#objects-conversion) by default. See [this](https://github.com/VictoriaMetrics/helm-charts/pull/1069) pull request for details.
- use bitnami/kubectl image for cleanup instead of deprecated gcr.io/google_containers/hyperkube

## 0.23.2

**Release date:** 2024-06-14

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Do not add `cluster` external label at VMAgent by default. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/774) for the details.

## 0.23.1

**Release date:** 2024-06-10

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to v0.45.0 release
- sync latest vm alerts and dashboards.

## 0.23.0

**Release date:** 2024-05-30

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- sync latest etcd v3.5.x rules from [upstream](https://github.com/etcd-io/etcd/blob/release-3.5/contrib/mixin/mixin.libsonnet).
- add Prometheus operator CRDs as an optional dependency. See [this PR](https://github.com/VictoriaMetrics/helm-charts/pull/1022) and [related issue](https://github.com/VictoriaMetrics/helm-charts/issues/341) for the details.

## 0.22.1

**Release date:** 2024-05-14

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix missing serviceaccounts patch permission in VM operator, see [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1012) for details.

## 0.22.0

**Release date:** 2024-05-10

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.44.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.44.0)

## 0.21.3

**Release date:** 2024-04-26

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.101.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.101.0)

## 0.21.2

**Release date:** 2024-04-23

![AppVersion: v1.100.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.100.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.43.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.43.3)

## 0.21.1

**Release date:** 2024-04-18

![AppVersion: v1.100.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.100.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

## 0.21.0

**Release date:** 2024-04-18

![AppVersion: v1.100.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.100.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- TODO

- bump version of VM operator to [0.43.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.43.0)
- updates CRDs definitions.

## 0.20.1

**Release date:** 2024-04-16

![AppVersion: v1.100.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.100.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- upgraded dashboards and alerting rules, added values file for local (Minikube) setup
- bump version of VM components to [v1.100.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.100.1)

## 0.20.0

**Release date:** 2024-04-02

![AppVersion: v1.99.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.99.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.42.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.42.3)

## 0.19.4

**Release date:** 2024-03-05

![AppVersion: v1.99.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.99.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.99.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.99.0)

## 0.19.3

**Release date:** 2024-03-05

![AppVersion: v1.98.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.98.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Commented default configuration for alertmanager. It simplifies configuration and makes it more explicit. See this [issue](https://github.com/VictoriaMetrics/helm-charts/issues/473) for details.
- Allow enabling/disabling default k8s rules when installing. See [#904](https://github.com/VictoriaMetrics/helm-charts/pull/904) by @passie.

## 0.19.2

**Release date:** 2024-02-26

![AppVersion: v1.98.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.98.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix templating of VMAgent `remoteWrite` in case both `VMSingle` and `VMCluster` are disabled. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/865) for details.

## 0.19.1

**Release date:** 2024-02-21

![AppVersion: v1.98.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.98.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update dependencies: victoria-metrics-operator -> 0.28.1, grafana -> 7.3.1.
- Update victoriametrics CRD resources yaml.

## 0.19.0

**Release date:** 2024-02-09

![AppVersion: v1.97.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.97.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Do not store original labels in `vmagent`'s memory by default. This reduces memory usage of `vmagent` but makes `vmagent`'s debugging UI less informative. See [this docs](https://docs.victoriametrics.com/victoriametrics/vmagent/#relabel-debug) for details on relabeling debug.
- Update dependencies: kube-state-metrics -> 5.16.0, prometheus-node-exporter -> 4.27.0, grafana -> 7.3.0.
- Update victoriametrics CRD resources yaml.
- Update builtin dashboards and rules.

## 0.18.12

**Release date:** 2024-02-01

![AppVersion: v1.97.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.97.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.97.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.97.1)
- Fix helm lint when ingress resources enabled - split templates of resources per kind. See [#820](https://github.com/VictoriaMetrics/helm-charts/pull/820) by @MemberIT.

## 0.18.11

**Release date:** 2023-12-15

![AppVersion: v1.96.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.96.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix missing `.Values.defaultRules.rules.vmcluster` value. See [#801](https://github.com/VictoriaMetrics/helm-charts/pull/801) by @MemberIT.

## 0.18.10

**Release date:** 2023-12-12

![AppVersion: v1.96.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.96.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.96.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.96.0)
- Add optional allowCrossNamespaceImport to GrafanaDashboard(s) (#788)

## 0.18.9

**Release date:** 2023-12-08

![AppVersion: v1.95.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.95.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Properly use variable from values file for Grafana datasource type. (#769)
- Update dashboards from upstream sources. (#780)

## 0.18.8

**Release date:** 2023-11-16

![AppVersion: v1.95.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.95.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.95.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.95.1)

## 0.18.7

**Release date:** 2023-11-15

![AppVersion: v1.95.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.95.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.95.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.95.0)
- Support adding extra group parameters for default vmrules. (#752)

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

- Update VictoriaMetrics components from v1.93.0 to v1.93.1

## 0.17.4

**Release date:** 2023-08-12

![AppVersion: v1.93.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.92.1 to v1.93.0
- delete an obsolete parameter remaining by mistake (see <https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/#upgrade-to-0130>) (#602)

## 0.17.3

**Release date:** 2023-07-28

![AppVersion: v1.92.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.92.0 to v1.92.1 (#599)

## 0.17.2

**Release date:** 2023-07-27

![AppVersion: v1.92.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.91.3 to v1.92.0
