## Next release

- set command for cleanup job. fixes [#2501](https://github.com/VictoriaMetrics/helm-charts/issues/2501).

## 0.54.0

**Release date:** 27 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.63.0](https://img.shields.io/badge/v0.63.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0630)

**Update node 1**: CRDs generated with `.Values.crds.plain: false` are now specless. For this case operator is fully responsible for VM specs validation. This was done to decrease helm release secret size limit. This change affects `kubectl explain` users and tools, that are rely on CRD specs during input data validation. If this behaviour is not acceptable consider using either `victoria-metrics-operator-crds` chart for CRDs management or set `.Values.crds.plain: true` to use plain CRDs.

- Added `securityContext` to the `cleanup` job.
- Make CRDs, that are rendered using template, specless. This allows to decrease size of k8s secret significantly. If this option is not acceptable for you consider installing CRDs separately using `victoria-metrics-operator-crds` chart or set `.Values.crds.plain: true` and `.Values.crds.upgrade.enabled: true` to use plain CRDs with upgrade job instead.
- Replaced `.Values.admissionWebhooks.enabledCRDValidation` with `.Values.admissionWebhooks.disabledFor` list of CRD names to disable validation for. This change should not affect anyone, since before condition with `.Values.admissionWebhooks.enabledCRDValidation` was not working at all.
- Added CRDs upgrade job, which is only available only for plain CRDs (`.Values.crds.plain: true`). See [#2334](https://github.com/VictoriaMetrics/helm-charts/issues/2334).

## 0.53.0

**Release date:** 12 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.63.0](https://img.shields.io/badge/v0.63.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0630)

**Update note 1**: This release contains new CRDs VTCluster and VTSingle. It requires to perform CRD versions update.

- updates operator to [v0.63.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.63.0) version

## 0.52.1

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.62.0](https://img.shields.io/badge/v0.62.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0620)

- updates operator to [v0.62.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.62.0) version

## 0.52.0

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.60.0](https://img.shields.io/badge/v0.60.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0600)

- Include patch version while building default cleanup image tag. See [#2339](https://github.com/VictoriaMetrics/helm-charts/issues/2339).
- updates operator to [v0.62.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.62.0) version

## 0.51.4

**Release date:** 23 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.61.2](https://img.shields.io/badge/v0.61.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0612)

- updates operator to [v0.61.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.2) version

## 0.51.3

**Release date:** 21 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.61.1](https://img.shields.io/badge/v0.61.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0611)

- updates operator to [v0.61.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.1) version

## 0.51.2

**Release date:** 17 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.61.0](https://img.shields.io/badge/v0.61.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0610)

- TODO

## 0.51.1

**Release date:** 16 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.61.0](https://img.shields.io/badge/v0.61.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0610)

- add missing `pods/eviction` RBAC permission. Thanks to the @kevinastone

## 0.51.0

**Release date:** 15 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.61.0](https://img.shields.io/badge/v0.61.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0610)

**Update note 1**: This release contains new CRD VLAgent. It requires to perform CRD versions update.

- updates operator to [v0.61.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.61.0) version

## 0.50.3

**Release date:** 27 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.60.2](https://img.shields.io/badge/v0.60.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0602)

- updates operator to [v0.60.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.2) version

## 0.50.2

**Release date:** 24 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.60.1](https://img.shields.io/badge/v0.60.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0601)

- updates operator to [v0.60.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.1) version

## 0.50.1

**Release date:** 24 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.60.0](https://img.shields.io/badge/v0.60.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0600)

- enabled VMAnomaly webhook

## 0.50.0

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.60.0](https://img.shields.io/badge/v0.60.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0600)

**Update note**: This release contains changes to validation webhooks and it requires operator version v0.60.0 or above

- updates operator to [v0.60.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.60.0) version

## 0.49.2

**Release date:** 12 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.59.2](https://img.shields.io/badge/v0.59.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0592)

**Update note**: This release contains changes to validation webhooks and it requires operator version v0.59.2 or above

- updates operator to [v0.59.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.59.2) version
- propagate .Values.global.image.registry to operator container VM_CONTAINERREGISTRY env variable. This will allow to use .Values.global.image.registry in k8s-stack chart. Related issue [#2226](https://github.com/VictoriaMetrics/helm-charts/issues/2226).

## 0.49.1

**Release date:** 30 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.59.1](https://img.shields.io/badge/v0.59.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0591)

**Update note 1**: This release contains new CRDs VLCluster and VLSingle. It requires to perform CRD versions update.
**Update note 2**: This release contains changes to validation webhooks and it requires operator version v0.59.2 or above

- Support scrape and probe CRs validation webhooks
- updates operator to [v0.59.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.59.1) version

## 0.49.0-rc1

**Release date:** 30 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.59.0](https://img.shields.io/badge/v0.59.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0590)

**Update note**: This release contains new CRDs VLCluster and VLSingle. It requires to perform CRD versions update.

- Support scrape and probe CRs validation webhooks
- updates operator to [v0.59.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.59.0) version

## 0.47.0

**Release date:** 14 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.58.0](https://img.shields.io/badge/v0.58.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0580)

- updates operator to [v0.58.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.58.0) version

## 0.46.0

**Release date:** 09 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.57.0](https://img.shields.io/badge/v0.57.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0570)

- updates operator to [v0.57.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.57.0) version

## 0.45.0

**Release date:** 17 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.56.0](https://img.shields.io/badge/v0.56.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0560)

- updates operator to [v0.56.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.56.0) version

## 0.44.0

**Release date:** 02 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.55.0](https://img.shields.io/badge/v0.55.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0550)

- updates operator to [v0.55.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.55.0) version

## 0.43.1

**Release date:** 21 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.54.1](https://img.shields.io/badge/v0.54.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0541)

- updated common dependency 0.0.39 -> 0.0.42
- add `.Values.crds.annotations` when `.Values.crds.plain: false`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2073).

## 0.43.0

**Release date:** 13 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.54.1](https://img.shields.io/badge/v0.54.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0541)

- updates operator to [v0.54.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.54.1) version

## 0.42.5

**Release date:** 11 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- Add `.Values.serviceMonitor.vm` toggle, which allows to switch from `VMServiceScrape` to `ServiceMonitor` for operator monitoring.

## 0.42.4

**Release date:** 03 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- add support for ServiceScrape `proxyURL`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2029).

## 0.42.3

**Release date:** 02 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- updated common dependency 0.0.39 -> 0.0.41

## 0.42.2

**Release date:** 02 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- added webhook certificates configurable subject and secretTemplate. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2022).

## 0.42.1

**Release date:** 25 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- updated common dependency 0.0.37 -> 0.0.39
- added fullname prefix for victoriametrics:admin and victoriametrics:view roles to avoid collision during while deploying more than one operator. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2012).

