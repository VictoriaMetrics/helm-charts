# Helm Chart For Victoria Metrics Alert.

 ![Version: 0.4.35](https://img.shields.io/badge/Version-0.4.35-informational?style=flat-square)

Victoria Metrics Alert - executes a list of given MetricsQL expressions (rules) and sends alerts to Alert Manager.

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-alert`` chart available to installation:

##### for helm v3

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

##### for helm v3

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

# How to uninstall

Remove application with command.

```console
helm uninstall vmalert -n NAMESPACE
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-alert

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-alert/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertmanager.baseURL | string | `""` |  |
| alertmanager.config.global.resolve_timeout | string | `"5m"` |  |
| alertmanager.config.receivers[0].name | string | `"devnull"` |  |
| alertmanager.config.route.group_by[0] | string | `"alertname"` |  |
| alertmanager.config.route.group_interval | string | `"10s"` |  |
| alertmanager.config.route.group_wait | string | `"30s"` |  |
| alertmanager.config.route.receiver | string | `"devnull"` |  |
| alertmanager.config.route.repeat_interval | string | `"24h"` |  |
| alertmanager.configMap | string | `""` |  |
| alertmanager.enabled | bool | `false` |  |
| alertmanager.extraArgs | object | `{}` |  |
| alertmanager.image | string | `"prom/alertmanager"` |  |
| alertmanager.imagePullSecrets | list | `[]` |  |
| alertmanager.ingress.annotations | object | `{}` |  |
| alertmanager.ingress.enabled | bool | `false` |  |
| alertmanager.ingress.extraLabels | object | `{}` |  |
| alertmanager.ingress.hosts | list | `[]` |  |
| alertmanager.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| alertmanager.ingress.tls | list | `[]` |  |
| alertmanager.nodeSelector | object | `{}` |  |
| alertmanager.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| alertmanager.persistentVolume.annotations | object | `{}` | Persistant volume annotations |
| alertmanager.persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for alertmanager component. Empty dir if false |
| alertmanager.persistentVolume.existingClaim | string | `""` | Existing Claim name. If defined, PVC must be created manually before volume will be bound |
| alertmanager.persistentVolume.mountPath | string | `"/data"` | Mount path. Alertmanager data Persistent Volume mount root path. |
| alertmanager.persistentVolume.size | string | `"50Mi"` | Size of the volume. Better to set the same as resource limit memory property. |
| alertmanager.persistentVolume.storageClass | string | `""` | StorageClass to use for persistent volume. Requires alertmanager.persistentVolume.enabled: true. If defined, PVC created automatically |
| alertmanager.persistentVolume.subPath | string | `""` | Mount subpath |
| alertmanager.podMetadata.annotations | object | `{}` |  |
| alertmanager.podMetadata.labels | object | `{}` |  |
| alertmanager.podSecurityContext | object | `{}` |  |
| alertmanager.priorityClassName | string | `""` |  |
| alertmanager.replicaCount | int | `1` |  |
| alertmanager.resources | object | `{}` |  |
| alertmanager.retention | string | `"120h"` |  |
| alertmanager.service.annotations | object | `{}` |  |
| alertmanager.service.port | int | `9093` |  |
| alertmanager.service.type | string | `"ClusterIP"` |  |
| alertmanager.tag | string | `"v0.20.0"` |  |
| alertmanager.templates | object | `{}` |  |
| alertmanager.tolerations | list | `[]` |  |
| imagePullSecrets | list | `[]` |  |
| rbac.annotations | object | `{}` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.namespaced | bool | `false` |  |
| rbac.pspEnabled | bool | `true` |  |
| server.affinity | object | `{}` |  |
| server.annotations | object | `{}` |  |
| server.config.alerts.groups | list | `[]` |  |
| server.configMap | string | `""` |  |
| server.datasource.basicAuth.password | string | `""` |  |
| server.datasource.basicAuth.username | string | `""` |  |
| server.datasource.url | string | `""` |  |
| server.enabled | bool | `true` |  |
| server.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://github.com/VictoriaMetrics/VictoriaMetrics#environment-variables |
| server.extraArgs."envflag.enable" | string | `"true"` |  |
| server.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| server.extraArgs.loggerFormat | string | `"json"` |  |
| server.extraContainers | list | `[]` |  |
| server.extraHostPathMounts | list | `[]` |  |
| server.extraVolumeMounts | list | `[]` |  |
| server.extraVolumes | list | `[]` |  |
| server.fullnameOverride | string | `""` |  |
| server.image.pullPolicy | string | `"IfNotPresent"` |  |
| server.image.repository | string | `"victoriametrics/vmalert"` |  |
| server.image.tag | string | `""` |  |
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
| server.notifier.alertmanager.url | string | `""` |  |
| server.podAnnotations | object | `{}` |  |
| server.podDisruptionBudget.enabled | bool | `false` |  |
| server.podDisruptionBudget.labels | object | `{}` |  |
| server.podLabels | object | `{}` |  |
| server.podSecurityContext | object | `{}` |  |
| server.priorityClassName | string | `""` |  |
| server.remote.read.url | string | `""` |  |
| server.remote.write.url | string | `""` |  |
| server.replicaCount | int | `1` |  |
| server.resources | object | `{}` |  |
| server.securityContext | object | `{}` |  |
| server.service.annotations | object | `{}` |  |
| server.service.clusterIP | string | `""` |  |
| server.service.externalIPs | list | `[]` |  |
| server.service.labels | object | `{}` |  |
| server.service.loadBalancerIP | string | `""` |  |
| server.service.loadBalancerSourceRanges | list | `[]` |  |
| server.service.servicePort | int | `8880` |  |
| server.service.type | string | `"ClusterIP"` |  |
| server.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| server.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| server.strategy.type | string | `"RollingUpdate"` |  |
| server.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.extraLabels | object | `{}` |  |
| serviceMonitor.relabelings | list | `[]` |  |