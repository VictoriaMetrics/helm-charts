## Next release

- TODO

## v0.2.0

**Release date:** 30 Sep 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.9.0](https://img.shields.io/badge/v1.9.0-success?logo=VictoriaMetrics&labelColor=gray)

**Update node 1**: due to change in label name pods will be restarted.

- added `app.kubernetes.io/component` with value from custom `app` label. See [#2785](https://github.com/VictoriaMetrics/helm-charts/issues/2785).
- add `nodePort` support for `Service` resources
- added `global.extraLabels` and `global.extraAnnotations` to apply common labels and annotations to all workload resources and pod templates
- added network policy configuration support. See [#2977](https://github.com/VictoriaMetrics/helm-charts/issues/2977)
- add `dnsConfig` option to set a custom DNS config for the pod. See [#3174](https://github.com/VictoriaMetrics/helm-charts/issues/3174)
- add `horizontalPodAutoscaler` and `podDisruptionBudget` support. `replicas` is omitted from the `Deployment` when HPA is enabled. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `topologySpreadConstraints`, `strategy`, `terminationGracePeriodSeconds`, `priorityClassName`, `initContainers`, `extraContainers`, `envFrom`, `lifecycle`, `startupProbe` and `extraObjects` options. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `service.annotations`, `service.extraLabels`, `service.trafficDistribution`, `service.clusterIP`, `service.externalIPs`, `service.loadBalancerIP`, `service.loadBalancerSourceRanges`, `service.externalTrafficPolicy`, `service.healthCheckNodePort`, `service.ipFamilyPolicy` and `service.ipFamilies` options. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- make `VMServiceScrape` configurable: `scrape.interval`, `scrape.scrapeTimeout`, `scrape.scheme`, `scrape.path`, `scrape.tlsConfig`, `scrape.basicAuth`, `scrape.relabelConfigs`, `scrape.metricRelabelConfigs`, `scrape.extraLabels`, `scrape.annotations` and `scrape.namespace`. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- add `serviceAccount.extraLabels`. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)
- fix `Ingress` missing `metadata.namespace`, so it is created in the release namespace like every other resource. See [#3229](https://github.com/VictoriaMetrics/helm-charts/issues/3229)

## v0.1.0

**Release date:** 10 Apr 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.9.0](https://img.shields.io/badge/v1.9.0-success?logo=VictoriaMetrics&labelColor=gray&link=)

- initial release
