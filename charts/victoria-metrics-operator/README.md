# Victoria Metrics Helm Chart for VM Operator

## Prerequisites Details
* [Victoria Metrics helm repository](https://github.com/VictoriaMetrics/helm-charts/#usage) is added.
* PV support on underlying infrastructure


## Chart Details
This chart will do the following:

* Rollout victoria metrics operator

## Installing the Chart

### 

To install the chart with the release name `my-release`:

```console
helm install -n my-release vm/victoria-metrics-operator
```

## Configuration

The following table lists the configurable parameters of the victoria metrics operator chart and their default values.

| Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `nameOverride`              | VM operatror deployment name override                   |`                                                    |
| `fullnameOverride`  | Overrides the full name of server component  | `""`                                |
| `image.repository`  | Image repository                 | `victoriametrics/operator`                                                   |
| `image.tag`         | Image tag              | `v0.2.1`                                                        |
| `image.pullPolicy`  | Image pull policy                      | `IfNotPresent`                                                   |
| `imagePullSecrets`  | Secret to pull images               |    |
| `logLevel`          | VM operator log level | `info` |
| `tolerations`       | Array of tolerations object. [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)                | `{}`                                 |
| `nodeSelector`      | Pod's node selector. [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/)| `{}`
| `affinity `         | Pod affinity| `{}`
| `resources`         | Resource object    | `{}`                                                     |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install -n my-release -f values.yaml vm/victoria-metrics-operator
```

> **Tip**: You can use the default [values.yaml](values.yaml)
