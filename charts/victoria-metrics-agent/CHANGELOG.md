## Next release

- bump operator chart version 0.0.42 -> 0.0.45

## 0.26.4

**Release date:** 04 Nov 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.129.1](https://img.shields.io/badge/v1.129.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11291)

- bump version of VM components to [v1.129.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.129.1)

## 0.26.3

**Release date:** 03 Nov 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.129.0](https://img.shields.io/badge/v1.129.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11290)

- bump version of VM components to [v1.129.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.129.0)

## 0.26.2

**Release date:** 21 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.128.0](https://img.shields.io/badge/v1.128.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11280)

- bump version of VM components to [v1.128.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.128.0)

## 0.26.1

**Release date:** 08 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11270)

- do not merge .Values.persistentVolume.extraLabels with default chart labels. See [#2460](https://github.com/VictoriaMetrics/helm-charts/issues/2460).

## 0.26.0

**Release date:** 08 Oct 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.127.0](https://img.shields.io/badge/v1.127.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11270)

- Added .Values.selectorLabels and .Values.service.selectorLabels to add additional selector labels for pod and service and for service only respectively. See [#2451](https://github.com/VictoriaMetrics/helm-charts/issues/2451).
- bump version of VM components to [v1.127.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.127.0)

## 0.25.10

**Release date:** 22 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.126.0](https://img.shields.io/badge/v1.126.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11260)

- added `.Values.config.useTpl` flag to enable scrape config templating.

## 0.25.9

**Release date:** 17 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.126.0](https://img.shields.io/badge/v1.126.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11260)

- Reverting templating support for scrape configuration. See [#2432](https://github.com/VictoriaMetrics/helm-charts/issues/2432).

## 0.25.8

**Release date:** 16 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.126.0](https://img.shields.io/badge/v1.126.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11260)

- render helm variables in the ConfigMap

## 0.25.7

**Release date:** 15 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.126.0](https://img.shields.io/badge/v1.126.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fvictoriametrics%2Fchangelog%2F%23v11260)

- bump version of VM components to [v1.126.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.126.0)

## 0.25.6

**Release date:** 10 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.1](https://img.shields.io/badge/v1.125.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11251)

- add `.Values.rbac.extraRules` to allow setting extra Role/ClusterRole rules

## 0.25.5

**Release date:** 03 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.1](https://img.shields.io/badge/v1.125.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11251)

- bump version of VM components to [v1.125.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.125.1)

## 0.25.4

**Release date:** 01 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.0](https://img.shields.io/badge/v1.125.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11250)

- Added hostAliases to add additional DNS entries to be injected directly into pods

## 0.25.3

**Release date:** 01 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.125.0](https://img.shields.io/badge/v1.125.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11250)

- bump version of VM components to [v1.125.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.125.0)

## 0.25.2

**Release date:** 18 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.124.0](https://img.shields.io/badge/v1.124.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11240)

- bump version of VM components to [v1.124.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.124.0)

## 0.25.1

**Release date:** 05 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.123.0](https://img.shields.io/badge/v1.123.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11230)

- bump version of VM components to [v1.123.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/victoriametrics/changelog/CHANGELOG.md#v11230)

## 0.25.0

**Release date:** 21 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.122.0](https://img.shields.io/badge/v1.122.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11220)

- bump version of VM components to [v1.122.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.122.0)

## 0.24.0

**Release date:** 07 Jul 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.121.0](https://img.shields.io/badge/v1.121.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11210)

- bump version of VM components to [v1.121.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/victoriametrics/changelog/CHANGELOG.md#v11210)

## 0.23.0

**Release date:** 23 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.120.0](https://img.shields.io/badge/v1.120.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11200)

- bump version of VM components to [v1.120.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.120.0)

## 0.22.1

**Release date:** 19 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.119.0](https://img.shields.io/badge/v1.119.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11190)

- TODO

## 0.22.0

**Release date:** 10 Jun 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.119.0](https://img.shields.io/badge/v1.119.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11190)

- Added `internalTrafficPolicy` option to service section to control how traffic from Kubernetes internal sources is routed to endpoints
- bump version of VM components to [v1.119.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.119.0)

## 0.21.0

**Release date:** 26 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.118.0](https://img.shields.io/badge/v1.118.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11180)

- bump version of VM components to [v1.118.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.118.0)

## 0.20.1

**Release date:** 16 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.117.1](https://img.shields.io/badge/v1.117.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11171)

- bump version of VM components to [v1.117.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.117.1)

## 0.20.0

**Release date:** 12 May 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.117.0](https://img.shields.io/badge/v1.117.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11170)

- bump version of VM components to [v1.117.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.117.0)

## 0.19.0

**Release date:** 29 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.116.0](https://img.shields.io/badge/v1.116.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11160)

- bump version of VM components to [v1.116.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.116.0)

## 0.18.2

**Release date:** 18 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- Support wildcard in ingress hostname. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2134).

## 0.18.1

**Release date:** 17 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- TODO

## 0.18.0

**Release date:** 07 Apr 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.115.0](https://img.shields.io/badge/v1.115.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11150)

- bump version of VM components to [v1.115.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.115.0)

## 0.17.3

**Release date:** 25 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.114.0](https://img.shields.io/badge/v1.114.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11140)

- bump version of VM components to [v1.114.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.114.0)

## 0.17.2

**Release date:** 19 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- Add empty values to list args for remoteWrite. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2065).
- updated common dependency 0.0.39 -> 0.0.42

## 0.17.1

**Release date:** 14 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- fixed usage of existingClaim in statefulSet mode. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2056).

## 0.17.0

**Release date:** 13 Mar 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.113.0](https://img.shields.io/badge/v1.113.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11130)

- bump version of VM components to [v1.113.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.113.0)

## 0.16.2

**Release date:** 27 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- Reverted serviceName removal, which was done in 0.16.0 release

## 0.16.1

**Release date:** 26 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

- fixed serviceAccount variable typo in server templates. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2014).

## 0.16.0

**Release date:** 24 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.112.0](https://img.shields.io/badge/v1.112.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11120)

**Update note 1**: `.Values.statefulSet.updateStrategy` was changed to `.Values.statefulSet.spec.updateStrategy`
**Update node 2**: `.Values.statefulSet.podManagementPolicy` was changed to `.Values.statefulSet.spec.podManagementPolicy`
**Update note 3**: `.Values.deployment.strategy` was changed to `.Values.deployment.spec.strategy`
**Update note 4**: `.Values.statefulSet.enabled` was replaced by `.Values.mode`, which accepts `deployment`, `statefulSet` or `daemonSet` values
**Update note 5**: `.Values.persistence` was changed to `.Values.persistentVolume`

- Force enabling service, when ingress in enabled. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/2007).
- Add ability to configure VMAgent as a DaemonSet. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1995).
- bump version of VM components to [v1.112.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.112.0)

