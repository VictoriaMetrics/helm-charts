

![Version](https://img.shields.io/badge/0.18.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-cluster%2Fchangelog%2F%230180)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-cluster)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Cluster version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

* PV support on underlying infrastructure

## Chart Details

Note: this chart installs VictoriaMetrics cluster components such as vminsert, vmselect and vmstorage. It doesn't create or configure metrics scraping. If you are looking for a chart to configure monitoring stack in cluster check out [victoria-metrics-k8s-stack chart](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack#helm-chart-for-victoria-metrics-kubernetes-monitoring-stack).

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-cluster` chart available to installation:

```console
helm search repo vm/victoria-metrics-cluster -l
```

### Install `victoria-metrics-cluster` chart

Export default values of `victoria-metrics-cluster` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-cluster > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vmc vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vmc oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vmc vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vmc oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmc'
```

Get the application by running this command:

```console
helm list -f vmc -n NAMESPACE
```

See the history of versions of `vmc` application with command.

```console
helm history vmc -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmc -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-cluster

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-cluster/values.yaml`` file.

<a id="helm-value-autodiscovery" href="#helm-value-autodiscovery" aria-hidden="true" tabindex="-1"></a>
[`autoDiscovery`](#helm-value-autodiscovery)`(bool)`: use SRV discovery for storageNode and selectNode flags for enterprise version
  ```helm-default
  false
  ```
   
<a id="helm-value-common-image" href="#helm-value-common-image" aria-hidden="true" tabindex="-1"></a>
[`common.image`](#helm-value-common-image)`(object)`: common for all components image configuration
  ```helm-default
  tag: ""
  ```
   
<a id="helm-value-extraobjects" href="#helm-value-extraobjects" aria-hidden="true" tabindex="-1"></a>
[`extraObjects`](#helm-value-extraobjects)`(list)`: Add extra specs dynamically to this chart
  ```helm-default
  []
  ```
   
<a id="helm-value-extrasecrets" href="#helm-value-extrasecrets" aria-hidden="true" tabindex="-1"></a>
[`extraSecrets`](#helm-value-extrasecrets)`(list)`:
  ```helm-default
  []
  ```
   
<a id="helm-value-global-cluster" href="#helm-value-global-cluster" aria-hidden="true" tabindex="-1"></a>
[`global.cluster`](#helm-value-global-cluster)`(object)`: k8s cluster domain suffix, uses for building storage pods' FQDN. Details are [here](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
  ```helm-default
  dnsDomain: cluster.local.
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
   
<a id="helm-value-global-image-vm-tag" href="#helm-value-global-image-vm-tag" aria-hidden="true" tabindex="-1"></a>
[`global.image.vm.tag`](#helm-value-global-image-vm-tag)`(string)`: Image tag for all vm charts
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
   
<a id="helm-value-printnotes" href="#helm-value-printnotes" aria-hidden="true" tabindex="-1"></a>
[`printNotes`](#helm-value-printnotes)`(bool)`: Print information after deployment
  ```helm-default
  true
  ```
   
<a id="helm-value-serviceaccount-annotations" href="#helm-value-serviceaccount-annotations" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.annotations`](#helm-value-serviceaccount-annotations)`(object)`: Service account annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-automounttoken" href="#helm-value-serviceaccount-automounttoken" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.automountToken`](#helm-value-serviceaccount-automounttoken)`(bool)`: mount API token to pod directly
  ```helm-default
  true
  ```
   
<a id="helm-value-serviceaccount-create" href="#helm-value-serviceaccount-create" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.create`](#helm-value-serviceaccount-create)`(bool)`: Specifies whether a service account should be created
  ```helm-default
  true
  ```
   
<a id="helm-value-serviceaccount-extralabels" href="#helm-value-serviceaccount-extralabels" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.extraLabels`](#helm-value-serviceaccount-extralabels)`(object)`: Service account labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-name" href="#helm-value-serviceaccount-name" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.name`](#helm-value-serviceaccount-name)`(string)`: The name of the service account to use. If not set and create is true, a name is generated using the fullname template
  ```helm-default
  null
  ```
   
<a id="helm-value-vmauth-affinity" href="#helm-value-vmauth-affinity" aria-hidden="true" tabindex="-1"></a>
[`vmauth.affinity`](#helm-value-vmauth-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-annotations" href="#helm-value-vmauth-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.annotations`](#helm-value-vmauth-annotations)`(object)`: VMAuth annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-config" href="#helm-value-vmauth-config" aria-hidden="true" tabindex="-1"></a>
[`vmauth.config`](#helm-value-vmauth-config)`(object)`: VMAuth configuration object
  ```helm-default
  unauthorized_user: {}
  ```
   
<a id="helm-value-vmauth-configsecretname" href="#helm-value-vmauth-configsecretname" aria-hidden="true" tabindex="-1"></a>
[`vmauth.configSecretName`](#helm-value-vmauth-configsecretname)`(string)`: VMAuth configuration secret name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-containerworkingdir" href="#helm-value-vmauth-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`vmauth.containerWorkingDir`](#helm-value-vmauth-containerworkingdir)`(string)`: Container workdir
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-enabled" href="#helm-value-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmauth.enabled`](#helm-value-vmauth-enabled)`(bool)`: Enable deployment of vmauth component. With vmauth enabled please set `service.clusterIP: None` and `service.type: ClusterIP` for `vminsert` and `vmselect` to use vmauth balancing benefits.
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-env" href="#helm-value-vmauth-env" aria-hidden="true" tabindex="-1"></a>
[`vmauth.env`](#helm-value-vmauth-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-envfrom" href="#helm-value-vmauth-envfrom" aria-hidden="true" tabindex="-1"></a>
[`vmauth.envFrom`](#helm-value-vmauth-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-extraargs" href="#helm-value-vmauth-extraargs" aria-hidden="true" tabindex="-1"></a>
[`vmauth.extraArgs`](#helm-value-vmauth-extraargs)`(object)`: Extra command line arguments for vmauth component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8427
  loggerFormat: json
  ```
   
<a id="helm-value-vmauth-extracontainers" href="#helm-value-vmauth-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`vmauth.extraContainers`](#helm-value-vmauth-extracontainers)`(list)`: Extra containers to run in a pod with vmauth
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-extralabels" href="#helm-value-vmauth-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmauth.extraLabels`](#helm-value-vmauth-extralabels)`(object)`: VMAuth additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-extravolumemounts" href="#helm-value-vmauth-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`vmauth.extraVolumeMounts`](#helm-value-vmauth-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-extravolumes" href="#helm-value-vmauth-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`vmauth.extraVolumes`](#helm-value-vmauth-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-fullnameoverride" href="#helm-value-vmauth-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`vmauth.fullnameOverride`](#helm-value-vmauth-fullnameoverride)`(string)`: Overrides the full name of vmauth component
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-horizontalpodautoscaler-behavior" href="#helm-value-vmauth-horizontalpodautoscaler-behavior" aria-hidden="true" tabindex="-1"></a>
[`vmauth.horizontalPodAutoscaler.behavior`](#helm-value-vmauth-horizontalpodautoscaler-behavior)`(object)`: Behavior settings for scaling by the HPA
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-horizontalpodautoscaler-enabled" href="#helm-value-vmauth-horizontalpodautoscaler-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmauth.horizontalPodAutoscaler.enabled`](#helm-value-vmauth-horizontalpodautoscaler-enabled)`(bool)`: Use HPA for vmauth component
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-horizontalpodautoscaler-maxreplicas" href="#helm-value-vmauth-horizontalpodautoscaler-maxreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmauth.horizontalPodAutoscaler.maxReplicas`](#helm-value-vmauth-horizontalpodautoscaler-maxreplicas)`(int)`: Maximum replicas for HPA to use to to scale the vmauth component
  ```helm-default
  10
  ```
   
<a id="helm-value-vmauth-horizontalpodautoscaler-metrics" href="#helm-value-vmauth-horizontalpodautoscaler-metrics" aria-hidden="true" tabindex="-1"></a>
[`vmauth.horizontalPodAutoscaler.metrics`](#helm-value-vmauth-horizontalpodautoscaler-metrics)`(list)`: Metric for HPA to use to scale the vmauth component
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-horizontalpodautoscaler-minreplicas" href="#helm-value-vmauth-horizontalpodautoscaler-minreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmauth.horizontalPodAutoscaler.minReplicas`](#helm-value-vmauth-horizontalpodautoscaler-minreplicas)`(int)`: Minimum replicas for HPA to use to scale the vmauth component
  ```helm-default
  2
  ```
   
<a id="helm-value-vmauth-image-pullpolicy" href="#helm-value-vmauth-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmauth.image.pullPolicy`](#helm-value-vmauth-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-vmauth-image-registry" href="#helm-value-vmauth-image-registry" aria-hidden="true" tabindex="-1"></a>
[`vmauth.image.registry`](#helm-value-vmauth-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-image-repository" href="#helm-value-vmauth-image-repository" aria-hidden="true" tabindex="-1"></a>
[`vmauth.image.repository`](#helm-value-vmauth-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/vmauth
  ```
   
<a id="helm-value-vmauth-image-tag" href="#helm-value-vmauth-image-tag" aria-hidden="true" tabindex="-1"></a>
[`vmauth.image.tag`](#helm-value-vmauth-image-tag)`(string)`: Image tag override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-image-variant" href="#helm-value-vmauth-image-variant" aria-hidden="true" tabindex="-1"></a>
[`vmauth.image.variant`](#helm-value-vmauth-image-variant)`(string)`: Variant of the image to use. e.g. cluster, enterprise-cluster
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-ingress-annotations" href="#helm-value-vmauth-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.annotations`](#helm-value-vmauth-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-ingress-enabled" href="#helm-value-vmauth-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.enabled`](#helm-value-vmauth-ingress-enabled)`(bool)`: Enable deployment of ingress for vmauth component
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-ingress-extralabels" href="#helm-value-vmauth-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.extraLabels`](#helm-value-vmauth-ingress-extralabels)`(object)`:
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-ingress-hosts" href="#helm-value-vmauth-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.hosts`](#helm-value-vmauth-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: vmauth.local
    path:
      - /insert
    port: http
  ```
   
<a id="helm-value-vmauth-ingress-pathtype" href="#helm-value-vmauth-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.pathType`](#helm-value-vmauth-ingress-pathtype)`(string)`: pathType is only for k8s >= 1.1=
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-vmauth-ingress-tls" href="#helm-value-vmauth-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ingress.tls`](#helm-value-vmauth-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-initcontainers" href="#helm-value-vmauth-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`vmauth.initContainers`](#helm-value-vmauth-initcontainers)`(list)`: Init containers for vmauth
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-lifecycle" href="#helm-value-vmauth-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`vmauth.lifecycle`](#helm-value-vmauth-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-name" href="#helm-value-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`vmauth.name`](#helm-value-vmauth-name)`(string)`: Override default `app` label name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-nodeselector" href="#helm-value-vmauth-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`vmauth.nodeSelector`](#helm-value-vmauth-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-podannotations" href="#helm-value-vmauth-podannotations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.podAnnotations`](#helm-value-vmauth-podannotations)`(object)`: Pod's annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-poddisruptionbudget" href="#helm-value-vmauth-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`vmauth.podDisruptionBudget`](#helm-value-vmauth-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-vmauth-podlabels" href="#helm-value-vmauth-podlabels" aria-hidden="true" tabindex="-1"></a>
[`vmauth.podLabels`](#helm-value-vmauth-podlabels)`(object)`: VMAuth pod labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-podsecuritycontext" href="#helm-value-vmauth-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`vmauth.podSecurityContext`](#helm-value-vmauth-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vmauth-ports-name" href="#helm-value-vmauth-ports-name" aria-hidden="true" tabindex="-1"></a>
[`vmauth.ports.name`](#helm-value-vmauth-ports-name)`(string)`: VMAuth http port name
  ```helm-default
  http
  ```
   
<a id="helm-value-vmauth-priorityclassname" href="#helm-value-vmauth-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`vmauth.priorityClassName`](#helm-value-vmauth-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-probe-liveness" href="#helm-value-vmauth-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`vmauth.probe.liveness`](#helm-value-vmauth-probe-liveness)`(object)`: VMAuth liveness probe
  ```helm-default
  failureThreshold: 3
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmauth-probe-readiness" href="#helm-value-vmauth-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`vmauth.probe.readiness`](#helm-value-vmauth-probe-readiness)`(object)`: VMAuth readiness probe
  ```helm-default
  failureThreshold: 10
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmauth-probe-startup" href="#helm-value-vmauth-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`vmauth.probe.startup`](#helm-value-vmauth-probe-startup)`(object)`: VMAuth startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-replicacount" href="#helm-value-vmauth-replicacount" aria-hidden="true" tabindex="-1"></a>
[`vmauth.replicaCount`](#helm-value-vmauth-replicacount)`(int)`: Count of vmauth pods
  ```helm-default
  2
  ```
   
<a id="helm-value-vmauth-resources" href="#helm-value-vmauth-resources" aria-hidden="true" tabindex="-1"></a>
[`vmauth.resources`](#helm-value-vmauth-resources)`(object)`: Resource object
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-securitycontext" href="#helm-value-vmauth-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`vmauth.securityContext`](#helm-value-vmauth-securitycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vmauth-service-annotations" href="#helm-value-vmauth-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.annotations`](#helm-value-vmauth-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-service-clusterip" href="#helm-value-vmauth-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.clusterIP`](#helm-value-vmauth-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-service-enabled" href="#helm-value-vmauth-service-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.enabled`](#helm-value-vmauth-service-enabled)`(bool)`: Create VMAuth service
  ```helm-default
  true
  ```
   
<a id="helm-value-vmauth-service-externalips" href="#helm-value-vmauth-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.externalIPs`](#helm-value-vmauth-service-externalips)`(list)`: Service External IPs. Details are [here]( https://kubernetes.io/docs/user-guide/services/#external-ips)
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-service-externaltrafficpolicy" href="#helm-value-vmauth-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.externalTrafficPolicy`](#helm-value-vmauth-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-service-extraports" href="#helm-value-vmauth-service-extraports" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.extraPorts`](#helm-value-vmauth-service-extraports)`(list)`: Extra service ports
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-service-healthchecknodeport" href="#helm-value-vmauth-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.healthCheckNodePort`](#helm-value-vmauth-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-service-ipfamilies" href="#helm-value-vmauth-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.ipFamilies`](#helm-value-vmauth-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-service-ipfamilypolicy" href="#helm-value-vmauth-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.ipFamilyPolicy`](#helm-value-vmauth-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-service-labels" href="#helm-value-vmauth-service-labels" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.labels`](#helm-value-vmauth-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-service-loadbalancerip" href="#helm-value-vmauth-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.loadBalancerIP`](#helm-value-vmauth-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-service-loadbalancersourceranges" href="#helm-value-vmauth-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.loadBalancerSourceRanges`](#helm-value-vmauth-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-service-serviceport" href="#helm-value-vmauth-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.servicePort`](#helm-value-vmauth-service-serviceport)`(int)`: Service port
  ```helm-default
  8427
  ```
   
<a id="helm-value-vmauth-service-targetport" href="#helm-value-vmauth-service-targetport" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.targetPort`](#helm-value-vmauth-service-targetport)`(string)`: Target port
  ```helm-default
  http
  ```
   
<a id="helm-value-vmauth-service-type" href="#helm-value-vmauth-service-type" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.type`](#helm-value-vmauth-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-vmauth-service-udp" href="#helm-value-vmauth-service-udp" aria-hidden="true" tabindex="-1"></a>
[`vmauth.service.udp`](#helm-value-vmauth-service-udp)`(bool)`: Enable UDP port. used if you have `spec.opentsdbListenAddr` specified Make sure that service is not type `LoadBalancer`, as it requires `MixedProtocolLBService` feature gate. Check [here](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-servicemonitor-annotations" href="#helm-value-vmauth-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.annotations`](#helm-value-vmauth-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-servicemonitor-basicauth" href="#helm-value-vmauth-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.basicAuth`](#helm-value-vmauth-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-servicemonitor-enabled" href="#helm-value-vmauth-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.enabled`](#helm-value-vmauth-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for vmauth component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-servicemonitor-extralabels" href="#helm-value-vmauth-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.extraLabels`](#helm-value-vmauth-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-servicemonitor-metricrelabelings" href="#helm-value-vmauth-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.metricRelabelings`](#helm-value-vmauth-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-servicemonitor-namespace" href="#helm-value-vmauth-servicemonitor-namespace" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.namespace`](#helm-value-vmauth-servicemonitor-namespace)`(string)`: Target namespace of ServiceMonitor manifest
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmauth-servicemonitor-relabelings" href="#helm-value-vmauth-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`vmauth.serviceMonitor.relabelings`](#helm-value-vmauth-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-strategy" href="#helm-value-vmauth-strategy" aria-hidden="true" tabindex="-1"></a>
[`vmauth.strategy`](#helm-value-vmauth-strategy)`(object)`: VMAuth Deployment strategy
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmauth-suppressstoragefqdnsrender" href="#helm-value-vmauth-suppressstoragefqdnsrender" aria-hidden="true" tabindex="-1"></a>
[`vmauth.suppressStorageFQDNsRender`](#helm-value-vmauth-suppressstoragefqdnsrender)`(bool)`: Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--storageNodes`, they can be re-defined in extraArgs
  ```helm-default
  false
  ```
   
<a id="helm-value-vmauth-tolerations" href="#helm-value-vmauth-tolerations" aria-hidden="true" tabindex="-1"></a>
[`vmauth.tolerations`](#helm-value-vmauth-tolerations)`(list)`: Array of tolerations object. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-vmauth-topologyspreadconstraints" href="#helm-value-vmauth-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`vmauth.topologySpreadConstraints`](#helm-value-vmauth-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-affinity" href="#helm-value-vminsert-affinity" aria-hidden="true" tabindex="-1"></a>
[`vminsert.affinity`](#helm-value-vminsert-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-annotations" href="#helm-value-vminsert-annotations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.annotations`](#helm-value-vminsert-annotations)`(object)`: StatefulSet/Deployment annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-containerworkingdir" href="#helm-value-vminsert-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`vminsert.containerWorkingDir`](#helm-value-vminsert-containerworkingdir)`(string)`: Container workdir
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-enabled" href="#helm-value-vminsert-enabled" aria-hidden="true" tabindex="-1"></a>
[`vminsert.enabled`](#helm-value-vminsert-enabled)`(bool)`: Enable deployment of vminsert component. Deployment is used
  ```helm-default
  true
  ```
   
<a id="helm-value-vminsert-env" href="#helm-value-vminsert-env" aria-hidden="true" tabindex="-1"></a>
[`vminsert.env`](#helm-value-vminsert-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-envfrom" href="#helm-value-vminsert-envfrom" aria-hidden="true" tabindex="-1"></a>
[`vminsert.envFrom`](#helm-value-vminsert-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-excludestorageids" href="#helm-value-vminsert-excludestorageids" aria-hidden="true" tabindex="-1"></a>
[`vminsert.excludeStorageIDs`](#helm-value-vminsert-excludestorageids)`(list)`: IDs of vmstorage nodes to exclude from writing
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-extraargs" href="#helm-value-vminsert-extraargs" aria-hidden="true" tabindex="-1"></a>
[`vminsert.extraArgs`](#helm-value-vminsert-extraargs)`(object)`: Extra command line arguments for vminsert component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8480
  loggerFormat: json
  ```
   
<a id="helm-value-vminsert-extracontainers" href="#helm-value-vminsert-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`vminsert.extraContainers`](#helm-value-vminsert-extracontainers)`(list)`: Extra containers to run in a pod with vminsert
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-extralabels" href="#helm-value-vminsert-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vminsert.extraLabels`](#helm-value-vminsert-extralabels)`(object)`: StatefulSet/Deployment additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-extravolumemounts" href="#helm-value-vminsert-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`vminsert.extraVolumeMounts`](#helm-value-vminsert-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-extravolumes" href="#helm-value-vminsert-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`vminsert.extraVolumes`](#helm-value-vminsert-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-fullnameoverride" href="#helm-value-vminsert-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`vminsert.fullnameOverride`](#helm-value-vminsert-fullnameoverride)`(string)`: Overrides the full name of vminsert component
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-horizontalpodautoscaler-behavior" href="#helm-value-vminsert-horizontalpodautoscaler-behavior" aria-hidden="true" tabindex="-1"></a>
[`vminsert.horizontalPodAutoscaler.behavior`](#helm-value-vminsert-horizontalpodautoscaler-behavior)`(object)`: Behavior settings for scaling by the HPA
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-horizontalpodautoscaler-enabled" href="#helm-value-vminsert-horizontalpodautoscaler-enabled" aria-hidden="true" tabindex="-1"></a>
[`vminsert.horizontalPodAutoscaler.enabled`](#helm-value-vminsert-horizontalpodautoscaler-enabled)`(bool)`: Use HPA for vminsert component
  ```helm-default
  false
  ```
   
<a id="helm-value-vminsert-horizontalpodautoscaler-maxreplicas" href="#helm-value-vminsert-horizontalpodautoscaler-maxreplicas" aria-hidden="true" tabindex="-1"></a>
[`vminsert.horizontalPodAutoscaler.maxReplicas`](#helm-value-vminsert-horizontalpodautoscaler-maxreplicas)`(int)`: Maximum replicas for HPA to use to to scale the vminsert component
  ```helm-default
  10
  ```
   
<a id="helm-value-vminsert-horizontalpodautoscaler-metrics" href="#helm-value-vminsert-horizontalpodautoscaler-metrics" aria-hidden="true" tabindex="-1"></a>
[`vminsert.horizontalPodAutoscaler.metrics`](#helm-value-vminsert-horizontalpodautoscaler-metrics)`(list)`: Metric for HPA to use to scale the vminsert component
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-horizontalpodautoscaler-minreplicas" href="#helm-value-vminsert-horizontalpodautoscaler-minreplicas" aria-hidden="true" tabindex="-1"></a>
[`vminsert.horizontalPodAutoscaler.minReplicas`](#helm-value-vminsert-horizontalpodautoscaler-minreplicas)`(int)`: Minimum replicas for HPA to use to scale the vminsert component
  ```helm-default
  2
  ```
   
<a id="helm-value-vminsert-image-pullpolicy" href="#helm-value-vminsert-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`vminsert.image.pullPolicy`](#helm-value-vminsert-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-vminsert-image-registry" href="#helm-value-vminsert-image-registry" aria-hidden="true" tabindex="-1"></a>
[`vminsert.image.registry`](#helm-value-vminsert-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-image-repository" href="#helm-value-vminsert-image-repository" aria-hidden="true" tabindex="-1"></a>
[`vminsert.image.repository`](#helm-value-vminsert-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/vminsert
  ```
   
<a id="helm-value-vminsert-image-tag" href="#helm-value-vminsert-image-tag" aria-hidden="true" tabindex="-1"></a>
[`vminsert.image.tag`](#helm-value-vminsert-image-tag)`(string)`: Image tag override Chart.AppVersion   
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-image-variant" href="#helm-value-vminsert-image-variant" aria-hidden="true" tabindex="-1"></a>
[`vminsert.image.variant`](#helm-value-vminsert-image-variant)`(string)`: Variant of the image to use. e.g. cluster, enterprise-cluster
  ```helm-default
  cluster
  ```
   
<a id="helm-value-vminsert-ingress-annotations" href="#helm-value-vminsert-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.annotations`](#helm-value-vminsert-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-ingress-enabled" href="#helm-value-vminsert-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.enabled`](#helm-value-vminsert-ingress-enabled)`(bool)`: Enable deployment of ingress for vminsert component
  ```helm-default
  false
  ```
   
<a id="helm-value-vminsert-ingress-extralabels" href="#helm-value-vminsert-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.extraLabels`](#helm-value-vminsert-ingress-extralabels)`(object)`: Ingress extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-ingress-hosts" href="#helm-value-vminsert-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.hosts`](#helm-value-vminsert-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: vminsert.local
    path:
      - /insert
    port: http
  ```
   
<a id="helm-value-vminsert-ingress-ingressclassname" href="#helm-value-vminsert-ingress-ingressclassname" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.ingressClassName`](#helm-value-vminsert-ingress-ingressclassname)`(string)`: Ingress controller class name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-ingress-pathtype" href="#helm-value-vminsert-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.pathType`](#helm-value-vminsert-ingress-pathtype)`(string)`: Ingress path type
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-vminsert-ingress-tls" href="#helm-value-vminsert-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ingress.tls`](#helm-value-vminsert-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-initcontainers" href="#helm-value-vminsert-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`vminsert.initContainers`](#helm-value-vminsert-initcontainers)`(list)`: Init containers for vminsert
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-lifecycle" href="#helm-value-vminsert-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`vminsert.lifecycle`](#helm-value-vminsert-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-name" href="#helm-value-vminsert-name" aria-hidden="true" tabindex="-1"></a>
[`vminsert.name`](#helm-value-vminsert-name)`(string)`: Override default `app` label name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-nodeselector" href="#helm-value-vminsert-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`vminsert.nodeSelector`](#helm-value-vminsert-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-podannotations" href="#helm-value-vminsert-podannotations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.podAnnotations`](#helm-value-vminsert-podannotations)`(object)`: Pod's annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-poddisruptionbudget" href="#helm-value-vminsert-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`vminsert.podDisruptionBudget`](#helm-value-vminsert-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-vminsert-podlabels" href="#helm-value-vminsert-podlabels" aria-hidden="true" tabindex="-1"></a>
[`vminsert.podLabels`](#helm-value-vminsert-podlabels)`(object)`: Pod’s additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-podsecuritycontext" href="#helm-value-vminsert-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`vminsert.podSecurityContext`](#helm-value-vminsert-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vminsert-ports-name" href="#helm-value-vminsert-ports-name" aria-hidden="true" tabindex="-1"></a>
[`vminsert.ports.name`](#helm-value-vminsert-ports-name)`(string)`: VMInsert http port name
  ```helm-default
  http
  ```
   
<a id="helm-value-vminsert-priorityclassname" href="#helm-value-vminsert-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`vminsert.priorityClassName`](#helm-value-vminsert-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-probe" href="#helm-value-vminsert-probe" aria-hidden="true" tabindex="-1"></a>
[`vminsert.probe`](#helm-value-vminsert-probe)`(object)`: Readiness & Liveness probes
  ```helm-default
  liveness:
      failureThreshold: 3
      initialDelaySeconds: 5
      periodSeconds: 15
      tcpSocket: {}
      timeoutSeconds: 5
  readiness:
      failureThreshold: 10
      httpGet: {}
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 5
  startup: {}
  ```
   
<a id="helm-value-vminsert-probe-liveness" href="#helm-value-vminsert-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`vminsert.probe.liveness`](#helm-value-vminsert-probe-liveness)`(object)`: VMInsert liveness probe
  ```helm-default
  failureThreshold: 3
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vminsert-probe-readiness" href="#helm-value-vminsert-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`vminsert.probe.readiness`](#helm-value-vminsert-probe-readiness)`(object)`: VMInsert readiness probe
  ```helm-default
  failureThreshold: 10
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vminsert-probe-startup" href="#helm-value-vminsert-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`vminsert.probe.startup`](#helm-value-vminsert-probe-startup)`(object)`: VMInsert startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-replicacount" href="#helm-value-vminsert-replicacount" aria-hidden="true" tabindex="-1"></a>
[`vminsert.replicaCount`](#helm-value-vminsert-replicacount)`(int)`: Count of vminsert pods
  ```helm-default
  2
  ```
   
<a id="helm-value-vminsert-resources" href="#helm-value-vminsert-resources" aria-hidden="true" tabindex="-1"></a>
[`vminsert.resources`](#helm-value-vminsert-resources)`(object)`: Resource object. Details are [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-securitycontext" href="#helm-value-vminsert-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`vminsert.securityContext`](#helm-value-vminsert-securitycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vminsert-service-annotations" href="#helm-value-vminsert-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.annotations`](#helm-value-vminsert-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-service-clusterip" href="#helm-value-vminsert-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.clusterIP`](#helm-value-vminsert-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-service-enabled" href="#helm-value-vminsert-service-enabled" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.enabled`](#helm-value-vminsert-service-enabled)`(bool)`: Create VMInsert service
  ```helm-default
  true
  ```
   
<a id="helm-value-vminsert-service-externalips" href="#helm-value-vminsert-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.externalIPs`](#helm-value-vminsert-service-externalips)`(list)`: Service external IPs. Details are [here]( https://kubernetes.io/docs/user-guide/services/#external-ips)
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-service-externaltrafficpolicy" href="#helm-value-vminsert-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.externalTrafficPolicy`](#helm-value-vminsert-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-service-extraports" href="#helm-value-vminsert-service-extraports" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.extraPorts`](#helm-value-vminsert-service-extraports)`(list)`: Extra service ports
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-service-healthchecknodeport" href="#helm-value-vminsert-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.healthCheckNodePort`](#helm-value-vminsert-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-service-ipfamilies" href="#helm-value-vminsert-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.ipFamilies`](#helm-value-vminsert-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-service-ipfamilypolicy" href="#helm-value-vminsert-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.ipFamilyPolicy`](#helm-value-vminsert-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-service-labels" href="#helm-value-vminsert-service-labels" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.labels`](#helm-value-vminsert-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-service-loadbalancerip" href="#helm-value-vminsert-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.loadBalancerIP`](#helm-value-vminsert-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-service-loadbalancersourceranges" href="#helm-value-vminsert-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.loadBalancerSourceRanges`](#helm-value-vminsert-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-service-serviceport" href="#helm-value-vminsert-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.servicePort`](#helm-value-vminsert-service-serviceport)`(int)`: Service port
  ```helm-default
  8480
  ```
   
<a id="helm-value-vminsert-service-targetport" href="#helm-value-vminsert-service-targetport" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.targetPort`](#helm-value-vminsert-service-targetport)`(string)`: Target port
  ```helm-default
  http
  ```
   
<a id="helm-value-vminsert-service-type" href="#helm-value-vminsert-service-type" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.type`](#helm-value-vminsert-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-vminsert-service-udp" href="#helm-value-vminsert-service-udp" aria-hidden="true" tabindex="-1"></a>
[`vminsert.service.udp`](#helm-value-vminsert-service-udp)`(bool)`: Enable UDP port. used if you have `spec.opentsdbListenAddr` specified Make sure that service is not type `LoadBalancer`, as it requires `MixedProtocolLBService` feature gate. Check [here](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) for details
  ```helm-default
  false
  ```
   
<a id="helm-value-vminsert-servicemonitor-annotations" href="#helm-value-vminsert-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.annotations`](#helm-value-vminsert-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-servicemonitor-basicauth" href="#helm-value-vminsert-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.basicAuth`](#helm-value-vminsert-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-servicemonitor-enabled" href="#helm-value-vminsert-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.enabled`](#helm-value-vminsert-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for vminsert component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-vminsert-servicemonitor-extralabels" href="#helm-value-vminsert-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.extraLabels`](#helm-value-vminsert-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-servicemonitor-metricrelabelings" href="#helm-value-vminsert-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.metricRelabelings`](#helm-value-vminsert-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-servicemonitor-namespace" href="#helm-value-vminsert-servicemonitor-namespace" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.namespace`](#helm-value-vminsert-servicemonitor-namespace)`(string)`: Target namespace of ServiceMonitor manifest
  ```helm-default
  ""
  ```
   
<a id="helm-value-vminsert-servicemonitor-relabelings" href="#helm-value-vminsert-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`vminsert.serviceMonitor.relabelings`](#helm-value-vminsert-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-strategy" href="#helm-value-vminsert-strategy" aria-hidden="true" tabindex="-1"></a>
[`vminsert.strategy`](#helm-value-vminsert-strategy)`(object)`: VMInsert strategy
  ```helm-default
  {}
  ```
   
<a id="helm-value-vminsert-suppressstoragefqdnsrender" href="#helm-value-vminsert-suppressstoragefqdnsrender" aria-hidden="true" tabindex="-1"></a>
[`vminsert.suppressStorageFQDNsRender`](#helm-value-vminsert-suppressstoragefqdnsrender)`(bool)`: Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--storageNodes`, they can be re-defined in extraArgs
  ```helm-default
  false
  ```
   
<a id="helm-value-vminsert-tolerations" href="#helm-value-vminsert-tolerations" aria-hidden="true" tabindex="-1"></a>
[`vminsert.tolerations`](#helm-value-vminsert-tolerations)`(list)`: Array of tolerations object. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-vminsert-topologyspreadconstraints" href="#helm-value-vminsert-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`vminsert.topologySpreadConstraints`](#helm-value-vminsert-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-affinity" href="#helm-value-vmselect-affinity" aria-hidden="true" tabindex="-1"></a>
[`vmselect.affinity`](#helm-value-vmselect-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-annotations" href="#helm-value-vmselect-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.annotations`](#helm-value-vmselect-annotations)`(object)`: StatefulSet/Deployment annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-cachemountpath" href="#helm-value-vmselect-cachemountpath" aria-hidden="true" tabindex="-1"></a>
[`vmselect.cacheMountPath`](#helm-value-vmselect-cachemountpath)`(string)`: Cache root folder
  ```helm-default
  /cache
  ```
   
<a id="helm-value-vmselect-containerworkingdir" href="#helm-value-vmselect-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`vmselect.containerWorkingDir`](#helm-value-vmselect-containerworkingdir)`(string)`: Container workdir
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-deployment" href="#helm-value-vmselect-deployment" aria-hidden="true" tabindex="-1"></a>
[`vmselect.deployment`](#helm-value-vmselect-deployment)`(object)`: [K8s Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) specific variables
  ```helm-default
  spec:
      strategy: {}
  ```
   
<a id="helm-value-vmselect-deployment-spec-strategy" href="#helm-value-vmselect-deployment-spec-strategy" aria-hidden="true" tabindex="-1"></a>
[`vmselect.deployment.spec.strategy`](#helm-value-vmselect-deployment-spec-strategy)`(object)`: VMSelect strategy
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-emptydir" href="#helm-value-vmselect-emptydir" aria-hidden="true" tabindex="-1"></a>
[`vmselect.emptyDir`](#helm-value-vmselect-emptydir)`(object)`: Empty dir configuration if persistence is disabled
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-enabled" href="#helm-value-vmselect-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.enabled`](#helm-value-vmselect-enabled)`(bool)`: Enable deployment of vmselect component. Can be deployed as Deployment(default) or StatefulSet
  ```helm-default
  true
  ```
   
<a id="helm-value-vmselect-env" href="#helm-value-vmselect-env" aria-hidden="true" tabindex="-1"></a>
[`vmselect.env`](#helm-value-vmselect-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-envfrom" href="#helm-value-vmselect-envfrom" aria-hidden="true" tabindex="-1"></a>
[`vmselect.envFrom`](#helm-value-vmselect-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-extraargs" href="#helm-value-vmselect-extraargs" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraArgs`](#helm-value-vmselect-extraargs)`(object)`: Extra command line arguments for vmselect component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8481
  loggerFormat: json
  ```
   
<a id="helm-value-vmselect-extracontainers" href="#helm-value-vmselect-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraContainers`](#helm-value-vmselect-extracontainers)`(list)`: Extra containers to run in a pod with vmselect
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-extrahostpathmounts" href="#helm-value-vmselect-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraHostPathMounts`](#helm-value-vmselect-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-extralabels" href="#helm-value-vmselect-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraLabels`](#helm-value-vmselect-extralabels)`(object)`: StatefulSet/Deployment additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-extravolumemounts" href="#helm-value-vmselect-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraVolumeMounts`](#helm-value-vmselect-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-extravolumes" href="#helm-value-vmselect-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`vmselect.extraVolumes`](#helm-value-vmselect-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-fullnameoverride" href="#helm-value-vmselect-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`vmselect.fullnameOverride`](#helm-value-vmselect-fullnameoverride)`(string)`: Overrides the full name of vmselect component
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-horizontalpodautoscaler-behavior" href="#helm-value-vmselect-horizontalpodautoscaler-behavior" aria-hidden="true" tabindex="-1"></a>
[`vmselect.horizontalPodAutoscaler.behavior`](#helm-value-vmselect-horizontalpodautoscaler-behavior)`(object)`: Behavior settings for scaling by the HPA
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-horizontalpodautoscaler-enabled" href="#helm-value-vmselect-horizontalpodautoscaler-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.horizontalPodAutoscaler.enabled`](#helm-value-vmselect-horizontalpodautoscaler-enabled)`(bool)`: Use HPA for vmselect component
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-horizontalpodautoscaler-maxreplicas" href="#helm-value-vmselect-horizontalpodautoscaler-maxreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmselect.horizontalPodAutoscaler.maxReplicas`](#helm-value-vmselect-horizontalpodautoscaler-maxreplicas)`(int)`: Maximum replicas for HPA to use to to scale the vmselect component
  ```helm-default
  10
  ```
   
<a id="helm-value-vmselect-horizontalpodautoscaler-metrics" href="#helm-value-vmselect-horizontalpodautoscaler-metrics" aria-hidden="true" tabindex="-1"></a>
[`vmselect.horizontalPodAutoscaler.metrics`](#helm-value-vmselect-horizontalpodautoscaler-metrics)`(list)`: Metric for HPA to use to scale the vmselect component
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-horizontalpodautoscaler-minreplicas" href="#helm-value-vmselect-horizontalpodautoscaler-minreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmselect.horizontalPodAutoscaler.minReplicas`](#helm-value-vmselect-horizontalpodautoscaler-minreplicas)`(int)`: Minimum replicas for HPA to use to scale the vmselect component
  ```helm-default
  2
  ```
   
<a id="helm-value-vmselect-image-pullpolicy" href="#helm-value-vmselect-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmselect.image.pullPolicy`](#helm-value-vmselect-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-vmselect-image-registry" href="#helm-value-vmselect-image-registry" aria-hidden="true" tabindex="-1"></a>
[`vmselect.image.registry`](#helm-value-vmselect-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-image-repository" href="#helm-value-vmselect-image-repository" aria-hidden="true" tabindex="-1"></a>
[`vmselect.image.repository`](#helm-value-vmselect-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/vmselect
  ```
   
<a id="helm-value-vmselect-image-tag" href="#helm-value-vmselect-image-tag" aria-hidden="true" tabindex="-1"></a>
[`vmselect.image.tag`](#helm-value-vmselect-image-tag)`(string)`: Image tag override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-image-variant" href="#helm-value-vmselect-image-variant" aria-hidden="true" tabindex="-1"></a>
[`vmselect.image.variant`](#helm-value-vmselect-image-variant)`(string)`: Variant of the image to use. e.g. cluster, enterprise-cluster
  ```helm-default
  cluster
  ```
   
<a id="helm-value-vmselect-ingress-annotations" href="#helm-value-vmselect-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.annotations`](#helm-value-vmselect-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-ingress-enabled" href="#helm-value-vmselect-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.enabled`](#helm-value-vmselect-ingress-enabled)`(bool)`: Enable deployment of ingress for vmselect component
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-ingress-extralabels" href="#helm-value-vmselect-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.extraLabels`](#helm-value-vmselect-ingress-extralabels)`(object)`: Ingress extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-ingress-hosts" href="#helm-value-vmselect-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.hosts`](#helm-value-vmselect-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: vmselect.local
    path:
      - /select
    port: http
  ```
   
<a id="helm-value-vmselect-ingress-ingressclassname" href="#helm-value-vmselect-ingress-ingressclassname" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.ingressClassName`](#helm-value-vmselect-ingress-ingressclassname)`(string)`: Ingress controller class name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-ingress-pathtype" href="#helm-value-vmselect-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.pathType`](#helm-value-vmselect-ingress-pathtype)`(string)`: Ingress path type
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-vmselect-ingress-tls" href="#helm-value-vmselect-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ingress.tls`](#helm-value-vmselect-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-initcontainers" href="#helm-value-vmselect-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`vmselect.initContainers`](#helm-value-vmselect-initcontainers)`(list)`: Init containers for vmselect
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-lifecycle" href="#helm-value-vmselect-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`vmselect.lifecycle`](#helm-value-vmselect-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-mode" href="#helm-value-vmselect-mode" aria-hidden="true" tabindex="-1"></a>
[`vmselect.mode`](#helm-value-vmselect-mode)`(string)`: vmselect mode: deployment, daemonSet
  ```helm-default
  deployment
  ```
   
<a id="helm-value-vmselect-name" href="#helm-value-vmselect-name" aria-hidden="true" tabindex="-1"></a>
[`vmselect.name`](#helm-value-vmselect-name)`(string)`: Override default `app` label name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-nodeselector" href="#helm-value-vmselect-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`vmselect.nodeSelector`](#helm-value-vmselect-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-persistentvolume-accessmodes" href="#helm-value-vmselect-persistentvolume-accessmodes" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.accessModes`](#helm-value-vmselect-persistentvolume-accessmodes)`(list)`: Array of access mode. Must match those of existing PV or dynamic provisioner. Details are [here](http://kubernetes.io/docs/user-guide/persistent-volumes/)
  ```helm-default
  - ReadWriteOnce
  ```
   
<a id="helm-value-vmselect-persistentvolume-annotations" href="#helm-value-vmselect-persistentvolume-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.annotations`](#helm-value-vmselect-persistentvolume-annotations)`(object)`: Persistent volume annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-persistentvolume-enabled" href="#helm-value-vmselect-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.enabled`](#helm-value-vmselect-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for vmselect component. Empty dir if false. If true, vmselect will create/use a Persistent Volume Claim
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-persistentvolume-existingclaim" href="#helm-value-vmselect-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.existingClaim`](#helm-value-vmselect-persistentvolume-existingclaim)`(string)`: Existing Claim name. Requires vmselect.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-persistentvolume-labels" href="#helm-value-vmselect-persistentvolume-labels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.labels`](#helm-value-vmselect-persistentvolume-labels)`(object)`: Persistent volume labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-persistentvolume-size" href="#helm-value-vmselect-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.size`](#helm-value-vmselect-persistentvolume-size)`(string)`: Size of the volume. Better to set the same as resource limit memory property
  ```helm-default
  2Gi
  ```
   
<a id="helm-value-vmselect-persistentvolume-subpath" href="#helm-value-vmselect-persistentvolume-subpath" aria-hidden="true" tabindex="-1"></a>
[`vmselect.persistentVolume.subPath`](#helm-value-vmselect-persistentvolume-subpath)`(string)`: Mount subpath
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-podannotations" href="#helm-value-vmselect-podannotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.podAnnotations`](#helm-value-vmselect-podannotations)`(object)`: Pod's annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-poddisruptionbudget" href="#helm-value-vmselect-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`vmselect.podDisruptionBudget`](#helm-value-vmselect-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-vmselect-poddisruptionbudget-enabled" href="#helm-value-vmselect-poddisruptionbudget-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.podDisruptionBudget.enabled`](#helm-value-vmselect-poddisruptionbudget-enabled)`(bool)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-podlabels" href="#helm-value-vmselect-podlabels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.podLabels`](#helm-value-vmselect-podlabels)`(object)`: Pod’s additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-podsecuritycontext" href="#helm-value-vmselect-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`vmselect.podSecurityContext`](#helm-value-vmselect-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  ```
   
<a id="helm-value-vmselect-ports-name" href="#helm-value-vmselect-ports-name" aria-hidden="true" tabindex="-1"></a>
[`vmselect.ports.name`](#helm-value-vmselect-ports-name)`(string)`: VMSelect http port name
  ```helm-default
  http
  ```
   
<a id="helm-value-vmselect-priorityclassname" href="#helm-value-vmselect-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`vmselect.priorityClassName`](#helm-value-vmselect-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-probe" href="#helm-value-vmselect-probe" aria-hidden="true" tabindex="-1"></a>
[`vmselect.probe`](#helm-value-vmselect-probe)`(object)`: Readiness & Liveness probes
  ```helm-default
  liveness:
      failureThreshold: 3
      initialDelaySeconds: 5
      periodSeconds: 15
      tcpSocket: {}
      timeoutSeconds: 5
  readiness:
      failureThreshold: 10
      httpGet: {}
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 5
  startup: {}
  ```
   
<a id="helm-value-vmselect-probe-liveness" href="#helm-value-vmselect-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`vmselect.probe.liveness`](#helm-value-vmselect-probe-liveness)`(object)`: VMSelect liveness probe
  ```helm-default
  failureThreshold: 3
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmselect-probe-readiness" href="#helm-value-vmselect-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`vmselect.probe.readiness`](#helm-value-vmselect-probe-readiness)`(object)`: VMSelect readiness probe
  ```helm-default
  failureThreshold: 10
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmselect-probe-startup" href="#helm-value-vmselect-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`vmselect.probe.startup`](#helm-value-vmselect-probe-startup)`(object)`: VMSelect startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-replicacount" href="#helm-value-vmselect-replicacount" aria-hidden="true" tabindex="-1"></a>
[`vmselect.replicaCount`](#helm-value-vmselect-replicacount)`(int)`: Count of vmselect pods
  ```helm-default
  2
  ```
   
<a id="helm-value-vmselect-resources" href="#helm-value-vmselect-resources" aria-hidden="true" tabindex="-1"></a>
[`vmselect.resources`](#helm-value-vmselect-resources)`(object)`: Resource object. Details are [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-securitycontext" href="#helm-value-vmselect-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`vmselect.securityContext`](#helm-value-vmselect-securitycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  ```
   
<a id="helm-value-vmselect-service-annotations" href="#helm-value-vmselect-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.annotations`](#helm-value-vmselect-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-service-clusterip" href="#helm-value-vmselect-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.clusterIP`](#helm-value-vmselect-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-service-enabled" href="#helm-value-vmselect-service-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.enabled`](#helm-value-vmselect-service-enabled)`(bool)`: Create VMSelect service
  ```helm-default
  true
  ```
   
<a id="helm-value-vmselect-service-externalips" href="#helm-value-vmselect-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.externalIPs`](#helm-value-vmselect-service-externalips)`(list)`: Service external IPs. Details are [here](https://kubernetes.io/docs/user-guide/services/#external-ips)
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-service-externaltrafficpolicy" href="#helm-value-vmselect-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.externalTrafficPolicy`](#helm-value-vmselect-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-service-extraports" href="#helm-value-vmselect-service-extraports" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.extraPorts`](#helm-value-vmselect-service-extraports)`(list)`: Extra service ports
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-service-healthchecknodeport" href="#helm-value-vmselect-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.healthCheckNodePort`](#helm-value-vmselect-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-service-ipfamilies" href="#helm-value-vmselect-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.ipFamilies`](#helm-value-vmselect-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-service-ipfamilypolicy" href="#helm-value-vmselect-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.ipFamilyPolicy`](#helm-value-vmselect-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-service-labels" href="#helm-value-vmselect-service-labels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.labels`](#helm-value-vmselect-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-service-loadbalancerip" href="#helm-value-vmselect-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.loadBalancerIP`](#helm-value-vmselect-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-service-loadbalancersourceranges" href="#helm-value-vmselect-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.loadBalancerSourceRanges`](#helm-value-vmselect-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-service-serviceport" href="#helm-value-vmselect-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.servicePort`](#helm-value-vmselect-service-serviceport)`(int)`: Service port
  ```helm-default
  8481
  ```
   
<a id="helm-value-vmselect-service-targetport" href="#helm-value-vmselect-service-targetport" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.targetPort`](#helm-value-vmselect-service-targetport)`(string)`: Target port
  ```helm-default
  http
  ```
   
<a id="helm-value-vmselect-service-type" href="#helm-value-vmselect-service-type" aria-hidden="true" tabindex="-1"></a>
[`vmselect.service.type`](#helm-value-vmselect-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-vmselect-servicemonitor-annotations" href="#helm-value-vmselect-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.annotations`](#helm-value-vmselect-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-servicemonitor-basicauth" href="#helm-value-vmselect-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.basicAuth`](#helm-value-vmselect-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-servicemonitor-enabled" href="#helm-value-vmselect-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.enabled`](#helm-value-vmselect-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for vmselect component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-servicemonitor-extralabels" href="#helm-value-vmselect-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.extraLabels`](#helm-value-vmselect-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmselect-servicemonitor-metricrelabelings" href="#helm-value-vmselect-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.metricRelabelings`](#helm-value-vmselect-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-servicemonitor-namespace" href="#helm-value-vmselect-servicemonitor-namespace" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.namespace`](#helm-value-vmselect-servicemonitor-namespace)`(string)`: Target namespace of ServiceMonitor manifest
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmselect-servicemonitor-relabelings" href="#helm-value-vmselect-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`vmselect.serviceMonitor.relabelings`](#helm-value-vmselect-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-statefulset" href="#helm-value-vmselect-statefulset" aria-hidden="true" tabindex="-1"></a>
[`vmselect.statefulSet`](#helm-value-vmselect-statefulset)`(object)`: [K8s StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) specific variables
  ```helm-default
  spec:
      podManagementPolicy: OrderedReady
  ```
   
<a id="helm-value-vmselect-statefulset-spec-podmanagementpolicy" href="#helm-value-vmselect-statefulset-spec-podmanagementpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmselect.statefulSet.spec.podManagementPolicy`](#helm-value-vmselect-statefulset-spec-podmanagementpolicy)`(string)`: Deploy order policy for StatefulSet pods
  ```helm-default
  OrderedReady
  ```
   
<a id="helm-value-vmselect-suppressstoragefqdnsrender" href="#helm-value-vmselect-suppressstoragefqdnsrender" aria-hidden="true" tabindex="-1"></a>
[`vmselect.suppressStorageFQDNsRender`](#helm-value-vmselect-suppressstoragefqdnsrender)`(bool)`: Suppress rendering `--storageNode` FQDNs based on `vmstorage.replicaCount` value. If true suppress rendering `--storageNodes`, they can be re-defined in extraArgs
  ```helm-default
  false
  ```
   
<a id="helm-value-vmselect-terminationgraceperiodseconds" href="#helm-value-vmselect-terminationgraceperiodseconds" aria-hidden="true" tabindex="-1"></a>
[`vmselect.terminationGracePeriodSeconds`](#helm-value-vmselect-terminationgraceperiodseconds)`(int)`: Pod's termination grace period in seconds
  ```helm-default
  60
  ```
   
<a id="helm-value-vmselect-tolerations" href="#helm-value-vmselect-tolerations" aria-hidden="true" tabindex="-1"></a>
[`vmselect.tolerations`](#helm-value-vmselect-tolerations)`(list)`: Array of tolerations object. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-vmselect-topologyspreadconstraints" href="#helm-value-vmselect-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`vmselect.topologySpreadConstraints`](#helm-value-vmselect-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-affinity" href="#helm-value-vmstorage-affinity" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.affinity`](#helm-value-vmstorage-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-annotations" href="#helm-value-vmstorage-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.annotations`](#helm-value-vmstorage-annotations)`(object)`: StatefulSet/Deployment annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-containerworkingdir" href="#helm-value-vmstorage-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.containerWorkingDir`](#helm-value-vmstorage-containerworkingdir)`(string)`: Container workdir
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-emptydir" href="#helm-value-vmstorage-emptydir" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.emptyDir`](#helm-value-vmstorage-emptydir)`(object)`: Empty dir configuration if persistence is disabled
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-enabled" href="#helm-value-vmstorage-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.enabled`](#helm-value-vmstorage-enabled)`(bool)`: Enable deployment of vmstorage component. StatefulSet is used
  ```helm-default
  true
  ```
   
<a id="helm-value-vmstorage-env" href="#helm-value-vmstorage-env" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.env`](#helm-value-vmstorage-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-envfrom" href="#helm-value-vmstorage-envfrom" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.envFrom`](#helm-value-vmstorage-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-extraargs" href="#helm-value-vmstorage-extraargs" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraArgs`](#helm-value-vmstorage-extraargs)`(object)`: Additional vmstorage container arguments. Extra command line arguments for vmstorage component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8482
  loggerFormat: json
  ```
   
<a id="helm-value-vmstorage-extracontainers" href="#helm-value-vmstorage-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraContainers`](#helm-value-vmstorage-extracontainers)`(list)`: Extra containers to run in a pod with vmstorage
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-extrahostpathmounts" href="#helm-value-vmstorage-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraHostPathMounts`](#helm-value-vmstorage-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-extralabels" href="#helm-value-vmstorage-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraLabels`](#helm-value-vmstorage-extralabels)`(object)`: StatefulSet/Deployment additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-extrasecretmounts" href="#helm-value-vmstorage-extrasecretmounts" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraSecretMounts`](#helm-value-vmstorage-extrasecretmounts)`(list)`: Extra secret mounts for vmstorage
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-extravolumemounts" href="#helm-value-vmstorage-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraVolumeMounts`](#helm-value-vmstorage-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-extravolumes" href="#helm-value-vmstorage-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.extraVolumes`](#helm-value-vmstorage-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-fullnameoverride" href="#helm-value-vmstorage-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.fullnameOverride`](#helm-value-vmstorage-fullnameoverride)`(string)`: Overrides the full name of vmstorage component
  ```helm-default
  null
  ```
   
<a id="helm-value-vmstorage-horizontalpodautoscaler-behavior" href="#helm-value-vmstorage-horizontalpodautoscaler-behavior" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.horizontalPodAutoscaler.behavior`](#helm-value-vmstorage-horizontalpodautoscaler-behavior)`(object)`: Behavior settings for scaling by the HPA
  ```helm-default
  scaleDown:
      selectPolicy: Disabled
  ```
   
<a id="helm-value-vmstorage-horizontalpodautoscaler-enabled" href="#helm-value-vmstorage-horizontalpodautoscaler-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.horizontalPodAutoscaler.enabled`](#helm-value-vmstorage-horizontalpodautoscaler-enabled)`(bool)`: Use HPA for vmstorage component
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-horizontalpodautoscaler-maxreplicas" href="#helm-value-vmstorage-horizontalpodautoscaler-maxreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.horizontalPodAutoscaler.maxReplicas`](#helm-value-vmstorage-horizontalpodautoscaler-maxreplicas)`(int)`: Maximum replicas for HPA to use to to scale the vmstorage component
  ```helm-default
  10
  ```
   
<a id="helm-value-vmstorage-horizontalpodautoscaler-metrics" href="#helm-value-vmstorage-horizontalpodautoscaler-metrics" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.horizontalPodAutoscaler.metrics`](#helm-value-vmstorage-horizontalpodautoscaler-metrics)`(list)`: Metric for HPA to use to scale the vmstorage component
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-horizontalpodautoscaler-minreplicas" href="#helm-value-vmstorage-horizontalpodautoscaler-minreplicas" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.horizontalPodAutoscaler.minReplicas`](#helm-value-vmstorage-horizontalpodautoscaler-minreplicas)`(int)`: Minimum replicas for HPA to use to scale the vmstorage component
  ```helm-default
  2
  ```
   
<a id="helm-value-vmstorage-image-pullpolicy" href="#helm-value-vmstorage-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.image.pullPolicy`](#helm-value-vmstorage-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-vmstorage-image-registry" href="#helm-value-vmstorage-image-registry" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.image.registry`](#helm-value-vmstorage-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-image-repository" href="#helm-value-vmstorage-image-repository" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.image.repository`](#helm-value-vmstorage-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/vmstorage
  ```
   
<a id="helm-value-vmstorage-image-tag" href="#helm-value-vmstorage-image-tag" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.image.tag`](#helm-value-vmstorage-image-tag)`(string)`: Image tag override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-image-variant" href="#helm-value-vmstorage-image-variant" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.image.variant`](#helm-value-vmstorage-image-variant)`(string)`: Variant of the image to use. e.g. cluster, enterprise-cluster
  ```helm-default
  cluster
  ```
   
<a id="helm-value-vmstorage-initcontainers" href="#helm-value-vmstorage-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.initContainers`](#helm-value-vmstorage-initcontainers)`(list)`: Init containers for vmstorage
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-lifecycle" href="#helm-value-vmstorage-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.lifecycle`](#helm-value-vmstorage-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-minreadyseconds" href="#helm-value-vmstorage-minreadyseconds" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.minReadySeconds`](#helm-value-vmstorage-minreadyseconds)`(int)`:
  ```helm-default
  5
  ```
   
<a id="helm-value-vmstorage-name" href="#helm-value-vmstorage-name" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.name`](#helm-value-vmstorage-name)`(string)`: Override default `app` label name
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-nodeselector" href="#helm-value-vmstorage-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.nodeSelector`](#helm-value-vmstorage-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-persistentvolume-accessmodes" href="#helm-value-vmstorage-persistentvolume-accessmodes" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.accessModes`](#helm-value-vmstorage-persistentvolume-accessmodes)`(list)`: Array of access modes. Must match those of existing PV or dynamic provisioner. Details are [here](http://kubernetes.io/docs/user-guide/persistent-volumes/)
  ```helm-default
  - ReadWriteOnce
  ```
   
<a id="helm-value-vmstorage-persistentvolume-annotations" href="#helm-value-vmstorage-persistentvolume-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.annotations`](#helm-value-vmstorage-persistentvolume-annotations)`(object)`: Persistent volume annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-persistentvolume-enabled" href="#helm-value-vmstorage-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.enabled`](#helm-value-vmstorage-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for vmstorage component. Empty dir if false. If true,  vmstorage will create/use a Persistent Volume Claim
  ```helm-default
  true
  ```
   
<a id="helm-value-vmstorage-persistentvolume-existingclaim" href="#helm-value-vmstorage-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.existingClaim`](#helm-value-vmstorage-persistentvolume-existingclaim)`(string)`: Existing Claim name. Requires vmstorage.persistentVolume.enabled: true. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-persistentvolume-labels" href="#helm-value-vmstorage-persistentvolume-labels" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.labels`](#helm-value-vmstorage-persistentvolume-labels)`(object)`: Persistent volume labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-persistentvolume-mountpath" href="#helm-value-vmstorage-persistentvolume-mountpath" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.mountPath`](#helm-value-vmstorage-persistentvolume-mountpath)`(string)`: Data root path. Vmstorage data Persistent Volume mount root path
  ```helm-default
  /storage
  ```
   
<a id="helm-value-vmstorage-persistentvolume-name" href="#helm-value-vmstorage-persistentvolume-name" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.name`](#helm-value-vmstorage-persistentvolume-name)`(string)`:
  ```helm-default
  vmstorage-volume
  ```
   
<a id="helm-value-vmstorage-persistentvolume-size" href="#helm-value-vmstorage-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.size`](#helm-value-vmstorage-persistentvolume-size)`(string)`: Size of the volume.
  ```helm-default
  8Gi
  ```
   
<a id="helm-value-vmstorage-persistentvolume-storageclassname" href="#helm-value-vmstorage-persistentvolume-storageclassname" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.storageClassName`](#helm-value-vmstorage-persistentvolume-storageclassname)`(string)`: Storage class name. Will be empty if not setted
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-persistentvolume-subpath" href="#helm-value-vmstorage-persistentvolume-subpath" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.persistentVolume.subPath`](#helm-value-vmstorage-persistentvolume-subpath)`(string)`: Mount subpath
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-podannotations" href="#helm-value-vmstorage-podannotations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.podAnnotations`](#helm-value-vmstorage-podannotations)`(object)`: Pod's annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-poddisruptionbudget" href="#helm-value-vmstorage-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.podDisruptionBudget`](#helm-value-vmstorage-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Details are [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-vmstorage-podlabels" href="#helm-value-vmstorage-podlabels" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.podLabels`](#helm-value-vmstorage-podlabels)`(object)`: Pod’s additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-podmanagementpolicy" href="#helm-value-vmstorage-podmanagementpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.podManagementPolicy`](#helm-value-vmstorage-podmanagementpolicy)`(string)`: Deploy order policy for StatefulSet pods
  ```helm-default
  OrderedReady
  ```
   
<a id="helm-value-vmstorage-podsecuritycontext" href="#helm-value-vmstorage-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.podSecurityContext`](#helm-value-vmstorage-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vmstorage-ports-name" href="#helm-value-vmstorage-ports-name" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.ports.name`](#helm-value-vmstorage-ports-name)`(string)`: VMStorage http port name
  ```helm-default
  http
  ```
   
<a id="helm-value-vmstorage-priorityclassname" href="#helm-value-vmstorage-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.priorityClassName`](#helm-value-vmstorage-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-probe" href="#helm-value-vmstorage-probe" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.probe`](#helm-value-vmstorage-probe)`(object)`: Readiness probes
  ```helm-default
  readiness:
      failureThreshold: 10
      httpGet: {}
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 5
  startup: {}
  ```
   
<a id="helm-value-vmstorage-probe-readiness" href="#helm-value-vmstorage-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.probe.readiness`](#helm-value-vmstorage-probe-readiness)`(object)`: VMStorage readiness probe
  ```helm-default
  failureThreshold: 10
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmstorage-probe-startup" href="#helm-value-vmstorage-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.probe.startup`](#helm-value-vmstorage-probe-startup)`(object)`: VMStorage startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-replicacount" href="#helm-value-vmstorage-replicacount" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.replicaCount`](#helm-value-vmstorage-replicacount)`(int)`: Count of vmstorage pods
  ```helm-default
  2
  ```
   
<a id="helm-value-vmstorage-resources" href="#helm-value-vmstorage-resources" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.resources`](#helm-value-vmstorage-resources)`(object)`: Resource object. Details are [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-retentionperiod" href="#helm-value-vmstorage-retentionperiod" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.retentionPeriod`](#helm-value-vmstorage-retentionperiod)`(int)`: Data retention period. Possible units character: h(ours), d(ays), w(eeks), y(ears), if no unit character specified - month. The minimum retention period is 24h. See these [docs](https://docs.victoriametrics.com/single-server-victoriametrics/#retention)
  ```helm-default
  1
  ```
   
<a id="helm-value-vmstorage-schedulername" href="#helm-value-vmstorage-schedulername" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.schedulerName`](#helm-value-vmstorage-schedulername)`(string)`: Use an alternate scheduler, e.g. "stork". Check [here](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-securitycontext" href="#helm-value-vmstorage-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.securityContext`](#helm-value-vmstorage-securitycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-vmstorage-service-annotations" href="#helm-value-vmstorage-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.annotations`](#helm-value-vmstorage-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-service-clusterip" href="#helm-value-vmstorage-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.clusterIP`](#helm-value-vmstorage-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  None
  ```
   
<a id="helm-value-vmstorage-service-enabled" href="#helm-value-vmstorage-service-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.enabled`](#helm-value-vmstorage-service-enabled)`(bool)`:
  ```helm-default
  true
  ```
   
<a id="helm-value-vmstorage-service-externaltrafficpolicy" href="#helm-value-vmstorage-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.externalTrafficPolicy`](#helm-value-vmstorage-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-service-extraports" href="#helm-value-vmstorage-service-extraports" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.extraPorts`](#helm-value-vmstorage-service-extraports)`(list)`: Extra service ports
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-service-healthchecknodeport" href="#helm-value-vmstorage-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.healthCheckNodePort`](#helm-value-vmstorage-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-service-ipfamilies" href="#helm-value-vmstorage-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.ipFamilies`](#helm-value-vmstorage-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-service-ipfamilypolicy" href="#helm-value-vmstorage-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.ipFamilyPolicy`](#helm-value-vmstorage-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-service-labels" href="#helm-value-vmstorage-service-labels" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.labels`](#helm-value-vmstorage-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-service-serviceport" href="#helm-value-vmstorage-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.servicePort`](#helm-value-vmstorage-service-serviceport)`(int)`: Service port
  ```helm-default
  8482
  ```
   
<a id="helm-value-vmstorage-service-type" href="#helm-value-vmstorage-service-type" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.type`](#helm-value-vmstorage-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-vmstorage-service-vminsertport" href="#helm-value-vmstorage-service-vminsertport" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.vminsertPort`](#helm-value-vmstorage-service-vminsertport)`(int)`: Port for accepting connections from vminsert
  ```helm-default
  8400
  ```
   
<a id="helm-value-vmstorage-service-vmselectport" href="#helm-value-vmstorage-service-vmselectport" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.service.vmselectPort`](#helm-value-vmstorage-service-vmselectport)`(int)`: Port for accepting connections from vmselect
  ```helm-default
  8401
  ```
   
<a id="helm-value-vmstorage-servicemonitor-annotations" href="#helm-value-vmstorage-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.annotations`](#helm-value-vmstorage-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-servicemonitor-basicauth" href="#helm-value-vmstorage-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.basicAuth`](#helm-value-vmstorage-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-servicemonitor-enabled" href="#helm-value-vmstorage-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.enabled`](#helm-value-vmstorage-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for vmstorage component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-servicemonitor-extralabels" href="#helm-value-vmstorage-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.extraLabels`](#helm-value-vmstorage-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-servicemonitor-metricrelabelings" href="#helm-value-vmstorage-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.metricRelabelings`](#helm-value-vmstorage-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-servicemonitor-namespace" href="#helm-value-vmstorage-servicemonitor-namespace" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.namespace`](#helm-value-vmstorage-servicemonitor-namespace)`(string)`: Target namespace of ServiceMonitor manifest
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-servicemonitor-relabelings" href="#helm-value-vmstorage-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.serviceMonitor.relabelings`](#helm-value-vmstorage-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-terminationgraceperiodseconds" href="#helm-value-vmstorage-terminationgraceperiodseconds" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.terminationGracePeriodSeconds`](#helm-value-vmstorage-terminationgraceperiodseconds)`(int)`: Pod's termination grace period in seconds
  ```helm-default
  60
  ```
   
<a id="helm-value-vmstorage-tolerations" href="#helm-value-vmstorage-tolerations" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.tolerations`](#helm-value-vmstorage-tolerations)`(list)`: Array of tolerations object. Node tolerations for server scheduling to nodes with taints. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-topologyspreadconstraints" href="#helm-value-vmstorage-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.topologySpreadConstraints`](#helm-value-vmstorage-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-destination" href="#helm-value-vmstorage-vmbackupmanager-destination" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.destination`](#helm-value-vmstorage-vmbackupmanager-destination)`(string)`: Backup destination at S3, GCS or local filesystem. Pod name will be included to path!
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-disabledaily" href="#helm-value-vmstorage-vmbackupmanager-disabledaily" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.disableDaily`](#helm-value-vmstorage-vmbackupmanager-disabledaily)`(bool)`: Disable daily backups
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-disablehourly" href="#helm-value-vmstorage-vmbackupmanager-disablehourly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.disableHourly`](#helm-value-vmstorage-vmbackupmanager-disablehourly)`(bool)`: Disable hourly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-disablemonthly" href="#helm-value-vmstorage-vmbackupmanager-disablemonthly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.disableMonthly`](#helm-value-vmstorage-vmbackupmanager-disablemonthly)`(bool)`: Disable monthly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-disableweekly" href="#helm-value-vmstorage-vmbackupmanager-disableweekly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.disableWeekly`](#helm-value-vmstorage-vmbackupmanager-disableweekly)`(bool)`: Disable weekly backups
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-enabled" href="#helm-value-vmstorage-vmbackupmanager-enabled" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.enabled`](#helm-value-vmstorage-vmbackupmanager-enabled)`(bool)`: Enable automatic creation of backup via vmbackupmanager. vmbackupmanager is part of Enterprise packages
  ```helm-default
  false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-env" href="#helm-value-vmstorage-vmbackupmanager-env" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.env`](#helm-value-vmstorage-vmbackupmanager-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-extraargs" href="#helm-value-vmstorage-vmbackupmanager-extraargs" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.extraArgs`](#helm-value-vmstorage-vmbackupmanager-extraargs)`(object)`: Extra command line arguments for container of component
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  loggerFormat: json
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-extrasecretmounts" href="#helm-value-vmstorage-vmbackupmanager-extrasecretmounts" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.extraSecretMounts`](#helm-value-vmstorage-vmbackupmanager-extrasecretmounts)`(list)`: Extra secret mounts for vmbackupmanager
  ```helm-default
  []
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-image-registry" href="#helm-value-vmstorage-vmbackupmanager-image-registry" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.image.registry`](#helm-value-vmstorage-vmbackupmanager-image-registry)`(string)`: VMBackupManager image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-image-repository" href="#helm-value-vmstorage-vmbackupmanager-image-repository" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.image.repository`](#helm-value-vmstorage-vmbackupmanager-image-repository)`(string)`: VMBackupManager image repository
  ```helm-default
  victoriametrics/vmbackupmanager
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-image-tag" href="#helm-value-vmstorage-vmbackupmanager-image-tag" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.image.tag`](#helm-value-vmstorage-vmbackupmanager-image-tag)`(string)`: VMBackupManager image tag override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-image-variant" href="#helm-value-vmstorage-vmbackupmanager-image-variant" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.image.variant`](#helm-value-vmstorage-vmbackupmanager-image-variant)`(string)`: Variant of the image tag to use. e.g. enterprise.
  ```helm-default
  cluster
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-probe" href="#helm-value-vmstorage-vmbackupmanager-probe" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.probe`](#helm-value-vmstorage-vmbackupmanager-probe)`(object)`: Readiness & Liveness probes
  ```helm-default
  liveness:
      failureThreshold: 10
      initialDelaySeconds: 30
      periodSeconds: 30
      tcpSocket:
          port: manager-http
      timeoutSeconds: 5
  readiness:
      failureThreshold: 10
      httpGet:
          port: manager-http
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 5
  startup: {}
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-probe-liveness" href="#helm-value-vmstorage-vmbackupmanager-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.probe.liveness`](#helm-value-vmstorage-vmbackupmanager-probe-liveness)`(object)`: VMBackupManager liveness probe
  ```helm-default
  failureThreshold: 10
  initialDelaySeconds: 30
  periodSeconds: 30
  tcpSocket:
      port: manager-http
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-probe-readiness" href="#helm-value-vmstorage-vmbackupmanager-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.probe.readiness`](#helm-value-vmstorage-vmbackupmanager-probe-readiness)`(object)`: VMBackupManager readiness probe
  ```helm-default
  failureThreshold: 10
  httpGet:
      port: manager-http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 5
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-probe-startup" href="#helm-value-vmstorage-vmbackupmanager-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.probe.startup`](#helm-value-vmstorage-vmbackupmanager-probe-startup)`(object)`: VMBackupManager startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-resources" href="#helm-value-vmstorage-vmbackupmanager-resources" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.resources`](#helm-value-vmstorage-vmbackupmanager-resources)`(object)`: Resource object. Details are [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-restore" href="#helm-value-vmstorage-vmbackupmanager-restore" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.restore`](#helm-value-vmstorage-vmbackupmanager-restore)`(object)`: Allows to enable restore options for pod. Check [here](https://docs.victoriametrics.com/vmbackupmanager#restore-commands) for details
  ```helm-default
  onStart:
      enabled: false
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-retention" href="#helm-value-vmstorage-vmbackupmanager-retention" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.retention`](#helm-value-vmstorage-vmbackupmanager-retention)`(object)`: Backups' retention settings
  ```helm-default
  keepLastDaily: 2
  keepLastHourly: 2
  keepLastMonthly: 2
  keepLastWeekly: 2
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-retention-keeplastdaily" href="#helm-value-vmstorage-vmbackupmanager-retention-keeplastdaily" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.retention.keepLastDaily`](#helm-value-vmstorage-vmbackupmanager-retention-keeplastdaily)`(int)`: Keep last N daily backups. 0 means delete all existing daily backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-retention-keeplasthourly" href="#helm-value-vmstorage-vmbackupmanager-retention-keeplasthourly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.retention.keepLastHourly`](#helm-value-vmstorage-vmbackupmanager-retention-keeplasthourly)`(int)`: Keep last N hourly backups. 0 means delete all existing hourly backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-retention-keeplastmonthly" href="#helm-value-vmstorage-vmbackupmanager-retention-keeplastmonthly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.retention.keepLastMonthly`](#helm-value-vmstorage-vmbackupmanager-retention-keeplastmonthly)`(int)`: Keep last N monthly backups. 0 means delete all existing monthly backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   
<a id="helm-value-vmstorage-vmbackupmanager-retention-keeplastweekly" href="#helm-value-vmstorage-vmbackupmanager-retention-keeplastweekly" aria-hidden="true" tabindex="-1"></a>
[`vmstorage.vmbackupmanager.retention.keepLastWeekly`](#helm-value-vmstorage-vmbackupmanager-retention-keeplastweekly)`(int)`: Keep last N weekly backups. 0 means delete all existing weekly backups. Specify -1 to turn off
  ```helm-default
  2
  ```
   

