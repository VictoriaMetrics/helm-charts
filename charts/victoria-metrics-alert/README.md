

![Version](https://img.shields.io/badge/0.14.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-alert%2Fchangelog%2F%230140)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-alert)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Alert - executes a list of given MetricsQL expressions (rules) and sends alerts to Alert Manager.

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-alert` chart available to installation:

```console
helm search repo vm/victoria-metrics-alert -l
```

### Install `victoria-metrics-alert` chart

Export default values of `victoria-metrics-alert` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-alert > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-alert > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-alert -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-alert -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-alert -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-alert -f values.yaml -n NAMESPACE
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

## HA configuration for Alertmanager

There is no option on this chart to set up Alertmanager with [HA mode](https://github.com/prometheus/alertmanager#high-availability).
To enable the HA configuration, you can use:
- [VictoriaMetrics Operator](https://docs.victoriametrics.com/operator/)
- official [Alertmanager Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)

## How to uninstall

Remove application with command.

```console
helm uninstall vma -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-alert

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-alert/values.yaml`` file.

<a id="helm-value-alertmanager-baseurl" href="#helm-value-alertmanager-baseurl" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.baseURL`](#helm-value-alertmanager-baseurl)`(string)`: External URL, that alertmanager will expose to receivers
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-baseurlprefix" href="#helm-value-alertmanager-baseurlprefix" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.baseURLPrefix`](#helm-value-alertmanager-baseurlprefix)`(string)`: External URL Prefix, Prefix for the internal routes of web endpoints
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-config" href="#helm-value-alertmanager-config" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.config`](#helm-value-alertmanager-config)`(object)`: Alertmanager configuration
  ```helm-default
  global:
      resolve_timeout: 5m
  receivers:
      - name: devnull
  route:
      group_by:
          - alertname
      group_interval: 10s
      group_wait: 30s
      receiver: devnull
      repeat_interval: 24h
  ```
   
<a id="helm-value-alertmanager-configmap" href="#helm-value-alertmanager-configmap" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.configMap`](#helm-value-alertmanager-configmap)`(string)`: Use existing configmap if specified otherwise .config values will be used
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-emptydir" href="#helm-value-alertmanager-emptydir" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.emptyDir`](#helm-value-alertmanager-emptydir)`(object)`: Empty dir configuration if persistence is disabled for Alertmanager
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-enabled" href="#helm-value-alertmanager-enabled" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.enabled`](#helm-value-alertmanager-enabled)`(bool)`: Create alertmanager resources
  ```helm-default
  false
  ```
   
<a id="helm-value-alertmanager-envfrom" href="#helm-value-alertmanager-envfrom" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.envFrom`](#helm-value-alertmanager-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-extraargs" href="#helm-value-alertmanager-extraargs" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.extraArgs`](#helm-value-alertmanager-extraargs)`(object)`: Extra command line arguments for container of component
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-extracontainers" href="#helm-value-alertmanager-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.extraContainers`](#helm-value-alertmanager-extracontainers)`(list)`: Extra containers to run in a pod with alertmanager
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-extrahostpathmounts" href="#helm-value-alertmanager-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.extraHostPathMounts`](#helm-value-alertmanager-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-extravolumemounts" href="#helm-value-alertmanager-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.extraVolumeMounts`](#helm-value-alertmanager-extravolumemounts)`(list)`: Extra Volume Mounts for the container
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-extravolumes" href="#helm-value-alertmanager-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.extraVolumes`](#helm-value-alertmanager-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-fullnameoverride" href="#helm-value-alertmanager-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.fullnameOverride`](#helm-value-alertmanager-fullnameoverride)`(string)`: Override Alertmanager resources fullname
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-image" href="#helm-value-alertmanager-image" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.image`](#helm-value-alertmanager-image)`(object)`: Alertmanager image configuration
  ```helm-default
  registry: ""
  repository: prom/alertmanager
  tag: v0.27.0
  ```
   
<a id="helm-value-alertmanager-imagepullsecrets" href="#helm-value-alertmanager-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.imagePullSecrets`](#helm-value-alertmanager-imagepullsecrets)`(list)`: Image pull secrets
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-ingress-annotations" href="#helm-value-alertmanager-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.annotations`](#helm-value-alertmanager-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-ingress-enabled" href="#helm-value-alertmanager-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.enabled`](#helm-value-alertmanager-ingress-enabled)`(bool)`: Enable deployment of ingress for alertmanager component
  ```helm-default
  false
  ```
   
<a id="helm-value-alertmanager-ingress-extralabels" href="#helm-value-alertmanager-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.extraLabels`](#helm-value-alertmanager-ingress-extralabels)`(object)`: Ingress extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-ingress-hosts" href="#helm-value-alertmanager-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.hosts`](#helm-value-alertmanager-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: alertmanager.local
    path:
      - /
    port: web
  ```
   
<a id="helm-value-alertmanager-ingress-ingressclassname" href="#helm-value-alertmanager-ingress-ingressclassname" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.ingressClassName`](#helm-value-alertmanager-ingress-ingressclassname)`(string)`: Ingress controller class name
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-ingress-pathtype" href="#helm-value-alertmanager-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.pathType`](#helm-value-alertmanager-ingress-pathtype)`(string)`: Ingress path type
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-alertmanager-ingress-tls" href="#helm-value-alertmanager-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.ingress.tls`](#helm-value-alertmanager-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-initcontainers" href="#helm-value-alertmanager-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.initContainers`](#helm-value-alertmanager-initcontainers)`(list)`: Additional initContainers to initialize the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-listenaddress" href="#helm-value-alertmanager-listenaddress" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.listenAddress`](#helm-value-alertmanager-listenaddress)`(string)`: Alertmanager listen address
  ```helm-default
  0.0.0.0:9093
  ```
   
<a id="helm-value-alertmanager-nodeselector" href="#helm-value-alertmanager-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.nodeSelector`](#helm-value-alertmanager-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-persistentvolume-accessmodes" href="#helm-value-alertmanager-persistentvolume-accessmodes" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.accessModes`](#helm-value-alertmanager-persistentvolume-accessmodes)`(list)`: Array of access modes. Must match those of existing PV or dynamic provisioner. Details are [here](http://kubernetes.io/docs/user-guide/persistent-volumes/)
  ```helm-default
  - ReadWriteOnce
  ```
   
<a id="helm-value-alertmanager-persistentvolume-annotations" href="#helm-value-alertmanager-persistentvolume-annotations" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.annotations`](#helm-value-alertmanager-persistentvolume-annotations)`(object)`: Persistant volume annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-persistentvolume-enabled" href="#helm-value-alertmanager-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.enabled`](#helm-value-alertmanager-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for alertmanager component. Empty dir if false
  ```helm-default
  false
  ```
   
<a id="helm-value-alertmanager-persistentvolume-existingclaim" href="#helm-value-alertmanager-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.existingClaim`](#helm-value-alertmanager-persistentvolume-existingclaim)`(string)`: Existing Claim name. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-persistentvolume-mountpath" href="#helm-value-alertmanager-persistentvolume-mountpath" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.mountPath`](#helm-value-alertmanager-persistentvolume-mountpath)`(string)`: Mount path. Alertmanager data Persistent Volume mount root path.
  ```helm-default
  /data
  ```
   
<a id="helm-value-alertmanager-persistentvolume-size" href="#helm-value-alertmanager-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.size`](#helm-value-alertmanager-persistentvolume-size)`(string)`: Size of the volume. Better to set the same as resource limit memory property.
  ```helm-default
  50Mi
  ```
   
<a id="helm-value-alertmanager-persistentvolume-storageclassname" href="#helm-value-alertmanager-persistentvolume-storageclassname" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.storageClassName`](#helm-value-alertmanager-persistentvolume-storageclassname)`(string)`: StorageClass to use for persistent volume. Requires alertmanager.persistentVolume.enabled: true. If defined, PVC created automatically
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-persistentvolume-subpath" href="#helm-value-alertmanager-persistentvolume-subpath" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.persistentVolume.subPath`](#helm-value-alertmanager-persistentvolume-subpath)`(string)`: Mount subpath
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-podannotations" href="#helm-value-alertmanager-podannotations" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.podAnnotations`](#helm-value-alertmanager-podannotations)`(object)`: Alertmanager Pod annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-podlabels" href="#helm-value-alertmanager-podlabels" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.podLabels`](#helm-value-alertmanager-podlabels)`(object)`: Alertmanager Pod labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-podsecuritycontext" href="#helm-value-alertmanager-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.podSecurityContext`](#helm-value-alertmanager-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-alertmanager-priorityclassname" href="#helm-value-alertmanager-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.priorityClassName`](#helm-value-alertmanager-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-probe-liveness" href="#helm-value-alertmanager-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.probe.liveness`](#helm-value-alertmanager-probe-liveness)`(object)`: Liveness probe
  ```helm-default
  httpGet:
      path: '{{ ternary "" .baseURLPrefix (empty .baseURLPrefix) }}/-/healthy'
      port: web
  ```
   
<a id="helm-value-alertmanager-probe-readiness" href="#helm-value-alertmanager-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.probe.readiness`](#helm-value-alertmanager-probe-readiness)`(object)`: Readiness probe
  ```helm-default
  httpGet:
      path: '{{ ternary "" .baseURLPrefix (empty .baseURLPrefix) }}/-/ready'
      port: web
  ```
   
<a id="helm-value-alertmanager-probe-startup" href="#helm-value-alertmanager-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.probe.startup`](#helm-value-alertmanager-probe-startup)`(object)`: Startup probe
  ```helm-default
  httpGet:
      path: '{{ ternary "" .baseURLPrefix (empty .baseURLPrefix) }}/-/ready'
      port: web
  ```
   
<a id="helm-value-alertmanager-resources" href="#helm-value-alertmanager-resources" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.resources`](#helm-value-alertmanager-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-retention" href="#helm-value-alertmanager-retention" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.retention`](#helm-value-alertmanager-retention)`(string)`: Alertmanager retention
  ```helm-default
  120h
  ```
   
<a id="helm-value-alertmanager-securitycontext" href="#helm-value-alertmanager-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.securityContext`](#helm-value-alertmanager-securitycontext)`(object)`: Security context to be added to server pods
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-alertmanager-service-annotations" href="#helm-value-alertmanager-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.annotations`](#helm-value-alertmanager-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-service-clusterip" href="#helm-value-alertmanager-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.clusterIP`](#helm-value-alertmanager-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-service-externalips" href="#helm-value-alertmanager-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.externalIPs`](#helm-value-alertmanager-service-externalips)`(list)`: Service external IPs. Check [here](https://kubernetes.io/docs/user-guide/services/#external-ips) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-service-externaltrafficpolicy" href="#helm-value-alertmanager-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.externalTrafficPolicy`](#helm-value-alertmanager-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-service-healthchecknodeport" href="#helm-value-alertmanager-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.healthCheckNodePort`](#helm-value-alertmanager-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-service-ipfamilies" href="#helm-value-alertmanager-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.ipFamilies`](#helm-value-alertmanager-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-service-ipfamilypolicy" href="#helm-value-alertmanager-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.ipFamilyPolicy`](#helm-value-alertmanager-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-service-labels" href="#helm-value-alertmanager-service-labels" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.labels`](#helm-value-alertmanager-service-labels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-service-loadbalancerip" href="#helm-value-alertmanager-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.loadBalancerIP`](#helm-value-alertmanager-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-alertmanager-service-loadbalancersourceranges" href="#helm-value-alertmanager-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.loadBalancerSourceRanges`](#helm-value-alertmanager-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-service-serviceport" href="#helm-value-alertmanager-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.servicePort`](#helm-value-alertmanager-service-serviceport)`(int)`: Service port
  ```helm-default
  9093
  ```
   
<a id="helm-value-alertmanager-service-type" href="#helm-value-alertmanager-service-type" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.service.type`](#helm-value-alertmanager-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-alertmanager-templates" href="#helm-value-alertmanager-templates" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.templates`](#helm-value-alertmanager-templates)`(object)`: Alertmanager extra templates
  ```helm-default
  {}
  ```
   
<a id="helm-value-alertmanager-tolerations" href="#helm-value-alertmanager-tolerations" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.tolerations`](#helm-value-alertmanager-tolerations)`(list)`: Node tolerations for server scheduling to nodes with taints. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-alertmanager-webconfig" href="#helm-value-alertmanager-webconfig" aria-hidden="true" tabindex="-1"></a>
[`alertmanager.webConfig`](#helm-value-alertmanager-webconfig)`(object)`: Alertmanager web configuration
  ```helm-default
  {}
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
   
<a id="helm-value-nameoverride" href="#helm-value-nameoverride" aria-hidden="true" tabindex="-1"></a>
[`nameOverride`](#helm-value-nameoverride)`(string)`: Override chart name
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-affinity" href="#helm-value-server-affinity" aria-hidden="true" tabindex="-1"></a>
[`server.affinity`](#helm-value-server-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-annotations" href="#helm-value-server-annotations" aria-hidden="true" tabindex="-1"></a>
[`server.annotations`](#helm-value-server-annotations)`(object)`: Annotations to be added to the deployment
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-config" href="#helm-value-server-config" aria-hidden="true" tabindex="-1"></a>
[`server.config`](#helm-value-server-config)`(object)`: VMAlert configuration
  ```helm-default
  alerts:
      groups: []
  ```
   
<a id="helm-value-server-configmap" href="#helm-value-server-configmap" aria-hidden="true" tabindex="-1"></a>
[`server.configMap`](#helm-value-server-configmap)`(string)`: VMAlert alert rules configuration. Use existing configmap if specified
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-datasource" href="#helm-value-server-datasource" aria-hidden="true" tabindex="-1"></a>
[`server.datasource`](#helm-value-server-datasource)`(object)`: VMAlert reads metrics from source, next section represents its configuration. It can be any service which supports MetricsQL or PromQL.
  ```helm-default
  basicAuth:
      password: ""
      username: ""
  bearer:
      token: ""
      tokenFile: ""
  url: ""
  ```
   
<a id="helm-value-server-datasource-basicauth" href="#helm-value-server-datasource-basicauth" aria-hidden="true" tabindex="-1"></a>
[`server.datasource.basicAuth`](#helm-value-server-datasource-basicauth)`(object)`: Basic auth for datasource
  ```helm-default
  password: ""
  username: ""
  ```
   
<a id="helm-value-server-datasource-bearer-token" href="#helm-value-server-datasource-bearer-token" aria-hidden="true" tabindex="-1"></a>
[`server.datasource.bearer.token`](#helm-value-server-datasource-bearer-token)`(string)`: Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-datasource-bearer-tokenfile" href="#helm-value-server-datasource-bearer-tokenfile" aria-hidden="true" tabindex="-1"></a>
[`server.datasource.bearer.tokenFile`](#helm-value-server-datasource-bearer-tokenfile)`(string)`: Token Auth file with Bearer token. You can use one of token or tokenFile
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-env" href="#helm-value-server-env" aria-hidden="true" tabindex="-1"></a>
[`server.env`](#helm-value-server-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for details.
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
  httpListenAddr: :8880
  loggerFormat: json
  rule:
      - /config/alert-rules.yaml
  ```
   
<a id="helm-value-server-extracontainers" href="#helm-value-server-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`server.extraContainers`](#helm-value-server-extracontainers)`(list)`: Additional containers to run in the same pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extrahostpathmounts" href="#helm-value-server-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraHostPathMounts`](#helm-value-server-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extravolumemounts" href="#helm-value-server-extravolumemounts" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumeMounts`](#helm-value-server-extravolumemounts)`(list)`: Extra Volume Mounts for the container. Expects a lice of [volume mounts](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#volumemount-v1-core)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-extravolumes" href="#helm-value-server-extravolumes" aria-hidden="true" tabindex="-1"></a>
[`server.extraVolumes`](#helm-value-server-extravolumes)`(list)`: Extra Volumes for the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-fullnameoverride" href="#helm-value-server-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`server.fullnameOverride`](#helm-value-server-fullnameoverride)`(string)`: Override vmalert resources fullname
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-image" href="#helm-value-server-image" aria-hidden="true" tabindex="-1"></a>
[`server.image`](#helm-value-server-image)`(object)`: VMAlert image configuration
  ```helm-default
  pullPolicy: IfNotPresent
  registry: ""
  repository: victoriametrics/vmalert
  tag: ""
  variant: ""
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
[`server.ingress.enabled`](#helm-value-server-ingress-enabled)`(bool)`: Enable deployment of ingress for vmalert component
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
  - name: vmalert.local
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
[`server.initContainers`](#helm-value-server-initcontainers)`(list)`: Additional initContainers to initialize the pod
  ```helm-default
  []
  ```
   
<a id="helm-value-server-labels" href="#helm-value-server-labels" aria-hidden="true" tabindex="-1"></a>
[`server.labels`](#helm-value-server-labels)`(object)`: Labels to be added to the deployment
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-minreadyseconds" href="#helm-value-server-minreadyseconds" aria-hidden="true" tabindex="-1"></a>
[`server.minReadySeconds`](#helm-value-server-minreadyseconds)`(int)`: Specifies the minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing/terminating 0 is the standard k8s default
  ```helm-default
  0
  ```
   
<a id="helm-value-server-name" href="#helm-value-server-name" aria-hidden="true" tabindex="-1"></a>
[`server.name`](#helm-value-server-name)`(string)`: Override default `app` label name
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-nodeselector" href="#helm-value-server-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`server.nodeSelector`](#helm-value-server-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-notifier" href="#helm-value-server-notifier" aria-hidden="true" tabindex="-1"></a>
[`server.notifier`](#helm-value-server-notifier)`(object)`: Notifier to use for alerts. Multiple notifiers can be enabled by using `notifiers` section
  ```helm-default
  alertmanager:
      basicAuth:
          password: ""
          username: ""
      bearer:
          token: ""
          tokenFile: ""
      url: ""
  ```
   
<a id="helm-value-server-notifier-alertmanager-basicauth" href="#helm-value-server-notifier-alertmanager-basicauth" aria-hidden="true" tabindex="-1"></a>
[`server.notifier.alertmanager.basicAuth`](#helm-value-server-notifier-alertmanager-basicauth)`(object)`: Basic auth for alertmanager
  ```helm-default
  password: ""
  username: ""
  ```
   
<a id="helm-value-server-notifier-alertmanager-bearer-token" href="#helm-value-server-notifier-alertmanager-bearer-token" aria-hidden="true" tabindex="-1"></a>
[`server.notifier.alertmanager.bearer.token`](#helm-value-server-notifier-alertmanager-bearer-token)`(string)`: Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-notifier-alertmanager-bearer-tokenfile" href="#helm-value-server-notifier-alertmanager-bearer-tokenfile" aria-hidden="true" tabindex="-1"></a>
[`server.notifier.alertmanager.bearer.tokenFile`](#helm-value-server-notifier-alertmanager-bearer-tokenfile)`(string)`: Token Auth file with Bearer token. You can use one of token or tokenFile
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-notifiers" href="#helm-value-server-notifiers" aria-hidden="true" tabindex="-1"></a>
[`server.notifiers`](#helm-value-server-notifiers)`(list)`: Additional notifiers to use for alerts
  ```helm-default
  []
  ```
   
<a id="helm-value-server-podannotations" href="#helm-value-server-podannotations" aria-hidden="true" tabindex="-1"></a>
[`server.podAnnotations`](#helm-value-server-podannotations)`(object)`: Annotations to be added to pod
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-poddisruptionbudget" href="#helm-value-server-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`server.podDisruptionBudget`](#helm-value-server-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Or check [docs](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
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
   
<a id="helm-value-server-probe-liveness" href="#helm-value-server-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`server.probe.liveness`](#helm-value-server-probe-liveness)`(object)`: Liveness probe
  ```helm-default
  failureThreshold: 3
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-probe-readiness" href="#helm-value-server-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`server.probe.readiness`](#helm-value-server-probe-readiness)`(object)`: Readiness probe
  ```helm-default
  failureThreshold: 3
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 15
  timeoutSeconds: 5
  ```
   
<a id="helm-value-server-probe-startup" href="#helm-value-server-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`server.probe.startup`](#helm-value-server-probe-startup)`(object)`: Startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-server-remote-read-basicauth" href="#helm-value-server-remote-read-basicauth" aria-hidden="true" tabindex="-1"></a>
[`server.remote.read.basicAuth`](#helm-value-server-remote-read-basicauth)`(object)`: Basic auth for remote read
  ```helm-default
  password: ""
  username: ""
  ```
   
<a id="helm-value-server-remote-read-bearer" href="#helm-value-server-remote-read-bearer" aria-hidden="true" tabindex="-1"></a>
[`server.remote.read.bearer`](#helm-value-server-remote-read-bearer)`(object)`: Auth based on Bearer token for remote read
  ```helm-default
  token: ""
  tokenFile: ""
  ```
   
<a id="helm-value-server-remote-read-bearer-token" href="#helm-value-server-remote-read-bearer-token" aria-hidden="true" tabindex="-1"></a>
[`server.remote.read.bearer.token`](#helm-value-server-remote-read-bearer-token)`(string)`: Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-remote-read-bearer-tokenfile" href="#helm-value-server-remote-read-bearer-tokenfile" aria-hidden="true" tabindex="-1"></a>
[`server.remote.read.bearer.tokenFile`](#helm-value-server-remote-read-bearer-tokenfile)`(string)`: Token Auth file with Bearer token. You can use one of token or tokenFile
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-remote-read-url" href="#helm-value-server-remote-read-url" aria-hidden="true" tabindex="-1"></a>
[`server.remote.read.url`](#helm-value-server-remote-read-url)`(string)`: VMAlert remote read URL
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-remote-write-basicauth" href="#helm-value-server-remote-write-basicauth" aria-hidden="true" tabindex="-1"></a>
[`server.remote.write.basicAuth`](#helm-value-server-remote-write-basicauth)`(object)`: Basic auth for remote write
  ```helm-default
  password: ""
  username: ""
  ```
   
<a id="helm-value-server-remote-write-bearer" href="#helm-value-server-remote-write-bearer" aria-hidden="true" tabindex="-1"></a>
[`server.remote.write.bearer`](#helm-value-server-remote-write-bearer)`(object)`: Auth based on Bearer token for remote write
  ```helm-default
  token: ""
  tokenFile: ""
  ```
   
<a id="helm-value-server-remote-write-bearer-token" href="#helm-value-server-remote-write-bearer-token" aria-hidden="true" tabindex="-1"></a>
[`server.remote.write.bearer.token`](#helm-value-server-remote-write-bearer-token)`(string)`: Token with Bearer token. You can use one of token or tokenFile. You don't need to add "Bearer" prefix string
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-remote-write-bearer-tokenfile" href="#helm-value-server-remote-write-bearer-tokenfile" aria-hidden="true" tabindex="-1"></a>
[`server.remote.write.bearer.tokenFile`](#helm-value-server-remote-write-bearer-tokenfile)`(string)`: Token Auth file with Bearer token. You can use one of token or tokenFile
  ```helm-default
  ""
  ```
   
<a id="helm-value-server-remote-write-url" href="#helm-value-server-remote-write-url" aria-hidden="true" tabindex="-1"></a>
[`server.remote.write.url`](#helm-value-server-remote-write-url)`(string)`: VMAlert remote write URL
  ```helm-default
  ""
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
  ""
  ```
   
<a id="helm-value-server-service-externalips" href="#helm-value-server-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`server.service.externalIPs`](#helm-value-server-service-externalips)`(list)`: Service external IPs. Check [here](https://kubernetes.io/docs/user-guide/services/#external-ips) for details
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
  8880
  ```
   
<a id="helm-value-server-service-type" href="#helm-value-server-service-type" aria-hidden="true" tabindex="-1"></a>
[`server.service.type`](#helm-value-server-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-server-strategy" href="#helm-value-server-strategy" aria-hidden="true" tabindex="-1"></a>
[`server.strategy`](#helm-value-server-strategy)`(object)`: Deployment strategy, set to standard k8s default
  ```helm-default
  rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  type: RollingUpdate
  ```
   
<a id="helm-value-server-tolerations" href="#helm-value-server-tolerations" aria-hidden="true" tabindex="-1"></a>
[`server.tolerations`](#helm-value-server-tolerations)`(list)`: Node tolerations for server scheduling to nodes with taints. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-server-verticalpodautoscaler" href="#helm-value-server-verticalpodautoscaler" aria-hidden="true" tabindex="-1"></a>
[`server.verticalPodAutoscaler`](#helm-value-server-verticalpodautoscaler)`(object)`: Vertical Pod Autoscaler
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-server-verticalpodautoscaler-enabled" href="#helm-value-server-verticalpodautoscaler-enabled" aria-hidden="true" tabindex="-1"></a>
[`server.verticalPodAutoscaler.enabled`](#helm-value-server-verticalpodautoscaler-enabled)`(bool)`: Use VPA for vmalert
  ```helm-default
  false
  ```
   
<a id="helm-value-serviceaccount-annotations" href="#helm-value-serviceaccount-annotations" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.annotations`](#helm-value-serviceaccount-annotations)`(object)`: Annotations to add to the service account
  ```helm-default
  {}
  ```
   
<a id="helm-value-serviceaccount-automounttoken" href="#helm-value-serviceaccount-automounttoken" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.automountToken`](#helm-value-serviceaccount-automounttoken)`(bool)`: Mount API token to pod directly
  ```helm-default
  true
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
   
<a id="helm-value-servicemonitor-annotations" href="#helm-value-servicemonitor-annotations" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.annotations`](#helm-value-servicemonitor-annotations)`(object)`: Service Monitor annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-servicemonitor-basicauth" href="#helm-value-servicemonitor-basicauth" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.basicAuth`](#helm-value-servicemonitor-basicauth)`(object)`: Basic auth params for Service Monitor
  ```helm-default
  {}
  ```
   
<a id="helm-value-servicemonitor-enabled" href="#helm-value-servicemonitor-enabled" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.enabled`](#helm-value-servicemonitor-enabled)`(bool)`: Enable deployment of Service Monitor for server component. This is Prometheus operator object
  ```helm-default
  false
  ```
   
<a id="helm-value-servicemonitor-extralabels" href="#helm-value-servicemonitor-extralabels" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.extraLabels`](#helm-value-servicemonitor-extralabels)`(object)`: Service Monitor labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-servicemonitor-metricrelabelings" href="#helm-value-servicemonitor-metricrelabelings" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.metricRelabelings`](#helm-value-servicemonitor-metricrelabelings)`(list)`: Service Monitor metricRelabelings
  ```helm-default
  []
  ```
   
<a id="helm-value-servicemonitor-relabelings" href="#helm-value-servicemonitor-relabelings" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.relabelings`](#helm-value-servicemonitor-relabelings)`(list)`: Service Monitor relabelings
  ```helm-default
  []
  ```
   

