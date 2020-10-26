# Helm Chart For Victoria Metrics Auth.

 ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

Victoria Metrics Auth - is a simple auth proxy and router for VictoriaMetrics.

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-auth`` chart available to installation:

##### for helm v3

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

##### for helm v3

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

# How to uninstall

Remove application with command.

```console
helm uninstall vmauth -n NAMESPACE
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-auth

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-auth/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| config.users[0].password | string | `"***"` |  |
| config.users[0].url_prefix | string | `"http://localhost:8428"` |  |
| config.users[0].username | string | `"local-single-node"` |  |
| config.users[1].password | string | `"***"` |  |
| config.users[1].url_prefix | string | `"http://vmselect:8481/select/123/prometheus"` |  |
| config.users[1].username | string | `"cluster-select-account-123"` |  |
| config.users[2].password | string | `"***"` |  |
| config.users[2].url_prefix | string | `"http://vminsert:8480/insert/42/prometheus"` |  |
| config.users[2].username | string | `"cluster-insert-account-42"` |  |
| configMap | string | `""` |  |
| containerWorkingDir | string | `"/"` |  |
| env | list | `[]` |  |
| extraArgs."envflag.enable" | string | `"true"` |  |
| extraArgs."envflag.prefix" | string | `"VM_"` |  |
| extraArgs.loggerFormat | string | `"json"` |  |
| extraHostPathMounts | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"victoriametrics/vmauth"` |  |
| image.tag | string | `"v1.44.0-cluster"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraLabels | object | `{}` |  |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.extraLabels | object | `{}` |  |
| persistence.size | string | `"10Gi"` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.labels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.create | bool | `true` |  |
| rbac.extraLabels | object | `{}` |  |
| rbac.pspEnabled | bool | `true` |  |
| remoteWriteUrls | list | `[]` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.enabled | bool | `true` |  |
| service.externalIPs | list | `[]` |  |
| service.extraLabels | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.servicePort | int | `8427` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.extraLabels | object | `{}` |  |
| tolerations | list | `[]` |  |