# Victoria Metrics Helm Chart for vmanomaly

![Version: 1.4.2](https://img.shields.io/badge/Version-1.4.2-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-anomaly)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)
[![GitHub license](https://img.shields.io/github/license/VictoriaMetrics/VictoriaMetrics.svg)](https://github.com/VictoriaMetrics/helm-charts/blob/master/LICENSE)
![Twitter Follow](https://img.shields.io/twitter/follow/VictoriaMetrics?style=social)
![Subreddit subscribers](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=social)

Victoria Metrics Anomaly Detection - a service that continuously scans Victoria Metrics time series and detects unexpected changes within data patterns in real-time.

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure

## Chart Details

This chart will do the following:

* Rollout victoria metrics anomaly

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-anomaly`` chart available to installation:

```console
helm search repo vm/victoria-metrics-anomaly -l
```

Export default values of ``victoria-metrics-anomaly`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-anomaly > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmanomaly vm/victoria-metrics-anomaly -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmanomaly vm/victoria-metrics-anomaly -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmanomaly'
```

Get the application by running this command:

```console
helm list -f vmanomaly -n NAMESPACE
```

See the history of versions of ``vmanomaly`` application with command.

```console
helm history vmanomaly -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmanomaly -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-anomaly

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

For more `vmanomaly` config parameters see https://docs.victoriametrics.com/anomaly-detection/components

Change the values according to the need of the environment in ``victoria-metrics-anomaly/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| annotations | object | `{}` | Annotations to be added to the deployment |
| config | object | `{"models":{},"preset":"","reader":{"class":"vm","datasource_url":"","queries":{},"sampling_period":"1m","tenant_id":""},"schedulers":{},"writer":{"class":"vm","datasource_url":"","tenant_id":""}}` | Full [vmanomaly config section](https://docs.victoriametrics.com/anomaly-detection/components/) |
| config.models | object | `{}` | [Models section](https://docs.victoriametrics.com/anomaly-detection/components/models/) |
| config.preset | string | `""` | Whether to use preset configuration. If not empty, preset name should be specified. |
| config.reader | object | `{"class":"vm","datasource_url":"","queries":{},"sampling_period":"1m","tenant_id":""}` | [Reader section](https://docs.victoriametrics.com/anomaly-detection/components/reader/) |
| config.reader.class | string | `"vm"` | Name of the class needed to enable reading from VictoriaMetrics or Prometheus. VmReader is the default option, if not specified. |
| config.reader.datasource_url | string | `""` | Datasource URL address. Required for example "http://single-victoria-metrics-single-server.default.svc.cluster.local:8428" or "http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480/insert/" |
| config.reader.queries | object | `{}` | Required. PromQL/MetricsQL query to select data in format: QUERY_ALIAS: "QUERY". As accepted by "/query_range?query=%s". See https://docs.victoriametrics.com/anomaly-detection/components/reader/#per-query-parameters for more details. |
| config.reader.sampling_period | string | `"1m"` | Frequency of the points returned. Will be converted to "/query_range?step=%s" param (in seconds). **Required** since 1.9.0. |
| config.reader.tenant_id | string | `""` | For VictoriaMetrics Cluster version only, tenants are identified by accountID or accountID:projectID. See VictoriaMetrics Cluster multitenancy docs |
| config.schedulers | object | `{}` | [Scheduler section](https://docs.victoriametrics.com/anomaly-detection/components/scheduler/) |
| config.writer | object | `{"class":"vm","datasource_url":"","tenant_id":""}` | [Writer section](https://docs.victoriametrics.com/anomaly-detection/components/writer/) |
| config.writer.class | string | `"vm"` | Name of the class needed to enable writing to VictoriaMetrics or Prometheus. VmWriter is the default option, if not specified. |
| config.writer.datasource_url | string | `""` | Datasource URL address. Required for example "http://single-victoria-metrics-single-server.default.svc.cluster.local:8428" or "http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480/insert/" |
| config.writer.tenant_id | string | `""` | For VictoriaMetrics Cluster version only, tenants are identified by accountID or accountID:projectID. See VictoriaMetrics Cluster multitenancy docs |
| containerWorkingDir | string | `"/vmanomaly"` |  |
| emptyDir | object | `{}` |  |
| env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) |
| envFrom | list | `[]` |  |
| eula | bool | `false` | should be true and means that you have the legal right to run a vmanomaly that can either be a signed contract or an email with confirmation to run the service in a trial period https://victoriametrics.com/legal/esa/ |
| extraArgs.loggerFormat | string | `"json"` |  |
| extraContainers | list | `[]` |  |
| extraHostPathMounts | list | `[]` | Additional hostPath mounts |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| fullnameOverride | string | `""` |  |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| image.registry | string | `""` | Victoria Metrics anomaly Docker registry |
| image.repository | string | `"victoriametrics/vmanomaly"` | Victoria Metrics anomaly Docker repository and image name |
| image.tag | string | `"v1.15.4"` | Tag of Docker image |
| imagePullSecrets | list | `[]` |  |
| license | object | `{"key":"","secret":{"key":"","name":""}}` | License key configuration for vmanomaly. See [docs](https://docs.victoriametrics.com/vmanomaly.html#licensing) Required starting from v1.5.0. |
| license.key | string | `""` | License key for vmanomaly |
| license.secret | object | `{"key":"","name":""}` | Use existing secret with license key for vmanomaly |
| license.secret.key | string | `""` | Key in secret with license key |
| license.secret.name | string | `""` | Existing secret name |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | NodeSelector configurations. Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| persistentVolume | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","matchLabels":{},"size":"1Gi","storageClassName":""}` | Persistence to store models on disk. Available starting from v1.13.0 |
| persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| persistentVolume.annotations | object | `{}` | Persistant volume annotations |
| persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for models dump. |
| persistentVolume.existingClaim | string | `""` | Existing Claim name. If defined, PVC must be created manually before volume will be bound |
| persistentVolume.matchLabels | object | `{}` | Bind Persistent Volume by labels. Must match all labels of targeted PV. |
| persistentVolume.size | string | `"1Gi"` | Size of the volume. Should be calculated based on the metrics you send and retention policy you set. |
| persistentVolume.storageClassName | string | `""` | StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically |
| podAnnotations | object | `{}` | Annotations to be added to pod |
| podDisruptionBudget | object | `{"enabled":false,"labels":{},"maxUnavailable":1,"minAvailable":1}` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| podMonitor.annotations | object | `{}` |  |
| podMonitor.enabled | bool | `false` |  |
| podMonitor.extraLabels | object | `{}` |  |
| podSecurityContext.enabled | bool | `true` |  |
| resources | object | `{}` |  |
| securityContext.enabled | bool | `true` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| tolerations | list | `[]` | Tolerations configurations. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |