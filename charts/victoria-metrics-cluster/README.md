# Victoria Metrics Helm Chart for Cluster Version

## Prerequisites Details
* [Victoria Metrics helm repository](https://github.com/VictoriaMetrics/helm-charts/#usage) is added.
* PV support on underlying infrastructure


## Chart Details
This chart will do the following:

* Rollout victoria metrics cluster

## Installing the Chart

### 

To install the chart with the release name `my-release`:

```console
helm install -n my-release vm/victoria-metrics-cluster
```

## Configuration

The following table lists the configurable parameters of the victoria metrics cluster chart and their default values.

| Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `clusterDomainSuffix`        | k8s cluster domain suffix, uses for building stroage pods' FQDN. [https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)               | `cluster.local` (k8s default)                                                  |
| `vmselect.enabled`           | Enable deployment of vmselect component. Can be deployed as Deployment(default) or StatefulSet                 | `true`                       |
| `vmselect.name`              | Vmselect container name                   | `vmselect`                                                    |
| `vmselect.image.repository`  | Image repository                 | `victoriametrics/vmselect`                                                   |
| `vmselect.image.tag`         | Image tag              | `v1.32.2-cluster`                                                        |
| `vmselect.image.pullPolicy`  | Image pull policy                      | `IfNotPresent`                                                   |
| `vmselect.priorityClassName` | Name of Priority Class | `""`                                |
| `vmselect.fullnameOverride`  | Overrides the full name of vmselect component  | `""`                                |
| `vmselect.extraArgs`         | Extra command line arguments for vmselect component               | `{}`
| `vmselect.tolerations`       | Array of tolerations object. [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)                | `{}`                                 |
| `vmselect.nodeSelector`      | Pod's node selector. [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/)| `{}`
| `vmselect. affinity `      | Pod affinity| `{}`
| `vmselect.podAnnotations`    | Pod's annotations     | `{}`                                                     |
| `vmselect.replicaCount`      | Count of vmselect pods | `2`                                                       |
| `vmselect.resources`         | Resource object    | `{}`                                                     |
| `vmselect.securityContext`   | Pod's security context. [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)      | `{}`                                                      |
| `vmselect.cacheMountPath`    | Cache root folder                | `/cache`                                                      |
| `vmselect.service.annotations` | Service annotations       | `{}`                                                      |
| `vmselect.service.labels`      | Service lables            | `{}`                                                     |
| `vmselect.service.clusterIP`   | Service ClusterIP | `""`                                                       |
| `vmselect.service.externalIPs`  | Service External IPs. [ https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips)                     | `[]`                                                      |
| `vmselect.service.loadBalancerIP`               | Service load balacner IP             | `"`                                                     |
| `vmselect.service.loadBalancerSourceRanges`     | Load balancer source range     | `[]`                                                     |
| `vmselect.service.servicePort`        | Service port | `8481`                                                     |
| `vmselect.service.type`           | Service type     | `ClusterIP`                                                     |
| `vmselect.ingress.enabled`        | Enable deployment of ingress for vmselect component | `false`                                                     |
| `vmselect.ingress.annotations`    | Ingress annotations       | `{}`                                                     |
| `vmselect.ingress.hosts`         | Array of host objects          | `[]`                                                     |
| `vmselect.ingress.tls`              | Array of TLS objects              | `[]`                                          |
| `vmselect.statefulSet.enabled`          | Deploy StatefulSet instread of Deployment for vmselect. Usefull if you want to keep cache data        | `false` |
| `vmselect.statefulSet.podManagementPolicy`           | Deploy order policy for StatefulSet pods        | `OrderedReady`                  |
| `vmselect.statefulSet.service.annotations`        | Headless service annotations | `{}`                                                        |
| `vmselect.statefulSet.service.labels`            | Headless service labels                  | `{}`                                                     |
| `vmselect.statefulSet.service.servicePort`     | Headless service port      | `8481`                                                    |
| `vmselect.persistentVolume.enabled` | Create/use Persistent Volume Claim for vmselect component. Empty dir if false  | `false`|
| `vmselect.persistentVolume.accessModes`      | Array of access modes       | `["ReadWriteOnce"]`                                                       |
| `vmselect.persistentVolume.annotations`      | Persistant volume annotations      | `{}`                                                       |
| `vmselect.persistentVolume.existingClaim`         | Existing Claim name        | `""`                                                       |
| `vmselect.persistentVolume.size`     | Size of the volume. Better to set the same as resource limit memory property    | `2Gi`                          |
| `vmselect.persistentVolume.subPath`        | Mount subpath       | `""`                                                 |
| `vmselect.serviceMonitor.enabled` | Enable deployment of Service Monitor for vmselect component. This is Prometheus operatior object      | `false`     |
| `vmselect.serviceMonitor.extraLabels`  | Service Monitor labels        | `{}`                                                    |
| `vmselect.serviceMonitor.annotations`       | Service Monitor annotations | `{}`                                    |
| `vmselect.serviceMonitor.interval`       | Commented. Prometheus scare interval for vmselect component| `15s`                                    |
| `vmselect.serviceMonitor.scrapeTimeout`       | Commented. Prometheus pre-scrape timeout for vmselect component| `5s`                                    |
| `vminsert.enabled`           | Enable deployment of vminsert component. Deployment is used             | `true`                       |
| `vminsert.name`              | vminsert container name                   | `vminsert`                                                    |
| `vminsert.image.repository`  | Image repository                 | `victoriametrics/vminsert`                                                   |
| `vminsert.image.tag`         | Image tag              | `v1.32.2-cluster`                                                        |
| `vminsert.image.pullPolicy`  | Image pull policy                      | `IfNotPresent`                                                   |
| `vminsert.priorityClassName` | Name of Priority Class | `""`                                |
| `vminsert.fullnameOverride`  | Overrides the full name of vminsert component  | `""`                                |
| `vminsert.extraArgs`         | Extra command line arguments for vminsert component               | `{}`
| `vminsert.tolerations`       | Array of tolerations object. [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)                | `{}`                                 |
| `vminsert.nodeSelector`      | Pod's node selector. [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/)| `{}`
| `vmselect. affinity `      | Pod affinity| `{}`
| `vminsert.podAnnotations`    | Pod's annotations     | `{}`                                                     |
| `vminsert.replicaCount`      | Count of vminsert pods | `2`                                                       |
| `vminsert.resources`         | Resource object    | `{}`                                                     |
| `vminsert.securityContext`   | Pod's security context. [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)      | `{}`                                                      |
| `vminsert.service.annotations` | Service annotations       | `{}`                                                      |
| `vminsert.service.labels`      | Service lables            | `{}`                                                     |
| `vminsert.service.clusterIP`   | Service ClusterIP | `""`                                                       |
| `vminsert.service.externalIPs`  | Service External IPs. [ https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips)                     | `[]`                                                      |
| `vminsert.service.loadBalancerIP`               | Service load balacner IP             | `"`                                                     |
| `vminsert.service.loadBalancerSourceRanges`     | Load balancer source range     | `[]`                                                     |
| `vminsert.service.servicePort`        | Service port | `8480`                                                     |
| `vminsert.service.type`           | Service type     | `ClusterIP`                                                     |
| `vminsert.ingress.enabled`        | Enable deployment of ingress for vminsert component | `false`                                                     |
| `vminsert.ingress.annotations`    | Ingress annotations       | `{}`                                                     |
| `vminsert.ingress.hosts`         | Array of host objects          | `[]`                                                     |
| `vminsert.ingress.tls`              | Array of TLS objects              | `[]`                                          |
| `vminsert.serviceMonitor.enabled` | Enable deployment of Service Monitor for vminsert component. This is Prometheus operatior object      | `false`     |
| `vminsert.serviceMonitor.extraLabels`  | Service Monitor labels        | `{}`                                                    |
| `vminsert.serviceMonitor.annotations`       | Service Monitor annotations | `{}`                                    |
| `vminsert.serviceMonitor.interval`       | Commented. Prometheus scare interval for vminsert component| `15s`                                    |
| `vminsert.serviceMonitor.scrapeTimeout`       | Commented. Prometheus pre-scrape timeout for vminsert component| `5s`                                    |
| `vmstorage.enabled`           | Enable deployment of vmstorage component. StatefulSet is used               | `true`                       |
| `vmstorage.name`              | vmstorage container name                   | `vmstorage`                                                    |
| `vmstorage.image.repository`  | Image repository                 | `victoriametrics/vmstorage`                                                   |
| `vmstorage.image.tag`         | Image tag              | `v1.32.2-cluster`                                                        |
| `vmstorage.image.pullPolicy`  | Image pull policy                      | `IfNotPresent`                                                   |
| `vmstorage.priorityClassName` | Name of Priority Class | `""`                                |
| `vmstorage.fullnameOverride`  | Overrides the full name of vmstorage component  | `""`                                |
| `vmstorage.retentionPeriod`   | Data retention period in month | `1`                                |
| `vmstorage.extraArgs`         | Extra command line arguments for vmstorage component               | `{}`
| `vmstorage.tolerations`       | Array of tolerations object. [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)                | `{}`                                 |
| `vmstorage.nodeSelector`      | Pod's node selector. [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/)| `{}`
| `vmstorage.affinity `         | Pod affinity| `{}` |
| `vmstorage.persistentVolume.enabled` | Create/use Persistent Volume Claim for vmstorage component. Empty dir if false  | `true`|
| `vmstorage.persistentVolume.accessModes`      | Array of access modes       | `["ReadWriteOnce"]`                                                       |
| `vmstorage.persistentVolume.annotations`      | Persistant volume annotations      | `{}`                                                       |
| `vmstorage.persistentVolume.existingClaim`         | Existing Claim name        | `""`                                                       |
| `vmstorage.persistentVolume.mountPath`         | Data root path        | `"/storage"`                                                       |
| `vmstorage.persistentVolume.size`     | Size of the volume. Better to set the same as resource limit memory property    | `2Gi`                          |
| `vmstorage.persistentVolume.subPath`        | Mount subpath       | `""`                          |
| `vmstorage.podAnnotations`    | Pod's annotations     | `{}`   | 
| `vmstorage.replicaCount`      | Count of vmstorage pods | `2`                                                       |
| `vmstorage.podManagementPolicy `    | Deploy order policy for StatefulSet pods     | `OrderedReady`   | 
| `vmstorage.resources`         | Resource object    | `{}`                                                     |
| `vmstorage.securityContext`   | Pod's security context. [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)      | `{}`                                                      |
| `vmstorage.service.annotations` | Service annotations       | `{}`                                                      |
| `vmstorage.service.labels`      | Service lables            | `{}`                                                     |
| `vmstorage.service.servicePort` | Service port            | `8482`                                                     |
| `vmstorage.service.vminsertPort`| Port for accepting connections from vminsert            | `8400`                                                     |
| `vmstorage.service.vmselectPort`      | Port for accepting connections from vmselect           | `8401`                                                     |
| `vmstorage.terminationGracePeriodSeconds`      | Pod's termination grace period in seconds          | `60`                                                     |
| `vmstorage.serviceMonitor.enabled` | Enable deployment of Service Monitor for vmstorage component. This is Prometheus operatior object      | `false`     |
| `vmstorage.serviceMonitor.extraLabels`  | Service Monitor labels        | `{}`                                                    |
| `vmstorage.serviceMonitor.annotations`       | Service Monitor annotations | `{}`                                    |
| `vmstorage.serviceMonitor.interval`       | Commented. Prometheus scare interval for vmstorage component| `15s`                                    |
| `vmstorage.serviceMonitor.scrapeTimeout`       | Commented. Prometheus pre-scrape timeout for vmstorage component| `5s`                                    |



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install -n my-release -f values.yaml vm/victoria-metrics-cluster
```

> **Tip**: You can use the default [values.yaml](values.yaml)

