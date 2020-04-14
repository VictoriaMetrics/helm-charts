# Victoria Metrics Helm Chart for Single Version

## Prerequisites Details
* [Victoria Metrics helm repository](https://github.com/VictoriaMetrics/helm-charts/#usage) is added.
* PV support on underlying infrastructure


## Chart Details
This chart will do the following:

* Rollout victoria metrics single 

## Installing the Chart

### 

To install the chart with the release name `my-release`:

```console
helm install -n my-release vm/victoria-metrics-single
```

## Configuration

The following table lists the configurable parameters of the victoria metrics cluster chart and their default values.

| Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `server.enabled`           | Enable deployment of server component. Deployed as StatefulSet                 | `true`                       |
| `server.name`              | Server container name                   | `server`                                                    |
| `server.image.repository`  | Image repository                 | `victoriametrics/victoria-metrics`                                                   |
| `server.image.tag`         | Image tag              | `v1.32.8`                                                        |
| `server.image.pullPolicy`  | Image pull policy                      | `IfNotPresent`                                                   |
| `server.priorityClassName` | Name of Priority Class | `""`                                |
| `server.fullnameOverride`  | Overrides the full name of server component  | `""`                                |
| `server.retentionPeriod`  | Data retention period in month  | `1`                                |
| `server.extraArgs`         | Extra command line arguments for server component               | `{}`
| `server.tolerations`       | Array of tolerations object. [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)                | `{}`                                 |
| `server.nodeSelector`      | Pod's node selector. [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/)| `{}`
| `server.affinity `       | Pod affinity| `{}`
| `server.persistentVolume.enabled` | Create/use Persistent Volume Claim for server component. Empty dir if false  | `true`|
| `server.persistentVolume.accessModes`      | Array of access modes       | `["ReadWriteOnce"]`                                                       |
| `server.persistentVolume.annotations`      | Persistant volume annotations      | `{}`                                                       |
| `server.persistentVolume.existingClaim`         | Existing Claim name        | `""`                                                       |
| `server.persistentVolume.storageClass`         | StorageClass to use for persistent volume       | `""`                                                       |
| `server.persistentVolume.size`     | Size of the volume. Better to set the same as resource limit memory property    | `16Gi`                          |
| `server.persistentVolume.mountPath`        | Mount path       | `""/storage`                                                 |
| `server.persistentVolume.subPath`        | Mount subpath       | `""`                                                 |
| `server.podAnnotations`    | Pod's annotations     | `{}`                                                     |
| `server.podManagementPolicy`    | Pod's management policy     | `OrderedReady`                                                     |
| `server.resources`         | Resource object    | `{}`                                                     |
| `server.securityContext`   | Pod's security context. [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)      | `{}`                                                      |
| `server.ingress.enabled`        | Enable deployment of ingress for server component | `false`                                                     |
| `server.ingress.annotations`    | Ingress annotations       | `{}`                                                     |
| `server.ingress.extraLabels`    | Ingress extra labels       | `{}`                                                     |
| `server.ingress.hosts`         | Array of host objects          | `[]`                                                     |
| `server.ingress.tls`              | Array of TLS objects              | `[]`                                          |
| `server.service.annotations` | Service annotations       | `{}`                                                      |
| `server.service.labels`      | Service labels            | `{}`                                                     |
| `server.service.clusterIP`   | Service ClusterIP | `""`                                                       |
| `server.service.externalIPs`  | Service External IPs. [ https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips)                     | `[]`                                                      |
| `server.service.loadBalancerIP`               | Service load balacner IP             | `"`                                                     |
| `server.service.loadBalancerSourceRanges`     | Load balancer source range     | `[]`                                                     |
| `server.service.servicePort`        | Service port | `8428`                                                     |
| `server.service.type`           | Service type     | `ClusterIP`                                                     |
| `server.statefulSet.enabled`      | Deploy StatefulSet instead of Deployment         | `true`                                                     |
| `server.statefulSet.podManagementPolicy`      | Deploy order policy for StatefulSet pods           | `OrderedReady`                                                     |
| `server.statefulSet.service.annotations`      | Headless service annotations          | `{}`                                                     |
| `server.statefulSet.service.labels`      | Headless service labels           | `{}`                                                     |
| `server.statefulSet.service.servicePort`      | Headless service port          | `60`                                                     |
| `server.terminationGracePeriodSeconds`      | Pod's termination grace period in seconds          | `60`                                                     |

| `server.serviceMonitor.enabled` | Enable deployment of Service Monitor for server component. This is Prometheus operator object      | `false`     |
| `server.serviceMonitor.extraLabels`  | Service Monitor labels        | `{}`                                                    |
| `server.serviceMonitor.annotations`       | Service Monitor annotations | 8428                                    |
| `server.serviceMonitor.interval`       | Commented. Prometheus scare interval for server component| `15s`                                    |
| `server.serviceMonitor.scrapeTimeout`       | Commented. Prometheus pre-scrape timeout for server component| `5s`                                    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install -n my-release -f values.yaml vm/victoria-metrics-single
```

> **Tip**: You can use the default [values.yaml](values.yaml)

