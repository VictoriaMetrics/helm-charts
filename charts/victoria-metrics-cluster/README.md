# Victoria Metrics Helm Chart for Cluster Version

 ![Version: 0.8.1](https://img.shields.io/badge/Version-0.8.1-informational?style=flat-square)

Victoria Metrics Cluster version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure

# Chart Details

This chart will do the following:

* Rollout victoria metrics cluster

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-cluster`` chart available to installation:

##### for helm v3

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

##### for helm v3

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

# How to uninstall

Remove application with command.

```console
helm uninstall vmcluster -n NAMESPACE
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-cluster

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-cluster/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterDomainSuffix | string | `"cluster.local"` | k8s cluster domain suffix, uses for building stroage pods' FQDN. Ref: [https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/) |
| printNotes | bool | `true` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.namespaced | bool | `false` |  |
| rbac.pspEnabled | bool | `true` |  |
| serviceAccount.automountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.extraLabels | object | `{}` |  |
| vminsert.affinity | object | `{}` | Pod affinity |
| vminsert.annotations | object | `{}` |  |
| vminsert.automountServiceAccountToken | bool | `true` |  |
| vminsert.enabled | bool | `true` | Enable deployment of vminsert component. Deployment is used |
| vminsert.env | list | `[]` |  |
| vminsert.extraArgs."envflag.enable" | string | `"true"` |  |
| vminsert.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vminsert.extraArgs.loggerFormat | string | `"json"` |  |
| vminsert.extraLabels | object | `{}` |  |
| vminsert.fullnameOverride | string | `""` | Overrides the full name of vminsert component |
| vminsert.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vminsert.image.repository | string | `"victoriametrics/vminsert"` | Image repository |
| vminsert.image.tag | string | `"v1.47.0-cluster"` | Image tag |
| vminsert.ingress.annotations | object | `{}` | Ingress annotations |
| vminsert.ingress.enabled | bool | `false` | Enable deployment of ingress for vminsert component |
| vminsert.ingress.extraLabels | object | `{}` |  |
| vminsert.ingress.hosts | list | `[]` | Array of host objects |
| vminsert.ingress.tls | list | `[]` |  |
| vminsert.name | string | `"vminsert"` | vminsert container name |
| vminsert.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vminsert.podAnnotations | object | `{}` | Pod's annotations |
| vminsert.podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| vminsert.podDisruptionBudget.labels | object | `{}` |  |
| vminsert.podSecurityContext | object | `{}` |  |
| vminsert.priorityClassName | string | `""` | Name of Priority Class |
| vminsert.replicaCount | int | `2` | Count of vminsert pods |
| vminsert.resources | object | `{}` | Resource object |
| vminsert.securityContext | object | `{}` |  |
| vminsert.service.annotations | object | `{}` | Service annotations |
| vminsert.service.clusterIP | string | `""` | Service ClusterIP |
| vminsert.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips) |
| vminsert.service.labels | object | `{}` | Service labels |
| vminsert.service.loadBalancerIP | string | `""` | Service load balancer IP |
| vminsert.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| vminsert.service.servicePort | int | `8480` | Service port |
| vminsert.service.type | string | `"ClusterIP"` | Service type |
| vminsert.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vminsert.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vminsert component. This is Prometheus operator object |
| vminsert.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vminsert.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vminsert.suppresStorageFQDNsRender | bool | `false` | Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--stroageNodes`, they can be re-defined in exrtaArgs |
| vminsert.tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| vmselect.affinity | object | `{}` | Pod affinity |
| vmselect.annotations | object | `{}` |  |
| vmselect.automountServiceAccountToken | bool | `true` |  |
| vmselect.cacheMountPath | string | `"/cache"` | Cache root folder |
| vmselect.enabled | bool | `true` | Enable deployment of vmselect component. Can be deployed as Deployment(default) or StatefulSet |
| vmselect.env | list | `[]` |  |
| vmselect.extraArgs."envflag.enable" | string | `"true"` |  |
| vmselect.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vmselect.extraArgs.loggerFormat | string | `"json"` |  |
| vmselect.extraLabels | object | `{}` |  |
| vmselect.fullnameOverride | string | `""` | Overrides the full name of vmselect component |
| vmselect.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vmselect.image.repository | string | `"victoriametrics/vmselect"` | Image repository |
| vmselect.image.tag | string | `"v1.47.0-cluster"` | Image tag |
| vmselect.ingress.annotations | object | `{}` | Ingress annotations |
| vmselect.ingress.enabled | bool | `false` | Enable deployment of ingress for vmselect component |
| vmselect.ingress.extraLabels | object | `{}` |  |
| vmselect.ingress.hosts | list | `[]` | Array of host objects |
| vmselect.ingress.tls | list | `[]` |  |
| vmselect.name | string | `"vmselect"` | Vmselect container name |
| vmselect.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vmselect.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access mode. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| vmselect.persistentVolume.annotations | object | `{}` | Persistent volume annotations |
| vmselect.persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for vmselect component. Empty dir if false. If true, vmselect will create/use a Persistent Volume Claim |
| vmselect.persistentVolume.existingClaim | string | `""` | Existing Claim name. Requires vmselect.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound |
| vmselect.persistentVolume.size | string | `"2Gi"` |  |
| vmselect.persistentVolume.subPath | string | `""` | Mount subpath |
| vmselect.podAnnotations | object | `{}` | Pod's annotations |
| vmselect.podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| vmselect.podDisruptionBudget.labels | object | `{}` |  |
| vmselect.podSecurityContext | object | `{}` |  |
| vmselect.priorityClassName | string | `""` | Name of Priority Class |
| vmselect.replicaCount | int | `2` | Count of vmselect pods |
| vmselect.resources | object | `{}` | Resource object |
| vmselect.securityContext | object | `{}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| vmselect.service.annotations | object | `{}` | Service annotations |
| vmselect.service.clusterIP | string | `""` | Service ClusterIP |
| vmselect.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips](https://kubernetes.io/docs/user-guide/services/#external-ips) |
| vmselect.service.labels | object | `{}` | Service labels |
| vmselect.service.loadBalancerIP | string | `""` | Service load balacner IP |
| vmselect.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| vmselect.service.servicePort | int | `8481` | Service port |
| vmselect.service.type | string | `"ClusterIP"` | Service type |
| vmselect.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vmselect.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vmselect component. This is Prometheus operator object |
| vmselect.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vmselect.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vmselect.statefulSet.enabled | bool | `false` | Deploy StatefulSet instead of Deployment for vmselect. Useful if you want to keep cache data. Creates statefulset instead of deployment, useful when you want to keep the cache |
| vmselect.statefulSet.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| vmselect.statefulSet.service.annotations | object | `{}` | Headless service annotations |
| vmselect.statefulSet.service.labels | object | `{}` | Headless service labels |
| vmselect.statefulSet.service.servicePort | int | `8481` | Headless service port |
| vmselect.suppresStorageFQDNsRender | bool | `false` | Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--stroageNodes`, they can be re-defined in exrtaArgs |
| vmselect.tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| vmstorage.affinity | object | `{}` | Pod affinity |
| vmstorage.annotations | object | `{}` |  |
| vmstorage.automountServiceAccountToken | bool | `true` |  |
| vmstorage.enabled | bool | `true` | Enable deployment of vmstorage component. StatefulSet is used |
| vmstorage.env | list | `[]` |  |
| vmstorage.extraArgs."envflag.enable" | string | `"true"` |  |
| vmstorage.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| vmstorage.extraArgs.loggerFormat | string | `"json"` |  |
| vmstorage.extraLabels | object | `{}` |  |
| vmstorage.fullnameOverride | string | `nil` | Overrides the full name of vmstorage component |
| vmstorage.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| vmstorage.image.repository | string | `"victoriametrics/vmstorage"` | Image repository |
| vmstorage.image.tag | string | `"v1.47.0-cluster"` | Image tag |
| vmstorage.name | string | `"vmstorage"` | vmstorage container name |
| vmstorage.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| vmstorage.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| vmstorage.persistentVolume.annotations | object | `{}` | Persistent volume annotations |
| vmstorage.persistentVolume.enabled | bool | `true` | Create/use Persistent Volume Claim for vmstorage component. Empty dir if false. If true,  vmstorage will create/use a Persistent Volume Claim |
| vmstorage.persistentVolume.existingClaim | string | `""` | Existing Claim name. Requires vmstorage.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound |
| vmstorage.persistentVolume.mountPath | string | `"/storage"` | Data root path. Vmstorage data Persistent Volume mount root path |
| vmstorage.persistentVolume.size | string | `"8Gi"` | Size of the volume. Better to set the same as resource limit memory property |
| vmstorage.persistentVolume.subPath | string | `""` | Mount subpath |
| vmstorage.podAnnotations | object | `{}` | Pod's annotations |
| vmstorage.podDisruptionBudget | object | `{"enabled":false,"labels":{}}` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| vmstorage.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| vmstorage.podSecurityContext | object | `{}` |  |
| vmstorage.priorityClassName | string | `""` | Name of Priority Class |
| vmstorage.probe.liveness.failureThreshold | int | `3` |  |
| vmstorage.probe.liveness.initialDelaySeconds | int | `5` |  |
| vmstorage.probe.liveness.periodSeconds | int | `15` |  |
| vmstorage.probe.liveness.timeoutSeconds | int | `5` |  |
| vmstorage.probe.readiness.failureThreshold | int | `3` |  |
| vmstorage.probe.readiness.initialDelaySeconds | int | `5` |  |
| vmstorage.probe.readiness.periodSeconds | int | `15` |  |
| vmstorage.probe.readiness.timeoutSeconds | int | `5` |  |
| vmstorage.replicaCount | int | `2` | Count of vmstorage pods |
| vmstorage.resources | object | `{}` | Resource object. Ref: [http://kubernetes.io/docs/user-guide/compute-resources/](http://kubernetes.io/docs/user-guide/compute-resources/) |
| vmstorage.retentionPeriod | int | `1` | Data retention period. Supported values 1w, 1d, number without measurement means month, e.g. 2 = 2month |
| vmstorage.securityContext | object | `{}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| vmstorage.service.annotations | object | `{}` | Service annotations |
| vmstorage.service.labels | object | `{}` | Service labels |
| vmstorage.service.servicePort | int | `8482` | Service port |
| vmstorage.service.vminsertPort | int | `8400` | Port for accepting connections from vminsert |
| vmstorage.service.vmselectPort | int | `8401` | Port for accepting connections from vmselect |
| vmstorage.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| vmstorage.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for vmstorage component. This is Prometheus operator object |
| vmstorage.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| vmstorage.serviceMonitor.namespace | string | `""` | Target namespace of ServiceMonitor manifest |
| vmstorage.terminationGracePeriodSeconds | int | `60` | Pod's termination grace period in seconds |
| vmstorage.tolerations | list | `[]` | Array of tolerations object. Node tolerations for server scheduling to nodes with taints. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
