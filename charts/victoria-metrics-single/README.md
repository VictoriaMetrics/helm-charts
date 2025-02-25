

![Version](https://img.shields.io/badge/0.14.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-single%2Fchangelog%2F%230140)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-single)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Single version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).
* PV support on underlying infrastructure.

## Chart Details

This chart will do the following:

* Rollout Victoria Metrics Single.

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-single` chart available to installation:

```console
helm search repo vm/victoria-metrics-single -l
```

### Install `victoria-metrics-single` chart

Export default values of `victoria-metrics-single` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-single > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-single > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vms vm/victoria-metrics-single -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vms oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-single -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vms vm/victoria-metrics-single -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vms oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-single -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vms'
```

Get the application by running this command:

```console
helm list -f vms -n NAMESPACE
```

See the history of versions of `vms` application with command.

```console
helm history vms -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vms -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-single

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-single/values.yaml`` file.

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
   
<a id="helm-value-license" href="#helm-value-license" aria-hidden="true" tabindex="-1"></a>
[`license`](#helm-value-license)`(object)`: Enterprise license key configuration for VictoriaMetrics enterprise. Required only for VictoriaMetrics enterprise. Check docs [here](https://docs.victoriametrics.com/enterprise), for more information, visit [site](https://victoriametrics.com/products/enterprise/). Request a trial license [here](https://victoriametrics.com/products/enterprise/trial/) Supported starting from VictoriaMetrics v1.94.0
  ```helm-default
  key: ""
  secret:
      key: ""
      name: ""
  ```
   
<a id="helm-value-license-key" href="#helm-value-license-key" aria-hidden="true" tabindex="-1"></a>
[`license.key`](#helm-value-license-key)`(string)`: License key
  ```helm-default
  ""
  ```
   
<a id="helm-value-license-secret" href="#helm-value-license-secret" aria-hidden="true" tabindex="-1"></a>
[`license.secret`](#helm-value-license-secret)`(object)`: Use existing secret with license key
  ```helm-default
  key: ""
  name: ""
  ```
   
<a id="helm-value-license-secret-key" href="#helm-value-license-secret-key" aria-hidden="true" tabindex="-1"></a>
[`license.secret.key`](#helm-value-license-secret-key)`(string)`: Key in secret with license key
  ```helm-default
  ""
  ```
   
<a id="helm-value-license-secret-name" href="#helm-value-license-secret-name" aria-hidden="true" tabindex="-1"></a>
[`license.secret.name`](#helm-value-license-secret-name)`(string)`: Existing secret name
  ```helm-default
  ""
  ```
   
<a id="helm-value-poddisruptionbudget" href="#helm-value-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  extraLabels: {}
  ```
   
<a id="helm-value-printnotes" href="#helm-value-printnotes" aria-hidden="true" tabindex="-1"></a>
[`printNotes`](#helm-value-printnotes)`(bool)`: Print chart notes
  ```helm-default
  true
  ```
   
<a id="helm-value-rbac-annotations" href="#helm-value-rbac-annotations" aria-hidden="true" tabindex="-1"></a>
[`rbac.annotations`](#helm-value-rbac-annotations)`(object)`: Role/RoleBinding annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-rbac-create" href="#helm-value-rbac-create" aria-hidden="true" tabindex="-1"></a>
[`rbac.create`](#helm-value-rbac-create)`(bool)`: Enables Role/RoleBinding creation
  ```helm-default
  true
  ```
   
<a id="helm-value-rbac-extralabels" href="#helm-value-rbac-extralabels" aria-hidden="true" tabindex="-1"></a>
[`rbac.extraLabels`](#helm-value-rbac-extralabels)`(object)`: Role/RoleBinding labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-rbac-namespaced" href="#helm-value-rbac-namespaced" aria-hidden="true" tabindex="-1"></a>
[`rbac.namespaced`](#helm-value-rbac-namespaced)`(bool)`: If true and `rbac.enabled`, will deploy a Role/RoleBinding instead of a ClusterRole/ClusterRoleBinding
  ```helm-default
  false
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
[`server.env`](#helm-value-server-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for more details
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
  httpListenAddr: :8428
  loggerFormat: json
  ```
   
<a id="helm-value-server-extracontainers" href="#helm-value-server-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`server.extraContainers`](#helm-value-server-extracontainers)`(list)`: Extra containers to run in a pod with VM single
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extrahostpathmounts" href="#helm-value-server-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraHostPathMounts`](#helm-value-server-extrahostpathmounts)`(list)`:
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extralabels" href="#helm-value-server-extralabels" aria-hidden="true" tabindex="-1"></a>
[`server.extraLabels`](#helm-value-server-extralabels)`(object)`: Sts/Deploy additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-extravolumemounts" href="#helm-value-server-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumeMounts`](#helm-value-server-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extravolumes" href="#helm-value-server-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumes`](#helm-value-server-extravolumes)`(list)`:
  ```helm-default
  []
  ```
   
<a id="helm-value-server-fullnameoverride" href="#helm-value-server-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`server.fullnameOverride`](#helm-value-server-fullnameoverride)`(string)`: Overrides the full name of server component
  ```helm-default
  null
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
  victoriametrics/victoria-metrics
  ```
   
<a id="helm-value-server-image-tag" href="#helm-value-server-image-tag" aria-hidden="true" tabindex="-1"></a>
[`server.image.tag`](#helm-value-server-image-tag)`(string)`: Image tag
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-image-variant" href="#helm-value-server-image-variant" aria-hidden="true" tabindex="-1"></a>
[`server.image.variant`](#helm-value-server-image-variant)`(string)`:
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-imagepullsecrets" href="#helm-value-server-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`server.imagePullSecrets`](#helm-value-server-imagepullsecrets)`(list)`: Image pull secrets
  ```helm-default
  []
  ```
   
<a id="helm-value-server-ingress-annotations" href="#helm-value-server-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.annotations`](#helm-value-server-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
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
  - name: vmsingle.local
    path:
      - /
    port: http
  ```
   
<a id="helm-value-server-ingress-pathtype" href="#helm-value-server-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.pathType`](#helm-value-server-ingress-pathtype)`(string)`:
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-server-ingress-tls" href="#helm-value-server-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`server.ingress.tls`](#helm-value-server-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-server-initcontainers" href="#helm-value-server-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`server.initContainers`](#helm-value-server-initcontainers)`(list)`: Init containers for VM single pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-lifecycle" href="#helm-value-server-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`server.lifecycle`](#helm-value-server-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-mode" href="#helm-value-server-mode" aria-hidden="true" tabindex="-1"></a>
[`server.mode`](#helm-value-server-mode)`(string)`: VictoriaMetrics mode: deployment, statefulSet
  ```helm-default
  deployment
  ```
   
<a id="helm-value-server-name" href="#helm-value-server-name" aria-hidden="true" tabindex="-1"></a>
[`server.name`](#helm-value-server-name)`(string)`: Override default `app` label name
  ```helm-default
  null
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
  true
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
[`server.persistentVolume.size`](#helm-value-server-persistentvolume-size)`(string)`: Size of the volume. Should be calculated based on the metrics you send and retention policy you set.
  ```helm-default
  16Gi
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
  ```
   
<a id="helm-value-server-priorityclassname" href="#helm-value-server-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`server.priorityClassName`](#helm-value-server-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-probe" href="#helm-value-server-probe" aria-hidden="true" tabindex="-1"></a>
[`server.probe`](#helm-value-server-probe)`(object)`: Readiness & Liveness probes
  ```helm-default
  liveness:
      failureThreshold: 10
      initialDelaySeconds: 30
      periodSeconds: 30
      tcpSocket: {}
      timeoutSeconds: 5
  readiness:
      failureThreshold: 3
      httpGet: {}
      initialDelaySeconds: 5
      periodSeconds: 15
      timeoutSeconds: 5
  startup: {}
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
   
<a id="helm-value-server-relabel" href="#helm-value-server-relabel" aria-hidden="true" tabindex="-1"></a>
[`server.relabel`](#helm-value-server-relabel)`(object)`: Global relabel configuration
  ```helm-default
  config: []
  configMap: ""
  enabled: false
  ```
   
<a id="helm-value-server-relabel-configmap" href="#helm-value-server-relabel-configmap" aria-hidden="true" tabindex="-1"></a>
[`server.relabel.configMap`](#helm-value-server-relabel-configmap)`(string)`: Use existing configmap if specified otherwise .config values will be used. Relabel config **should** reside under `relabel.yml` key
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-replicacount" href="#helm-value-server-replicacount" aria-hidden="true" tabindex="-1"></a>
[`server.replicaCount`](#helm-value-server-replicacount)`(int)`: Number of victoriametrics single replicas
  ```helm-default
  1
  ```
   
<a id="helm-value-server-resources" href="#helm-value-server-resources" aria-hidden="true" tabindex="-1"></a>
[`server.resources`](#helm-value-server-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-retentionperiod" href="#helm-value-server-retentionperiod" aria-hidden="true" tabindex="-1"></a>
[`server.retentionPeriod`](#helm-value-server-retentionperiod)`(int)`: Data retention period. Possible units character: h(ours), d(ays), w(eeks), y(ears), if no unit character specified - month. The minimum retention period is 24h. See these [docs](https://docs.victoriametrics.com/single-server-victoriametrics/#retention)
  ```helm-default
  1
  ```
   
<a id="helm-value-server-schedulername" href="#helm-value-server-schedulername" aria-hidden="true" tabindex="-1"></a>
[`server.schedulerName`](#helm-value-server-schedulername)`(string)`: Use an alternate scheduler, e.g. "stork". Check [here](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/) for more details
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-scrape-config" href="#helm-value-server-scrape-config" aria-hidden="true" tabindex="-1"></a>
[`server.scrape.config`](#helm-value-server-scrape-config)`(object)`: Scrape config
  ```helm-default
  global:
      scrape_interval: 15s
  scrape_configs:
      - job_name: victoriametrics
        static_configs:
          - targets:
              - localhost:8428
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        job_name: kubernetes-apiservers
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - action: keep
            regex: default;kubernetes;https
            source_labels:
              - __meta_kubernetes_namespace
              - __meta_kubernetes_service_name
              - __meta_kubernetes_endpoint_port_name
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        job_name: kubernetes-nodes
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - replacement: kubernetes.default.svc:443
            target_label: __address__
          - regex: (.+)
            replacement: /api/v1/nodes/$1/proxy/metrics
            source_labels:
              - __meta_kubernetes_node_name
            target_label: __metrics_path__
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        honor_timestamps: false
        job_name: kubernetes-nodes-cadvisor
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - replacement: kubernetes.default.svc:443
            target_label: __address__
          - regex: (.+)
            replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
            source_labels:
              - __meta_kubernetes_node_name
            target_label: __metrics_path__
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - job_name: kubernetes-service-endpoints
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - action: drop
            regex: true
            source_labels:
              - __meta_kubernetes_pod_container_init
          - action: keep_if_equal
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_port
              - __meta_kubernetes_pod_container_port_number
          - action: keep
            regex: true
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scrape
          - action: replace
            regex: (https?)
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scheme
            target_label: __scheme__
          - action: replace
            regex: (.+)
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_path
            target_label: __metrics_path__
          - action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            source_labels:
              - __address__
              - __meta_kubernetes_service_annotation_prometheus_io_port
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - action: replace
            source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - action: replace
            source_labels:
              - __meta_kubernetes_service_name
            target_label: service
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_node_name
            target_label: node
      - job_name: kubernetes-service-endpoints-slow
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - action: drop
            regex: true
            source_labels:
              - __meta_kubernetes_pod_container_init
          - action: keep_if_equal
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_port
              - __meta_kubernetes_pod_container_port_number
          - action: keep
            regex: true
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scrape_slow
          - action: replace
            regex: (https?)
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scheme
            target_label: __scheme__
          - action: replace
            regex: (.+)
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_path
            target_label: __metrics_path__
          - action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            source_labels:
              - __address__
              - __meta_kubernetes_service_annotation_prometheus_io_port
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - action: replace
            source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - action: replace
            source_labels:
              - __meta_kubernetes_service_name
            target_label: service
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_node_name
            target_label: node
        scrape_interval: 5m
        scrape_timeout: 30s
      - job_name: kubernetes-services
        kubernetes_sd_configs:
          - role: service
        metrics_path: /probe
        params:
          module:
              - http_2xx
        relabel_configs:
          - action: keep
            regex: true
            source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_probe
          - source_labels:
              - __address__
            target_label: __param_target
          - replacement: blackbox
            target_label: __address__
          - source_labels:
              - __param_target
            target_label: instance
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - source_labels:
              - __meta_kubernetes_service_name
            target_label: service
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - action: drop
            regex: true
            source_labels:
              - __meta_kubernetes_pod_container_init
          - action: keep_if_equal
            source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_port
              - __meta_kubernetes_pod_container_port_number
          - action: keep
            regex: true
            source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scrape
          - action: replace
            regex: (.+)
            source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_path
            target_label: __metrics_path__
          - action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            source_labels:
              - __address__
              - __meta_kubernetes_pod_annotation_prometheus_io_port
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - action: replace
            source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_name
            target_label: pod
  ```
   
<a id="helm-value-server-scrape-configmap" href="#helm-value-server-scrape-configmap" aria-hidden="true" tabindex="-1"></a>
[`server.scrape.configMap`](#helm-value-server-scrape-configmap)`(string)`: Use existing configmap if specified otherwise .config values will be used. Scrape config **should** reside under `scrape.yml` key
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-scrape-enabled" href="#helm-value-server-scrape-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.scrape.enabled`](#helm-value-server-scrape-enabled)`(bool)`: If true scrapes targets, creates config map or use specified one with scrape targets
  ```helm-default
  false
  ```
   
<a id="helm-value-server-scrape-extrascrapeconfigs" href="#helm-value-server-scrape-extrascrapeconfigs" aria-hidden="true" tabindex="-1"></a>
[`server.scrape.extraScrapeConfigs`](#helm-value-server-scrape-extrascrapeconfigs)`(list)`: Extra scrape configs that will be appended to `server.scrape.config`
  ```helm-default
  []
  ```
   
<a id="helm-value-server-securitycontext" href="#helm-value-server-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`server.securityContext`](#helm-value-server-securitycontext)`(object)`: Security context to be added to server pods
  ```helm-default
  enabled: true
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
[`server.service.externalIPs`](#helm-value-server-service-externalips)`(list)`: Service external IPs. Details are [here](https://kubernetes.io/docs/user-guide/services/#external-ips)
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
  8428
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
   
<a id="helm-value-server-vmbackupmanager-destination" href="#helm-value-server-vmbackupmanager-destination" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.destination`](#helm-value-server-vmbackupmanager-destination)`(string)`: Backup destination at S3, GCS or local filesystem. Release name will be included to path!
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-vmbackupmanager-disabledaily" href="#helm-value-server-vmbackupmanager-disabledaily" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.disableDaily`](#helm-value-server-vmbackupmanager-disabledaily)`(bool)`: Disable daily backups
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmbackupmanager-disablehourly" href="#helm-value-server-vmbackupmanager-disablehourly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.disableHourly`](#helm-value-server-vmbackupmanager-disablehourly)`(bool)`: Disable hourly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmbackupmanager-disablemonthly" href="#helm-value-server-vmbackupmanager-disablemonthly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.disableMonthly`](#helm-value-server-vmbackupmanager-disablemonthly)`(bool)`: Disable monthly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmbackupmanager-disableweekly" href="#helm-value-server-vmbackupmanager-disableweekly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.disableWeekly`](#helm-value-server-vmbackupmanager-disableweekly)`(bool)`: Disable weekly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmbackupmanager-enabled" href="#helm-value-server-vmbackupmanager-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.enabled`](#helm-value-server-vmbackupmanager-enabled)`(bool)`: Enable automatic creation of backup via vmbackupmanager. vmbackupmanager is part of Enterprise packages
  ```helm-default
  false
  ```
   
<a id="helm-value-server-vmbackupmanager-env" href="#helm-value-server-vmbackupmanager-env" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.env`](#helm-value-server-vmbackupmanager-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-vmbackupmanager-extraargs" href="#helm-value-server-vmbackupmanager-extraargs" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.extraArgs`](#helm-value-server-vmbackupmanager-extraargs)`(object)`: Extra command line arguments for container of component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  loggerFormat: json
  ```
   
<a id="helm-value-server-vmbackupmanager-extravolumemounts" href="#helm-value-server-vmbackupmanager-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.extraVolumeMounts`](#helm-value-server-vmbackupmanager-extravolumemounts)`(list)`:
  ```helm-default
  []
  ```
   
<a id="helm-value-server-vmbackupmanager-image-registry" href="#helm-value-server-vmbackupmanager-image-registry" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.image.registry`](#helm-value-server-vmbackupmanager-image-registry)`(string)`: VMBackupManager image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-vmbackupmanager-image-repository" href="#helm-value-server-vmbackupmanager-image-repository" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.image.repository`](#helm-value-server-vmbackupmanager-image-repository)`(string)`: VMBackupManager image repository
  ```helm-default
  victoriametrics/vmbackupmanager
  ```
   
<a id="helm-value-server-vmbackupmanager-image-tag" href="#helm-value-server-vmbackupmanager-image-tag" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.image.tag`](#helm-value-server-vmbackupmanager-image-tag)`(string)`: VMBackupManager image tag
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-vmbackupmanager-image-variant" href="#helm-value-server-vmbackupmanager-image-variant" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.image.variant`](#helm-value-server-vmbackupmanager-image-variant)`(string)`:
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-vmbackupmanager-probe" href="#helm-value-server-vmbackupmanager-probe" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.probe`](#helm-value-server-vmbackupmanager-probe)`(object)`: Readiness & Liveness probes
  ```helm-default
  liveness:
      failureThreshold: 10
      initialDelaySeconds: 30
      periodSeconds: 30
      tcpSocket:
          port: manager-http
      timeoutSeconds: 5
  readiness:
      failureThreshold: 3
      httpGet:
          port: manager-http
      initialDelaySeconds: 5
      periodSeconds: 15
      timeoutSeconds: 5
  startup:
      httpGet:
          port: manager-http
  ```
   
<a id="helm-value-server-vmbackupmanager-probe-liveness" href="#helm-value-server-vmbackupmanager-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.probe.liveness`](#helm-value-server-vmbackupmanager-probe-liveness)`(object)`: VMBackupManager liveness probe
  ```helm-default
  failureThreshold: 10
  initialDelaySeconds: 30
  periodSeconds: 30
  tcpSocket:
      port: manager-http
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-vmbackupmanager-probe-readiness" href="#helm-value-server-vmbackupmanager-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.probe.readiness`](#helm-value-server-vmbackupmanager-probe-readiness)`(object)`: VMBackupManager readiness probe
  ```helm-default
  failureThreshold: 3
  httpGet:
      port: manager-http
  initialDelaySeconds: 5
  periodSeconds: 15
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-vmbackupmanager-probe-startup" href="#helm-value-server-vmbackupmanager-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.probe.startup`](#helm-value-server-vmbackupmanager-probe-startup)`(object)`: VMBackupManager startup probe
  ```helm-default
  httpGet:
      port: manager-http
  ```
   
<a id="helm-value-server-vmbackupmanager-resources" href="#helm-value-server-vmbackupmanager-resources" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.resources`](#helm-value-server-vmbackupmanager-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-vmbackupmanager-restore" href="#helm-value-server-vmbackupmanager-restore" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.restore`](#helm-value-server-vmbackupmanager-restore)`(object)`: Allows to enable restore options for pod. Read more [here](https://docs.victoriametrics.com/vmbackupmanager#restore-commands)
  ```helm-default
  onStart:
      enabled: false
  ```
   
<a id="helm-value-server-vmbackupmanager-retention" href="#helm-value-server-vmbackupmanager-retention" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.retention`](#helm-value-server-vmbackupmanager-retention)`(object)`: Backups' retention settings
  ```helm-default
  keepLastDaily: 2
  keepLastHourly: 2
  keepLastMonthly: 2
  keepLastWeekly: 2
  ```
   
<a id="helm-value-server-vmbackupmanager-retention-keeplastdaily" href="#helm-value-server-vmbackupmanager-retention-keeplastdaily" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.retention.keepLastDaily`](#helm-value-server-vmbackupmanager-retention-keeplastdaily)`(int)`: Keep last N daily backups. 0 means delete all existing daily backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-server-vmbackupmanager-retention-keeplasthourly" href="#helm-value-server-vmbackupmanager-retention-keeplasthourly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.retention.keepLastHourly`](#helm-value-server-vmbackupmanager-retention-keeplasthourly)`(int)`: Keep last N hourly backups. 0 means delete all existing hourly backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-server-vmbackupmanager-retention-keeplastmonthly" href="#helm-value-server-vmbackupmanager-retention-keeplastmonthly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.retention.keepLastMonthly`](#helm-value-server-vmbackupmanager-retention-keeplastmonthly)`(int)`: Keep last N monthly backups. 0 means delete all existing monthly backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-server-vmbackupmanager-retention-keeplastweekly" href="#helm-value-server-vmbackupmanager-retention-keeplastweekly" aria-hidden="true" tabindex="-1"></a>
[`server.vmbackupmanager.retention.keepLastWeekly`](#helm-value-server-vmbackupmanager-retention-keeplastweekly)`(int)`: Keep last N weekly backups. 0 means delete all existing weekly backups. Specify -1 to turn off
  ```helm-default
  2
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
  true
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
   

