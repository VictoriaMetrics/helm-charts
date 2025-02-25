

![Version](https://img.shields.io/badge/0.8.16-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-logs-single%2Fchangelog%2F%230816)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-logs-single)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Logs Single version - high-performance, cost-effective and scalable logs storage

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

* PV support on underlying infrastructure.

## Chart Details

This chart will do the following:

* Rollout Victoria Logs Single.
* (optional) Rollout [vector](https://vector.dev/) to collect logs from pods.

Chart allows to configure logs collection from Kubernetes pods to VictoriaLogs.
In order to do that you need to enable vector:
```yaml
vector:
  enabled: true
```
By default, vector will forward logs to VictoriaLogs installation deployed by this chart.

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-logs-single` chart available to installation:

```console
helm search repo vm/victoria-logs-single -l
```

### Install `victoria-logs-single` chart

Export default values of `victoria-logs-single` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-logs-single > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-logs-single > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vls vm/victoria-logs-single -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vls oci://ghcr.io/victoriametrics/helm-charts/victoria-logs-single -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vls vm/victoria-logs-single -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vls oci://ghcr.io/victoriametrics/helm-charts/victoria-logs-single -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vls'
```

Get the application by running this command:

```console
helm list -f vls -n NAMESPACE
```

See the history of versions of `vls` application with command.

```console
helm history vls -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vls -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-logs-single

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-logs-single/values.yaml`` file.

<a id="helm-value-dashboards-annotations" href="#helm-value-dashboards-annotations" aria-hidden="true" tabindex="-1"></a>
[`dashboards.annotations`](#helm-value-dashboards-annotations)`(object)`: Dashboard annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-dashboards-enabled" href="#helm-value-dashboards-enabled" aria-hidden="true" tabindex="-1"></a>
[`dashboards.enabled`](#helm-value-dashboards-enabled)`(bool)`: Create VictoriaLogs dashboards
  ```helm-default
  false
  ```
   
<a id="helm-value-dashboards-grafanaoperator-enabled" href="#helm-value-dashboards-grafanaoperator-enabled" aria-hidden="true" tabindex="-1"></a>
[`dashboards.grafanaOperator.enabled`](#helm-value-dashboards-grafanaoperator-enabled)`(bool)`:
  ```helm-default
  false
  ```
   
<a id="helm-value-dashboards-grafanaoperator-spec-allowcrossnamespaceimport" href="#helm-value-dashboards-grafanaoperator-spec-allowcrossnamespaceimport" aria-hidden="true" tabindex="-1"></a>
[`dashboards.grafanaOperator.spec.allowCrossNamespaceImport`](#helm-value-dashboards-grafanaoperator-spec-allowcrossnamespaceimport)`(bool)`:
  ```helm-default
  false
  ```
   
<a id="helm-value-dashboards-grafanaoperator-spec-instanceselector-matchlabels-dashboards" href="#helm-value-dashboards-grafanaoperator-spec-instanceselector-matchlabels-dashboards" aria-hidden="true" tabindex="-1"></a>
[`dashboards.grafanaOperator.spec.instanceSelector.matchLabels.dashboards`](#helm-value-dashboards-grafanaoperator-spec-instanceselector-matchlabels-dashboards)`(string)`:
  ```helm-default
  grafana
  ```
   
<a id="helm-value-dashboards-labels" href="#helm-value-dashboards-labels" aria-hidden="true" tabindex="-1"></a>
[`dashboards.labels`](#helm-value-dashboards-labels)`(object)`: Dashboard labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-dashboards-namespace" href="#helm-value-dashboards-namespace" aria-hidden="true" tabindex="-1"></a>
[`dashboards.namespace`](#helm-value-dashboards-namespace)`(string)`: Override default namespace, where to create dashboards
  ```helm-default
  ""
  ```
   
<a id="helm-value-extraobjects" href="#helm-value-extraobjects" aria-hidden="true" tabindex="-1"></a>
[`extraObjects`](#helm-value-extraobjects)`(list)`: Add extra specs dynamically to this chart
  ```helm-default
  []
  ```
   
<a id="helm-value-global-cluster-dnsdomain" href="#helm-value-global-cluster-dnsdomain" aria-hidden="true" tabindex="-1"></a>
[`global.cluster.dnsDomain`](#helm-value-global-cluster-dnsdomain)`(string)`: K8s cluster domain suffix, uses for building storage pods' FQDN. Details are [here](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
  ```helm-default
  cluster.local.
  ```
   
<a id="helm-value-global-compatibility" href="#helm-value-global-compatibility" aria-hidden="true" tabindex="-1"></a>
[`global.compatibility`](#helm-value-global-compatibility)`(object)`: Openshift security context compatibility configuration
  ```helm-default
  openshift:
      adaptSecurityContext: auto
  ```
   
<a id="helm-value-global-image-registry" href="#helm-value-global-image-registry" aria-hidden="true" tabindex="-1"></a>
[`global.image.registry`](#helm-value-global-image-registry)`(string)`: Image registry, that can be shared across multiple helm charts
  ```helm-default
  ""
  ```
   
<a id="helm-value-global-imagepullsecrets" href="#helm-value-global-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`global.imagePullSecrets`](#helm-value-global-imagepullsecrets)`(list)`: Image pull secrets, that can be shared across multiple helm charts
  ```helm-default
  []
  ```
   
<a id="helm-value-nameoverride" href="#helm-value-nameoverride" aria-hidden="true" tabindex="-1"></a>
[`nameOverride`](#helm-value-nameoverride)`(string)`: Override chart name
  ```helm-default
  ""
  ```
   
<a id="helm-value-poddisruptionbudget" href="#helm-value-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  extraLabels: {}
  ```
   
<a id="helm-value-poddisruptionbudget-extralabels" href="#helm-value-poddisruptionbudget-extralabels" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget.extraLabels`](#helm-value-poddisruptionbudget-extralabels)`(object)`: PodDisruptionBudget extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-printnotes" href="#helm-value-printnotes" aria-hidden="true" tabindex="-1"></a>
[`printNotes`](#helm-value-printnotes)`(bool)`: Print chart notes
  ```helm-default
  true
  ```
   
<a id="helm-value-server-affinity" href="#helm-value-server-affinity" aria-hidden="true" tabindex="-1"></a>
[`server.affinity`](#helm-value-server-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-containerworkingdir" href="#helm-value-server-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`server.containerWorkingDir`](#helm-value-server-containerworkingdir)`(string)`: Container workdir
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-deployment" href="#helm-value-server-deployment" aria-hidden="true" tabindex="-1"></a>
[`server.deployment`](#helm-value-server-deployment)`(object)`: [K8s Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) specific variables
  ```helm-default
  spec:
      strategy:
          type: Recreate
  ```
   
<a id="helm-value-server-emptydir" href="#helm-value-server-emptydir" aria-hidden="true" tabindex="-1"></a>
[`server.emptyDir`](#helm-value-server-emptydir)`(object)`:
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-enabled" href="#helm-value-server-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.enabled`](#helm-value-server-enabled)`(bool)`: Enable deployment of server component. Deployed as StatefulSet
  ```helm-default
  true
  ```
   
<a id="helm-value-server-env" href="#helm-value-server-env" aria-hidden="true" tabindex="-1"></a>
[`server.env`](#helm-value-server-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Details are [here](https://github.com/VictoriaMetrics/VictoriaMetrics#environment-variables)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-envfrom" href="#helm-value-server-envfrom" aria-hidden="true" tabindex="-1"></a>
[`server.envFrom`](#helm-value-server-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extraargs" href="#helm-value-server-extraargs" aria-hidden="true" tabindex="-1"></a>
[`server.extraArgs`](#helm-value-server-extraargs)`(object)`: Extra command line arguments for container of component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :9428
  loggerFormat: json
  ```
   
<a id="helm-value-server-extracontainers" href="#helm-value-server-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`server.extraContainers`](#helm-value-server-extracontainers)`(list)`: Extra containers to run in a pod with Victoria Logs container
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extrahostpathmounts" href="#helm-value-server-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraHostPathMounts`](#helm-value-server-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extralabels" href="#helm-value-server-extralabels" aria-hidden="true" tabindex="-1"></a>
[`server.extraLabels`](#helm-value-server-extralabels)`(object)`: StatefulSet/Deployment additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-extravolumemounts" href="#helm-value-server-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumeMounts`](#helm-value-server-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extravolumes" href="#helm-value-server-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumes`](#helm-value-server-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-image-pullpolicy" href="#helm-value-server-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`server.image.pullPolicy`](#helm-value-server-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-server-image-registry" href="#helm-value-server-image-registry" aria-hidden="true" tabindex="-1"></a>
[`server.image.registry`](#helm-value-server-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-image-repository" href="#helm-value-server-image-repository" aria-hidden="true" tabindex="-1"></a>
[`server.image.repository`](#helm-value-server-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/victoria-logs
  ```
   
<a id="helm-value-server-image-tag" href="#helm-value-server-image-tag" aria-hidden="true" tabindex="-1"></a>
[`server.image.tag`](#helm-value-server-image-tag)`(string)`: Image tag
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-image-variant" href="#helm-value-server-image-variant" aria-hidden="true" tabindex="-1"></a>
[`server.image.variant`](#helm-value-server-image-variant)`(string)`: Image tag suffix, which is appended to `Chart.AppVersion` if no `server.image.tag` is defined
  ```helm-default
  victorialogs
  ```
   
<a id="helm-value-server-imagepullsecrets" href="#helm-value-server-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`server.imagePullSecrets`](#helm-value-server-imagepullsecrets)`(list)`: Image pull secrets
  ```helm-default
  []
  ```
   
<a id="helm-value-server-ingress-annotations" href="#helm-value-server-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.annotations`](#helm-value-server-ingress-annotations)`(string)`: Ingress annotations
  ```helm-default
  null
  ```
   
<a id="helm-value-server-ingress-enabled" href="#helm-value-server-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.enabled`](#helm-value-server-ingress-enabled)`(bool)`: Enable deployment of ingress for server component
  ```helm-default
  false
  ```
   
<a id="helm-value-server-ingress-extralabels" href="#helm-value-server-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.extraLabels`](#helm-value-server-ingress-extralabels)`(object)`: Ingress extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-ingress-hosts" href="#helm-value-server-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.hosts`](#helm-value-server-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: vlogs.local
    path:
      - /
    port: http
  ```
   
<a id="helm-value-server-ingress-ingressclassname" href="#helm-value-server-ingress-ingressclassname" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.ingressClassName`](#helm-value-server-ingress-ingressclassname)`(string)`: Ingress controller class name
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-ingress-pathtype" href="#helm-value-server-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.pathType`](#helm-value-server-ingress-pathtype)`(string)`: Ingress path type
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-server-ingress-tls" href="#helm-value-server-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.tls`](#helm-value-server-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-server-initcontainers" href="#helm-value-server-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`server.initContainers`](#helm-value-server-initcontainers)`(list)`: Init containers for Victoria Logs Pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-lifecycle" href="#helm-value-server-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`server.lifecycle`](#helm-value-server-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-mode" href="#helm-value-server-mode" aria-hidden="true" tabindex="-1"></a>
[`server.mode`](#helm-value-server-mode)`(string)`: VictoriaLogs mode: deployment, statefulSet
  ```helm-default
  statefulSet
  ```
   
<a id="helm-value-server-nodeselector" href="#helm-value-server-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`server.nodeSelector`](#helm-value-server-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-persistentvolume-accessmodes" href="#helm-value-server-persistentvolume-accessmodes" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.accessModes`](#helm-value-server-persistentvolume-accessmodes)`(list)`: Array of access modes. Must match those of existing PV or dynamic provisioner. Details are [here](http://kubernetes.io/docs/user-guide/persistent-volumes/)
  ```helm-default
  - ReadWriteOnce
  ```
   
<a id="helm-value-server-persistentvolume-annotations" href="#helm-value-server-persistentvolume-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.annotations`](#helm-value-server-persistentvolume-annotations)`(object)`: Persistant volume annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-persistentvolume-enabled" href="#helm-value-server-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.enabled`](#helm-value-server-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for server component. Empty dir if false
  ```helm-default
  false
  ```
   
<a id="helm-value-server-persistentvolume-existingclaim" href="#helm-value-server-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.existingClaim`](#helm-value-server-persistentvolume-existingclaim)`(string)`: Existing Claim name. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-persistentvolume-matchlabels" href="#helm-value-server-persistentvolume-matchlabels" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.matchLabels`](#helm-value-server-persistentvolume-matchlabels)`(object)`: Bind Persistent Volume by labels. Must match all labels of targeted PV.
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-persistentvolume-mountpath" href="#helm-value-server-persistentvolume-mountpath" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.mountPath`](#helm-value-server-persistentvolume-mountpath)`(string)`: Mount path. Server data Persistent Volume mount root path.
  ```helm-default
  /storage
  ```
   
<a id="helm-value-server-persistentvolume-name" href="#helm-value-server-persistentvolume-name" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.name`](#helm-value-server-persistentvolume-name)`(string)`: Override Persistent Volume Claim name
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-persistentvolume-size" href="#helm-value-server-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.size`](#helm-value-server-persistentvolume-size)`(string)`: Size of the volume. Should be calculated based on the logs you send and retention policy you set.
  ```helm-default
  3Gi
  ```
   
<a id="helm-value-server-persistentvolume-storageclassname" href="#helm-value-server-persistentvolume-storageclassname" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.storageClassName`](#helm-value-server-persistentvolume-storageclassname)`(string)`: StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-persistentvolume-subpath" href="#helm-value-server-persistentvolume-subpath" aria-hidden="true" tabindex="-1"></a>
[`server.persistentVolume.subPath`](#helm-value-server-persistentvolume-subpath)`(string)`: Mount subpath
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-podannotations" href="#helm-value-server-podannotations" aria-hidden="true" tabindex="-1"></a>
[`server.podAnnotations`](#helm-value-server-podannotations)`(object)`: Pod's annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-podlabels" href="#helm-value-server-podlabels" aria-hidden="true" tabindex="-1"></a>
[`server.podLabels`](#helm-value-server-podlabels)`(object)`: Pod's additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-podsecuritycontext" href="#helm-value-server-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`server.podSecurityContext`](#helm-value-server-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  fsGroup: 2000
  runAsNonRoot: true
  runAsUser: 1000
  ```
   
<a id="helm-value-server-priorityclassname" href="#helm-value-server-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`server.priorityClassName`](#helm-value-server-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-probe-liveness" href="#helm-value-server-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`server.probe.liveness`](#helm-value-server-probe-liveness)`(object)`: Indicates whether the Container is running. If the liveness probe fails, the kubelet kills the Container, and the Container is subjected to its restart policy. If a Container does not provide a liveness probe, the default state is Success.
  ```helm-default
  failureThreshold: 10
  initialDelaySeconds: 30
  periodSeconds: 30
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-probe-readiness" href="#helm-value-server-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`server.probe.readiness`](#helm-value-server-probe-readiness)`(object)`: Indicates whether the Container is ready to service requests. If the readiness probe fails, the endpoints controller removes the Pod's IP address from the endpoints of all Services that match the Pod. The default state of readiness before the initial delay is Failure. If a Container does not provide a readiness probe, the default state is Success.
  ```helm-default
  failureThreshold: 3
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 15
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-probe-startup" href="#helm-value-server-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`server.probe.startup`](#helm-value-server-probe-startup)`(object)`: Indicates whether the Container is done with potentially costly initialization. If set it is executed first. If it fails Container is restarted. If it succeeds liveness and readiness probes takes over.
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-replicacount" href="#helm-value-server-replicacount" aria-hidden="true" tabindex="-1"></a>
[`server.replicaCount`](#helm-value-server-replicacount)`(int)`: Replica count
  ```helm-default
  1
  ```
   
<a id="helm-value-server-resources" href="#helm-value-server-resources" aria-hidden="true" tabindex="-1"></a>
[`server.resources`](#helm-value-server-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-retentiondiskspaceusage" href="#helm-value-server-retentiondiskspaceusage" aria-hidden="true" tabindex="-1"></a>
[`server.retentionDiskSpaceUsage`](#helm-value-server-retentiondiskspaceusage)`(string)`: Data retention max capacity. Default unit is GiB. See these [docs](https://docs.victoriametrics.com/victorialogs/#retention-by-disk-space-usage)
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-retentionperiod" href="#helm-value-server-retentionperiod" aria-hidden="true" tabindex="-1"></a>
[`server.retentionPeriod`](#helm-value-server-retentionperiod)`(int)`: Data retention period. Possible units character: h(ours), d(ays), w(eeks), y(ears), if no unit character specified - month. The minimum retention period is 24h. See these [docs](https://docs.victoriametrics.com/victorialogs/#retention)
  ```helm-default
  1
  ```
   
<a id="helm-value-server-schedulername" href="#helm-value-server-schedulername" aria-hidden="true" tabindex="-1"></a>
[`server.schedulerName`](#helm-value-server-schedulername)`(string)`: Use an alternate scheduler, e.g. "stork". Check details [here](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/)
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-securitycontext" href="#helm-value-server-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`server.securityContext`](#helm-value-server-securitycontext)`(object)`: Security context to be added to server pods
  ```helm-default
  allowPrivilegeEscalation: false
  capabilities:
      drop:
          - ALL
  enabled: true
  readOnlyRootFilesystem: true
  ```
   
<a id="helm-value-server-service-annotations" href="#helm-value-server-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.service.annotations`](#helm-value-server-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-service-clusterip" href="#helm-value-server-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`server.service.clusterIP`](#helm-value-server-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  None
  ```
   
<a id="helm-value-server-service-externalips" href="#helm-value-server-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`server.service.externalIPs`](#helm-value-server-service-externalips)`(list)`: Service external IPs. Details are [here]( https://kubernetes.io/docs/user-guide/services/#external-ips)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-service-externaltrafficpolicy" href="#helm-value-server-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`server.service.externalTrafficPolicy`](#helm-value-server-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-service-healthchecknodeport" href="#helm-value-server-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`server.service.healthCheckNodePort`](#helm-value-server-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-service-ipfamilies" href="#helm-value-server-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`server.service.ipFamilies`](#helm-value-server-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-server-service-ipfamilypolicy" href="#helm-value-server-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`server.service.ipFamilyPolicy`](#helm-value-server-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-service-labels" href="#helm-value-server-service-labels" aria-hidden="true" tabindex="-1"></a>
[`server.service.labels`](#helm-value-server-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-service-loadbalancerip" href="#helm-value-server-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`server.service.loadBalancerIP`](#helm-value-server-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-service-loadbalancersourceranges" href="#helm-value-server-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`server.service.loadBalancerSourceRanges`](#helm-value-server-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-server-service-serviceport" href="#helm-value-server-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`server.service.servicePort`](#helm-value-server-service-serviceport)`(int)`: Service port
  ```helm-default
  9428
  ```
   
<a id="helm-value-server-service-targetport" href="#helm-value-server-service-targetport" aria-hidden="true" tabindex="-1"></a>
[`server.service.targetPort`](#helm-value-server-service-targetport)`(string)`: Target port
  ```helm-default
  http
  ```
   
<a id="helm-value-server-service-type" href="#helm-value-server-service-type" aria-hidden="true" tabindex="-1"></a>
[`server.service.type`](#helm-value-server-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-server-servicemonitor-annotations" href="#helm-value-server-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.annotations`](#helm-value-server-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-servicemonitor-basicauth" href="#helm-value-server-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.basicAuth`](#helm-value-server-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-servicemonitor-enabled" href="#helm-value-server-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.enabled`](#helm-value-server-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for server component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-server-servicemonitor-extralabels" href="#helm-value-server-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.extraLabels`](#helm-value-server-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-servicemonitor-metricrelabelings" href="#helm-value-server-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.metricRelabelings`](#helm-value-server-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-server-servicemonitor-relabelings" href="#helm-value-server-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.relabelings`](#helm-value-server-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-server-servicemonitor-targetport" href="#helm-value-server-servicemonitor-targetport" aria-hidden="true" tabindex="-1"></a>
[`server.serviceMonitor.targetPort`](#helm-value-server-servicemonitor-targetport)`(string)`: Service Monitor target port
  ```helm-default
  http
  ```
   
<a id="helm-value-server-statefulset" href="#helm-value-server-statefulset" aria-hidden="true" tabindex="-1"></a>
[`server.statefulSet`](#helm-value-server-statefulset)`(object)`: [K8s StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) specific variables
  ```helm-default
  spec:
      podManagementPolicy: OrderedReady
      updateStrategy: {}
  ```
   
<a id="helm-value-server-statefulset-spec-podmanagementpolicy" href="#helm-value-server-statefulset-spec-podmanagementpolicy" aria-hidden="true" tabindex="-1"></a>
[`server.statefulSet.spec.podManagementPolicy`](#helm-value-server-statefulset-spec-podmanagementpolicy)`(string)`: Deploy order policy for StatefulSet pods
  ```helm-default
  OrderedReady
  ```
   
<a id="helm-value-server-statefulset-spec-updatestrategy" href="#helm-value-server-statefulset-spec-updatestrategy" aria-hidden="true" tabindex="-1"></a>
[`server.statefulSet.spec.updateStrategy`](#helm-value-server-statefulset-spec-updatestrategy)`(object)`: StatefulSet update strategy. Check [here](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies) for details.
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-terminationgraceperiodseconds" href="#helm-value-server-terminationgraceperiodseconds" aria-hidden="true" tabindex="-1"></a>
[`server.terminationGracePeriodSeconds`](#helm-value-server-terminationgraceperiodseconds)`(int)`: Pod's termination grace period in seconds
  ```helm-default
  60
  ```
   
<a id="helm-value-server-tolerations" href="#helm-value-server-tolerations" aria-hidden="true" tabindex="-1"></a>
[`server.tolerations`](#helm-value-server-tolerations)`(list)`: Node tolerations for server scheduling to nodes with taints. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-topologyspreadconstraints" href="#helm-value-server-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`server.topologySpreadConstraints`](#helm-value-server-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   
<a id="helm-value-server-vmservicescrape-annotations" href="#helm-value-server-vmservicescrape-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.annotations`](#helm-value-server-vmservicescrape-annotations)`(object)`:
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-vmservicescrape-enabled" href="#helm-value-server-vmservicescrape-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.enabled`](#helm-value-server-vmservicescrape-enabled)`(bool)`: Enable deployment of VMServiceScrape for server component. This is Victoria Metrics operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmservicescrape-extralabels" href="#helm-value-server-vmservicescrape-extralabels" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.extraLabels`](#helm-value-server-vmservicescrape-extralabels)`(object)`:
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-vmservicescrape-metricrelabelings" href="#helm-value-server-vmservicescrape-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.metricRelabelings`](#helm-value-server-vmservicescrape-metricrelabelings)`(list)`:
  ```helm-default
  []
  ```
   
<a id="helm-value-server-vmservicescrape-relabelings" href="#helm-value-server-vmservicescrape-relabelings" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.relabelings`](#helm-value-server-vmservicescrape-relabelings)`(list)`: Commented. TLS configuration to use when scraping the endpoint    tlsConfig:      insecureSkipVerify: true
  ```helm-default
  []
  ```
   
<a id="helm-value-server-vmservicescrape-targetport" href="#helm-value-server-vmservicescrape-targetport" aria-hidden="true" tabindex="-1"></a>
[`server.vmServiceScrape.targetPort`](#helm-value-server-vmservicescrape-targetport)`(string)`: target port
  ```helm-default
  http
  ```
   
<a id="helm-value-serviceaccount-annotations" href="#helm-value-serviceaccount-annotations" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.annotations`](#helm-value-serviceaccount-annotations)`(object)`: ServiceAccount annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-automounttoken" href="#helm-value-serviceaccount-automounttoken" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.automountToken`](#helm-value-serviceaccount-automounttoken)`(bool)`: Mount API token to pod directly
  ```helm-default
  true
  ```
   
<a id="helm-value-serviceaccount-create" href="#helm-value-serviceaccount-create" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.create`](#helm-value-serviceaccount-create)`(bool)`: Create service account.
  ```helm-default
  false
  ```
   
<a id="helm-value-serviceaccount-extralabels" href="#helm-value-serviceaccount-extralabels" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.extraLabels`](#helm-value-serviceaccount-extralabels)`(object)`: ServiceAccount labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-name" href="#helm-value-serviceaccount-name" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.name`](#helm-value-serviceaccount-name)`(string)`: The name of the service account to use. If not set and create is true, a name is generated using the fullname template
  ```helm-default
  null
  ```
   
<a id="helm-value-vector" href="#helm-value-vector" aria-hidden="true" tabindex="-1"></a>
[`vector`](#helm-value-vector)`(object)`: Values for [vector helm chart](https://github.com/vectordotdev/helm-charts/tree/develop/charts/vector)
  ```helm-default
  args:
      - -w
      - --config-dir
      - /etc/vector/
  containerPorts:
      - containerPort: 9090
        name: prom-exporter
        protocol: TCP
  customConfig:
      api:
          address: 0.0.0.0:8686
          enabled: false
          playground: true
      data_dir: /vector-data-dir
      sinks:
          exporter:
              address: 0.0.0.0:9090
              inputs:
                  - internal_metrics
              type: prometheus_exporter
          vlogs:
              api_version: v8
              compression: gzip
              endpoints: << include "vlogs.es.urls" . >>
              healthcheck:
                  enabled: false
              inputs:
                  - parser
              mode: bulk
              request:
                  headers:
                      AccountID: "0"
                      ProjectID: "0"
                      VL-Msg-Field: message,msg,_msg,log.msg,log.message,log
                      VL-Stream-Fields: stream,kubernetes.pod_name,kubernetes.container_name,kubernetes.pod_namespace
                      VL-Time-Field: timestamp
              type: elasticsearch
      sources:
          internal_metrics:
              type: internal_metrics
          k8s:
              type: kubernetes_logs
      transforms:
          parser:
              inputs:
                  - k8s
              source: |
                  .log = parse_json(.message) ?? .message
                  del(.message)
              type: remap
  customConfigNamespace: ""
  dataDir: /vector-data-dir
  enabled: false
  existingConfigMaps:
      - vl-config
  resources: {}
  role: Agent
  service:
      enabled: false
  ```
   
<a id="helm-value-vector-customconfignamespace" href="#helm-value-vector-customconfignamespace" aria-hidden="true" tabindex="-1"></a>
[`vector.customConfigNamespace`](#helm-value-vector-customconfignamespace)`(string)`: Forces custom configuration creation in a given namespace even if vector.enabled is false
  ```helm-default
  ""
  ```
   
<a id="helm-value-vector-enabled" href="#helm-value-vector-enabled" aria-hidden="true" tabindex="-1"></a>
[`vector.enabled`](#helm-value-vector-enabled)`(bool)`: Enable deployment of vector
  ```helm-default
  false
  ```
   