## 0.15.8

**Release date:** 10 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.111.0](https://img.shields.io/badge/v1.111.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11110)

- updated common dependency 0.0.37 -> 0.0.39
- bump version of VM components to [v1.111.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.111.0)

## 0.15.7

**Release date:** 05 Feb 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- added `.Values.allowedMetricsEndpoints` to set allowed scrape endpoints. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1970) for details.

## 0.15.6

**Release date:** 27 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.110.0](https://img.shields.io/badge/v1.110.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11100)

- bump version of VM components to [v1.110.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.110.0)

## 0.15.5

**Release date:** 17 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.109.1](https://img.shields.io/badge/v1.109.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11091)

- bump version of VM components to [v1.109.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.109.1)

## 0.15.4

**Release date:** 14 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.109.0](https://img.shields.io/badge/v1.109.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11090)

- bump version of VM components to [v1.109.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.109.0)

## 0.15.3

**Release date:** 06 Jan 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- Exclude markdown files from package
- updated common dependency 0.0.35 -> 0.0.37
- support templating in `.Values.extraObjects`

## 0.15.2

**Release date:** 19 Dec 2024

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.108.1](https://img.shields.io/badge/v1.108.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11081)

- updated common dependency 0.0.34 -> 0.0.35
- bump version of VM components to [v1.108.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.108.1)

## 0.15.1

**Release date:** 2024-12-16

![AppVersion: v1.108.0](https://img.shields.io/badge/v1.108.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11080)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.108.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.108.0)

## 0.15.0

**Release date:** 2024-12-02

![AppVersion: v1.107.0](https://img.shields.io/badge/v1.107.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11070)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.31 -> 0.0.33
- Added service.targetPort and serviceMonitor.targetPort to add ability to point service to one of extraContainers port, like oauth2-proxy
- bump version of VM components to [v1.107.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.107.0)

## 0.14.9

**Release date:** 2024-11-22

![AppVersion: v1.106.1](https://img.shields.io/badge/v1.106.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11061)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.28 -> 0.0.31
- fixed app.kubernetes.io/version tag override if custom tag is set. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1766).

## 0.14.8

**Release date:** 2024-11-18

![AppVersion: v1.106.1](https://img.shields.io/badge/v1.106.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11061)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated common dependency 0.0.23 -> 0.0.28
- bump version of VM components to [v1.106.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.106.1)

## 0.14.7

**Release date:** 2024-11-12

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- set default DNS domain to `cluster.local.`
- updated common dependency 0.0.19 -> 0.0.23
- added template for configmap name
- fixed statefulset variable name typo

## 0.14.6

**Release date:** 2024-11-06

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Use only podLabels as extra labels for pods
- Renamed `.Values.statefulset` to `.Values.statefulSet` for consistency
- Fix Deployment/StatefulSets when `serviceAccount.name` is empty and `serviceAccount.create: false`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1683).

## 0.14.5

**Release date:** 2024-11-05

![AppVersion: v1.106.0](https://img.shields.io/badge/v1.106.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11060)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.106.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.106.0)

## 0.14.4

**Release date:** 2024-10-29

![AppVersion: v1.105.0](https://img.shields.io/badge/v1.105.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11050)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Support HPA for Statefulset

## 0.14.3

**Release date:** 2024-10-21

![AppVersion: v1.105.0](https://img.shields.io/badge/v1.105.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11050)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.105.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.105.0)

## 0.14.2

**Release date:** 2024-10-11

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Human-readable error about Helm version requirement

## 0.14.1

**Release date:** 2024-10-04

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- upgraded common chart dependency

## 0.14.0

**Release date:** 2024-10-02

![AppVersion: v1.104.0](https://img.shields.io/badge/v1.104.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11040)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.104.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.104.0)

## 0.13.0

**Release date:** 2024-09-27

![AppVersion: v1.103.0](https://img.shields.io/badge/v1.103.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11030)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: `remoteWriteUrls` and `multiTenantUrls` parameters were replaced by `remoteWrite`. Please follow [upgrade guide](https://docs.victoriametrics.com/helm/victoria-metrics-agent/#upgrade-to-0130)

- Fail if no remoteWriteUrls set
- Added `remoteWrite` array param, which can contain all `remoteWrite.*` flag values. Please check chart docs for details.

## 0.12.2

**Release date:** 2024-09-12

![AppVersion: v1.103.0](https://img.shields.io/badge/v1.103.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11030)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added ability to override deployment namespace using `namespaceOverride` and `global.namespaceOverride` variables
- Removed deprecated API from RBAC. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1438)

## 0.12.1

**Release date:** 2024-09-03

![AppVersion: v1.103.0](https://img.shields.io/badge/v1.103.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11030)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Fixed PVC in StatefulSet

## 0.12.0

**Release date:** 2024-08-29

![AppVersion: v1.103.0](https://img.shields.io/badge/v1.103.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11030)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- bump version of VM components to [v1.103.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.103.0)
- Added ability to configure container port
- Fixed image pull secrets. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1285)
- Removed necessity to set `.Values.persistentVolume.existingClaim` when volume is expected to be created by chart. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/189)

## 0.11.0

**Release date:** 2024-08-21

![AppVersion: v1.102.1](https://img.shields.io/badge/v1.102.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v11021)
![Helm: v3.14](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: main container name was changed to `vmagent`, which will recreate a pod.

**Update note**: requires Helm 3.14+

- Removed `PodSecurityPolicy`
- Set minimal kubernetes version to `1.25`
- Removed support for `policy/v1beta1/PodDisruptionBudget`
- Added params to configure probes `.Values.probe.readiness`, `.Values.probe.liveness` and `.Values.probe.startup`
- Added `.Values.global.imagePullSecrets` and `.Values.global.image.registry`
- Added `.Values.emptyDir` to customize default cache directory
- Use static container names in a pod
- Removed `networking.k8s.io/v1beta1/Ingress` and `extensions/v1beta1/Ingress` support
- Added `.Values.service.ipFamilies` and `.Values.service.ipFamilyPolicy` for service IP family management

## 0.10.14

**Release date:** 2024-08-14

![AppVersion: v1.102.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- add basicAuth support for ServiceMonitor
- fix license volume mount when using statefulset mode

## 0.10.13

**Release date:** 2024-08-01

![AppVersion: v1.102.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.102.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.102.1)

## 0.10.12

**Release date:** 2024-08-01

![AppVersion: v1.102.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix possible template error when `.Values.rbac.namespaced=true`. Thanks to @guptaachin for [the pull request](https://github.com/VictoriaMetrics/helm-charts/pull/1179).

## 0.10.11

**Release date:** 2024-07-23

![AppVersion: v1.102.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.102.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.102.0)

## 0.10.10

**Release date:** 2024-07-08

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- add missing API version and kind for volumeClaimTemplates, see [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1092).

## 0.10.9

**Release date:** 2024-06-14

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Update note**: The VictoriaMetrics components image tag template has been updated. This change introduces `.Values.<component>.image.variant` to specify tag suffixes like `-scratch`, `-cluster`, `-enterprise`. Additionally, you can now omit `.Values.<component>.image.tag` to automatically use the version specified in `.Chart.AppVersion`.

- support specifying image tag suffix like "-enterprise" for VictoriaMetrics components using `.Values.<component>.image.variant`.

## 0.10.8

**Release date:** 2024-05-16

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix lost customized securityContext when introduced new default behavior for securityContext in [pull request](https://github.com/VictoriaMetrics/helm-charts/pull/995).

## 0.10.7

**Release date:** 2024-05-10

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- support disabling default securityContext to keep compatible with platform like openshift, see this [pull request](https://github.com/VictoriaMetrics/helm-charts/pull/995) by @Baboulinet-33 for details.

## 0.10.6

**Release date:** 2024-04-26

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- properly truncate value of `app.kubernetes.io/managed-by` and `app.kubernetes.io/instance` labels in case release name exceeds 63 characters.
- bump version of VM components to [v1.101.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.101.0)

## 0.10.5

**Release date:** 2024-04-16

![AppVersion: v1.100.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.100.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.100.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.100.1)

## 0.10.4

**Release date:** 2024-03-28

![AppVersion: v1.99.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.99.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- added ability to use slice variables in extraArgs (#944)
- support adding `metricRelabelings` for server serviceMonitor (#946)

## 0.10.3

**Release date:** 2024-03-11

![AppVersion: v1.99.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.99.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Actually fix templating of HPA for vmagent. Previously, it was rendered with incorrect `kind` and thus was unusable. See [this pull request](https://github.com/VictoriaMetrics/helm-charts/pull/922).

## 0.10.2

**Release date:** 2024-03-05

![AppVersion: v1.99.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.99.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.99.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.99.0)

## 0.10.1

**Release date:** 2024-03-05

![AppVersion: v1.97.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.97.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix templating of HPA for vmagent. Previously, it was rendered with incorrect `kind` and thus was unusable. See [this pull request](https://github.com/VictoriaMetrics/helm-charts/pull/905).

## 0.10.0

**Release date:** 2024-02-28

![AppVersion: v1.97.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.97.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add ability to use HPA for vmagent. See [this](https://github.com/VictoriaMetrics/helm-charts/pull/863) pull request.

## 0.9.17

**Release date:** 2024-02-01

![AppVersion: v1.97.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.97.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.97.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.97.1)

## 0.9.16

**Release date:** 2023-12-20

![AppVersion: v1.96.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.96.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Add init containers for deployment and statefulset. See [#806](https://github.com/VictoriaMetrics/helm-charts/pull/806) by @MemberIT.

## 0.9.15

**Release date:** 2023-12-13

![AppVersion: v1.96.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.96.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fix configuration of volume mount for license key referenced by using secret.

## 0.9.14

**Release date:** 2023-12-12

![AppVersion: v1.96.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.96.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.96.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.96.0)

## 0.9.13

**Release date:** 2023-11-16

![AppVersion: v1.95.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.95.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.95.1](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.95.1)

## 0.9.12

**Release date:** 2023-11-15

![AppVersion: v1.95.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.95.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.95.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.95.0)

## 0.9.11

**Release date:** 2023-10-04

![AppVersion: v1.94.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.94.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of VM components to [v1.94.0](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.94.0)
- Add support of providing enterprise license key for VictoriaMetrics enterprise. See [these docs](https://docs.victoriametrics.com/victoriametrics/enterprise/) for details.

## 0.9.10

**Release date:** 2023-09-21

![AppVersion: v1.93.5](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.5&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of VM components to [v1.93.5](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.5)

## 0.9.9

**Release date:** 2023-09-11

![AppVersion: v1.93.4](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.4&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of VM components to [v1.93.4](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.93.4)

## 0.9.8

**Release date:** 2023-09-04

![AppVersion: v1.93.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump version of vmagent to `v1.93.3`

## 0.9.6

**Release date:** 2023-08-30

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- fix `honor_timestamps` field for cadvisor scrape job (#626)

## 0.9.5

**Release date:** 2023-08-24

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Disable `honorTimestamps` for cadvisor scrape job by default (#617)

## 0.9.4

**Release date:** 2023-08-23

![AppVersion: v1.93.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.93.0 to v1.93.1

## 0.9.3

**Release date:** 2023-08-12

![AppVersion: v1.93.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.93.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.92.1 to v1.93.0

## 0.9.2

**Release date:** 2023-07-28

![AppVersion: v1.92.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.92.0 to v1.92.1 (#599)

## 0.9.1

**Release date:** 2023-07-27

![AppVersion: v1.92.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.92.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Update VictoriaMetrics components from v1.91.3 to v1.92.0
- make package merge gen-docs

## 0.9.0

**Release date:** 2023-07-13

![AppVersion: v1.91.3](https://img.shields.io/static/v1?label=AppVersion&message=v1.91.3&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- bump version of agent, alert, auth, cluster, single
- feat(vmagent): Add support for topologySpreadConstraints field (#583)
- Feat: Add custom objects to vma helm charts (#558)
- fix(vmagent): Use endpoints instead of endpointslices on kubernetes-apiservers (#574)
