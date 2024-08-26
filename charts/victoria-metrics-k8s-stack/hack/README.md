## Thanks
Thanks to [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) community
this scripts was created by them, and we just adopted it for our needs

## [sync_rules.py](sync_rules.py)

This script generates VMRules set from any properly formatted kubernetes yaml based on defined input, splitting rules to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus rules set](https://github.com/prometheus-operator/kube-prometheus/tree/master/manifests)
- [VictoriaMetrics/VictoriaMetrics](https://github.com/VictoriaMetrics/VictoriaMetrics/tree/master/deployment/docker)
- [etcd-io/website rules set](https://github.com/etcd-io/website/blob/main/content/en/docs/v3.4/op-guide/etcd3_alert.rules.yml)


## [sync_dashboards.py](sync_dashboards.py)

This script generates dashboards from json files, splitting them to separate files based on group name.

Currently following imported:

- [VictoriaMetrics/VictoriaMetrics](https://github.com/VictoriaMetrics/VictoriaMetrics/tree/master/dashboards)
- [dotdc/grafana-dashboards-kubernetes](https://github.com/dotdc/grafana-dashboards-kubernetes/tree/master/dashboards)
- [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/grafana-dashboardDefinitions.yaml)
