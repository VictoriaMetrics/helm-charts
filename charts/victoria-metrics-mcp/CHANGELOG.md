## Next release

- add ability to override container command.
- add `nodePort` support for `Service` resources
- added `global.extraLabels` and `global.extraAnnotations` to apply common labels and annotations to all workload resources and pod templates
- fix `VMServiceScrape` to target the correct namespace
- added network policy configuration support. See [#2977](https://github.com/VictoriaMetrics/helm-charts/issues/2977)
- add `dnsConfig` option to set a custom DNS config for the pod. See [#3174](https://github.com/VictoriaMetrics/helm-charts/issues/3174)
- add `horizontalPodAutoscaler` and `podDisruptionBudget` support. `replicas` is omitted from the `Deployment` when HPA is enabled. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `topologySpreadConstraints`, `strategy`, `terminationGracePeriodSeconds`, `priorityClassName`, `initContainers`, `extraContainers`, `envFrom`, `lifecycle`, `startupProbe` and `extraObjects` options. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `service.annotations`, `service.extraLabels`, `service.trafficDistribution`, `service.clusterIP`, `service.externalIPs`, `service.loadBalancerIP`, `service.loadBalancerSourceRanges`, `service.externalTrafficPolicy`, `service.healthCheckNodePort`, `service.ipFamilyPolicy` and `service.ipFamilies` options. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- make `VMServiceScrape` configurable: `scrape.interval`, `scrape.scrapeTimeout`, `scrape.scheme`, `scrape.path`, `scrape.tlsConfig`, `scrape.basicAuth`, `scrape.relabelConfigs`, `scrape.metricRelabelConfigs`, `scrape.extraLabels`, `scrape.annotations` and `scrape.namespace`. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `serviceAccount.extraLabels`. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- allow `vm.cloudAPIKey` to be a `valueFrom` map so the key can be sourced from a `Secret`, the same way `vm.bearerToken` already can. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- fail early on unsupported `vm.type` values, matching the existing `mcp.mode` check. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- fix `Ingress` missing `metadata.namespace`, so it is created in the release namespace like every other resource. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)

## v0.3.0

**Release date:** 18 May 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.1](https://img.shields.io/badge/v1.120.1-success?logo=VictoriaMetrics&labelColor=gray&link=)

**Update node 1**: due to change in label name pods will be restarted.

- added `app.kubernetes.io/component` with value from custom `app` label. See [#2785](https://github.com/VictoriaMetrics/helm-charts/issues/2785).

## v0.2.0

**Release date:** 18 Mar 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.19.0](https://img.shields.io/badge/v1.19.0-success?logo=VictoriaMetrics&labelColor=gray&link=)

- move helm chart from mcp-victoriametrics repo to helm-charts repo
- add new `mcp.passthroughHeaders` param

## v0.1.0

**Release date:** 27 Oct 2025

![AppVersion: v1.19.0](https://img.shields.io/badge/v1.19.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fmcp-victoriametrics%2Freleases%2Ftag%2Fv1.19.0)

- initial release
