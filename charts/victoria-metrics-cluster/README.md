# Victoria Metrics Helm Chart for Cluster Version

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.11.23](https://img.shields.io/badge/Version-0.11.23-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-cluster)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)

Victoria Metrics Cluster version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure

## Chart Details

Note: this chart installs VictoriaMetrics cluster components such as vminsert, vmselect and vmstorage. It doesn't create or configure metrics scraping. If you are looking for a chart to configure monitoring stack in cluster check out [victoria-metrics-k8s-stack chart](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack#helm-chart-for-victoria-metrics-kubernetes-monitoring-stack).

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-cluster`` chart available to installation:

```console
helm search repo vm/victoria-metrics-cluster -l
```

Export default values of ``victoria-metrics-cluster`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-cluster > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmcluster vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmcluster vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vminsert\|vmselect\|vmstorage'
```

Get the application by running this command:

```console
helm list -f vmcluster -n NAMESPACE
```

See the history of versions of ``vmcluster`` application with command.

```console
helm history vmcluster -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmcluster -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-cluster

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-cluster/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterDomainSuffix | string | `"cluster.local"` | k8s cluster domain suffix, uses for building storage pods' FQDN. Ref: [https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/) |
| extraObjects | list | `[]` | Add extra specs dynamically to this chart |
| extraSecrets | list | `[]` |  |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| license | object | `{"key":"","secret":{"key":"","name":""}}` | Enterprise license key configuration for VictoriaMetrics enterprise. Required only for VictoriaMetrics enterprise. Documentation - https://docs.victoriametrics.com/enterprise.html, for more information, visit https://victoriametrics.com/products/enterprise/ . To request a trial license, go to https://victoriametrics.com/products/enterprise/trial/ Supported starting from VictoriaMetrics v1.94.0 |
| license.key | string | `""` | License key |
| license.secret | object | `{"key":"","name":""}` | Use existing secret with license key |
| license.secret.key | string | `""` | Key in secret with license key |
| license.secret.name | string | `""` | Existing secret name |
| printNotes | bool | `true` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.namespaced | bool | `false` |  |
| serviceAccount.automountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.extraLabels | object | `{}` |  |
| vminsert.affinity | object | `{}` | Pod affinity |
| vminsert.annotations | object | `{}` |  |
| vminsert.automountServiceAccountToken | bool | `true` |  |
| vminsert.containerWorkingDir | string | `""` | Container workdir |
| vminsert.enabled | bool | `true` | Enable deployment of vminsert component. Deployment is used |
| vminsert.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| vminsert.envFrom | list | `[]` |  |
| vminsert.extraArgs."envflag.enable" | string | `"true"` |  |
| vminsert.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vminsert.extraArgs.loggerFormat | string | `"json"` |  |
| vminsert.extraContainers | list | `[]` |  |
| vminsert.extraLabels | object | `{}` |  |
| vminsert.extraVolumeMounts | list | `[]` |  |
| vminsert.extraVolumes | list | `[]` |  |
| vminsert.fullnameOverride | string | `""` | Overrides the full name of vminsert component |
| vminsert.horizontalPodAutoscaler.behavior | object | `{}` | Behavior settings for scaling by the HPA |
| vminsert.horizontalPodAutoscaler.enabled | bool | `false` | Use HPA for vminsert component |
| vminsert.horizontalPodAutoscaler.maxReplicas | int | `10` | Maximum replicas for HPA to use to to scale the vminsert component |
| vminsert.horizontalPodAutoscaler.metrics | list | `[]` | Metric for HPA to use to scale the vminsert component |
| vminsert.horizontalPodAutoscaler.minReplicas | int | `2` | Minimum replicas for HPA to use to scale the vminsert component |
| vminsert.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vminsert.image.registry | string | `""` | Image registry |
| vminsert.image.repository | string | `"victoriametrics/vminsert"` | Image repository |
| vminsert.image.tag | string | `""` | Image tag override Chart.AppVersion     |
| vminsert.image.variant | string | `"cluster"` |  |
| vminsert.ingress.annotations | object | `{}` | Ingress annotations |
| vminsert.ingress.enabled | bool | `false` | Enable deployment of ingress for vminsert component |
| vminsert.ingress.extraLabels | object | `{}` |  |
| vminsert.ingress.hosts | list | `[]` | Array of host objects |
| vminsert.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| vminsert.ingress.tls | list | `[]` | Array of TLS objects |
| vminsert.initContainers | list | `[]` |  |
| vminsert.name | string | `"vminsert"` | vminsert container name |
| vminsert.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vminsert.podAnnotations | object | `{}` | Pod's annotations |
| vminsert.podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| vminsert.podDisruptionBudget.labels | object | `{}` |  |
| vminsert.podSecurityContext.enabled | bool | `false` |  |
| vminsert.ports.name | string | `"http"` |  |
| vminsert.priorityClassName | string | `""` | Name of Priority Class |
| vminsert.probe.liveness.failureThreshold | int | `3` |  |
| vminsert.probe.liveness.initialDelaySeconds | int | `5` |  |
| vminsert.probe.liveness.periodSeconds | int | `15` |  |
| vminsert.probe.liveness.tcpSocket.port | string | `"{{ dig \"ports\" \"name\" \"http\" (.app | dict) }}"` |  |
| vminsert.probe.liveness.timeoutSeconds | int | `5` |  |
| vminsert.probe.readiness.failureThreshold | int | `3` |  |
| vminsert.probe.readiness.httpGet.path | string | `"{{ index .app.extraArgs \"http.pathPrefix\" | default \"\" | trimSuffix \"/\" }}/health"` |  |
| vminsert.probe.readiness.httpGet.port | string | `"{{ dig \"ports\" \"name\" \"http\" (.app | dict) }}"` |  |
| vminsert.probe.readiness.httpGet.scheme | string | `"{{ ternary \"HTTPS\" \"HTTP\" (.app.extraArgs.tls | default false) }}"` |  |
| vminsert.probe.readiness.initialDelaySeconds | int | `5` |  |
| vminsert.probe.readiness.periodSeconds | int | `15` |  |
| vminsert.probe.readiness.timeoutSeconds | int | `5` |  |
| vminsert.probe.startup | object | `{}` |  |
| vminsert.replicaCount | int | `2` | Count of vminsert pods |
| vminsert.resources | object | `{}` | Resource object |
| vminsert.securityContext | object | `{"enabled":false}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| vminsert.service.annotations | object | `{}` | Service annotations |
| vminsert.service.clusterIP | string | `""` | Service ClusterIP |
| vminsert.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips) |
| vminsert.service.extraPorts | list | `[]` | Extra service ports |
| vminsert.service.labels | object | `{}` | Service labels |
| vminsert.service.loadBalancerIP | string | `""` | Service load balancer IP |
| vminsert.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| vminsert.service.servicePort | int | `8480` | Service port |
| vminsert.service.targetPort | string | `"http"` | Target port |
| vminsert.service.type | string | `"ClusterIP"` | Service type |
| vminsert.service.udp | bool | `false` | Make sure that service is not type "LoadBalancer", as it requires "MixedProtocolLBService" feature gate. ref: https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/ |
| vminsert.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vminsert.serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| vminsert.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vminsert component. This is Prometheus operator object |
| vminsert.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vminsert.serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| vminsert.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vminsert.serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
| vminsert.strategy | object | `{}` |  |
| vminsert.suppressStorageFQDNsRender | bool | `false` | Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--storageNodes`, they can be re-defined in extraArgs |
| vminsert.tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| vminsert.topologySpreadConstraints | list | `[]` | Pod topologySpreadConstraints |
| vmselect.affinity | object | `{}` | Pod affinity |
| vmselect.annotations | object | `{}` |  |
| vmselect.automountServiceAccountToken | bool | `true` |  |
| vmselect.cacheMountPath | string | `"/cache"` | Cache root folder |
| vmselect.containerWorkingDir | string | `""` | Container workdir |
| vmselect.emptyDir | object | `{}` |  |
| vmselect.enabled | bool | `true` | Enable deployment of vmselect component. Can be deployed as Deployment(default) or StatefulSet |
| vmselect.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| vmselect.envFrom | list | `[]` |  |
| vmselect.extraArgs."envflag.enable" | bool | `true` |  |
| vmselect.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vmselect.extraArgs.loggerFormat | string | `"json"` |  |
| vmselect.extraContainers | list | `[]` |  |
| vmselect.extraHostPathMounts | list | `[]` |  |
| vmselect.extraLabels | object | `{}` |  |
| vmselect.extraVolumeMounts | list | `[]` |  |
| vmselect.extraVolumes | list | `[]` |  |
| vmselect.fullnameOverride | string | `""` | Overrides the full name of vmselect component |
| vmselect.horizontalPodAutoscaler.behavior | object | `{}` | Behavior settings for scaling by the HPA |
| vmselect.horizontalPodAutoscaler.enabled | bool | `false` | Use HPA for vmselect component |
| vmselect.horizontalPodAutoscaler.maxReplicas | int | `10` | Maximum replicas for HPA to use to to scale the vmselect component |
| vmselect.horizontalPodAutoscaler.metrics | list | `[]` | Metric for HPA to use to scale the vmselect component |
| vmselect.horizontalPodAutoscaler.minReplicas | int | `2` | Minimum replicas for HPA to use to scale the vmselect component |
| vmselect.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vmselect.image.registry | string | `""` | Image registry |
| vmselect.image.repository | string | `"victoriametrics/vmselect"` | Image repository |
| vmselect.image.tag | string | `""` | Image tag override Chart.AppVersion |
| vmselect.image.variant | string | `"cluster"` |  |
| vmselect.ingress.annotations | object | `{}` | Ingress annotations |
| vmselect.ingress.enabled | bool | `false` | Enable deployment of ingress for vmselect component |
| vmselect.ingress.extraLabels | object | `{}` |  |
| vmselect.ingress.hosts | list | `[]` | Array of host objects |
| vmselect.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| vmselect.ingress.tls | list | `[]` | Array of TLS objects |
| vmselect.initContainers | list | `[]` |  |
| vmselect.name | string | `"vmselect"` | Vmselect container name |
| vmselect.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vmselect.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access mode. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| vmselect.persistentVolume.annotations | object | `{}` | Persistent volume annotations |
| vmselect.persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for vmselect component. Empty dir if false. If true, vmselect will create/use a Persistent Volume Claim |
| vmselect.persistentVolume.existingClaim | string | `""` | Existing Claim name. Requires vmselect.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound |
| vmselect.persistentVolume.labels | object | `{}` | Persistent volume labels |
| vmselect.persistentVolume.size | string | `"2Gi"` | Size of the volume. Better to set the same as resource limit memory property |
| vmselect.persistentVolume.subPath | string | `""` | Mount subpath |
| vmselect.podAnnotations | object | `{}` | Pod's annotations |
| vmselect.podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| vmselect.podDisruptionBudget.labels | object | `{}` |  |
| vmselect.podSecurityContext.enabled | bool | `true` |  |
| vmselect.ports.name | string | `"http"` |  |
| vmselect.priorityClassName | string | `""` | Name of Priority Class |
| vmselect.probe.liveness.failureThreshold | int | `3` |  |
| vmselect.probe.liveness.initialDelaySeconds | int | `5` |  |
| vmselect.probe.liveness.periodSeconds | int | `15` |  |
| vmselect.probe.liveness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| vmselect.probe.liveness.timeoutSeconds | int | `5` |  |
| vmselect.probe.readiness.failureThreshold | int | `3` |  |
| vmselect.probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| vmselect.probe.readiness.httpGet.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| vmselect.probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| vmselect.probe.readiness.initialDelaySeconds | int | `5` |  |
| vmselect.probe.readiness.periodSeconds | int | `15` |  |
| vmselect.probe.readiness.timeoutSeconds | int | `5` |  |
| vmselect.probe.startup | object | `{}` |  |
| vmselect.replicaCount | int | `2` | Count of vmselect pods |
| vmselect.resources | object | `{}` | Resource object |
| vmselect.securityContext | object | `{"enabled":true}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| vmselect.service.annotations | object | `{}` | Service annotations |
| vmselect.service.clusterIP | string | `""` | Service ClusterIP |
| vmselect.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips](https://kubernetes.io/docs/user-guide/services/#external-ips) |
| vmselect.service.extraPorts | list | `[]` | Extra service ports |
| vmselect.service.labels | object | `{}` | Service labels |
| vmselect.service.loadBalancerIP | string | `""` | Service load balacner IP |
| vmselect.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| vmselect.service.servicePort | int | `8481` | Service port |
| vmselect.service.targetPort | string | `"http"` | Target port |
| vmselect.service.type | string | `"ClusterIP"` | Service type |
| vmselect.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vmselect.serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| vmselect.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vmselect component. This is Prometheus operator object |
| vmselect.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vmselect.serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| vmselect.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vmselect.serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
| vmselect.statefulSet.enabled | bool | `false` | Deploy StatefulSet instead of Deployment for vmselect. Useful if you want to keep cache data. |
| vmselect.statefulSet.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| vmselect.statefulSet.service.annotations | object | `{}` | Headless service annotations |
| vmselect.statefulSet.service.labels | object | `{}` | Headless service labels |
| vmselect.statefulSet.service.servicePort | int | `8481` | Headless service port |
| vmselect.strategy | object | `{}` |  |
| vmselect.suppressStorageFQDNsRender | bool | `false` | Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--storageNodes`, they can be re-defined in extraArgs |
| vmselect.tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| vmselect.topologySpreadConstraints | list | `[]` | Pod topologySpreadConstraints |
| vmstorage.affinity | object | `{}` | Pod affinity |
| vmstorage.annotations | object | `{}` |  |
| vmstorage.automountServiceAccountToken | bool | `true` |  |
| vmstorage.containerWorkingDir | string | `""` | Container workdir |
| vmstorage.emptyDir | object | `{}` |  |
| vmstorage.enabled | bool | `true` | Enable deployment of vmstorage component. StatefulSet is used |
| vmstorage.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| vmstorage.envFrom | list | `[]` |  |
| vmstorage.extraArgs."envflag.enable" | string | `"true"` |  |
| vmstorage.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vmstorage.extraArgs.loggerFormat | string | `"json"` |  |
| vmstorage.extraContainers | list | `[]` |  |
| vmstorage.extraHostPathMounts | list | `[]` |  |
| vmstorage.extraLabels | object | `{}` |  |
| vmstorage.extraSecretMounts | list | `[]` |  |
| vmstorage.extraVolumeMounts | list | `[]` |  |
| vmstorage.extraVolumes | list | `[]` |  |
| vmstorage.fullnameOverride | string | `nil` | Overrides the full name of vmstorage component |
| vmstorage.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vmstorage.image.registry | string | `""` | Image registry |
| vmstorage.image.repository | string | `"victoriametrics/vmstorage"` | Image repository |
| vmstorage.image.tag | string | `""` | Image tag override Chart.AppVersion |
| vmstorage.image.variant | string | `"cluster"` |  |
| vmstorage.initContainers | list | `[]` |  |
| vmstorage.name | string | `"vmstorage"` | vmstorage container name |
| vmstorage.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vmstorage.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| vmstorage.persistentVolume.annotations | object | `{}` | Persistent volume annotations |
| vmstorage.persistentVolume.enabled | bool | `true` | Create/use Persistent Volume Claim for vmstorage component. Empty dir if false. If true,  vmstorage will create/use a Persistent Volume Claim |
| vmstorage.persistentVolume.existingClaim | string | `""` | Existing Claim name. Requires vmstorage.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound |
| vmstorage.persistentVolume.labels | object | `{}` | Persistent volume labels |
| vmstorage.persistentVolume.mountPath | string | `"/storage"` | Data root path. Vmstorage data Persistent Volume mount root path |
| vmstorage.persistentVolume.name | string | `"vmstorage-volume"` |  |
| vmstorage.persistentVolume.size | string | `"8Gi"` | Size of the volume. |
| vmstorage.persistentVolume.storageClass | string | `""` | Storage class name. Will be empty if not setted |
| vmstorage.persistentVolume.subPath | string | `""` | Mount subpath |
| vmstorage.podAnnotations | object | `{}` | Pod's annotations |
| vmstorage.podDisruptionBudget | object | `{"enabled":false,"labels":{}}` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| vmstorage.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| vmstorage.podSecurityContext.enabled | bool | `false` |  |
| vmstorage.ports.name | string | `"http"` |  |
| vmstorage.priorityClassName | string | `""` | Name of Priority Class |
| vmstorage.probe.liveness.failureThreshold | int | `10` |  |
| vmstorage.probe.liveness.initialDelaySeconds | int | `30` |  |
| vmstorage.probe.liveness.periodSeconds | int | `30` |  |
| vmstorage.probe.liveness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| vmstorage.probe.liveness.timeoutSeconds | int | `5` |  |
| vmstorage.probe.readiness.failureThreshold | int | `3` |  |
| vmstorage.probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| vmstorage.probe.readiness.httpGet.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| vmstorage.probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| vmstorage.probe.readiness.initialDelaySeconds | int | `5` |  |
| vmstorage.probe.readiness.periodSeconds | int | `15` |  |
| vmstorage.probe.readiness.timeoutSeconds | int | `5` |  |
| vmstorage.probe.startup | object | `{}` |  |
| vmstorage.replicaCount | int | `2` | Count of vmstorage pods |
| vmstorage.resources | object | `{}` | Resource object. Ref: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| vmstorage.retentionPeriod | int | `1` | Data retention period. Supported values 1w, 1d, number without measurement means month, e.g. 2 = 2month |
| vmstorage.securityContext | object | `{"enabled":false}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| vmstorage.service.annotations | object | `{}` | Service annotations |
| vmstorage.service.extraPorts | list | `[]` | Extra service ports |
| vmstorage.service.labels | object | `{}` | Service labels |
| vmstorage.service.servicePort | int | `8482` | Service port |
| vmstorage.service.vminsertPort | int | `8400` | Port for accepting connections from vminsert |
| vmstorage.service.vmselectPort | int | `8401` | Port for accepting connections from vmselect |
| vmstorage.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vmstorage.serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| vmstorage.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vmstorage component. This is Prometheus operator object |
| vmstorage.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vmstorage.serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| vmstorage.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vmstorage.serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
| vmstorage.terminationGracePeriodSeconds | int | `60` | Pod's termination grace period in seconds |
| vmstorage.tolerations | list | `[]` | Array of tolerations object. Node tolerations for server scheduling to nodes with taints. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) # |
| vmstorage.topologySpreadConstraints | list | `[]` | Pod topologySpreadConstraints |
| vmstorage.vmbackupmanager.destination | string | `""` | backup destination at S3, GCS or local filesystem. Pod name will be included to path! |
| vmstorage.vmbackupmanager.disableDaily | bool | `false` | disable daily backups |
| vmstorage.vmbackupmanager.disableHourly | bool | `false` | disable hourly backups |
| vmstorage.vmbackupmanager.disableMonthly | bool | `false` | disable monthly backups |
| vmstorage.vmbackupmanager.disableWeekly | bool | `false` | disable weekly backups |
| vmstorage.vmbackupmanager.enable | bool | `false` | enable automatic creation of backup via vmbackupmanager. vmbackupmanager is part of Enterprise packages |
| vmstorage.vmbackupmanager.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| vmstorage.vmbackupmanager.eula | bool | `false` | should be true and means that you have the legal right to run a backup manager that can either be a signed contract or an email with confirmation to run the service in a trial period # https://victoriametrics.com/legal/esa/ |
| vmstorage.vmbackupmanager.extraArgs."envflag.enable" | string | `"true"` |  |
| vmstorage.vmbackupmanager.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vmstorage.vmbackupmanager.extraArgs.loggerFormat | string | `"json"` |  |
| vmstorage.vmbackupmanager.extraSecretMounts | list | `[]` |  |
| vmstorage.vmbackupmanager.image.registry | string | `""` | vmbackupmanager image registry |
| vmstorage.vmbackupmanager.image.repository | string | `"victoriametrics/vmbackupmanager"` | vmbackupmanager image repository |
| vmstorage.vmbackupmanager.image.tag | string | `""` | vmbackupmanager image tag override Chart.AppVersion |
| vmstorage.vmbackupmanager.image.variant | string | `"cluster"` |  |
| vmstorage.vmbackupmanager.probe.liveness.failureThreshold | int | `10` |  |
| vmstorage.vmbackupmanager.probe.liveness.initialDelaySeconds | int | `30` |  |
| vmstorage.vmbackupmanager.probe.liveness.periodSeconds | int | `30` |  |
| vmstorage.vmbackupmanager.probe.liveness.tcpSocket.port | string | `"manager-http"` |  |
| vmstorage.vmbackupmanager.probe.liveness.timeoutSeconds | int | `5` |  |
| vmstorage.vmbackupmanager.probe.readiness.failureThreshold | int | `3` |  |
| vmstorage.vmbackupmanager.probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| vmstorage.vmbackupmanager.probe.readiness.httpGet.port | string | `"manager-http"` |  |
| vmstorage.vmbackupmanager.probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| vmstorage.vmbackupmanager.probe.readiness.initialDelaySeconds | int | `5` |  |
| vmstorage.vmbackupmanager.probe.readiness.periodSeconds | int | `15` |  |
| vmstorage.vmbackupmanager.probe.readiness.timeoutSeconds | int | `5` |  |
| vmstorage.vmbackupmanager.probe.startup | object | `{}` |  |
| vmstorage.vmbackupmanager.resources | object | `{}` |  |
| vmstorage.vmbackupmanager.restore | object | `{"onStart":{"enabled":false}}` | Allows to enable restore options for pod. Read more: https://docs.victoriametrics.com/vmbackupmanager.html#restore-commands |
| vmstorage.vmbackupmanager.retention | object | `{"keepLastDaily":2,"keepLastHourly":2,"keepLastMonthly":2,"keepLastWeekly":2}` | backups' retention settings |
| vmstorage.vmbackupmanager.retention.keepLastDaily | int | `2` | keep last N daily backups. 0 means delete all existing daily backups. Specify -1 to turn off |
| vmstorage.vmbackupmanager.retention.keepLastHourly | int | `2` | keep last N hourly backups. 0 means delete all existing hourly backups. Specify -1 to turn off |
| vmstorage.vmbackupmanager.retention.keepLastMonthly | int | `2` | keep last N monthly backups. 0 means delete all existing monthly backups. Specify -1 to turn off |
| vmstorage.vmbackupmanager.retention.keepLastWeekly | int | `2` | keep last N weekly backups. 0 means delete all existing weekly backups. Specify -1 to turn off |