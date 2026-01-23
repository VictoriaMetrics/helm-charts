## Next release

- TODO

## 0.2.6

**Release date:** 12 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1431)

- support extraArgs parameter for additional command line arguments
- renamed `collector` container to `vlagent`
- use value from `.Values.extraArgs.tmpDataPath` as a most mount path

## 0.2.5

**Release date:** 10 Jan 2026

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1431)

- add ability to configure license for VictoriaLogs enterprise. See [#2649](https://github.com/VictoriaMetrics/helm-charts/issues/2649).

## 0.2.4

**Release date:** 26 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.1](https://img.shields.io/badge/v1.43.1-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1431)

- bump vlagent version to [v1.43.1](https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/v1.43.1).

## 0.2.3

**Release date:** 26 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- allow overriding the default `remoteWrite.url` path by specifying a non-empty value other than `/` for the `remoteWrite.url` field

## 0.2.2

**Release date:** 25 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- removed unneeded `remoteWrite.tmpDataPath`

## 0.2.1

**Release date:** 25 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- moved all collector-specific properties to `collector` section. List of moved properties: `msgField`, `timeField`, `includeNodeAnnotations`, `includePodAnnotations`, `includePodLabels`, `includeNodeAnnotations` and `excludeFilter`. Old properties are supported as well.

## 0.2.0

**Release date:** 24 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0) ![AppVersion: v1.43.0](https://img.shields.io/badge/v1.43.0-success?logo=VictoriaMetrics&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fchangelog%2F%23v1430)

- `.Values.remoteWrite[*].basicAuth` section is no longer supported. Chart installation will fail if it's set
- moved management of remote write parameters, that set headers to `.Values.remoteWrite[*].headers`. `.Values.remoteWrite` parameters were renamed:
  * `.Values.remoteWrite[*].accountID` => `.Values.remoteWrite[*].headers.AccountID`
  * `.Values.remoteWrite[*].projectID` => `.Values.remoteWrite[*].headers.ProjectID`
  * `.Values.remoteWrite[*].ignoreFields` => `.Values.remoteWrite[*].headers.VL-Ignore-Fields`
  * `.Values.remoteWrite[*].extraFields` => `.Values.remoteWrite[*].headers.VL-Extra-Fields`
- replaced `.Values.remoteWrite[*].tls` section with parameters that are equal to VLAgent cmd flag names: `.Values.remoteWrite[*].tlsCAFile` and `.Values.remoteWrite[*].tlsInsecureSkipVerify`.
- switched from vector to vlagent
- support `includeNodeAnnotations`, `includePodAnnotations`, `includePodLabels`, `includeNodeAnnotations` and `excludeFilter` parameters

## 0.1.7

**Release date:** 23 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- TODO

## 0.1.6

**Release date:** 23 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- use common template for args generation

## 0.1.5

**Release date:** 22 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- updated native endpoint from `/internal/insert` to `/insert/native`

## 0.1.4

**Release date:** 20 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- do not ignore imagePullSecrets

## 0.1.3

**Release date:** 20 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- update common chart dependency: 0.0.42 -> 0.0.45

## 0.1.2

**Release date:** 01 Dec 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Explicitly define namespace for namespaced resources. See [#2578](https://github.com/VictoriaMetrics/helm-charts/issues/2578).
- Bump Vector version to [v0.51.1](https://vector.dev/releases/0.51.1/).

## 0.1.1

**Release date:** 20 Nov 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Add support for globally configurable `timeField` and `msgField` parameters that apply across all remoteWrite destinations. Configure via `timeField` and `msgField` in values.yaml.

## 0.1.0

**Release date:** 04 Nov 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

**Update note**: All resources that are managed by chart will be recreated due to changes in naming and labels.

- Bump Vector version to [v0.51.0](https://vector.dev/releases/0.51.0/).
- replace chart's template for fullname generation with common's `vm.fullname`

## 0.0.5

**Release date:** 16 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Bump Vector version to [v0.49.0](https://vector.dev/releases/0.49.0/).
- Switch to alpine-based build. See [#2429](https://github.com/VictoriaMetrics/helm-charts/issues/2429) for details.

## 0.0.4

**Release date:** 10 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- minor refactoring

## 0.0.3

**Release date:** 10 Sep 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- Added support for configurable `msgField` in `values.yaml` to extend `VL-Msg-Field` beyond the default `message`.

## 0.0.2

**Release date:** 27 Aug 2025

![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-informational?color=informational&logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)

- trigger OCI release

## 0.0.1

**Release date:**

![Helm: v3](https://img.shields.io/badge/Helm-v3-informational?color=informational&logo=helm)

* charts/victoria-logs-collector: add new chart
