# Helm Chart For Victoria Metrics kubernetes monitoring stack.

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.9.8](https://img.shields.io/badge/Version-0.9.8-informational?style=flat-square)

Kubernetes monitoring on VictoriaMetrics stack. Includes VictoriaMetrics Operator, Grafana dashboards, ServiceScrapes and VMRules

# Title
* [Prerequisites](#Prerequisites)
* [Dependencies](#Dependencies)
* [Quick Start](#How-to-install)
* [Uninstall](#How-to-uninstall)
* [Version Upgrade](#Upgrade-guide)
* [Troubleshooting](#Troubleshooting)
* [Values](#Parameters)

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* Add dependency chart repositories

```console
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

* PV support on underlying infrastructure.

# Chart Details

This chart will do the following:

* Rollout victoria metrics operator, grafana, prometheus-node-exporter and kube-state-metrics helm charts
* Create VMSingle, VMAgent, VMAlert, VMAlertManager CRDs
* Configure Grafana for VictoriaMetrics datasource
* Configure ServiceScrapes for Node Exporter, kube-state-metrics and various kubernetes metrics
* Install Grafana dashboards for kubernetes monitoring based on [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)

## Dependencies

By default this chart installs additional, dependent charts:

- [VictoriaMetrics/victoria-metrics-operator](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-operator)
- [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/master/charts/kube-state-metrics)
- [prometheus-community/prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
- [grafana/grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

> ATTENTION !!! Default values are inherited from helm charts declared as a dependency in the Chart.yaml file. If you want to change the default values that are inherited, access the documentation and the values.yaml file for each chart to understand the content and create a customized values.yaml file for your need.

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-k8s-stack`` chart available to installation:

##### for helm v3

```console
helm search repo vm/victoria-metrics-k8s-stack -l
```

Export default values of ``victoria-metrics-k8s-stack`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-k8s-stack > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install [RELEASE_NAME] vm/victoria-metrics-k8s-stack -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

##### for helm v3

```console
helm install [RELEASE_NAME] vm/victoria-metrics-k8s-stack -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'victoria-metrics'
```

# How to uninstall

Remove application with command.

```console
helm uninstall [RELEASE_NAME] -n NAMESPACE
```
This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

CRDs created by this chart are not removed by default and should be manually cleaned up:

```console
kubectl get crd | grep victoriametrics.com | awk '{print $1 }' | xargs -i kubectl delete crd {}
```

# Troubleshooting

- If you cannot install helm chart with error `configmap already exist`. It could happen because of name collisions, if you set too long release name.
  Kubernetes by default, allows only 63 symbols at resource names and all resource names are trimmed by helm to 63 symbols.
  To mitigate it, use shorter name for helm chart release name, like:
```bash
# stack - is short enough
helm upgrade -i stack vm/victoria-metrics-k8s-stack
```
  Or use override for helm chart release name:
```bash
helm upgrade -i some-very-long-name vm/victoria-metrics-k8s-stack --set fullnameOverride=stack
```

# Upgrade guide

Usually, helm upgrade doesn't requires manual actions. But release with CRD update must be patched manually with kubectl.
 Just execute command:
```console
$ helm upgrade [RELEASE_NAME] vm/victoria-metrics-k8s-stack
```
 All CRD manual actions upgrades listed below:

### Upgrade to 0.6.0

 All `CRD` must be update to the lastest version with command:

```bash
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/helm-charts/master/charts/victoria-metrics-k8s-stack/crds/crd.yaml

```

### Upgrade to 0.4.0

 All `CRD` must be update to `v1` version with command:

```bash
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/helm-charts/master/charts/victoria-metrics-k8s-stack/crds/crd.yaml

```

### Upgrade from 0.2.8 to 0.2.9

 Update `VMAgent` crd

command:
```bash
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.16.0/config/crd/bases/operator.victoriametrics.com_vmagents.yaml
```

 ### Upgrade from 0.2.5 to 0.2.6

New CRD added to operator - `VMUser` and `VMAuth`, new fields added to exist crd.
Manual commands:
```bash
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmusers.yaml
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmauths.yaml
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmalerts.yaml
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmagents.yaml
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmsingles.yaml
kubectl apply -f https://raw.githubusercontent.com/VictoriaMetrics/operator/v0.15.0/config/crd/bases/operator.victoriametrics.com_vmclusters.yaml
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-k8s-stack

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-k8s-stack/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVictoriaMetricsMap | string | `nil` |  |
| alertmanager.annotations | object | `{}` |  |
| alertmanager.config.global.resolve_timeout | string | `"5m"` |  |
| alertmanager.config.global.slack_api_url | string | `"http://slack:30500/"` |  |
| alertmanager.config.receivers[0].name | string | `"slack-monitoring"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].text | string | `"Runbook :green_book:"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].url | string | `"{{ (index .Alerts 0).Annotations.runbook_url }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[1].text | string | `"Query :mag:"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[1].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[1].url | string | `"{{ (index .Alerts 0).GeneratorURL }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[2].text | string | `"Dashboard :grafana:"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[2].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[2].url | string | `"{{ (index .Alerts 0).Annotations.dashboard }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[3].text | string | `"Silence :no_bell:"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[3].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[3].url | string | `"{{ template \"__alert_silence_link\" . }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[4].text | string | `"{{ template \"slack.monzo.link_button_text\" . }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[4].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[4].url | string | `"{{ .CommonAnnotations.link_url }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].channel | string | `"#channel"` |  |
| alertmanager.config.receivers[0].slack_configs[0].color | string | `"{{ template \"slack.monzo.color\" . }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].icon_emoji | string | `"{{ template \"slack.monzo.icon_emoji\" . }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].send_resolved | bool | `true` |  |
| alertmanager.config.receivers[0].slack_configs[0].text | string | `"{{ template \"slack.monzo.text\" . }}"` |  |
| alertmanager.config.receivers[0].slack_configs[0].title | string | `"{{ template \"slack.monzo.title\" . }}"` |  |
| alertmanager.config.receivers[1].name | string | `"slack-code-owners"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[0].text | string | `"Runbook :green_book:"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[0].type | string | `"button"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[0].url | string | `"{{ (index .Alerts 0).Annotations.runbook }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[1].text | string | `"Query :mag:"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[1].type | string | `"button"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[1].url | string | `"{{ (index .Alerts 0).GeneratorURL }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[2].text | string | `"Dashboard :grafana:"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[2].type | string | `"button"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[2].url | string | `"{{ (index .Alerts 0).Annotations.dashboard }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[3].text | string | `"Silence :no_bell:"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[3].type | string | `"button"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[3].url | string | `"{{ template \"__alert_silence_link\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[4].text | string | `"{{ template \"slack.monzo.link_button_text\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[4].type | string | `"button"` |  |
| alertmanager.config.receivers[1].slack_configs[0].actions[4].url | string | `"{{ .CommonAnnotations.link_url }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].channel | string | `"#{{ .CommonLabels.code_owner_channel }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].color | string | `"{{ template \"slack.monzo.color\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].icon_emoji | string | `"{{ template \"slack.monzo.icon_emoji\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].send_resolved | bool | `true` |  |
| alertmanager.config.receivers[1].slack_configs[0].text | string | `"{{ template \"slack.monzo.text\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].title | string | `"{{ template \"slack.monzo.title\" . }}"` |  |
| alertmanager.config.route.group_by[0] | string | `"alertgroup"` |  |
| alertmanager.config.route.group_by[1] | string | `"job"` |  |
| alertmanager.config.route.group_interval | string | `"5m"` |  |
| alertmanager.config.route.group_wait | string | `"30s"` |  |
| alertmanager.config.route.receiver | string | `"slack-monitoring"` |  |
| alertmanager.config.route.repeat_interval | string | `"12h"` |  |
| alertmanager.config.route.routes[0].group_by[0] | string | `"code_owner_channel"` |  |
| alertmanager.config.route.routes[0].group_by[1] | string | `"alertgroup"` |  |
| alertmanager.config.route.routes[0].group_by[2] | string | `"job"` |  |
| alertmanager.config.route.routes[0].matchers[0] | string | `"code_owner_channel!=\"\""` |  |
| alertmanager.config.route.routes[0].matchers[1] | string | `"severity=~\"info|warning|critical\""` |  |
| alertmanager.config.route.routes[0].receiver | string | `"slack-code-owners"` |  |
| alertmanager.config.route.routes[1].continue | bool | `true` |  |
| alertmanager.config.route.routes[1].matchers[0] | string | `"severity=~\"info|warning|critical\""` |  |
| alertmanager.config.route.routes[1].receiver | string | `"slack-monitoring"` |  |
| alertmanager.config.templates[0] | string | `"/etc/vm/configs/**/*.tmpl"` |  |
| alertmanager.enabled | bool | `true` |  |
| alertmanager.ingress.annotations | object | `{}` |  |
| alertmanager.ingress.enabled | bool | `false` |  |
| alertmanager.ingress.extraPaths | list | `[]` |  |
| alertmanager.ingress.hosts[0] | string | `"alertmanager.domain.com"` |  |
| alertmanager.ingress.labels | object | `{}` |  |
| alertmanager.ingress.path | string | `"/"` |  |
| alertmanager.ingress.pathType | string | `"Prefix"` |  |
| alertmanager.ingress.tls | list | `[]` |  |
| alertmanager.monzoTemplate.enabled | bool | `true` |  |
| alertmanager.spec.externalURL | string | `""` |  |
| alertmanager.spec.image.tag | string | `"v0.23.0"` |  |
| alertmanager.spec.routePrefix | string | `"/"` |  |
| alertmanager.spec.selectAllByDefault | bool | `true` |  |
| alertmanager.templateFiles | object | `{}` |  |
| argocdReleaseOverride | string | `""` | For correct working need set value 'argocdReleaseOverride=$ARGOCD_APP_NAME' |
| coreDns | object | `{"enabled":true,"service":{"enabled":true,"port":9153,"selector":{"k8s-app":"kube-dns"},"targetPort":9153},"vmServiceScrape":{"enabled":true,"spec":{"endpoints":[{"bearerTokenFile":"/var/run/secrets/kubernetes.io/serviceaccount/token","port":"http-metrics"}]}}}` | Component scraping coreDns. Use either this or kubeDns |
| defaultRules.additionalRuleLabels | object | `{}` | Additional labels for PrometheusRule alerts |
| defaultRules.annotations | object | `{}` | Annotations for default rules |
| defaultRules.appNamespacesTarget | string | `".*"` |  |
| defaultRules.create | bool | `true` |  |
| defaultRules.labels | object | `{}` | Labels for default rules |
| defaultRules.rules.alertmanager | bool | `true` |  |
| defaultRules.rules.etcd | bool | `true` |  |
| defaultRules.rules.general | bool | `true` |  |
| defaultRules.rules.k8s | bool | `true` |  |
| defaultRules.rules.kubeApiserver | bool | `true` |  |
| defaultRules.rules.kubeApiserverAvailability | bool | `true` |  |
| defaultRules.rules.kubeApiserverSlos | bool | `true` |  |
| defaultRules.rules.kubePrometheusGeneral | bool | `true` |  |
| defaultRules.rules.kubePrometheusNodeRecording | bool | `true` |  |
| defaultRules.rules.kubeScheduler | bool | `true` |  |
| defaultRules.rules.kubeStateMetrics | bool | `true` |  |
| defaultRules.rules.kubelet | bool | `true` |  |
| defaultRules.rules.kubernetesApps | bool | `true` |  |
| defaultRules.rules.kubernetesResources | bool | `true` |  |
| defaultRules.rules.kubernetesStorage | bool | `true` |  |
| defaultRules.rules.kubernetesSystem | bool | `true` |  |
| defaultRules.rules.network | bool | `true` |  |
| defaultRules.rules.node | bool | `true` |  |
| defaultRules.rules.vmagent | bool | `true` |  |
| defaultRules.rules.vmhealth | bool | `true` |  |
| defaultRules.rules.vmsingle | bool | `true` |  |
| defaultRules.runbookUrl | string | `"https://runbooks.prometheus-operator.dev/runbooks"` | Runbook url prefix for default rules |
| fullnameOverride | string | `""` |  |
| grafana.additionalDataSources | list | `[]` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".apiVersion | int | `1` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].disableDeletion | bool | `false` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].editable | bool | `true` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].folder | string | `""` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].name | string | `"default"` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].options.path | string | `"/var/lib/grafana/dashboards/default"` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].orgId | int | `1` |  |
| grafana.dashboardProviders."dashboardproviders.yaml".providers[0].type | string | `"file"` |  |
| grafana.dashboards.default.nodeexporter.datasource | string | `"VictoriaMetrics"` |  |
| grafana.dashboards.default.nodeexporter.gnetId | int | `1860` |  |
| grafana.dashboards.default.nodeexporter.revision | int | `22` |  |
| grafana.defaultDashboardsEnabled | bool | `true` |  |
| grafana.enabled | bool | `true` |  |
| grafana.forceDeployDatasource | bool | `false` |  |
| grafana.ingress.annotations | object | `{}` |  |
| grafana.ingress.enabled | bool | `false` |  |
| grafana.ingress.extraPaths | list | `[]` |  |
| grafana.ingress.hosts[0] | string | `"grafana.domain.com"` |  |
| grafana.ingress.labels | object | `{}` |  |
| grafana.ingress.path | string | `"/"` |  |
| grafana.ingress.pathType | string | `"Prefix"` |  |
| grafana.ingress.tls | list | `[]` |  |
| grafana.sidecar.dashboards.additionalDashboardAnnotations | object | `{}` |  |
| grafana.sidecar.dashboards.additionalDashboardLabels | object | `{}` |  |
| grafana.sidecar.dashboards.enabled | bool | `true` |  |
| grafana.sidecar.dashboards.multicluster | bool | `false` |  |
| grafana.sidecar.datasources.createVMReplicasDatasources | bool | `false` |  |
| grafana.sidecar.datasources.enabled | bool | `true` |  |
| grafana.sidecar.datasources.jsonData | object | `{}` |  |
| grafana.vmServiceScrape.enabled | bool | `true` |  |
| grafana.vmServiceScrape.spec | object | `{}` |  |
| kube-state-metrics.enabled | bool | `true` |  |
| kube-state-metrics.vmServiceScrape.spec | object | `{}` |  |
| kubeApiServer | object | `{"enabled":true,"spec":{"endpoints":[{"bearerTokenFile":"/var/run/secrets/kubernetes.io/serviceaccount/token","port":"https","scheme":"https","tlsConfig":{"caFile":"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt","serverName":"kubernetes"}}],"jobLabel":"component","namespaceSelector":{"matchNames":["default"]},"selector":{"matchLabels":{"component":"apiserver","provider":"kubernetes"}}}}` | Component scraping the kube api server |
| kubeControllerManager | object | `{"enabled":true,"endpoints":[],"service":{"enabled":true,"port":10252,"targetPort":10252},"vmServiceScrape":{"enabled":true,"spec":{"endpoints":[{"bearerTokenFile":"/var/run/secrets/kubernetes.io/serviceaccount/token","port":"http-metrics","scheme":"https","tlsConfig":{"caFile":"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt","serverName":"kubernetes"}}],"jobLabel":"jobLabel"}}}` | Component scraping the kube controller manager |
| kubeDns.enabled | bool | `false` |  |
| kubeDns.service.dnsmasq.port | int | `10054` |  |
| kubeDns.service.dnsmasq.targetPort | int | `10054` |  |
| kubeDns.service.enabled | bool | `false` |  |
| kubeDns.service.selector.k8s-app | string | `"kube-dns"` |  |
| kubeDns.service.skydns.port | int | `10055` |  |
| kubeDns.service.skydns.targetPort | int | `10055` |  |
| kubeDns.vmServiceScrape.enabled | bool | `true` |  |
| kubeDns.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeDns.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics-dnsmasq"` |  |
| kubeDns.vmServiceScrape.spec.endpoints[1].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeDns.vmServiceScrape.spec.endpoints[1].port | string | `"http-metrics-skydns"` |  |
| kubeEtcd.enabled | bool | `true` |  |
| kubeEtcd.endpoints | list | `[]` |  |
| kubeEtcd.service.enabled | bool | `true` |  |
| kubeEtcd.service.port | int | `2379` |  |
| kubeEtcd.service.targetPort | int | `2379` |  |
| kubeEtcd.vmServiceScrape.enabled | bool | `true` |  |
| kubeEtcd.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeEtcd.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics"` |  |
| kubeEtcd.vmServiceScrape.spec.endpoints[0].scheme | string | `"https"` |  |
| kubeEtcd.vmServiceScrape.spec.endpoints[0].tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubeEtcd.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
| kubeProxy.enabled | bool | `false` |  |
| kubeProxy.endpoints | list | `[]` |  |
| kubeProxy.service.enabled | bool | `true` |  |
| kubeProxy.service.port | int | `10249` |  |
| kubeProxy.service.targetPort | int | `10249` |  |
| kubeProxy.vmServiceScrape.enabled | bool | `true` |  |
| kubeProxy.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeProxy.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics"` |  |
| kubeProxy.vmServiceScrape.spec.endpoints[0].scheme | string | `"https"` |  |
| kubeProxy.vmServiceScrape.spec.endpoints[0].tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubeProxy.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
| kubeScheduler.enabled | bool | `true` |  |
| kubeScheduler.endpoints | list | `[]` |  |
| kubeScheduler.service.enabled | bool | `true` |  |
| kubeScheduler.service.port | int | `10251` |  |
| kubeScheduler.service.targetPort | int | `10251` |  |
| kubeScheduler.vmServiceScrape.enabled | bool | `true` |  |
| kubeScheduler.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeScheduler.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics"` |  |
| kubeScheduler.vmServiceScrape.spec.endpoints[0].scheme | string | `"https"` |  |
| kubeScheduler.vmServiceScrape.spec.endpoints[0].tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubeScheduler.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
| kubelet.cadvisor | bool | `true` | Enable scraping /metrics/cadvisor from kubelet's service |
| kubelet.enabled | bool | `true` |  |
| kubelet.probes | bool | `true` | Enable scraping /metrics/probes from kubelet's service |
| kubelet.spec.bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubelet.spec.honorLabels | bool | `true` |  |
| kubelet.spec.interval | string | `"30s"` |  |
| kubelet.spec.metricRelabelConfigs[0].action | string | `"labeldrop"` |  |
| kubelet.spec.metricRelabelConfigs[0].regex | string | `"(uid)"` |  |
| kubelet.spec.metricRelabelConfigs[1].action | string | `"labeldrop"` |  |
| kubelet.spec.metricRelabelConfigs[1].regex | string | `"(id|name)"` |  |
| kubelet.spec.metricRelabelConfigs[2].action | string | `"drop"` |  |
| kubelet.spec.metricRelabelConfigs[2].regex | string | `"(rest_client_request_duration_seconds_bucket|rest_client_request_duration_seconds_sum|rest_client_request_duration_seconds_count)"` |  |
| kubelet.spec.metricRelabelConfigs[2].source_labels[0] | string | `"__name__"` |  |
| kubelet.spec.relabelConfigs[0].action | string | `"labelmap"` |  |
| kubelet.spec.relabelConfigs[0].regex | string | `"__meta_kubernetes_node_label_(.+)"` |  |
| kubelet.spec.relabelConfigs[1].sourceLabels[0] | string | `"__metrics_path__"` |  |
| kubelet.spec.relabelConfigs[1].targetLabel | string | `"metrics_path"` |  |
| kubelet.spec.relabelConfigs[2].replacement | string | `"kubelet"` |  |
| kubelet.spec.relabelConfigs[2].targetLabel | string | `"job"` |  |
| kubelet.spec.scheme | string | `"https"` |  |
| kubelet.spec.scrapeTimeout | string | `"5s"` |  |
| kubelet.spec.tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubelet.spec.tlsConfig.insecureSkipVerify | bool | `true` |  |
| nameOverride | string | `""` |  |
| operator | object | `{"cleanupCRD":true,"cleanupSA":{"create":true,"name":""},"enabled":true,"kubectlImage":{"pullPolicy":"IfNotPresent","repository":"gcr.io/google_containers/hyperkube","tag":"v1.16.0"}}` | Configures operator CRD |
| operator.cleanupCRD | bool | `true` | Tells helm to remove CRD after chart remove |
| prometheus-node-exporter.enabled | bool | `true` |  |
| prometheus-node-exporter.extraArgs[0] | string | `"--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)"` |  |
| prometheus-node-exporter.extraArgs[1] | string | `"--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"` |  |
| prometheus-node-exporter.podLabels.jobLabel | string | `"node-exporter"` |  |
| prometheus-node-exporter.vmServiceScrape.enabled | bool | `true` |  |
| prometheus-node-exporter.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the fullname template |
| victoria-metrics-operator | object | `{"createCRD":false,"operator":{"disable_prometheus_converter":true}}` | For possible values refer to https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-operator#parameters |
| victoria-metrics-operator.createCRD | bool | `false` | all values for victoria-metrics-operator helm chart can be specified here |
| victoria-metrics-operator.operator.disable_prometheus_converter | bool | `true` | By default, operator converts prometheus-operator objects. |
| vmagent.additionalRemoteWrites | list | `[]` |  |
| vmagent.annotations | object | `{}` |  |
| vmagent.enabled | bool | `true` |  |
| vmagent.ingress.annotations | object | `{}` |  |
| vmagent.ingress.enabled | bool | `false` |  |
| vmagent.ingress.extraPaths | list | `[]` |  |
| vmagent.ingress.hosts[0] | string | `"vmagent.domain.com"` |  |
| vmagent.ingress.labels | object | `{}` |  |
| vmagent.ingress.path | string | `"/"` |  |
| vmagent.ingress.pathType | string | `"Prefix"` |  |
| vmagent.ingress.tls | list | `[]` |  |
| vmagent.spec.externalLabels.cluster | string | `"cluster-name"` |  |
| vmagent.spec.extraArgs."promscrape.streamParse" | string | `"true"` |  |
| vmagent.spec.image.tag | string | `"v1.79.0"` |  |
| vmagent.spec.scrapeInterval | string | `"25s"` |  |
| vmagent.spec.selectAllByDefault | bool | `true` |  |
| vmalert.annotations | object | `{}` |  |
| vmalert.enabled | bool | `true` |  |
| vmalert.ingress.annotations | object | `{}` |  |
| vmalert.ingress.enabled | bool | `false` |  |
| vmalert.ingress.extraPaths | list | `[]` |  |
| vmalert.ingress.hosts[0] | string | `"vmalert.domain.com"` |  |
| vmalert.ingress.labels | object | `{}` |  |
| vmalert.ingress.path | string | `"/"` |  |
| vmalert.ingress.pathType | string | `"Prefix"` |  |
| vmalert.ingress.tls | list | `[]` |  |
| vmalert.spec.evaluationInterval | string | `"15s"` |  |
| vmalert.spec.image.tag | string | `"v1.79.0"` |  |
| vmalert.spec.selectAllByDefault | bool | `true` |  |
| vmalert.templateFiles | object | `{}` |  |
| vmcluster.annotations | object | `{}` |  |
| vmcluster.enabled | bool | `false` |  |
| vmcluster.ingress.insert.annotations | object | `{}` |  |
| vmcluster.ingress.insert.enabled | bool | `false` |  |
| vmcluster.ingress.insert.extraPaths | list | `[]` |  |
| vmcluster.ingress.insert.hosts[0] | string | `"vminsert.domain.com"` |  |
| vmcluster.ingress.insert.labels | object | `{}` |  |
| vmcluster.ingress.insert.path | string | `"/"` |  |
| vmcluster.ingress.insert.pathType | string | `"Prefix"` |  |
| vmcluster.ingress.insert.tls | list | `[]` |  |
| vmcluster.ingress.select.annotations | object | `{}` |  |
| vmcluster.ingress.select.enabled | bool | `false` |  |
| vmcluster.ingress.select.extraPaths | list | `[]` |  |
| vmcluster.ingress.select.hosts[0] | string | `"vmselect.domain.com"` |  |
| vmcluster.ingress.select.labels | object | `{}` |  |
| vmcluster.ingress.select.path | string | `"/"` |  |
| vmcluster.ingress.select.pathType | string | `"Prefix"` |  |
| vmcluster.ingress.select.tls | list | `[]` |  |
| vmcluster.ingress.storage.annotations | object | `{}` |  |
| vmcluster.ingress.storage.enabled | bool | `false` |  |
| vmcluster.ingress.storage.extraPaths | list | `[]` |  |
| vmcluster.ingress.storage.hosts[0] | string | `"vmstorage.domain.com"` |  |
| vmcluster.ingress.storage.labels | object | `{}` |  |
| vmcluster.ingress.storage.path | string | `"/"` |  |
| vmcluster.ingress.storage.pathType | string | `"Prefix"` |  |
| vmcluster.ingress.storage.tls | list | `[]` |  |
| vmcluster.spec.replicationFactor | int | `2` |  |
| vmcluster.spec.retentionPeriod | string | `"14"` |  |
| vmcluster.spec.vminsert.image.tag | string | `"v1.79.0-cluster"` |  |
| vmcluster.spec.vminsert.replicaCount | int | `2` |  |
| vmcluster.spec.vminsert.resources | object | `{}` |  |
| vmcluster.spec.vmselect.cacheMountPath | string | `"/select-cache"` |  |
| vmcluster.spec.vmselect.image.tag | string | `"v1.79.0-cluster"` |  |
| vmcluster.spec.vmselect.replicaCount | int | `2` |  |
| vmcluster.spec.vmselect.resources | object | `{}` |  |
| vmcluster.spec.vmselect.storage.volumeClaimTemplate.spec.resources.requests.storage | string | `"2Gi"` |  |
| vmcluster.spec.vmstorage.image.tag | string | `"v1.79.0-cluster"` |  |
| vmcluster.spec.vmstorage.replicaCount | int | `2` |  |
| vmcluster.spec.vmstorage.resources | object | `{}` |  |
| vmcluster.spec.vmstorage.storage.volumeClaimTemplate.spec.resources.requests.storage | string | `"10Gi"` |  |
| vmcluster.spec.vmstorage.storageDataPath | string | `"/vm-data"` |  |
| vmsingle | object | `{"annotations":{},"enabled":true,"ingress":{"annotations":{},"enabled":false,"extraPaths":[],"hosts":["vmsingle.domain.com"],"labels":{},"path":"/","pathType":"Prefix","tls":[]},"spec":{"image":{"tag":"v1.79.0"},"replicaCount":1,"retentionPeriod":"14","storage":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"20Gi"}}}}}` | Configures vmsingle params |
