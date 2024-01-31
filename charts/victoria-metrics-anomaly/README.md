# Victoria Metrics Helm Chart for vmanomaly

![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square)
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

Change the values according to the need of the environment in ``victoria-metrics-anomaly/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| annotations | object | `{}` | Annotations to be added to the deployment |
| containerWorkingDir | string | `"/vmanomaly"` |  |
| env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) |
| envFrom | list | `[]` | Additional environment variables by referencing secrets or configmaps |
| eula | bool | `false` | should be true and means that you have the legal right to run a vmanomaly that can either be a signed contract or an email with confirmation to run the service in a trial period https://victoriametrics.com/legal/esa/ |
| extraArgs.loggerFormat | string | `"json"` |  |
| extraContainers | list | `[]` |  |
| extraHostPathMounts | list | `[]` | Additional hostPath mounts |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| extra_labels | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| image.repository | string | `"us-docker.pkg.dev/victoriametrics-test/public/vmanomaly-trial"` | Victoria Metrics anomaly Docker repository and image name |
| image.tag | string | `""` | Tag of Docker image |
| imagePullSecrets | list | `[]` |  |
| license | object | `{"key":"","secret":{"key":"","name":""}}` | License key configuration for vmanomaly. See https://docs.victoriametrics.com/vmanomaly.html#licensing Required starting from v1.5.0. |
| license.key | string | `""` | License key for vmanomaly |
| license.secret | object | `{"key":"","name":""}` | Use existing secret with license key for vmanomaly |
| license.secret.key | string | `""` | Key in secret with license key |
| license.secret.name | string | `""` | Existing secret name |
| model.enabled | string | `"prophet"` | Available options: zscore, prophet, holt_winters |
| model.holt_winters.frequency | string | `"1h"` |  |
| model.holt_winters.seasonality | string | `"1d"` |  |
| model.prophet.interval_width | float | `0.98` |  |
| model.zscore.z_threshold | float | `2.5` |  |
| monitoring | object | `{"pull":{"enabled":false,"port":8440},"push":{"extra_labels":{"job":"vmanomaly-push"},"url":""}}` | vmanomaly internal monitoring in Prometheus format |
| monitoring.pull.enabled | bool | `false` | if true expose metrics on /metrics endpoint |
| monitoring.pull.port | int | `8440` | port for /metrics endpoint |
| monitoring.push.url | string | `""` | push metrics on prometheus format if defined |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | NodeSelector configurations. Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` | Annotations to be added to pod |
| podDisruptionBudget | object | `{"enabled":false,"labels":{}}` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| podSecurityContext | object | `{}` |  |
| queries | object | `{}` | Query names and expressions. Required. Examples:  active_timeseries: 'sum(vm_cache_entries{type="storage/hour_metric_ids"})'  churn_rate: 'sum(rate(vm_new_timeseries_created_total[5m]))'  ingestion_rate: 'sum(rate(vm_rows_inserted_total[5m])) by (type,accountID) > 0'  insertion_rate: 'sum(rate(vm_http_requests_total{path=~"/api/v1/write|.*insert.*"}[5m])) by (path) > 0'  slow_inserts: 'sum(rate(vm_slow_row_inserts_total[5m])) / sum(rate(vm_rows_inserted_total[5m]))' |
| remote.read.basicAuth.password | string | `""` |  |
| remote.read.basicAuth.username | string | `""` |  |
| remote.read.bearer_token | string | `""` | Bearer token to use for authentication |
| remote.read.extra_filters | list | `[]` | List of extra filters to apply to all queries. See: https://docs.victoriametrics.com/#prometheus-querying-api-enhancements |
| remote.read.health | string | `""` | Health endpoint. vmanomaly add /health to url if it's empty. You can specify full path when VictoriaMetircs is hidden via vmauth or other proxies/balancers |
| remote.read.tenant_id | string | `""` | When read from VictoriaMetrics cluster. Format: vm_account_id:vm_project_id (for example: 0:0) or vm_account_id (for example 0). See https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html#multitenancy |
| remote.read.url | string | `""` | URL for data reading. Required for example "http://single-victoria-metrics-single-server.default.svc.cluster.local:8428" or "http://cluster-victoria-metrics-cluster-vmselect.default.svc.cluster.local:8481/select/" |
| remote.read.verify_tls | bool | `true` | Whether to verify TLS certificates when connecting to read endpoint |
| remote.write.basicAuth.password | string | `""` |  |
| remote.write.basicAuth.username | string | `""` |  |
| remote.write.bearer_token | string | `""` | Bearer token to use for authentication |
| remote.write.health | string | `""` | Health endpoint. vmanomaly add /health to url if it's empty. You can specify full path when VictoriaMetircs is hidden via vmauth or other proxies/balancers |
| remote.write.metric_format.name | string | `"$VAR"` |  |
| remote.write.metric_format.query_key | string | `"query"` |  |
| remote.write.tenant | string | `""` | When write to VictoriaMetrics cluster. Format: vm_account_id:vm_project_id (for example: 0:0) or vm_account_id (for example 0). See https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html#multitenancy |
| remote.write.url | string | `""` | URL for data writing. Required for example "http://single-victoria-metrics-single-server.default.svc.cluster.local:8428" or "http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480/insert/" |
| remote.write.verify_tls | bool | `true` | Whether to verify TLS certificates when connecting to write endpoint |
| resources | object | `{}` |  |
| samplingPeriod | string | `"1m"` |  |
| scheduler.class | string | `"scheduler.periodic.PeriodicScheduler"` |  |
| scheduler.fit_every | string | `"2h"` |  |
| scheduler.fit_window | string | `"14d"` |  |
| scheduler.infer_every | string | `"1m"` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.extraLabels | object | `{}` |  |
| tolerations | list | `[]` | Tolerations configurations. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |