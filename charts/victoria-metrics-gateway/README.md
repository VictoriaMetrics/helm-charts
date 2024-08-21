# Victoria Metrics Helm Chart for vmgateway

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-gateway)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)

Victoria Metrics Gateway - Auth & Rate-Limitting proxy for Victoria Metrics

# Table of Content

* [Prerequisites](#prerequisites)
* [Chart Details](#chart-details)
* [How to Install](#how-to-install)
* [How to Uninstall](#how-to-uninstall)
* [How to use JWT signature verification](#how-to-use-jwt-signature-verification)
* [Documentation of Helm Chart](#documentation-of-helm-chart)

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).
* PV support on underlying infrastructure

## Chart Details

This chart will do the following:

* Rollout victoria metrics gateway

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-gateway`` chart available to installation:

```console
helm search repo vm/victoria-metrics-gateway -l
```

Export default values of ``victoria-metrics-gateway`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-gateway > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmgateway vm/victoria-metrics-gateway -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmgateway vm/victoria-metrics-gateway -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmgateway'
```

Get the application by running this command:

```console
helm list -f vmgateway -n NAMESPACE
```

See the history of versions of ``vmgateway`` application with command.

```console
helm history vmgateway -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmgateway -n NAMESPACE
```

# How to use [JWT signature verification](https://docs.victoriametrics.com/vmgateway.html#jwt-signature-verification)

Kubernetes best-practice is to store sensitive configuration parts in secrets. For example, 2 keys will be stored as:
```yaml
apiVersion: v1
data:
  key: "<<KEY_DATA>>"
kind: Secret
metadata:
  name: key1
---
apiVersion: v1
data:
  key: "<<KEY_DATA>>"
kind: Secret
metadata:
  name: key2
```

In order to use those secrets it is needed to:
- mount secrets into pod
- provide flag pointing to secret on disk

Here is an example `values.yml` file configuration to achieve this:
```yaml
auth:
  enable: true

extraVolumes:
  - name: key1
    secret:
      secretName: key1
  - name: key2
    secret:
      secretName: key2

extraVolumeMounts:
  - name: key1
    mountPath: /key1
  - name: key2
    mountPath: /key2

extraArgs:
  envflag.enable: "true"
  envflag.prefix: VM_
  loggerFormat: json
  auth.publicKeyFiles: "/key1/key,/key2/key"
```
Note that in this configuration all secret keys will be mounted and accessible to pod.
Please, refer to [this](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#secretvolumesource-v1-core) doc to see all available secret source options.

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-gateway

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-gateway/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| annotations | object | `{}` | Annotations to be added to the deployment |
| auth | object | `{"enable":false}` | Access Control configuration. https://docs.victoriametrics.com/vmgateway.html#access-control |
| auth.enable | bool | `false` | Enable/Disable access-control |
| clusterMode | bool | `false` | Specify to True if the source for rate-limiting, reading and writing as a VictoriaMetrics Cluster. Must be true for rate limiting |
| configMap | string | `""` | Use existing configmap if specified otherwise .config values will be used. Ref: https://victoriametrics.github.io/vmgateway.html |
| containerWorkingDir | string | `"/"` |  |
| env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://github.com/VictoriaMetrics/VictoriaMetrics#environment-variables |
| envFrom | list | `[]` |  |
| eula | bool | `false` | should be true and means that you have the legal right to run a vmgateway that can either be a signed contract or an email with confirmation to run the service in a trial period https://victoriametrics.com/legal/esa/ |
| extraArgs."envflag.enable" | string | `"true"` |  |
| extraArgs."envflag.prefix" | string | `"VM_"` |  |
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
| image.registry | string | `""` | Victoria Metrics gateway Docker registry |
| image.repository | string | `"victoriametrics/vmgateway"` | Victoria Metrics gateway Docker repository and image name |
| image.tag | string | `""` | Tag of Docker image override Chart.AppVersion |
| image.variant | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraLabels | object | `{}` |  |
| ingress.hosts | list | `[]` |  |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` |  |
| license | object | `{"key":"","secret":{"key":"","name":""}}` | Enterprise license key configuration for VictoriaMetrics enterprise. Required only for VictoriaMetrics enterprise. Documentation - https://docs.victoriametrics.com/enterprise.html, for more information, visit https://victoriametrics.com/products/enterprise/ . To request a trial license, go to https://victoriametrics.com/products/enterprise/trial/ Supported starting from VictoriaMetrics v1.94.0 |
| license.key | string | `""` | License key |
| license.secret | object | `{"key":"","name":""}` | Use existing secret with license key |
| license.secret.key | string | `""` | Key in secret with license key |
| license.secret.name | string | `""` | Existing secret name |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | NodeSelector configurations. Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` | Annotations to be added to pod |
| podDisruptionBudget | object | `{"enabled":false,"labels":{}}` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| podSecurityContext.enabled | bool | `true` |  |
| probe.liveness.initialDelaySeconds | int | `5` |  |
| probe.liveness.periodSeconds | int | `15` |  |
| probe.liveness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| probe.liveness.timeoutSeconds | int | `5` |  |
| probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| probe.readiness.httpGet.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| probe.readiness.initialDelaySeconds | int | `5` |  |
| probe.readiness.periodSeconds | int | `15` |  |
| probe.startup | object | `{}` |  |
| rateLimiter | object | `{"config":{},"datasource":{"url":""},"enable":false}` | Rate limiter configuration. Docs https://docs.victoriametrics.com/vmgateway.html#rate-limiter |
| rateLimiter.datasource.url | string | `""` | Datasource VictoriaMetrics or vmselects. Required. Example http://victoroametrics:8428 or http://vmselect:8481/select/0/prometheus |
| rateLimiter.enable | bool | `false` | Enable/Disable rate-limiting |
| read.url | string | `""` | Read endpoint without suffixes, victoriametrics or vmselect. Example http://victoroametrics:8428 or http://vmselect:8481 |
| replicaCount | int | `1` | Number of replicas of vmgateway |
| resources | object | `{}` | We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| securityContext.enabled | bool | `true` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.enabled | bool | `true` |  |
| service.externalIPs | list | `[]` |  |
| service.extraLabels | object | `{}` |  |
| service.ipFamilies | list | `[]` |  |
| service.ipFamilyPolicy | string | `""` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.servicePort | int | `8431` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for server component. This is Prometheus operator object |
| serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
| tolerations | list | `[]` | Tolerations configurations. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| write.url | string | `""` | Write endpoint without suffixes, victoriametrics or vminsert. Example http://victoroametrics:8428 or http://vminsert:8480 |