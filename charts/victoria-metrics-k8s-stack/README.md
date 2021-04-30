# Helm Chart For Victoria Metrics kubernetes monitoring stack.

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square)

Kubernetes monitoring on VictoriaMetrics stack. Includes VictoriaMetrics Operator, Grafana dashboards, ServiceScrapes and VMRules

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* Add dependency chart repositories

```console
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ksm https://kubernetes.github.io/kube-state-metrics
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

* PV support on underlying infrastructure.

# Upgrade guide

```console
$ helm upgrade [RELEASE_NAME] vm/victoria-metrics-k8s-stack
```

With Helm v3, CRDs created by this chart are not updated by default and should be manually updated.
Consult also the [Helm Documentation on CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions).

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

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
| alertmanager.config.global.resolve_timeout | string | `"5m"` |  |
| alertmanager.config.global.slack_api_url | string | `"http://slack:30500/"` |  |
| alertmanager.config.receivers[0].name | string | `"slack-monitoring"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].text | string | `"Runbook :green_book:"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].type | string | `"button"` |  |
| alertmanager.config.receivers[0].slack_configs[0].actions[0].url | string | `"{{ (index .Alerts 0).Annotations.runbook }}"` |  |
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
| alertmanager.config.receivers[1].slack_configs[0].channel | string | `"#{{- template \"slack.monzo.code_owner_channel\" . -}}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].color | string | `"{{ template \"slack.monzo.color\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].icon_emoji | string | `"{{ template \"slack.monzo.icon_emoji\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].send_resolved | bool | `true` |  |
| alertmanager.config.receivers[1].slack_configs[0].text | string | `"{{ template \"slack.monzo.text\" . }}"` |  |
| alertmanager.config.receivers[1].slack_configs[0].title | string | `"{{ template \"slack.monzo.title\" . }}"` |  |
| alertmanager.config.route.group_by[0] | string | `"job"` |  |
| alertmanager.config.route.group_interval | string | `"5m"` |  |
| alertmanager.config.route.group_wait | string | `"30s"` |  |
| alertmanager.config.route.receiver | string | `"slack-monitoring"` |  |
| alertmanager.config.route.repeat_interval | string | `"12h"` |  |
| alertmanager.config.route.routes[0].match_re.code_owner | string | `".+"` |  |
| alertmanager.config.route.routes[0].routes[0].continue | bool | `true` |  |
| alertmanager.config.route.routes[0].routes[0].match.severity | string | `"info|warning|critical"` |  |
| alertmanager.config.route.routes[0].routes[0].receiver | string | `"slack-code-owners"` |  |
| alertmanager.config.route.routes[1].continue | bool | `true` |  |
| alertmanager.config.route.routes[1].match_re.severity | string | `"info|warning|critical"` |  |
| alertmanager.config.route.routes[1].receiver | string | `"slack-monitoring"` |  |
| alertmanager.config.templates[0] | string | `"/etc/vm/configs/**/*.tmpl"` |  |
| alertmanager.enabled | bool | `true` |  |
| alertmanager.ingress.enabled | bool | `false` |  |
| alertmanager.ingress.hosts | list | `[]` |  |
| alertmanager.ingress.paths | list | `[]` |  |
| alertmanager.monzoTemplate.enabled | bool | `true` |  |
| alertmanager.spec.externalURL | string | `""` |  |
| alertmanager.spec.routePrefix | string | `"/"` |  |
| coreDns.enabled | bool | `true` |  |
| coreDns.service.enabled | bool | `true` |  |
| coreDns.service.port | int | `9153` |  |
| coreDns.service.targetPort | int | `9153` |  |
| coreDns.vmServiceScrape.enabled | bool | `true` |  |
| coreDns.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| coreDns.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics"` |  |
| defaultRules.additionalRuleLabels | object | `{}` |  |
| defaultRules.annotations | object | `{}` |  |
| defaultRules.appNamespacesTarget | string | `".*"` |  |
| defaultRules.create | bool | `true` |  |
| defaultRules.labels | object | `{}` |  |
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
| defaultRules.runbookUrl | string | `"https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#"` |  |
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
| grafana.dashboards.default.victoriametrics.url | string | `"https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics.json"` |  |
| grafana.dashboards.default.vmagent.url | string | `"https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmagent.json"` |  |
| grafana.defaultDashboardsEnabled | bool | `true` |  |
| grafana.enabled | bool | `true` |  |
| grafana.sidecar.dashboards.enabled | bool | `true` |  |
| grafana.sidecar.datasources.createVMReplicasDatasources | bool | `false` |  |
| grafana.sidecar.datasources.enabled | bool | `true` |  |
| grafana.vmServiceScrape.enabled | bool | `true` |  |
| grafana.vmServiceScrape.spec | object | `{}` |  |
| kube-state-metrics.enabled | bool | `true` |  |
| kube-state-metrics.vmServiceScrape.spec | object | `{}` |  |
| kubeApiServer.enabled | bool | `true` |  |
| kubeApiServer.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeApiServer.spec.endpoints[0].port | string | `"https"` |  |
| kubeApiServer.spec.endpoints[0].scheme | string | `"https"` |  |
| kubeApiServer.spec.endpoints[0].tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubeApiServer.spec.endpoints[0].tlsConfig.serverName | string | `"kubernetes"` |  |
| kubeApiServer.spec.jobLabel | string | `"component"` |  |
| kubeApiServer.spec.namespaceSelector.matchNames[0] | string | `"default"` |  |
| kubeApiServer.spec.selector.matchLabels.component | string | `"apiserver"` |  |
| kubeApiServer.spec.selector.matchLabels.provider | string | `"kubernetes"` |  |
| kubeControllerManager.enabled | bool | `true` |  |
| kubeControllerManager.endpoints | list | `[]` |  |
| kubeControllerManager.service.enabled | bool | `true` |  |
| kubeControllerManager.service.port | int | `10252` |  |
| kubeControllerManager.service.targetPort | int | `10252` |  |
| kubeControllerManager.vmServiceScrape.enabled | bool | `true` |  |
| kubeControllerManager.vmServiceScrape.spec.endpoints[0].bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubeControllerManager.vmServiceScrape.spec.endpoints[0].port | string | `"http-metrics"` |  |
| kubeControllerManager.vmServiceScrape.spec.endpoints[0].scheme | string | `"https"` |  |
| kubeControllerManager.vmServiceScrape.spec.endpoints[0].tlsConfig.caFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| kubeControllerManager.vmServiceScrape.spec.endpoints[0].tlsConfig.serverName | string | `"kubernetes"` |  |
| kubeControllerManager.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
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
| kubelet.cadvisor | bool | `true` |  |
| kubelet.enabled | bool | `true` |  |
| kubelet.probes | bool | `true` |  |
| kubelet.spec.bearerTokenFile | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| kubelet.spec.honorLabels | bool | `true` |  |
| kubelet.spec.interval | string | `"30s"` |  |
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
| operator.cleanupCRD | bool | `true` |  |
| operator.cleanupSA.create | bool | `true` |  |
| operator.cleanupSA.name | string | `""` |  |
| operator.kubectlImage.pullPolicy | string | `"IfNotPresent"` |  |
| operator.kubectlImage.repository | string | `"bitnami/kubectl"` |  |
| operator.kubectlImage.tag | float | `1.16` |  |
| prometheus-node-exporter.enabled | bool | `true` |  |
| prometheus-node-exporter.extraArgs[0] | string | `"--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)"` |  |
| prometheus-node-exporter.extraArgs[1] | string | `"--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"` |  |
| prometheus-node-exporter.podLabels.jobLabel | string | `"node-exporter"` |  |
| prometheus-node-exporter.vmServiceScrape.enabled | bool | `true` |  |
| prometheus-node-exporter.vmServiceScrape.spec.jobLabel | string | `"jobLabel"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| victoria-metrics-operator.createCRD | bool | `false` |  |
| victoria-metrics-operator.operator.disable_promethues_converter | bool | `true` | By default, operator converts prometheus-operator objects. |
| vmagent.enabled | bool | `true` |  |
| vmagent.spec.externalLabels.cluster | string | `"cluster-name"` |  |
| vmagent.spec.scrapeInterval | string | `"25s"` |  |
| vmalert.enabled | bool | `true` |  |
| vmalert.spec.evaluationInterval | string | `"15s"` |  |
| vmalert.spec.externalLabels.cluster | string | `"cluster-name"` |  |
| vmsingle.enabled | bool | `true` |  |
| vmsingle.spec.replicaCount | int | `1` |  |
| vmsingle.spec.retentionPeriod | string | `"14"` |  |