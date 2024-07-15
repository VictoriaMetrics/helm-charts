# CHANGELOG for `victoria-metrics-distributed` helm-chart

## Next release

- TODO

## 0.2.0

**Release date:** 2024-07-15

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Breaking change: disable multitenancy mode by default, see how to enable it in https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-distributed#how-to-use-multitenancy. See [this pull request](https://github.com/VictoriaMetrics/helm-charts/pull/1137) for details.

## 0.1.1

**Release date:** 2024-06-27

![AppVersion: v1.101.0](https://img.shields.io/static/v1?label=AppVersion&message=v1.101.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- [vmauth-read-balancer-zone]: change server from vmselect pod enumeration to service DNS address, so it still work when vmselect scales.
