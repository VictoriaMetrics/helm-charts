# Helm Chart For Victoria Metrics Operator.

 ![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square)

Victoria Metrics Operator

# Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure.

# Chart Details

This chart will do the following:

* Rollout victoria metrics operator

# How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-operator`` chart available to installation:

##### for helm v3

```console
helm search repo vm/victoria-metrics-operator -l
```

Export default values of ``victoria-metrics-operator`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-operator > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmoperator vm/victoria-metrics-operator -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

##### for helm v3

```console
helm install vmoperator vm/victoria-metrics-operator -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'operator'
```

Get the application by running this command:

```console
helm list -f vmoperator -n NAMESPACE
```

See the history of versions of ``vmoperator`` application with command.

```console
helm history vmoperator -n NAMESPACE
```

# How to uninstall

Remove application with command.

```console
helm uninstall vmoperator -n NAMESPACE
```

# Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-operator

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

# Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-operator/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity |
| env | list | `[]` |  |
| fullnameOverride | string | `""` | Overrides the full name of server component |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"victoriametrics/operator"` | Image repository |
| image.tag | string | `"v0.4.0"` | Image tag |
| imagePullSecrets | list | `[]` | Secret to pull images |
| logLevel | string | `"info"` | VM operator log level |
| nameOverride | string | `""` | VM operatror deployment name overrid |
| nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/ |
| rbac.create | bool | `true` | Specifies whether the RBAC resources should be created |
| resources | object | `{"limits":{"cpu":"120m","memory":"320Mi"},"requests":{"cpu":"80m","memory":"120Mi"}}` | Resource object |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |