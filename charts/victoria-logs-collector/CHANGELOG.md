## Next release

- TODO

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