## 0.42.0

**Release date:** 05 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.53.0](https://img.shields.io/badge/v0.53.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0530)

- updates operator to [v0.53.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.53.0) version

## 0.41.2

**Release date:** 05 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.52.0](https://img.shields.io/badge/v0.52.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0520)

- added `.Values.allowedMetricsEndpoints`

## 0.41.1

**Release date:** 04 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.52.0](https://img.shields.io/badge/v0.52.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0520)

- Added default values for securityContext and podSecurityContext

## 0.41.0

**Release date:** 22 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.52.0](https://img.shields.io/badge/v0.52.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0520)

- updates operator to [v0.52.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.52.0) version

## 0.40.5

**Release date:** 20 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.3](https://img.shields.io/badge/v0.51.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0513)

- Made certManager certificates commonName and duration configurable. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1924).
- Add pod priority class configuration for operator. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1929).

## 0.40.4

**Release date:** 13 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.3](https://img.shields.io/badge/v0.51.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0513)

- updates operator to [v0.51.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.3) version

## 0.40.3

**Release date:** 06 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.2](https://img.shields.io/badge/v0.51.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0512)

- updated common dependency 0.0.36 -> 0.0.37
- support templating in `.Values.extraObjects`

## 0.40.2

**Release date:** 24 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.2](https://img.shields.io/badge/v0.51.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0512)

- add option to enable hostNetwork for custom CNI based deployments
- updated common dependency 0.0.35 -> 0.0.36
- updates operator to [v0.51.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.2) version

## 0.40.1

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.1](https://img.shields.io/badge/v0.51.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0511)

- Compact CRD template. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1888).
- Exclude markdown files from package

