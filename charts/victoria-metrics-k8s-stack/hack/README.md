## Thanks
Thanks to [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) community
this scripts was created by them, and we just adopted it for our needs

## [sync_rules.py](sync_rules.py)

This script generates VMRules set from any properly formatted kubernetes yaml based on defined input, splitting rules to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus rules set](https://github.com/prometheus-operator/kube-prometheus/tree/master/manifests/kubernetes-prometheusRule.yaml)
- [etcd-io/website rules set](https://github.com/etcd-io/website/tree/master/content/docs/v3.4.0/etcd-mixin/README.md)


## [sync_grafana_dashboards.py](sync_grafana_dashboards.py)

This script generates grafana dashboards from json files, splitting them to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus dashboards](https://github.com/prometheus-operator/kube-prometheus/tree/master/manifests/grafana-deployment.yaml)
- [etcd-io/website dashboard](https://etcd.io/docs/v3.1/op-guide/grafana.json)
