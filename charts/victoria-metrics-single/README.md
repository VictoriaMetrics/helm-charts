# Victoria Metrics Helm Chart for Single Version

 ![Version: 0.6.16](https://img.shields.io/badge/Version-0.6.16-informational?style=flat-square)

Victoria Metrics Single version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure.

# Chart Details

This chart will do the following:

* Rollout Victoria Metrics Single.

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-single`` chart available to installation:

##### for helm v3

```console
helm search repo vm/victoria-metrics-single -l
```

Export default values of ``victoria-metrics-single`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-single > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmsingle vm/victoria-metrics-single -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

##### for helm v3

```console
helm install vmsingle vm/victoria-metrics-single -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'single'
```

Get the application by running this command:

```console
helm list -f vmsingle -n NAMESPACE
```

See the history of versions of ``vmsingle`` application with command.

```console
helm history vmsingle -n NAMESPACE
```

# How to uninstall

Remove application with command.

```console
helm uninstall vmsingle -n NAMESPACE
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-single

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-single/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `true` |  |
| podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| podDisruptionBudget.extraLabels | object | `{}` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.namespaced | bool | `false` |  |
| rbac.pspEnabled | bool | `true` |  |
| server.affinity | object | `{}` | Pod affinity |
| server.enabled | bool | `true` | Enable deployment of server component. Deployed as StatefulSet |
| server.env | list | `[]` | Env variables |
| server.extraArgs."envflag.enable" | string | `"true"` |  |
| server.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| server.extraArgs.loggerFormat | string | `"json"` |  |
| server.extraContainers | list | `[]` |  |
| server.extraHostPathMounts | list | `[]` |  |
| server.extraVolumeMounts | list | `[]` |  |
| server.extraVolumes | list | `[]` |  |
| server.fullnameOverride | string | `nil` | Overrides the full name of server component |
| server.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| server.image.repository | string | `"victoriametrics/victoria-metrics"` | Image repository |
| server.image.tag | string | `"v1.55.1"` | Image tag |
| server.ingress.annotations | object | `{}` | Ingress annotations |
| server.ingress.enabled | bool | `false` | Enable deployment of ingress for server component |
| server.ingress.extraLabels | object | `{}` | Ingress extra labels |
| server.ingress.hosts | list | `[]` | Array of host objects |
| server.ingress.tls | list | `[]` | Array of TLS objects |
| server.livenessProbe.initialDelaySeconds | int | `5` |  |
| server.livenessProbe.periodSeconds | int | `15` |  |
| server.livenessProbe.tcpSocket.port | string | `"http"` |  |
| server.livenessProbe.timeoutSeconds | int | `5` |  |
| server.name | string | `"server"` | Server container name |
| server.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| server.persistentVolume.annotations | object | `{}` | Persistant volume annotations |
| server.persistentVolume.enabled | bool | `true` | Create/use Persistent Volume Claim for server component. Empty dir if false |
| server.persistentVolume.existingClaim | string | `""` | Existing Claim name. If defined, PVC must be created manually before volume will be bound |
| server.persistentVolume.mountPath | string | `"/storage"` | Mount path. Server data Persistent Volume mount root path. |
| server.persistentVolume.size | string | `"16Gi"` | Size of the volume. Better to set the same as resource limit memory property. |
| server.persistentVolume.storageClass | string | `""` | StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically |
| server.persistentVolume.subPath | string | `""` | Mount subpath |
| server.podAnnotations | object | `{}` | Pod's annotations |
| server.podLabels | object | `{}` | Pod's additional labels |
| server.podManagementPolicy | string | `"OrderedReady"` | Pod's management policy  |
| server.podSecurityContext | object | `{}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.priorityClassName | string | `""` | Name of Priority Class |
| server.readinessProbe.httpGet.path | string | `"/health"` |  |
| server.readinessProbe.httpGet.port | string | `"http"` |  |
| server.readinessProbe.initialDelaySeconds | int | `5` |  |
| server.readinessProbe.periodSeconds | int | `15` |  |
| server.readinessProbe.timeoutSeconds | int | `5` |  |
| server.resources | object | `{}` | Resource object. Ref: [http://kubernetes.io/docs/user-guide/compute-resources/](http://kubernetes.io/docs/user-guide/compute-resources/ |
| server.retentionPeriod | int | `1` | Data retention period in month |
| server.securityContext | object | `{}` | Security context to be added to server pods |
| server.service.annotations | object | `{}` | Service annotations |
| server.service.clusterIP | string | `""` | Service ClusterIP |
| server.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips) |
| server.service.labels | object | `{}` | Service labels |
| server.service.loadBalancerIP | string | `""` | Service load balacner IP |
| server.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| server.service.servicePort | int | `8428` | Service port |
| server.service.type | string | `"ClusterIP"` | Service type |
| server.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| server.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for server component. This is Prometheus operator object |
| server.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| server.statefulSet.enabled | bool | `true` | Creates statefulset instead of deployment, useful when you want to keep the cache |
| server.statefulSet.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| server.statefulSet.service.annotations | object | `{}` | Headless service annotations |
| server.statefulSet.service.labels | object | `{}` | Headless service labels |
| server.statefulSet.service.servicePort | int | `8428` | Headless service port |
| server.terminationGracePeriodSeconds | int | `60` | Pod's termination grace period in seconds |
| server.tolerations | list | `[]` |  |
| serviceAccount.automountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` | Create service account. |
| serviceAccount.extraLabels | object | `{}` |  |
