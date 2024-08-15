# Helm Chart For Victoria Metrics Auth.

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.4.14](https://img.shields.io/badge/Version-0.4.14-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-auth)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)

Victoria Metrics Auth - is a simple auth proxy and router for VictoriaMetrics.

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-auth`` chart available to installation:

```console
helm search repo vm/victoria-metrics-auth -l
```

Export default values of ``victoria-metrics-auth`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-auth > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmauth vm/victoria-metrics-auth -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmauth vm/victoria-metrics-auth -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmauth'
```

Get the application by running this command:

```console
helm list -f vmauth -n NAMESPACE
```

See the history of versions of ``vmauth`` application with command.

```console
helm history vmauth -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmauth -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-auth

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-auth/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| annotations | object | `{}` | Annotations to be added to the deployment |
| config | string | `nil` | Config file content. |
| containerWorkingDir | string | `"/"` |  |
| env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://docs.victoriametrics.com/#environment-variables |
| envFrom | list | `[]` |  |
| extraArgs."envflag.enable" | string | `"true"` |  |
| extraArgs."envflag.prefix" | string | `"VM_"` |  |
| extraArgs.loggerFormat | string | `"json"` |  |
| extraContainers | list | `[]` |  |
| extraHostPathMounts | list | `[]` | Additional hostPath mounts |
| extraLabels | object | `{}` | Labels to be added to the deployment and pods |
| extraObjects | list | `[]` | Add extra specs dynamically to this chart |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| fullnameOverride | string | `""` |  |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| image.registry | string | `""` | Image registry |
| image.repository | string | `"victoriametrics/vmauth"` | Victoria Metrics Auth Docker repository and image name |
| image.tag | string | `""` | Tag of Docker image |
| image.variant | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraLabels | object | `{}` |  |
| ingress.hosts | list | `[]` |  |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` |  |
| ingressInternal.annotations | object | `{}` |  |
| ingressInternal.enabled | bool | `false` |  |
| ingressInternal.extraLabels | object | `{}` |  |
| ingressInternal.hosts | list | `[]` |  |
| ingressInternal.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingressInternal.tls | list | `[]` |  |
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
| probe.readiness.initialDelaySeconds | int | `5` |  |
| probe.readiness.periodSeconds | int | `15` |  |
| probe.readiness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| probe.startup | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.extraLabels | object | `{}` |  |
| replicaCount | int | `1` | Number of replicas of vmauth |
| resources | object | `{}` | We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| secretName | string | `""` | Use existing secret if specified otherwise .config values will be used. Ref: https://victoriametrics.github.io/vmauth.html. Configuration in the given secret must be stored under `auth.yml` key. |
| securityContext.enabled | bool | `true` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.enabled | bool | `true` |  |
| service.externalIPs | list | `[]` |  |
| service.extraLabels | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.servicePort | int | `8427` |  |
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