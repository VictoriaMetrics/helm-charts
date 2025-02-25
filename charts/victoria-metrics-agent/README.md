

![Version](https://img.shields.io/badge/0.16.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-agent%2Fchangelog%2F%230160)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-agent)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Agent - collects metrics from various sources and stores them to VictoriaMetrics

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
List versions of `vm/victoria-metrics-agent` chart available to installation:

```console
helm search repo vm/victoria-metrics-agent -l
```

### Install `victoria-metrics-agent` chart

Export default values of `victoria-metrics-agent` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-agent > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-agent > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-agent -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-agent -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vma vm/victoria-metrics-agent -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vma oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-agent -f values.yaml -n NAMESPACE
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

## Upgrade guide

### Upgrade to 0.13.0

- replace `remoteWriteUrls` to `remoteWrite`:

Given below config

```yaml
remoteWriteUrls:
- http://address1/api/v1/write
- http://address2/api/v1/write
```

should be changed to

```yaml
remoteWrite:
- url: http://address1/api/v1/write
- url: http://address2/api/v1/write
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
cd charts/victoria-metrics-agent

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-agent/values.yaml`` file.

<a id="helm-value-affinity" href="#helm-value-affinity" aria-hidden="true" tabindex="-1"></a>
[`affinity`](#helm-value-affinity)`(object)`: Pod affinity
  ```helm-default
  {}
  ```
   
<a id="helm-value-allowedmetricsendpoints-0-" href="#helm-value-allowedmetricsendpoints-0-" aria-hidden="true" tabindex="-1"></a>
[`allowedMetricsEndpoints[0]`](#helm-value-allowedmetricsendpoints-0-)`(string)`:
  ```helm-default
  /metrics
  ```
   
<a id="helm-value-annotations" href="#helm-value-annotations" aria-hidden="true" tabindex="-1"></a>
[`annotations`](#helm-value-annotations)`(object)`: Annotations to be added to the deployment
  ```helm-default
  {}
  ```
   
<a id="helm-value-config" href="#helm-value-config" aria-hidden="true" tabindex="-1"></a>
[`config`](#helm-value-config)`(object)`: VMAgent scrape configuration
  ```helm-default
  global:
      scrape_interval: 10s
  scrape_configs:
      - job_name: vmagent
        static_configs:
          - targets:
              - localhost:8429
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
          - role: endpointslices
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
          - source_labels:
              - __meta_kubernetes_pod_name
            target_label: pod
          - source_labels:
              - __meta_kubernetes_pod_container_name
            target_label: container
          - source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - source_labels:
              - __meta_kubernetes_service_name
            target_label: service
          - replacement: ${1}
            source_labels:
              - __meta_kubernetes_service_name
            target_label: job
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_node_name
            target_label: node
      - job_name: kubernetes-service-endpoints-slow
        kubernetes_sd_configs:
          - role: endpointslices
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
          - source_labels:
              - __meta_kubernetes_pod_name
            target_label: pod
          - source_labels:
              - __meta_kubernetes_pod_container_name
            target_label: container
          - source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - source_labels:
              - __meta_kubernetes_service_name
            target_label: service
          - replacement: ${1}
            source_labels:
              - __meta_kubernetes_service_name
            target_label: job
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
          - source_labels:
              - __meta_kubernetes_pod_name
            target_label: pod
          - source_labels:
              - __meta_kubernetes_pod_container_name
            target_label: container
          - source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_node_name
            target_label: node
  ```
   
<a id="helm-value-configmap" href="#helm-value-configmap" aria-hidden="true" tabindex="-1"></a>
[`configMap`](#helm-value-configmap)`(string)`: VMAgent [scraping configuration](https://docs.victoriametrics.com/vmagent#how-to-collect-metrics-in-prometheus-format) use existing configmap if specified otherwise .config values will be used
  ```helm-default
  ""
  ```
   
<a id="helm-value-containerworkingdir" href="#helm-value-containerworkingdir" aria-hidden="true" tabindex="-1"></a>
[`containerWorkingDir`](#helm-value-containerworkingdir)`(string)`: Container working directory
  ```helm-default
  /
  ```
   
<a id="helm-value-daemonset" href="#helm-value-daemonset" aria-hidden="true" tabindex="-1"></a>
[`daemonSet`](#helm-value-daemonset)`(object)`: [K8s DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) specific variables
  ```helm-default
  spec: {}
  ```
   
<a id="helm-value-deployment" href="#helm-value-deployment" aria-hidden="true" tabindex="-1"></a>
[`deployment`](#helm-value-deployment)`(object)`: [K8s Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) specific variables
  ```helm-default
  spec:
      strategy: {}
  ```
   
<a id="helm-value-deployment-spec-strategy" href="#helm-value-deployment-spec-strategy" aria-hidden="true" tabindex="-1"></a>
[`deployment.spec.strategy`](#helm-value-deployment-spec-strategy)`(object)`: Deployment strategy. Check [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) for details
  ```helm-default
  {}
  ```
   
<a id="helm-value-emptydir" href="#helm-value-emptydir" aria-hidden="true" tabindex="-1"></a>
[`emptyDir`](#helm-value-emptydir)`(object)`: Empty dir configuration for a case, when persistence is disabled
  ```helm-default
  {}
  ```
   
<a id="helm-value-env" href="#helm-value-env" aria-hidden="true" tabindex="-1"></a>
[`env`](#helm-value-env)`(list)`: Additional environment variables (ex.: secret tokens, flags). Check [here](https://docs.victoriametrics.com/#environment-variables) for more details.
  ```helm-default
  []
  ```
   
<a id="helm-value-envfrom" href="#helm-value-envfrom" aria-hidden="true" tabindex="-1"></a>
[`envFrom`](#helm-value-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-extraargs" href="#helm-value-extraargs" aria-hidden="true" tabindex="-1"></a>
[`extraArgs`](#helm-value-extraargs)`(object)`: VMAgent extra command line arguments
  ```helm-default
  envflag.enable: true
  envflag.prefix: VM_
  httpListenAddr: :8429
  loggerFormat: json
  ```
   
<a id="helm-value-extracontainers" href="#helm-value-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`extraContainers`](#helm-value-extracontainers)`(list)`: Extra containers to run in a pod with vmagent
  ```helm-default
  []
  ```
   
<a id="helm-value-extrahostpathmounts" href="#helm-value-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`extraHostPathMounts`](#helm-value-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-extralabels" href="#helm-value-extralabels" aria-hidden="true" tabindex="-1"></a>
[`extraLabels`](#helm-value-extralabels)`(object)`: Extra labels for Deployment and Statefulset
  ```helm-default
  {}
  ```
   
<a id="helm-value-extraobjects" href="#helm-value-extraobjects" aria-hidden="true" tabindex="-1"></a>
[`extraObjects`](#helm-value-extraobjects)`(list)`: Add extra specs dynamically to this chart
  ```helm-default
  []
  ```
   
<a id="helm-value-extrascrapeconfigs" href="#helm-value-extrascrapeconfigs" aria-hidden="true" tabindex="-1"></a>
[`extraScrapeConfigs`](#helm-value-extrascrapeconfigs)`(list)`: Extra scrape configs that will be appended to `config`
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
   
<a id="helm-value-horizontalpodautoscaling" href="#helm-value-horizontalpodautoscaling" aria-hidden="true" tabindex="-1"></a>
[`horizontalPodAutoscaling`](#helm-value-horizontalpodautoscaling)`(object)`: Horizontal Pod Autoscaling. Note that it is not intended to be used for vmagents which perform scraping. In order to scale scraping vmagents check [here](https://docs.victoriametrics.com/vmagent/#scraping-big-number-of-targets)
  ```helm-default
  enabled: false
  maxReplicas: 10
  metrics: []
  minReplicas: 1
  ```
   
<a id="helm-value-horizontalpodautoscaling-enabled" href="#helm-value-horizontalpodautoscaling-enabled" aria-hidden="true" tabindex="-1"></a>
[`horizontalPodAutoscaling.enabled`](#helm-value-horizontalpodautoscaling-enabled)`(bool)`: Use HPA for vmagent
  ```helm-default
  false
  ```
   
<a id="helm-value-horizontalpodautoscaling-maxreplicas" href="#helm-value-horizontalpodautoscaling-maxreplicas" aria-hidden="true" tabindex="-1"></a>
[`horizontalPodAutoscaling.maxReplicas`](#helm-value-horizontalpodautoscaling-maxreplicas)`(int)`: Maximum replicas for HPA to use to to scale vmagent
  ```helm-default
  10
  ```
   
<a id="helm-value-horizontalpodautoscaling-metrics" href="#helm-value-horizontalpodautoscaling-metrics" aria-hidden="true" tabindex="-1"></a>
[`horizontalPodAutoscaling.metrics`](#helm-value-horizontalpodautoscaling-metrics)`(list)`: Metric for HPA to use to scale vmagent
  ```helm-default
  []
  ```
   
<a id="helm-value-horizontalpodautoscaling-minreplicas" href="#helm-value-horizontalpodautoscaling-minreplicas" aria-hidden="true" tabindex="-1"></a>
[`horizontalPodAutoscaling.minReplicas`](#helm-value-horizontalpodautoscaling-minreplicas)`(int)`: Minimum replicas for HPA to use to scale vmagent
  ```helm-default
  1
  ```
   
<a id="helm-value-image-pullpolicy" href="#helm-value-image-pullpolicy" aria-hidden="true" tabindex="-1"></a>
[`image.pullPolicy`](#helm-value-image-pullpolicy)`(string)`: Image pull policy
  ```helm-default
  IfNotPresent
  ```
   
<a id="helm-value-image-registry" href="#helm-value-image-registry" aria-hidden="true" tabindex="-1"></a>
[`image.registry`](#helm-value-image-registry)`(string)`: Image registry
  ```helm-default
  ""
  ```
   
<a id="helm-value-image-repository" href="#helm-value-image-repository" aria-hidden="true" tabindex="-1"></a>
[`image.repository`](#helm-value-image-repository)`(string)`: Image repository
  ```helm-default
  victoriametrics/vmagent
  ```
   
<a id="helm-value-image-tag" href="#helm-value-image-tag" aria-hidden="true" tabindex="-1"></a>
[`image.tag`](#helm-value-image-tag)`(string)`: Image tag, set to `Chart.AppVersion` by default
  ```helm-default
  ""
  ```
   
<a id="helm-value-image-variant" href="#helm-value-image-variant" aria-hidden="true" tabindex="-1"></a>
[`image.variant`](#helm-value-image-variant)`(string)`: Variant of the image to use. e.g. enterprise, scratch
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
[`ingress.enabled`](#helm-value-ingress-enabled)`(bool)`: Enable deployment of ingress for agent
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
  - name: vmagent.local
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
[`initContainers`](#helm-value-initcontainers)`(list)`: Init containers for vmagent
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
   
<a id="helm-value-lifecycle" href="#helm-value-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`lifecycle`](#helm-value-lifecycle)`(object)`: Specify pod lifecycle
  ```helm-default
  {}
  ```
   
<a id="helm-value-mode" href="#helm-value-mode" aria-hidden="true" tabindex="-1"></a>
[`mode`](#helm-value-mode)`(string)`: VMAgent mode: daemonSet, deployment, statefulSet
  ```helm-default
  deployment
  ```
   
<a id="helm-value-nameoverride" href="#helm-value-nameoverride" aria-hidden="true" tabindex="-1"></a>
[`nameOverride`](#helm-value-nameoverride)`(string)`: Override chart name
  ```helm-default
  ""
  ```
   
<a id="helm-value-nodeselector" href="#helm-value-nodeselector" aria-hidden="true" tabindex="-1"></a>
[`nodeSelector`](#helm-value-nodeselector)`(object)`: Pod's node selector. Details are [here](https://kubernetes.io/docs/user-guide/node-selection/)
  ```helm-default
  {}
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
   
<a id="helm-value-persistentvolume-enabled" href="#helm-value-persistentvolume-enabled" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.enabled`](#helm-value-persistentvolume-enabled)`(bool)`: Create/use Persistent Volume Claim for server component. Empty dir if false
  ```helm-default
  false
  ```
   
<a id="helm-value-persistentvolume-existingclaim" href="#helm-value-persistentvolume-existingclaim" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.existingClaim`](#helm-value-persistentvolume-existingclaim)`(string)`: Existing Claim name. If defined, PVC must be created manually before volume will be bound
  ```helm-default
  ""
  ```
   
<a id="helm-value-persistentvolume-extralabels" href="#helm-value-persistentvolume-extralabels" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.extraLabels`](#helm-value-persistentvolume-extralabels)`(object)`: Persistant volume additional labels
  ```helm-default
  {}
  ```
   
<a id="helm-value-persistentvolume-matchlabels" href="#helm-value-persistentvolume-matchlabels" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.matchLabels`](#helm-value-persistentvolume-matchlabels)`(object)`: Bind Persistent Volume by labels. Must match all labels of targeted PV.
  ```helm-default
  {}
  ```
   
<a id="helm-value-persistentvolume-size" href="#helm-value-persistentvolume-size" aria-hidden="true" tabindex="-1"></a>
[`persistentVolume.size`](#helm-value-persistentvolume-size)`(string)`: Size of the volume. Should be calculated based on the logs you send and retention policy you set.
  ```helm-default
  10Gi
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
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more or check [official documentation](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-podlabels" href="#helm-value-podlabels" aria-hidden="true" tabindex="-1"></a>
[`podLabels`](#helm-value-podlabels)`(object)`: Extra labels for Pods only
  ```helm-default
  {}
  ```
   
<a id="helm-value-podsecuritycontext" href="#helm-value-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`podSecurityContext`](#helm-value-podsecuritycontext)`(object)`: Security context to be added to pod
  ```helm-default
  enabled: true
  ```
   
<a id="helm-value-priorityclassname" href="#helm-value-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`priorityClassName`](#helm-value-priorityclassname)`(string)`: Priority class to be assigned to the pod(s)
  ```helm-default
  ""
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
   
<a id="helm-value-remotewrite" href="#helm-value-remotewrite" aria-hidden="true" tabindex="-1"></a>
[`remoteWrite`](#helm-value-remotewrite)`(list)`: Generates `remoteWrite.*` flags and config maps with value content for values, that are of type list of map. Each item should contain `url` param to pass validation.
  ```helm-default
  []
  ```
   
<a id="helm-value-replicacount" href="#helm-value-replicacount" aria-hidden="true" tabindex="-1"></a>
[`replicaCount`](#helm-value-replicacount)`(int)`: Replica count    
  ```helm-default
  1
  ```
   
<a id="helm-value-resources" href="#helm-value-resources" aria-hidden="true" tabindex="-1"></a>
[`resources`](#helm-value-resources)`(object)`: Resource object. Details are [here](http://kubernetes.io/docs/user-guide/compute-resources/)
  ```helm-default
  {}
  ```
   
<a id="helm-value-schedulername" href="#helm-value-schedulername" aria-hidden="true" tabindex="-1"></a>
[`schedulerName`](#helm-value-schedulername)`(string)`: Use an alternate scheduler, e.g. "stork". Check details [here](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/)
  ```helm-default
  ""
  ```
   
<a id="helm-value-securitycontext" href="#helm-value-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`securityContext`](#helm-value-securitycontext)`(object)`: Security context to be added to pod's containers
  ```helm-default
  enabled: true
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
[`service.enabled`](#helm-value-service-enabled)`(bool)`: Enable agent service
  ```helm-default
  false
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
  8429
  ```
   
<a id="helm-value-service-targetport" href="#helm-value-service-targetport" aria-hidden="true" tabindex="-1"></a>
[`service.targetPort`](#helm-value-service-targetport)`(string)`: Target port
  ```helm-default
  http
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
   
<a id="helm-value-servicemonitor-targetport" href="#helm-value-servicemonitor-targetport" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor.targetPort`](#helm-value-servicemonitor-targetport)`(string)`: Service Monitor targetPort
  ```helm-default
  http
  ```
   
<a id="helm-value-statefulset" href="#helm-value-statefulset" aria-hidden="true" tabindex="-1"></a>
[`statefulSet`](#helm-value-statefulset)`(object)`: [K8s StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) specific variables
  ```helm-default
  clusterMode: false
  replicationFactor: 1
  spec:
      updateStrategy: {}
  ```
   
<a id="helm-value-statefulset-clustermode" href="#helm-value-statefulset-clustermode" aria-hidden="true" tabindex="-1"></a>
[`statefulSet.clusterMode`](#helm-value-statefulset-clustermode)`(bool)`: create cluster of vmagents. Check [here](https://docs.victoriametrics.com/vmagent#scraping-big-number-of-targets) available since [v1.77.2](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.77.2)
  ```helm-default
  false
  ```
   
<a id="helm-value-statefulset-replicationfactor" href="#helm-value-statefulset-replicationfactor" aria-hidden="true" tabindex="-1"></a>
[`statefulSet.replicationFactor`](#helm-value-statefulset-replicationfactor)`(int)`: replication factor for vmagent in cluster mode
  ```helm-default
  1
  ```
   
<a id="helm-value-statefulset-spec-updatestrategy" href="#helm-value-statefulset-spec-updatestrategy" aria-hidden="true" tabindex="-1"></a>
[`statefulSet.spec.updateStrategy`](#helm-value-statefulset-spec-updatestrategy)`(object)`: StatefulSet update strategy. Check [here](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies) for details.
  ```helm-default
  {}
  ```
   
<a id="helm-value-tolerations" href="#helm-value-tolerations" aria-hidden="true" tabindex="-1"></a>
[`tolerations`](#helm-value-tolerations)`(list)`: Node tolerations for server scheduling to nodes with taints. Details are [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-topologyspreadconstraints" href="#helm-value-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`topologySpreadConstraints`](#helm-value-topologyspreadconstraints)`(list)`: Pod topologySpreadConstraints
  ```helm-default
  []
  ```
   

