# CHANGELOG for `victoria-metrics-common` helm-chart

## Next release

- TODO

## 0.0.2

**Release date:** 2024-08-23

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added `vm.port.from.flag` template to extract port from cmd flag listen address.

## 0.0.1

**Release date:** 2024-08-15

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added `vm.enterprise.only` template to fail rendering if required license arguments weren't set.
- Added `vm.image` template that introduces common chart logic of how to build image name from application variables.
- Added `vm.ingress.port` template to render properly tngress port configuration depending on args type.
- Added `vm.probe.*` templates to render probes params consistently across all templates.
