

![Version](https://img.shields.io/badge/1.7.2-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-anomaly%2Fchangelog%2F%23172)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-anomaly)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Anomaly Detection - a service that continuously scans Victoria Metrics time series and detects unexpected changes within data patterns in real-time.

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

* PV support on underlying infrastructure

## Chart Details

This chart will do the following:

* Rollout victoria metrics anomaly

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-anomaly` chart available to installation:

```console
helm search repo vm/victoria-metrics-anomaly -l
```

### Install `victoria-metrics-anomaly` chart

Export default values of `victoria-metrics-anomaly` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-anomaly > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-anomaly > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-anomaly -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-anomaly -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-anomaly -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-anomaly -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vma'
```

Get the application by running this command:

```console
helm list -f vma -n NAMESPACE
```

See the history of versions of `vma` application with command.

```console
helm history vma -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vma -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-anomaly

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

For more `vmanomaly` config parameters see https://docs.victoriametrics.com/anomaly-detection/components

Change the values according to the need of the environment in ``victoria-metrics-anomaly/values.yaml`` file.

<a id="helm-value-affinity" href="#helm-value-affinity" aria-hidden="true" tabindex="-1"></a>
[`affinity`](#helm-value-affinity)`(object)`: Affinity configurations
  ```helm-default
  {}
  ```
   
<a id="helm-value-annotations" href="#helm-value-annotations" aria-hidden="true" tabindex="-1"></a>
[`annotations`](#helm-value-annotations)`(object)`: Annotations to be added to the deployment
  ```helm-default
  {}
  ```
   
<a id="helm-value-config" href="#helm-value-config" aria-hidden="true" tabindex="-1"></a>
[`config`](#helm-value-config)`(object)`: Full [vmanomaly config section](https://docs.victoriametrics.com/anomaly-detection/components/)
  ```helm-default
  models: {}
  preset: ""
  reader:
      class: vm
      datasource_url: ""
      queries: {}
      sampling_period: 1m
      tenant_id: ""
  schedulers: {}
  writer:
      class: vm
      datasource_url: ""
      tenant_id: ""
  ```
   
<a id="helm-value-config-models" href="#helm-value-config-models" aria-hidden="true" tabindex="-1"></a>
[`config.models`](#helm-value-config-models)`(object)`: [Models section](https://docs.victoriametrics.com/anomaly-detection/components/models/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-config-preset" href="#helm-value-config-preset" aria-hidden="true" tabindex="-1"></a>
[`config.preset`](#helm-value-config-preset)`(string)`: Whether to use preset configuration. If not empty, preset name should be specified.
  ```helm-default
  ""
  ```
   
<a id="helm-value-config-reader" href="#helm-value-config-reader" aria-hidden="true" tabindex="-1"></a>
[`config.reader`](#helm-value-config-reader)`(object)`: [Reader section](https://docs.victoriametrics.com/anomaly-detection/components/reader/)
  ```helm-default
  class: vm
  datasource_url: ""
  queries: {}
  sampling_period: 1m
  tenant_id: ""
  ```
   
<a id="helm-value-config-reader-class" href="#helm-value-config-reader-class" aria-hidden="true" tabindex="-1"></a>
[`config.reader.class`](#helm-value-config-reader-class)`(string)`: Name of the class needed to enable reading from VictoriaMetrics or Prometheus. VmReader is the default option, if not specified.
  ```helm-default
  vm
  ```
   
<a id="helm-value-config-reader-datasource-url" href="#helm-value-config-reader-datasource-url" aria-hidden="true" tabindex="-1"></a>
[`config.reader.datasource_url`](#helm-value-config-reader-datasource-url)`(string)`: Datasource URL address. Required for example `http://single-victoria-metrics-single-server.default.svc.cluster.local:8428` or `http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480`
  ```helm-default
  ""
  ```
   
<a id="helm-value-config-reader-queries" href="#helm-value-config-reader-queries" aria-hidden="true" tabindex="-1"></a>
[`config.reader.queries`](#helm-value-config-reader-queries)`(object)`: Required. PromQL/MetricsQL query to select data in format: QUERY_ALIAS: "QUERY". As accepted by "/query_range?query=%s". See [here](https://docs.victoriametrics.com/anomaly-detection/components/reader/#per-query-parameters) for more details.
  ```helm-default
  {}
  ```
   
<a id="helm-value-config-reader-sampling-period" href="#helm-value-config-reader-sampling-period" aria-hidden="true" tabindex="-1"></a>
[`config.reader.sampling_period`](#helm-value-config-reader-sampling-period)`(string)`: Frequency of the points returned. Will be converted to `/query_range?step=%s` param (in seconds). **Required** since 1.9.0.
  ```helm-default
  1m
  ```
   
<a id="helm-value-config-reader-tenant-id" href="#helm-value-config-reader-tenant-id" aria-hidden="true" tabindex="-1"></a>
[`config.reader.tenant_id`](#helm-value-config-reader-tenant-id)`(string)`: For VictoriaMetrics Cluster version only, tenants are identified by accountID or accountID:projectID. See VictoriaMetrics Cluster multitenancy docs
  ```helm-default
  ""
  ```
   
<a id="helm-value-config-schedulers" href="#helm-value-config-schedulers" aria-hidden="true" tabindex="-1"></a>
[`config.schedulers`](#helm-value-config-schedulers)`(object)`: [Scheduler section](https://docs.victoriametrics.com/anomaly-detection/components/scheduler/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-config-writer" href="#helm-value-config-writer" aria-hidden="true" tabindex="-1"></a>
[`config.writer`](#helm-value-config-writer)`(object)`: [Writer section](https://docs.victoriametrics.com/anomaly-detection/components/writer/)
  ```helm-default
  class: vm
  datasource_url: ""
  tenant_id: ""
  ```
   
<a id="helm-value-config-writer-class" href="#helm-value-config-writer-class" aria-hidden="true" tabindex="-1"></a>
[`config.writer.class`](#helm-value-config-writer-class)`(string)`: Name of the class needed to enable writing to VictoriaMetrics or Prometheus. VmWriter is the default option, if not specified.
  ```helm-default
  vm
  ```
   
<a id="helm-value-config-writer-datasource-url" href="#helm-value-config-writer-datasource-url" aria-hidden="true" tabindex="-1"></a>
[`config.writer.datasource_url`](#helm-value-config-writer-datasource-url)`(string)`: Datasource URL address. Required for example `http://single-victoria-metrics-single-server.default.svc.cluster.local:8428` or `http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480`
  ```helm-default
  ""
  ```
   
<a id="helm-value-config-writer-tenant-id" href="#helm-value-config-writer-tenant-id" aria-hidden="true" tabindex="-1"></a>
[`config.writer.tenant_id`](#helm-value-config-writer-tenant-id)`(string)`: For VictoriaMetrics Cluster version only, tenants are identified by accountID or accountID:projectID. See VictoriaMetrics Cluster multitenancy docs
  ```helm-default
  ""
  ```
   
<a id="helm-value-configmapannotations" href="#helm-value-configmapannotations" aria-hidden="true" tabindex="-1"></a>
[`configMapAnnotations`](#helm-value-configmapannotations)`(object)`: Annotations to be added to configMap
  ```helm-default
  {}
  ```
   
<a id="helm-value-containerworkingdir" href="#helm-value-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`containerWorkingDir`](#helm-value-containerworkingdir)`(string)`: Container working directory
  ```helm-default
  /vmanomaly
  ```
   
<a id="helm-value-emptydir" href="#helm-value-emptydir" aria-hidden="true" tabindex="-1"></a>
[`emptyDir`](#helm-value-emptydir)`(object)`: Empty dir configuration when persistence is disabled
  ```helm-default
  {}
  ```
   
<a id="helm-value-env" href="#helm-value-env" aria-hidden="true" tabindex="-1"></a>
[`env`](#helm-value-env)`(list)`: Additional environment variables (ex.: secret tokens, flags)
  ```helm-default
  []
  ```
   
<a id="helm-value-envfrom" href="#helm-value-envfrom" aria-hidden="true" tabindex="-1"></a>
[`envFrom`](#helm-value-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-extraargs" href="#helm-value-extraargs" aria-hidden="true" tabindex="-1"></a>
[`extraArgs`](#helm-value-extraargs)`(object)`: Extra command line arguments for container of component
  ```helm-default
  {}
  ```
   
<a id="helm-value-extracontainers" href="#helm-value-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`extraContainers`](#helm-value-extracontainers)`(list)`: Extra containers to run in a pod with anomaly container
  ```helm-default
  []
  ```
   
<a id="helm-value-extrahostpathmounts" href="#helm-value-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`extraHostPathMounts`](#helm-value-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-extraobjects" href="#helm-value-extraobjects" aria-hidden="true" tabindex="-1"></a>
[`extraObjects`](#helm-value-extraobjects)`(list)`: Add extra specs dynamically to this chart
  ```helm-default
  []
  ```
   
<a id="helm-value-extravolumemounts" href="#helm-value-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`extraVolumeMounts`](#helm-value-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-extravolumes" href="#helm-value-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`extraVolumes`](#helm-value-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-fullnameoverride" href="#helm-value-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`fullnameOverride`](#helm-value-fullnameoverride)`(string)`: Override resources fullname
  ```helm-default
  ""
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
   
<a id="helm-value-image-pullpolicy" href="#helm-value-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`image.pullPolicy`](#helm-value-image-pullpolicy)`(string)`: Pull policy of Docker image
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-image-registry" href="#helm-value-image-registry" aria-hidden="true" tabindex="-1"></a>
[`image.registry`](#helm-value-image-registry)`(string)`: Victoria Metrics anomaly Docker registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-image-repository" href="#helm-value-image-repository" aria-hidden="true" tabindex="-1"></a>
[`image.repository`](#helm-value-image-repository)`(string)`: Victoria Metrics anomaly Docker repository and image name
  ```helm-default
  victoriametrics/vmanomaly
  ```
   
<a id="helm-value-image-tag" href="#helm-value-image-tag" aria-hidden="true" tabindex="-1"></a>
[`image.tag`](#helm-value-image-tag)`(string)`: Tag of Docker image
  ```helm-default
  ""
  ```
   
<a id="helm-value-imagepullsecrets" href="#helm-value-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`imagePullSecrets`](#helm-value-imagepullsecrets)`(list)`: Image pull secrets
  ```helm-default
  []
  ```
   
<a id="helm-value-license" href="#helm-value-license" aria-hidden="true" tabindex="-1"></a>
[`license`](#helm-value-license)`(object)`: License key configuration for vmanomaly. See [docs](https://docs.victoriametrics.com/vmanomaly#licensing) Required starting from v1.5.0.
  ```helm-default
  key: ""
  secret:
      key: ""
      name: ""
  ```
   
<a id="helm-value-license-key" href="#helm-value-license-key" aria-hidden="true" tabindex="-1"></a>
[`license.key`](#helm-value-license-key)`(string)`: License key for vmanomaly
  ```helm-default
  ""
  ```
   
<a id="helm-value-license-secret" href="#helm-value-license-secret" aria-hidden="true" tabindex="-1"></a>
[`license.secret`](#helm-value-license-secret)`(object)`: Use existing secret with license key for vmanomaly
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
   
<a id="helm-value-nameoverride" href="#helm-value-nameoverride" aria-hidden="true" tabindex="-1"></a>
[`nameOverride`](#helm-value-nameoverride)`(string)`: Override chart name
  ```helm-default
  ""
  ```
   
<a id="helm-value-nodeselector" href="#helm-value-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`nodeSelector`](#helm-value-nodeselector)`(object)`: NodeSelector configurations. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-persistentvolume" href="#helm-value-persistentvolume" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume`](#helm-value-persistentvolume)`(object)`: Persistence to store models on disk. Available starting from v1.13.0
  ```helm-default
  accessModes:
      - ReadWriteOnce
  annotations: {}
  dumpData: true
  dumpModels: true
  enabled: false
  existingClaim: ""
  matchLabels: {}
  size: 1Gi
  storageClassName: ""
  ```
   
<a id="helm-value-persistentvolume-accessmodes" href="#helm-value-persistentvolume-accessmodes" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.accessModes`](#helm-value-persistentvolume-accessmodes)`(list)`: Array of access modes. Must match those of existing PV or dynamic provisioner. Details are [here](http://kubernetes.io/docs/user-guide/persistent-volumes/)
  ```helm-default
  - ReadWriteOnce
  ```
   
<a id="helm-value-persistentvolume-annotations" href="#helm-value-persistentvolume-annotations" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.annotations`](#helm-value-persistentvolume-annotations)`(object)`: Persistant volume annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-persistentvolume-dumpdata" href="#helm-value-persistentvolume-dumpdata" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.dumpData`](#helm-value-persistentvolume-dumpdata)`(bool)`: Enables dumpling data which is fetched from VictoriaMetrics to persistence disk. This is helpful to reduce memory usage.
  ```helm-default
  true
  ```
   
<a id="helm-value-persistentvolume-dumpmodels" href="#helm-value-persistentvolume-dumpmodels" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.dumpModels`](#helm-value-persistentvolume-dumpmodels)`(bool)`: Enables dumping models to persistence disk. This is helpful to reduce memory usage.
  ```helm-default
  true
  ```
   
<a id="helm-value-persistentvolume-enabled" href="#helm-value-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.enabled`](#helm-value-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for models dump.
  ```helm-default
  false
  ```
   
<a id="helm-value-persistentvolume-existingclaim" href="#helm-value-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.existingClaim`](#helm-value-persistentvolume-existingclaim)`(string)`: Existing Claim name. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-persistentvolume-matchlabels" href="#helm-value-persistentvolume-matchlabels" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.matchLabels`](#helm-value-persistentvolume-matchlabels)`(object)`: Bind Persistent Volume by labels. Must match all labels of targeted PV.
  ```helm-default
  {}
  ```
   
<a id="helm-value-persistentvolume-size" href="#helm-value-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.size`](#helm-value-persistentvolume-size)`(string)`: Size of the volume. Should be calculated based on the metrics you send and retention policy you set.
  ```helm-default
  1Gi
  ```
   
<a id="helm-value-persistentvolume-storageclassname" href="#helm-value-persistentvolume-storageclassname" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.storageClassName`](#helm-value-persistentvolume-storageclassname)`(string)`: StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically
  ```helm-default
  ""
  ```
   
<a id="helm-value-podannotations" href="#helm-value-podannotations" aria-hidden="true" tabindex="-1"></a>
[`podAnnotations`](#helm-value-podannotations)`(object)`: Annotations to be added to pod
  ```helm-default
  {}
  ```
   
<a id="helm-value-poddisruptionbudget" href="#helm-value-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  minAvailable: 1
  ```
   
<a id="helm-value-podlabels" href="#helm-value-podlabels" aria-hidden="true" tabindex="-1"></a>
[`podLabels`](#helm-value-podlabels)`(object)`: Labels to be added to pod
  ```helm-default
  {}
  ```
   
<a id="helm-value-podmonitor-annotations" href="#helm-value-podmonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`podMonitor.annotations`](#helm-value-podmonitor-annotations)`(object)`: PodMonitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-podmonitor-enabled" href="#helm-value-podmonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`podMonitor.enabled`](#helm-value-podmonitor-enabled)`(bool)`: Enable PodMonitor
  ```helm-default
  false
  ```
   
<a id="helm-value-podmonitor-extralabels" href="#helm-value-podmonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`podMonitor.extraLabels`](#helm-value-podmonitor-extralabels)`(object)`: PodMonitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-podsecuritycontext" href="#helm-value-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`podSecurityContext`](#helm-value-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  fsGroup: 1000
  ```
   
<a id="helm-value-resources" href="#helm-value-resources" aria-hidden="true" tabindex="-1"></a>
[`resources`](#helm-value-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-securitycontext" href="#helm-value-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`securityContext`](#helm-value-securitycontext)`(object)`: Check [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for details.
  ```helm-default
  enabled: true
  runAsGroup: 1000
  runAsNonRoot: true
  runAsUser: 1000
  ```
   
<a id="helm-value-serviceaccount-annotations" href="#helm-value-serviceaccount-annotations" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.annotations`](#helm-value-serviceaccount-annotations)`(object)`: Annotations to add to the service account
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-create" href="#helm-value-serviceaccount-create" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.create`](#helm-value-serviceaccount-create)`(bool)`: Specifies whether a service account should be created
  ```helm-default
  true
  ```
   
<a id="helm-value-serviceaccount-name" href="#helm-value-serviceaccount-name" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.name`](#helm-value-serviceaccount-name)`(string)`: The name of the service account to use. If not set and create is true, a name is generated using the fullname template
  ```helm-default
  null
  ```
   
<a id="helm-value-tolerations" href="#helm-value-tolerations" aria-hidden="true" tabindex="-1"></a>
[`tolerations`](#helm-value-tolerations)`(list)`: Tolerations configurations. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   

