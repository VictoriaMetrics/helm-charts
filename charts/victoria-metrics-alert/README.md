# Helm Chart For Victoria Metrics Alert.

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.10.0](https://img.shields.io/badge/Version-0.10.0-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-alert)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)

Victoria Metrics Alert - executes a list of given MetricsQL expressions (rules) and sends alerts to Alert Manager.

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-alert`` chart available to installation:

```console
helm search repo vm/victoria-metrics-alert -l
```

Export default values of ``victoria-metrics-alert`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-alert > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmalert vm/victoria-metrics-alert -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmalert vm/victoria-metrics-alert -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'alert'
```

Get the application by running this command:

```console
helm list -f vmalert -n NAMESPACE
```

See the history of versions of ``vmalert`` application with command.

```console
helm history vmalert -n NAMESPACE
```

## HA configuration for Alertmanager

There is no option on this chart to set up Alertmanager with [HA mode](https://github.com/prometheus/alertmanager#high-availability).
To enable the HA configuration, you can use:
- [VictoriaMetrics Operator](https://docs.victoriametrics.com/operator/VictoriaMetrics-Operator.html)
- official [Alertmanager Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)

## How to uninstall

Remove application with command.

```console
helm uninstall vmalert -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-alert

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-alert/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertmanager.baseURL | string | `""` |  |
| alertmanager.baseURLPrefix | string | `""` |  |
| alertmanager.config.global.resolve_timeout | string | `"5m"` |  |
| alertmanager.config.receivers[0].name | string | `"devnull"` |  |
| alertmanager.config.route.group_by[0] | string | `"alertname"` |  |
| alertmanager.config.route.group_interval | string | `"10s"` |  |
| alertmanager.config.route.group_wait | string | `"30s"` |  |
| alertmanager.config.route.receiver | string | `"devnull"` |  |
| alertmanager.config.route.repeat_interval | string | `"24h"` |  |
| alertmanager.configMap | string | `""` |  |
| alertmanager.emptyDir | object | `{}` |  |
| alertmanager.enabled | bool | `false` |  |
| alertmanager.envFrom | list | `[]` |  |
| alertmanager.extraArgs | object | `{}` |  |
| alertmanager.extraContainers | list | `[]` |  |
| alertmanager.extraHostPathMounts | list | `[]` |  |
| alertmanager.extraVolumeMounts | list | `[]` |  |
| alertmanager.extraVolumes | list | `[]` |  |
| alertmanager.image.registry | string | `""` |  |
| alertmanager.image.repository | string | `"prom/alertmanager"` |  |
| alertmanager.image.tag | string | `"v0.25.0"` |  |
| alertmanager.imagePullSecrets | list | `[]` |  |
| alertmanager.ingress.annotations | object | `{}` |  |
| alertmanager.ingress.enabled | bool | `false` |  |
| alertmanager.ingress.extraLabels | object | `{}` |  |
| alertmanager.ingress.hosts | list | `[]` |  |
| alertmanager.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| alertmanager.ingress.tls | list | `[]` |  |
| alertmanager.listenAddress | string | `"0.0.0.0:9093"` |  |
| alertmanager.nodeSelector | object | `{}` |  |
| alertmanager.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| alertmanager.persistentVolume.annotations | object | `{}` | Persistant volume annotations |
| alertmanager.persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for alertmanager component. Empty dir if false |
| alertmanager.persistentVolume.existingClaim | string | `""` | Existing Claim name. If defined, PVC must be created manually before volume will be bound |
| alertmanager.persistentVolume.mountPath | string | `"/data"` | Mount path. Alertmanager data Persistent Volume mount root path. |
| alertmanager.persistentVolume.size | string | `"50Mi"` | Size of the volume. Better to set the same as resource limit memory property. |
| alertmanager.persistentVolume.storageClassName | string | `""` | StorageClass to use for persistent volume. Requires alertmanager.persistentVolume.enabled: true. If defined, PVC created automatically |
| alertmanager.persistentVolume.subPath | string | `""` | Mount subpath |
| alertmanager.podMetadata.annotations | object | `{}` |  |
| alertmanager.podMetadata.labels | object | `{}` |  |
| alertmanager.podSecurityContext.enabled | bool | `false` |  |
| alertmanager.priorityClassName | string | `""` |  |
| alertmanager.probe.liveness.httpGet.path | string | `"{{ ternary \"\" .baseURLPrefix (empty .baseURLPrefix) }}/-/healthy"` |  |
| alertmanager.probe.liveness.httpGet.port | string | `"web"` |  |
| alertmanager.probe.readiness.httpGet.path | string | `"{{ ternary \"\" .baseURLPrefix (empty .baseURLPrefix) }}/-/ready"` |  |
| alertmanager.probe.readiness.httpGet.port | string | `"web"` |  |
| alertmanager.probe.startup.httpGet.path | string | `"{{ ternary \"\" .baseURLPrefix (empty .baseURLPrefix) }}/-/ready"` |  |
| alertmanager.probe.startup.httpGet.port | string | `"web"` |  |
| alertmanager.resources | object | `{}` |  |
| alertmanager.retention | string | `"120h"` |  |
| alertmanager.securityContext.enabled | bool | `false` |  |
| alertmanager.service.annotations | object | `{}` |  |
| alertmanager.service.clusterIP | string | `""` |  |
| alertmanager.service.externalIPs | list | `[]` | Ref: https://kubernetes.io/docs/user-guide/services/#external-ips |
| alertmanager.service.externalTrafficPolicy | string | `""` | Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| alertmanager.service.healthCheckNodePort | string | `""` |  |
| alertmanager.service.ipFamilies | list | `[]` |  |
| alertmanager.service.ipFamilyPolicy | string | `""` |  |
| alertmanager.service.labels | object | `{}` |  |
| alertmanager.service.loadBalancerIP | string | `""` |  |
| alertmanager.service.loadBalancerSourceRanges | list | `[]` |  |
| alertmanager.service.nodePort | string | `""` | if you want to force a specific nodePort. Must be use with service.type=NodePort |
| alertmanager.service.port | int | `9093` |  |
| alertmanager.service.servicePort | int | `8880` |  |
| alertmanager.service.type | string | `"ClusterIP"` |  |
| alertmanager.templates | object | `{}` |  |
| alertmanager.tolerations | list | `[]` |  |
| extraObjects | list | `[]` | Add extra specs dynamically to this chart |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| license | object | `{"key":"","secret":{"key":"","name":""}}` | Enterprise license key configuration for VictoriaMetrics enterprise. Required only for VictoriaMetrics enterprise. Documentation - https://docs.victoriametrics.com/enterprise.html, for more information, visit https://victoriametrics.com/products/enterprise/ . To request a trial license, go to https://victoriametrics.com/products/enterprise/trial/ Supported starting from VictoriaMetrics v1.94.0 |
| license.key | string | `""` | License key |
| license.secret | object | `{"key":"","name":""}` | Use existing secret with license key |
| license.secret.key | string | `""` | Key in secret with license key |
| license.secret.name | string | `""` | Existing secret name |
| rbac.annotations | object | `{}` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.namespaced | bool | `false` |  |
| server.affinity | object | `{}` |  |
| server.annotations | object | `{}` |  |
| server.config.alerts.groups | list | `[]` |  |
| server.configMap | string | `""` |  |
| server.datasource.basicAuth | object | `{"password":"","username":""}` | Basic auth for datasource |
| server.datasource.bearer.token | string | `""` | Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string |
| server.datasource.bearer.tokenFile | string | `""` | Token Auth file with Bearer token. You can use one of token or tokenFile |
| server.datasource.url | string | `""` |  |
| server.enabled | bool | `true` |  |
| server.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| server.envFrom | list | `[]` |  |
| server.extraArgs."envflag.enable" | string | `"true"` |  |
| server.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| server.extraArgs.loggerFormat | string | `"json"` |  |
| server.extraContainers | list | `[]` | Additional containers to run in the same pod |
| server.extraHostPathMounts | list | `[]` | Additional hostPath mounts |
| server.extraVolumeMounts | list | `[]` | Extra Volume Mounts for the container |
| server.extraVolumes | list | `[]` | Extra Volumes for the pod |
| server.fullnameOverride | string | `""` |  |
| server.image.pullPolicy | string | `"IfNotPresent"` |  |
| server.image.registry | string | `""` |  |
| server.image.repository | string | `"victoriametrics/vmalert"` |  |
| server.image.tag | string | `""` |  |
| server.image.variant | string | `""` |  |
| server.imagePullSecrets | list | `[]` |  |
| server.ingress.annotations | object | `{}` |  |
| server.ingress.enabled | bool | `false` |  |
| server.ingress.extraLabels | object | `{}` |  |
| server.ingress.hosts | list | `[]` |  |
| server.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| server.ingress.tls | list | `[]` |  |
| server.labels | object | `{}` |  |
| server.minReadySeconds | int | `0` |  |
| server.name | string | `"server"` |  |
| server.nameOverride | string | `""` |  |
| server.nodeSelector | object | `{}` |  |
| server.notifier | object | `{"alertmanager":{"basicAuth":{"password":"","username":""},"bearer":{"token":"","tokenFile":""},"url":""}}` | Notifier to use for alerts. Multiple notifiers can be enabled by using `notifiers` section |
| server.notifier.alertmanager.basicAuth | object | `{"password":"","username":""}` | Basic auth for alertmanager |
| server.notifier.alertmanager.bearer.token | string | `""` | Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string |
| server.notifier.alertmanager.bearer.tokenFile | string | `""` | Token Auth file with Bearer token. You can use one of token or tokenFile |
| server.notifiers | list | `[]` | Additional notifiers to use for alerts |
| server.podAnnotations | object | `{}` |  |
| server.podDisruptionBudget.enabled | bool | `false` |  |
| server.podDisruptionBudget.labels | object | `{}` |  |
| server.podLabels | object | `{}` |  |
| server.podSecurityContext.enabled | bool | `true` |  |
| server.priorityClassName | string | `""` |  |
| server.probe.liveness.failureThreshold | int | `3` |  |
| server.probe.liveness.initialDelaySeconds | int | `5` |  |
| server.probe.liveness.periodSeconds | int | `15` |  |
| server.probe.liveness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| server.probe.liveness.timeoutSeconds | int | `5` |  |
| server.probe.readiness.failureThreshold | int | `3` |  |
| server.probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| server.probe.readiness.httpGet.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| server.probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| server.probe.readiness.initialDelaySeconds | int | `5` |  |
| server.probe.readiness.periodSeconds | int | `15` |  |
| server.probe.readiness.timeoutSeconds | int | `5` |  |
| server.probe.startup | object | `{}` |  |
| server.remote.read.basicAuth | object | `{"password":"","username":""}` | Basic auth for remote read |
| server.remote.read.bearer.token | string | `""` | Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string |
| server.remote.read.bearer.tokenFile | string | `""` | Token Auth file with Bearer token. You can use one of token or tokenFile |
| server.remote.read.url | string | `""` |  |
| server.remote.write.basicAuth | object | `{"password":"","username":""}` | Basic auth for remote write |
| server.remote.write.bearer | object | `{"token":"","tokenFile":""}` | Auth based on Bearer token for remote write |
| server.remote.write.bearer.token | string | `""` | Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string |
| server.remote.write.bearer.tokenFile | string | `""` | Token Auth file with Bearer token. You can use one of token or tokenFile |
| server.remote.write.url | string | `""` |  |
| server.replicaCount | int | `1` |  |
| server.resources | object | `{}` |  |
| server.securityContext.enabled | bool | `true` |  |
| server.service.annotations | object | `{}` |  |
| server.service.clusterIP | string | `""` |  |
| server.service.externalIPs | list | `[]` |  |
| server.service.externalTrafficPolicy | string | `""` |  |
| server.service.healthCheckNodePort | string | `""` |  |
| server.service.ipFamilies | list | `[]` |  |
| server.service.ipFamilyPolicy | string | `""` |  |
| server.service.labels | object | `{}` |  |
| server.service.loadBalancerIP | string | `""` |  |
| server.service.loadBalancerSourceRanges | list | `[]` |  |
| server.service.servicePort | int | `8880` |  |
| server.service.type | string | `"ClusterIP"` |  |
| server.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| server.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| server.strategy.type | string | `"RollingUpdate"` |  |
| server.tolerations | list | `[]` |  |
| server.verticalPodAutoscaler | object | `{"enabled":false}` | Vertical Pod Autoscaler |
| server.verticalPodAutoscaler.enabled | bool | `false` | Use VPA for vmalert |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for server component. This is Prometheus operator object |
| serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