## 0.40.0

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v0.51.1](https://img.shields.io/badge/v0.51.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0511)

- updated common dependency 0.0.34 -> 0.0.35
- updates operator to [v0.51.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.51.1) version


## 0.40.0-rc.1

**Release date:** 2024-12-17

![AppVersion: v0.51.0-rc1](https://img.shields.io/badge/v0.51.0--rc1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0510)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.32 -> 0.0.33
- add an option to mount `ServiceAccount` token manually for security hardening reasons.

## 0.39.1

**Release date:** 2024-11-25

![AppVersion: v0.50.0](https://img.shields.io/badge/v0.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0500)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.31 -> 0.0.32

## 0.39.0

**Release date:** 2024-11-25

![AppVersion: v0.50.0](https://img.shields.io/badge/v0.50.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0500)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.28 -> 0.0.31
- fixed app.kubernetes.io/version tag override if custom tag is set. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1766).

## 0.38.0

**Release date:** 2024-11-18

![AppVersion: v0.49.1](https://img.shields.io/badge/v0.49.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0491)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fix Deployment/StatefulSets when `serviceAccount.name` is empty and `serviceAccount.create: false`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1683).
- set default DNS domain to `cluster.local.`
- updated common dependency 0.0.19 -> 0.0.28
- added back `crds.enabled: false` option, which disables CRD creation, but due to limitation of dependencies condition it allows to disable only in combination with `crds.plain: false`
- disabled cleanup, while `crds.enabled: false`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1563).
- updates operator to [v0.50.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.49.0) version

## 0.37.0

**Release date:** 2024-11-05

![AppVersion: v0.49.0](https://img.shields.io/badge/v0.49.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0490)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Migrated to common templates
- updates operator to [v0.49.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.49.0) version


## 0.36.0

**Release date:** 2024-10-22

![AppVersion: v0.48.4](https://img.shields.io/badge/v0.48.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0484)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- replaced `crd.enabled` property to `crds.plain`. Instead of disabling CRDs it selects if CRDs should be rendered from template or as plain CRDs

## 0.35.5

**Release date:** 2024-10-15

![AppVersion: v0.48.4](https://img.shields.io/badge/v0.48.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0484)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.48.4](https://github.com/VictoriaMetrics/operator/releases/tag/v0.48.4) version

## 0.35.4

**Release date:** 2024-10-11

![AppVersion: v0.48.3](https://img.shields.io/badge/v0.48.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0483)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Human-readable error about Helm version requirement

## 0.35.3

**Release date:** 2024-10-10

![AppVersion: v0.48.3](https://img.shields.io/badge/v0.48.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0483)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- upgraded common chart dependency
- made webhook pod port configurable. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1565)
- added configurable cleanup hook resources. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1571)
- added ability to configure `terminationGracePeriodSeconds` and `lifecycle`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1563) for details

## 0.35.2

**Release date:** 2024-09-29

![AppVersion: v0.48.3](https://img.shields.io/badge/v0.48.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0483)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.48.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.48.3) version

## 0.35.1

**Release date:** 2024-09-26

![AppVersion: v0.48.1](https://img.shields.io/badge/v0.48.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0481)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.48.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.48.1) version

## 0.35.0

**Release date:** 2024-09-26

![AppVersion: v0.48.0](https://img.shields.io/badge/v0.48.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0480)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Made webhook port configurable. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1506)
- Changed crd cleanup hook delete policy to prevent `resource already exists` error.
- updates operator to [v0.48.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.48.0) version

## 0.34.8

**Release date:** 2024-09-10

![AppVersion: v0.47.3](https://img.shields.io/badge/v0.47.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0473)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added ability to override deployment namespace using `namespaceOverride` and `global.namespaceOverride` variables
- Fixed template for cert-manager certificates
- Fixed operator Role creation when only watching own namespace using `watchNamespaces`
- Changed webhook service port from 443 to 9443

## 0.34.7

**Release date:** 2024-09-03

![AppVersion: v0.47.3](https://img.shields.io/badge/v0.47.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0473)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Do not create ClusterRole if `watchNamespaces` contains only namespace, where operator is deployed

## 0.34.6

**Release date:** 2024-08-29

![AppVersion: v0.47.3](https://img.shields.io/badge/v0.47.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0473)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.47.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.47.3) version
- Made `cleanupCRD` deprecated in a favour of `crd.cleanup.enabled`
- Made `cleanupImage` deprecated in a favour of `crd.cleanup.image`
- Made `watchNamespace` string deprecated in a favour of `watchNamespaces` slice
- Decreased rendering time by 2 seconds

## 0.34.5

**Release date:** 2024-08-26

![AppVersion: v0.47.2](https://img.shields.io/badge/v0.47.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0472)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixes typo at clean webhook. vmlogs->vlogs.

## 0.34.4

**Release date:** 2024-08-26

![AppVersion: v0.47.2](https://img.shields.io/badge/v0.47.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0472)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fixes RBAC by rollback <https://github.com/VictoriaMetrics/helm-charts/commit/7d75b93525bb0a99a8011b700d0a51b6b762321c>

## 0.34.3

**Release date:** 2024-08-26

![AppVersion: v0.47.2](https://img.shields.io/badge/v0.47.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0472)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- removes not implemented scrape CRDs from validation webhook

## 0.34.2

**Release date:** 2024-08-26

![AppVersion: v0.47.2](https://img.shields.io/badge/v0.47.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0472)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- set `admissionWebhooks.keepTLSSecret` to `true` by default
- fixed indent, for Issuer crd, when `cert-manager.enabled: true`
- updates operator to [v0.47.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.47.2) version

## 0.34.1

**Release date:** 2024-08-23

![AppVersion: v0.47.1](https://img.shields.io/badge/v0.47.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0471)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: main container name was changed to `operator`, which will recreate a pod.

- Updated operator to v0.47.1 release
- Added global imagePullSecrets and image.registry
- Use static container names in a pod
- Updated operator service scrape config
- Added `.Values.vmstorage.service.ipFamilies` and `.Values.vmstorage.service.ipFamilyPolicy` for service IP family management
- Enabled webhook by default
- Generate webhook certificate when Cert Manager is not enabled
- Added ability to configure container port
- Fixed image pull secrets. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1285)

## 0.34.0

**Release date:** 2024-08-15

![AppVersion: v0.47.0](https://img.shields.io/badge/v0.47.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0470)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Set minimal kubernetes version to 1.25
- Removed support for policy/v1beta1/PodDisruptionBudget
- Added configurable probes at `.Values.probe`
- updates operator to [v0.47.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.47.0) release
- adds RBAC permissions to VLogs object

## 0.33.6

**Release date:** 2024-08-07

![AppVersion: v0.46.4](https://img.shields.io/badge/v0.46.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0464)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- add missing permission to allow patching `horizontalpodautoscalers` when operator watches single namespace.

## 0.33.5

**Release date:** 2024-08-01

![AppVersion: v0.46.4](https://img.shields.io/badge/v0.46.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0464)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- fix cleanup job image tag when `.Capabilities.KubeVersion.Minor` returns version with plus sign. See [this pull request](https://github.com/VictoriaMetrics/helm-charts/pull/1169) by @dimaslv.

## 0.33.4

**Release date:** 2024-07-10

![AppVersion: v0.46.4](https://img.shields.io/badge/v0.46.4-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0464)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.46.4](https://github.com/VictoriaMetrics/operator/releases/tag/v0.46.4) release

## 0.33.3

**Release date:** 2024-07-05

![AppVersion: v0.46.3](https://img.shields.io/badge/v0.46.3-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0463)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updates operator to [v0.46.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.46.3) release

## 0.33.2

**Release date:** 2024-07-04

![AppVersion: v0.46.2](https://img.shields.io/badge/v0.46.2-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0462)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- breaking change: operator uses different entrypoint, remove `command` entrypoint
- breaking change: operator uses new flag for leader election `leader-elect`
- removes podsecurity policy. It's longer supported by kubernetes
- updates operator to [v0.46.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.46.2) release

## 0.33.1

**Release date:** 2024-07-03

![AppVersion: v0.46.0](https://img.shields.io/badge/v0.46.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Foperator%2Fchangelog%2F%23v0460)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- breaking change: operator uses different entrypoint, remove `command` entrypoint
- breaking change: operator uses new flag for leader election `leader-elect`
- removes podsecurity policy. It's longer supported by kubernetes
- updates operator to [v0.46.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.46.0) release

## 0.32.3

**Release date:** 2024-07-02

![AppVersion: v0.45.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.45.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- use bitnami/kubectl image for cleanup instead of deprecated gcr.io/google_containers/hyperkube

## 0.32.2

**Release date:** 2024-06-14

![AppVersion: v0.45.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.45.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix default image tag when using `Chart.AppVersion`, previously the version is missing "v".

## 0.32.1

**Release date:** 2024-06-14

![AppVersion: 0.45.0](https://img.shields.io/static/v1?label=AppVersion&message=0.45.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Update note**: The VictoriaMetrics components image tag template has been updated. This change introduces `.Values.<component>.image.variant` to specify tag suffixes like `-scratch`, `-cluster`, `-enterprise`. Additionally, you can now omit `.Values.<component>.image.tag` to automatically use the version specified in `.Chart.AppVersion`.

- support specifying image tag suffix like "-enterprise" for VictoriaMetrics components using `.Values.<component>.image.variant`.

## 0.32.0

**Release date:** 2024-06-10

![AppVersion: 0.45.0](https://img.shields.io/static/v1?label=AppVersion&message=0.45.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to [v0.45.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.45.0)

## 0.31.2

**Release date:** 2024-05-14

![AppVersion: 0.44.0](https://img.shields.io/static/v1?label=AppVersion&message=0.44.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix missing serviceaccounts patch permission in ClusterRole, see [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1012) for details.

## 0.31.1

**Release date:** 2024-05-10

![AppVersion: 0.44.0](https://img.shields.io/static/v1?label=AppVersion&message=0.44.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix serviceAccount template when `.Values.serviceAccount.create=false`, see this [pull request](https://github.com/VictoriaMetrics/helm-charts/pull/1002) by @tylerturk for details.
- support creating aggregated clusterRoles for VM CRDs with admin and read permissions, see this [pull request](https://github.com/VictoriaMetrics/helm-charts/pull/996) by @reegnz for details.

## 0.31.0

**Release date:** 2024-05-09

![AppVersion: 0.44.0](https://img.shields.io/static/v1?label=AppVersion&message=0.44.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to [v0.44.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.44.0)

## 0.30.3

**Release date:** 2024-04-26

![AppVersion: 0.43.5](https://img.shields.io/static/v1?label=AppVersion&message=0.43.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to [v0.43.5](https://github.com/VictoriaMetrics/operator/releases/tag/v0.43.5)

## 0.30.2

**Release date:** 2024-04-23

![AppVersion: 0.43.3](https://img.shields.io/static/v1?label=AppVersion&message=0.43.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to v0.43.1 version
- fixes typo at single-namespace role for `vmscrapeconfig`. See this [issue](https://github.com/VictoriaMetrics/helm-charts/issues/987) for details.

## 0.30.1

**Release date:** 2024-04-18

![AppVersion: 0.43.1](https://img.shields.io/static/v1?label=AppVersion&message=0.43.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- TODO

- updates operator to v0.43.1 version

## 0.30.0

**Release date:** 2024-04-18

![AppVersion: 0.43.0](https://img.shields.io/static/v1?label=AppVersion&message=0.43.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator to v0.43.0-0 version
- adds `events` create permission
- properly truncate value of `app.kubernetes.io/managed-by` and `app.kubernetes.io/instance` labels in case release name exceeds 63 characters.

## 0.29.6

**Release date:** 2024-04-16

![AppVersion: 0.42.4](https://img.shields.io/static/v1?label=AppVersion&message=0.42.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- clean up vmauth as well when uninstall chart with `cleanupCRD: true`, since it also has `finalizers`.
- sync new crd VMScrapeConfig from operator, see detail in <https://docs.victoriametrics.com/operator/api/#vmscrapeconfig>.

## 0.29.5

**Release date:** 2024-04-02

![AppVersion: 0.42.4](https://img.shields.io/static/v1?label=AppVersion&message=0.42.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.42.4](https://github.com/VictoriaMetrics/operator/releases/tag/v0.42.4)

## 0.29.4

**Release date:** 2024-03-28

![AppVersion: 0.42.3](https://img.shields.io/static/v1?label=AppVersion&message=0.42.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- added ability to use slice variables in extraArgs (#944)

## 0.29.3

**Release date:** 2024-03-12

![AppVersion: 0.42.3](https://img.shields.io/static/v1?label=AppVersion&message=0.42.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- TODO

## 0.29.2

**Release date:** 2024-03-06

![AppVersion: 0.42.2](https://img.shields.io/static/v1?label=AppVersion&message=0.42.2&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.42.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.42.2)

## 0.29.0

**Release date:** 2024-03-06

![AppVersion: 0.42.1](https://img.shields.io/static/v1?label=AppVersion&message=0.42.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.42.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.42.1)

## 0.29.0

**Release date:** 2024-03-04

![AppVersion: 0.42.0](https://img.shields.io/static/v1?label=AppVersion&message=0.42.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.42.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.42.0)

## 0.28.1

**Release date:** 2024-02-21

![AppVersion: 0.41.2](https://img.shields.io/static/v1?label=AppVersion&message=0.41.2&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.41.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.41.2)

## 0.28.0

**Release date:** 2024-02-09

![AppVersion: 0.41.1](https://img.shields.io/static/v1?label=AppVersion&message=0.41.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update victoriametrics CRD resources yaml.

## 0.27.11

**Release date:** 2024-02-01

![AppVersion: 0.41.1](https://img.shields.io/static/v1?label=AppVersion&message=0.41.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.41.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.41.1)

## 0.27.10

**Release date:** 2024-01-24

![AppVersion: 0.40.0](https://img.shields.io/static/v1?label=AppVersion&message=0.40.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump operator version to [0.40.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.40.0)

## 0.27.9

**Release date:** 2023-12-12

![AppVersion: 0.39.4](https://img.shields.io/static/v1?label=AppVersion&message=0.39.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.39.4](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.4)

## 0.27.8

**Release date:** 2023-12-08

![AppVersion: 0.39.3](https://img.shields.io/static/v1?label=AppVersion&message=0.39.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Sync CRD resources with operator [v0.39.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.3).

## 0.27.7

**Release date:** 2023-12-08

![AppVersion: 0.39.3](https://img.shields.io/static/v1?label=AppVersion&message=0.39.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Skip deleting victoriametrics CRD resources when uninstall release.

## 0.27.6

**Release date:** 2023-11-16

![AppVersion: 0.39.3](https://img.shields.io/static/v1?label=AppVersion&message=0.39.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.39.3](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.3)

## 0.27.5

**Release date:** 2023-11-15

![AppVersion: 0.39.2](https://img.shields.io/static/v1?label=AppVersion&message=0.39.2&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.39.2](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.2)
- Add `extraObjects` to allow deploying additional resources with the chart release. (#751)

## 0.27.4

**Release date:** 2023-11-01

![AppVersion: 0.39.1](https://img.shields.io/static/v1?label=AppVersion&message=0.39.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.39.1](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.1)

## 0.27.3

**Release date:** 2023-10-08

![AppVersion: 0.39.0](https://img.shields.io/static/v1?label=AppVersion&message=0.39.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added endpointslices permissions to operator roles (#708)

## 0.27.2

**Release date:** 2023-10-04

![AppVersion: 0.39.0](https://img.shields.io/static/v1?label=AppVersion&message=0.39.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM operator to [0.39.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.39.0)

## 0.27.1

**Release date:** 2023-09-28

![AppVersion: 0.38.0](https://img.shields.io/static/v1?label=AppVersion&message=0.38.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix `relabelConfigs` for operator's VMServiceScrape (#624)

## 0.27.0

**Release date:** 2023-09-11

![AppVersion: 0.38.0](https://img.shields.io/static/v1?label=AppVersion&message=0.38.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of operator to [v0.38.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.38.0)

## 0.26.2

**Release date:** 2023-09-07

![AppVersion: 0.37.1](https://img.shields.io/static/v1?label=AppVersion&message=0.37.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Updated CRDs for operator

## 0.26.1

**Release date:** 2023-09-04

![AppVersion: 0.37.1](https://img.shields.io/static/v1?label=AppVersion&message=0.37.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of Victoria Metrics operator to `v0.37.1`

## 0.26.0

**Release date:** 2023-08-30

![AppVersion: 0.37.0](https://img.shields.io/static/v1?label=AppVersion&message=0.37.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump operator version to [v0.37.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.37.0)
- `psp_auto_creation_enabled` for operator is disabled by default

## 0.25.0

**Release date:** 2023-08-24

![AppVersion: 0.36.0](https://img.shields.io/static/v1?label=AppVersion&message=0.36.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added `topologySpreadConstraints` for the operator + a small refactoring (#611)
- Fix vm operator appVersion (#589)
- Fixes operator doc description
- Add `cleanupCRD` option to clean up vm cr resources when uninstalling (#593)
- Bump operator version to [v0.36.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.36.0)

## 0.24.1

**Release date:** 2023-07-13

![AppVersion: 0.35.](https://img.shields.io/static/v1?label=AppVersion&message=0.35.&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- operator release v0.35.1

## 0.24.0

**Release date:** 2023-07-03

![AppVersion: 0.35.0](https://img.shields.io/static/v1?label=AppVersion&message=0.35.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator for v0.35.0
- updates for v1.91.1 release

## 0.23.1

**Release date:** 2023-05-29

![AppVersion: 0.34.1](https://img.shields.io/static/v1?label=AppVersion&message=0.34.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- updates operator for v0.34.1 version

## 0.23.0

**Release date:** 2023-05-25

![AppVersion: 0.34.0](https://img.shields.io/static/v1?label=AppVersion&message=0.34.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump operator version
- feat(operator): add PodDisruptionBudget (#546)
