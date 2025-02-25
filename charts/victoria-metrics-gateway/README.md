

![Version](https://img.shields.io/badge/0.7.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-gateway%2Fchangelog%2F%23070)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-gateway)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Gateway - Auth & Rate-Limitting proxy for Victoria Metrics

# Table of Content

* [Prerequisites](#prerequisites)
* [Chart Details](#chart-details)
* [How to Install](#how-to-install)
* [How to Uninstall](#how-to-uninstall)
* [How to use JWT signature verification](#how-to-use-jwt-signature-verification)
* [Documentation of Helm Chart](#documentation-of-helm-chart)

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).
* PV support on underlying infrastructure

## Chart Details

This chart will do the following:

* Rollout victoria metrics gateway

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-gateway` chart available to installation:

```console
helm search repo vm/victoria-metrics-gateway -l
```

### Install `victoria-metrics-gateway` chart

Export default values of `victoria-metrics-gateway` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-gateway > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-gateway > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vmg vm/victoria-metrics-gateway -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vmg oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-gateway -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vmg vm/victoria-metrics-gateway -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vmg oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-gateway -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmg'
```

Get the application by running this command:

```console
helm list -f vmg -n NAMESPACE
```

See the history of versions of `vmg` application with command.

```console
helm history vmg -n NAMESPACE
```

# How to use [JWT signature verification](https://docs.victoriametrics.com/vmgateway#jwt-signature-verification)

Kubernetes best-practice is to store sensitive configuration parts in secrets. For example, 2 keys will be stored as:
```yaml
apiVersion: v1
data:
  key: "<<KEY_DATA>>"
kind: Secret
metadata:
  name: key1
---
apiVersion: v1
data:
  key: "<<KEY_DATA>>"
kind: Secret
metadata:
  name: key2
```

In order to use those secrets it is needed to:
- mount secrets into pod
- provide flag pointing to secret on disk

Here is an example `values.yml` file configuration to achieve this:
```yaml
auth:
  enable: true

extraVolumes:
  - name: key1
    secret:
      secretName: key1
  - name: key2
    secret:
      secretName: key2

extraVolumeMounts:
  - name: key1
    mountPath: /key1
  - name: key2
    mountPath: /key2

extraArgs:
  envflag.enable: "true"
  envflag.prefix: VM_
  loggerFormat: json
  auth.publicKeyFiles: "/key1/key,/key2/key"
```
Note that in this configuration all secret keys will be mounted and accessible to pod.
Please, refer to [this](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#secretvolumesource-v1-core) doc to see all available secret source options.

## How to uninstall

Remove application with command.

```console
helm uninstall vmg -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-gateway

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-gateway/values.yaml`` file.

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
   
<a id="helm-value-auth" href="#helm-value-auth" aria-hidden="true" tabindex="-1"></a>
[`auth`](#helm-value-auth)`(object)`: Access Control configuration. Check [here](https://docs.victoriametrics.com/vmgateway#access-control) for details
  ```helm-default
  enabled: false
  ```
   
<a id="helm-value-auth-enabled" href="#helm-value-auth-enabled" aria-hidden="true" tabindex="-1"></a>
[`auth.enabled`](#helm-value-auth-enabled)`(bool)`: Enable/Disable access-control
  ```helm-default
  false
  ```
   
<a id="helm-value-clustermode" href="#helm-value-clustermode" aria-hidden="true" tabindex="-1"></a>
[`clusterMode`](#helm-value-clustermode)`(bool)`: Specify to True if the source for rate-limiting, reading and writing as a VictoriaMetrics Cluster. Must be true for rate limiting
  ```helm-default
  false
  ```
   
<a id="helm-value-configmap" href="#helm-value-configmap" aria-hidden="true" tabindex="-1"></a>
[`configMap`](#helm-value-configmap)`(string)`: Use existing configmap if specified otherwise .config values will be used. Check [here](https://docs.victoriametrics.com/vmgateway) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-containerworkingdir" href="#helm-value-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`containerWorkingDir`](#helm-value-containerworkingdir)`(string)`: Container working directory
  ```helm-default
  /
  ```
   
<a id="helm-value-env" href="#helm-value-env" aria-hidden="true" tabindex="-1"></a>
[`env`](#helm-value-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://github.com/VictoriaMetrics/VictoriaMetrics#environment-variables) for details.
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
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8431
  loggerFormat: json
  ```
   
<a id="helm-value-extracontainers" href="#helm-value-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`extraContainers`](#helm-value-extracontainers)`(list)`: Extra containers to run in a pod with vmgateway
  ```helm-default
  []
  ```
   
<a id="helm-value-extrahostpathmounts" href="#helm-value-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`extraHostPathMounts`](#helm-value-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-extralabels" href="#helm-value-extralabels" aria-hidden="true" tabindex="-1"></a>
[`extraLabels`](#helm-value-extralabels)`(object)`: Labels to be added to Deployment
  ```helm-default
  {}
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
[`image.registry`](#helm-value-image-registry)`(string)`: Victoria Metrics gateway Docker registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-image-repository" href="#helm-value-image-repository" aria-hidden="true" tabindex="-1"></a>
[`image.repository`](#helm-value-image-repository)`(string)`: Victoria Metrics gateway Docker repository and image name
  ```helm-default
  victoriametrics/vmgateway
  ```
   
<a id="helm-value-image-tag" href="#helm-value-image-tag" aria-hidden="true" tabindex="-1"></a>
[`image.tag`](#helm-value-image-tag)`(string)`: Tag of Docker image override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-image-variant" href="#helm-value-image-variant" aria-hidden="true" tabindex="-1"></a>
[`image.variant`](#helm-value-image-variant)`(string)`: Variant of the image to use. e.g. enterprise, enterprise-scratch
  ```helm-default
  ""
  ```
   
<a id="helm-value-imagepullsecrets" href="#helm-value-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`imagePullSecrets`](#helm-value-imagepullsecrets)`(list)`: Image pull secrets
  ```helm-default
  []
  ```
   
<a id="helm-value-ingress-annotations" href="#helm-value-ingress-annotations" aria-hidden="true" tabindex="-1"></a>
[`ingress.annotations`](#helm-value-ingress-annotations)`(object)`: Ingress annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-ingress-enabled" href="#helm-value-ingress-enabled" aria-hidden="true" tabindex="-1"></a>
[`ingress.enabled`](#helm-value-ingress-enabled)`(bool)`: Enable deployment of ingress for server component
  ```helm-default
  false
  ```
   
<a id="helm-value-ingress-extralabels" href="#helm-value-ingress-extralabels" aria-hidden="true" tabindex="-1"></a>
[`ingress.extraLabels`](#helm-value-ingress-extralabels)`(object)`: Ingress extra labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-ingress-hosts" href="#helm-value-ingress-hosts" aria-hidden="true" tabindex="-1"></a>
[`ingress.hosts`](#helm-value-ingress-hosts)`(list)`: Array of host objects
  ```helm-default
  - name: vmgateway.local
    path:
      - /
    port: http
  ```
   
<a id="helm-value-ingress-ingressclassname" href="#helm-value-ingress-ingressclassname" aria-hidden="true" tabindex="-1"></a>
[`ingress.ingressClassName`](#helm-value-ingress-ingressclassname)`(string)`: Ingress controller class name
  ```helm-default
  ""
  ```
   
<a id="helm-value-ingress-pathtype" href="#helm-value-ingress-pathtype" aria-hidden="true" tabindex="-1"></a>
[`ingress.pathType`](#helm-value-ingress-pathtype)`(string)`: Ingress path type
  ```helm-default
  Prefix
  ```
   
<a id="helm-value-ingress-tls" href="#helm-value-ingress-tls" aria-hidden="true" tabindex="-1"></a>
[`ingress.tls`](#helm-value-ingress-tls)`(list)`: Array of TLS objects
  ```helm-default
  []
  ```
   
<a id="helm-value-initcontainers" href="#helm-value-initcontainers" aria-hidden="true" tabindex="-1"></a>
[`initContainers`](#helm-value-initcontainers)`(list)`: Init containers for vmgateway
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
   
<a id="helm-value-nodeselector" href="#helm-value-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`nodeSelector`](#helm-value-nodeselector)`(object)`: NodeSelector configurations. Check [here](https://kubernetes.io/docs/user-guide/node-selection/) for details
  ```helm-default
  {}
  ```
   
<a id="helm-value-podannotations" href="#helm-value-podannotations" aria-hidden="true" tabindex="-1"></a>
[`podAnnotations`](#helm-value-podannotations)`(object)`: Annotations to be added to pod
  ```helm-default
  {}
  ```
   
<a id="helm-value-poddisruptionbudget" href="#helm-value-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more. Check [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) for details
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-podlabels" href="#helm-value-podlabels" aria-hidden="true" tabindex="-1"></a>
[`podLabels`](#helm-value-podlabels)`(object)`: Labels to be added to pod
  ```helm-default
  {}
  ```
   
<a id="helm-value-podsecuritycontext" href="#helm-value-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`podSecurityContext`](#helm-value-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  ```
   
<a id="helm-value-probe-liveness" href="#helm-value-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`probe.liveness`](#helm-value-probe-liveness)`(object)`: Liveness probe
  ```helm-default
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket: {}
  timeoutSeconds: 5
  ```
   
<a id="helm-value-probe-readiness" href="#helm-value-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`probe.readiness`](#helm-value-probe-readiness)`(object)`: Readiness probe
  ```helm-default
  httpGet: {}
  initialDelaySeconds: 5
  periodSeconds: 15
  ```
   
<a id="helm-value-probe-startup" href="#helm-value-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`probe.startup`](#helm-value-probe-startup)`(object)`: Startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-ratelimiter" href="#helm-value-ratelimiter" aria-hidden="true" tabindex="-1"></a>
[`rateLimiter`](#helm-value-ratelimiter)`(object)`: Rate limiter configuration. Docs are [here](https://docs.victoriametrics.com/vmgateway#rate-limiter)
  ```helm-default
  config: {}
  datasource:
      url: ""
  enabled: false
  ```
   
<a id="helm-value-ratelimiter-datasource-url" href="#helm-value-ratelimiter-datasource-url" aria-hidden="true" tabindex="-1"></a>
[`rateLimiter.datasource.url`](#helm-value-ratelimiter-datasource-url)`(string)`: Datasource VictoriaMetrics or vmselects. Required. Example http://victoroametrics:8428 or http://vmselect:8481/select/0/prometheus
  ```helm-default
  ""
  ```
   
<a id="helm-value-ratelimiter-enabled" href="#helm-value-ratelimiter-enabled" aria-hidden="true" tabindex="-1"></a>
[`rateLimiter.enabled`](#helm-value-ratelimiter-enabled)`(bool)`: Enable/Disable rate-limiting
  ```helm-default
  false
  ```
   
<a id="helm-value-read-url" href="#helm-value-read-url" aria-hidden="true" tabindex="-1"></a>
[`read.url`](#helm-value-read-url)`(string)`: Read endpoint without suffixes, victoriametrics or vmselect. Example http://victoroametrics:8428 or http://vmselect:8481
  ```helm-default
  ""
  ```
   
<a id="helm-value-replicacount" href="#helm-value-replicacount" aria-hidden="true" tabindex="-1"></a>
[`replicaCount`](#helm-value-replicacount)`(int)`: Number of replicas of vmgateway
  ```helm-default
  1
  ```
   
<a id="helm-value-resources" href="#helm-value-resources" aria-hidden="true" tabindex="-1"></a>
[`resources`](#helm-value-resources)`(object)`: We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ```helm-default
  {}
  ```
   
<a id="helm-value-securitycontext" href="#helm-value-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`securityContext`](#helm-value-securitycontext)`(object)`: Pod security context. Check [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for details
  ```helm-default
  enabled: true
  runAsGroup: 1000
  runAsNonRoot: true
  runAsUser: 1000
  ```
   
<a id="helm-value-service-annotations" href="#helm-value-service-annotations" aria-hidden="true" tabindex="-1"></a>
[`service.annotations`](#helm-value-service-annotations)`(object)`: Service annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-service-clusterip" href="#helm-value-service-clusterip" aria-hidden="true" tabindex="-1"></a>
[`service.clusterIP`](#helm-value-service-clusterip)`(string)`: Service ClusterIP
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-enabled" href="#helm-value-service-enabled" aria-hidden="true" tabindex="-1"></a>
[`service.enabled`](#helm-value-service-enabled)`(bool)`: Enabled vmgateway service
  ```helm-default
  true
  ```
   
<a id="helm-value-service-externalips" href="#helm-value-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`service.externalIPs`](#helm-value-service-externalips)`(list)`: Service external IPs. Check [here](https://kubernetes.io/docs/user-guide/services/#external-ips) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-service-externaltrafficpolicy" href="#helm-value-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`service.externalTrafficPolicy`](#helm-value-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-extralabels" href="#helm-value-service-extralabels" aria-hidden="true" tabindex="-1"></a>
[`service.extraLabels`](#helm-value-service-extralabels)`(object)`: Service labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-service-healthchecknodeport" href="#helm-value-service-healthchecknodeport" aria-hidden="true" tabindex="-1"></a>
[`service.healthCheckNodePort`](#helm-value-service-healthchecknodeport)`(string)`: Health check node port for a service. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-ipfamilies" href="#helm-value-service-ipfamilies" aria-hidden="true" tabindex="-1"></a>
[`service.ipFamilies`](#helm-value-service-ipfamilies)`(list)`: List of service IP families. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  []
  ```
   
<a id="helm-value-service-ipfamilypolicy" href="#helm-value-service-ipfamilypolicy" aria-hidden="true" tabindex="-1"></a>
[`service.ipFamilyPolicy`](#helm-value-service-ipfamilypolicy)`(string)`: Service IP family policy. Check [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) for details.
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-loadbalancerip" href="#helm-value-service-loadbalancerip" aria-hidden="true" tabindex="-1"></a>
[`service.loadBalancerIP`](#helm-value-service-loadbalancerip)`(string)`: Service load balancer IP
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-loadbalancersourceranges" href="#helm-value-service-loadbalancersourceranges" aria-hidden="true" tabindex="-1"></a>
[`service.loadBalancerSourceRanges`](#helm-value-service-loadbalancersourceranges)`(list)`: Load balancer source range
  ```helm-default
  []
  ```
   
<a id="helm-value-service-serviceport" href="#helm-value-service-serviceport" aria-hidden="true" tabindex="-1"></a>
[`service.servicePort`](#helm-value-service-serviceport)`(int)`: Service port
  ```helm-default
  8431
  ```
   
<a id="helm-value-service-type" href="#helm-value-service-type" aria-hidden="true" tabindex="-1"></a>
[`service.type`](#helm-value-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
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
   
<a id="helm-value-tolerations" href="#helm-value-tolerations" aria-hidden="true" tabindex="-1"></a>
[`tolerations`](#helm-value-tolerations)`(list)`: Tolerations configurations. Check [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) for details
  ```helm-default
  []
  ```
   
<a id="helm-value-write-url" href="#helm-value-write-url" aria-hidden="true" tabindex="-1"></a>
[`write.url`](#helm-value-write-url)`(string)`: Write endpoint without suffixes, victoriametrics or vminsert. Example http://victoroametrics:8428 or http://vminsert:8480
  ```helm-default
  ""
  ```
   

