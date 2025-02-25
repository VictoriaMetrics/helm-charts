

![Version](https://img.shields.io/badge/0.42.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-operator%2Fchangelog%2F%230420)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-operator)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

Victoria Metrics Operator

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).
* PV support on underlying infrastructure.

## ArgoCD issues

When running operator using ArgoCD without Cert Manager (`.Values.admissionWebhooks.certManager.enabled: false`) it will rerender webhook certificates
on each sync since Helm `lookup` function is not respected by ArgoCD. To prevent this please update you operator Application `spec.syncPolicy` and `spec.ignoreDifferences` with a following:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
...
spec:
  ...
  destination:
    ...
    namespace: <operator-namespace>
  ...
  syncPolicy:
    syncOptions:
    # https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs
    # argocd must also ignore difference during apply stage
    # otherwise it ll silently override changes and cause a problem
    - RespectIgnoreDifferences=true
  ignoreDifferences:
    - group: ""
      kind: Secret
      name: <fullname>-validation
      namespace: <operator-namespace>
      jsonPointers:
        - /data
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: <fullname>-admission
      jqPathExpressions:
      - '.webhooks[]?.clientConfig.caBundle'
```
where `<fullname>` is output of `{{ include "vm-operator.fullname" }}` for your setup

## Upgrade guide

 During release an issue with helm CRD was discovered. So for upgrade from version less then 0.1.3 you have to two options:
 1) use helm management for CRD, enabled by default.
 2) use own management system, need to add variable: --set createCRD=false.

If you choose helm management, following steps must be done before upgrade:

1) define namespace and helm release name variables

```
export NAMESPACE=default
export RELEASE_NAME=operator
```

execute kubectl commands:

```
kubectl get crd  | grep victoriametrics.com | awk '{print $1 }' | xargs -i kubectl label crd {} app.kubernetes.io/managed-by=Helm --overwrite
kubectl get crd  | grep victoriametrics.com | awk '{print $1 }' | xargs -i kubectl annotate crd {} meta.helm.sh/release-namespace="$NAMESPACE" meta.helm.sh/release-name="$RELEASE_NAME"  --overwrite
```

run helm upgrade command.

## Chart Details

This chart will do the following:

* Rollout victoria metrics operator

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-operator` chart available to installation:

```console
helm search repo vm/victoria-metrics-operator -l
```

### Install `victoria-metrics-operator` chart

Export default values of `victoria-metrics-operator` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-operator > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vmo vm/victoria-metrics-operator -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vmo oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vmo vm/victoria-metrics-operator -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vmo oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-operator -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmo'
```

Get the application by running this command:

```console
helm list -f vmo -n NAMESPACE
```

See the history of versions of `vmo` application with command.

```console
helm history vmo -n NAMESPACE
```

## Validation webhook

  Its possible to use validation of created resources with operator. For now, you need cert-manager to easily certificate management https://cert-manager.io/docs/

```yaml
admissionWebhooks:
  enabled: true
  # what to do in case, when operator not available to validate request.
  certManager:
    # enables cert creation and injection by cert-manager
    enabled: true
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmo -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-operator

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Disabling automatic ServiceAccount token mount

There are cases when it is required to disable automatic ServiceAccount token mount due to hardening reasons. To disable it, set the following values:
```
serviceAccount:
  automountServiceAccountToken: false

extraVolumes:
  - name: operator
    projected:
      sources:
        - downwardAPI:
            items:
              - fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
                path: namespace
        - configMap:
            name: kube-root-ca.crt
        - serviceAccountToken:
            expirationSeconds: 7200
            path: token

extraVolumeMounts:
  - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
    name: operator
```

This configuration disables the automatic ServiceAccount token mount and mounts the token explicitly.

## Enable hostNetwork on operator

When running managed Kubernetes such as EKS with custom CNI solution like Cilium or Calico, EKS control plane cannot communicate with CNI's pod CIDR.
In that scenario, we need to run webhook service i.e operator with hostNetwork so that it can share node's network namespace.

```yaml
hostNetwork: true
```

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-operator/values.yaml`` file.

<a id="helm-value-admissionwebhooks" href="#helm-value-admissionwebhooks" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks`](#helm-value-admissionwebhooks)`(object)`: Configures resource validation
  ```helm-default
  certManager:
      ca:
          commonName: ca.validation.victoriametrics
          duration: 63800h0m0s
      cert:
          commonName: ""
          duration: 45800h0m0s
      enabled: false
      issuer: {}
  enabled: true
  enabledCRDValidation:
      vlogs: true
      vmagent: true
      vmalert: true
      vmalertmanager: true
      vmalertmanagerconfig: true
      vmauth: true
      vmcluster: true
      vmrule: true
      vmsingle: true
      vmuser: true
  keepTLSSecret: true
  policy: Fail
  tls:
      caCert: null
      cert: null
      key: null
  ```
   
<a id="helm-value-admissionwebhooks-certmanager" href="#helm-value-admissionwebhooks-certmanager" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.certManager`](#helm-value-admissionwebhooks-certmanager)`(object)`: Enables custom ca bundle, if you are not using cert-manager. In case of custom ca, you have to create secret - {chart-name}-validation with keys: tls.key, tls.crt, ca.crt
  ```helm-default
  ca:
      commonName: ca.validation.victoriametrics
      duration: 63800h0m0s
  cert:
      commonName: ""
      duration: 45800h0m0s
  enabled: false
  issuer: {}
  ```
   
<a id="helm-value-admissionwebhooks-certmanager-ca" href="#helm-value-admissionwebhooks-certmanager-ca" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.certManager.ca`](#helm-value-admissionwebhooks-certmanager-ca)`(object)`: Certificate Authority parameters
  ```helm-default
  commonName: ca.validation.victoriametrics
  duration: 63800h0m0s
  ```
   
<a id="helm-value-admissionwebhooks-certmanager-cert" href="#helm-value-admissionwebhooks-certmanager-cert" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.certManager.cert`](#helm-value-admissionwebhooks-certmanager-cert)`(object)`: Certificate parameters
  ```helm-default
  commonName: ""
  duration: 45800h0m0s
  ```
   
<a id="helm-value-admissionwebhooks-certmanager-enabled" href="#helm-value-admissionwebhooks-certmanager-enabled" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.certManager.enabled`](#helm-value-admissionwebhooks-certmanager-enabled)`(bool)`: Enables cert creation and injection by cert-manager.
  ```helm-default
  false
  ```
   
<a id="helm-value-admissionwebhooks-certmanager-issuer" href="#helm-value-admissionwebhooks-certmanager-issuer" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.certManager.issuer`](#helm-value-admissionwebhooks-certmanager-issuer)`(object)`: If needed, provide own issuer. Operator will create self-signed if empty.
  ```helm-default
  {}
  ```
   
<a id="helm-value-admissionwebhooks-enabled" href="#helm-value-admissionwebhooks-enabled" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.enabled`](#helm-value-admissionwebhooks-enabled)`(bool)`: Enables validation webhook.
  ```helm-default
  true
  ```
   
<a id="helm-value-admissionwebhooks-policy" href="#helm-value-admissionwebhooks-policy" aria-hidden="true" tabindex="-1"></a>
[`admissionWebhooks.policy`](#helm-value-admissionwebhooks-policy)`(string)`: What to do in case, when operator not available to validate request.
  ```helm-default
  Fail
  ```
   
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
   
<a id="helm-value-allowedmetricsendpoints-1-" href="#helm-value-allowedmetricsendpoints-1-" aria-hidden="true" tabindex="-1"></a>
[`allowedMetricsEndpoints[1]`](#helm-value-allowedmetricsendpoints-1-)`(string)`:
  ```helm-default
  /metrics/resources
  ```
   
<a id="helm-value-annotations" href="#helm-value-annotations" aria-hidden="true" tabindex="-1"></a>
[`annotations`](#helm-value-annotations)`(object)`: Annotations to be added to the all resources
  ```helm-default
  {}
  ```
   
<a id="helm-value-crds-cleanup-enabled" href="#helm-value-crds-cleanup-enabled" aria-hidden="true" tabindex="-1"></a>
[`crds.cleanup.enabled`](#helm-value-crds-cleanup-enabled)`(bool)`: Tells helm to clean up all the vm resources under this release's namespace when uninstalling
  ```helm-default
  false
  ```
   
<a id="helm-value-crds-cleanup-image" href="#helm-value-crds-cleanup-image" aria-hidden="true" tabindex="-1"></a>
[`crds.cleanup.image`](#helm-value-crds-cleanup-image)`(object)`: Image configuration for CRD cleanup Job
  ```helm-default
  pullPolicy: IfNotPresent
  repository: bitnami/kubectl
  tag: ""
  ```
   
<a id="helm-value-crds-cleanup-resources" href="#helm-value-crds-cleanup-resources" aria-hidden="true" tabindex="-1"></a>
[`crds.cleanup.resources`](#helm-value-crds-cleanup-resources)`(object)`: Cleanup hook resources
  ```helm-default
  limits:
      cpu: 500m
      memory: 256Mi
  requests:
      cpu: 100m
      memory: 56Mi
  ```
   
<a id="helm-value-crds-enabled" href="#helm-value-crds-enabled" aria-hidden="true" tabindex="-1"></a>
[`crds.enabled`](#helm-value-crds-enabled)`(bool)`: manages CRD creation. Disables CRD creation only in combination with `crds.plain: false` due to helm dependency conditions limitation
  ```helm-default
  true
  ```
   
<a id="helm-value-crds-plain" href="#helm-value-crds-plain" aria-hidden="true" tabindex="-1"></a>
[`crds.plain`](#helm-value-crds-plain)`(bool)`: check if plain or templated CRDs should be created. with this option set to `false`, all CRDs will be rendered from templates. with this option set to `true`, all CRDs are immutable and require manual upgrade.
  ```helm-default
  false
  ```
   
<a id="helm-value-env" href="#helm-value-env" aria-hidden="true" tabindex="-1"></a>
[`env`](#helm-value-env)`(list)`: Extra settings for the operator deployment. Full list [here](https://docs.victoriametrics.com/operator/vars)
  ```helm-default
  []
  ```
   
<a id="helm-value-envfrom" href="#helm-value-envfrom" aria-hidden="true" tabindex="-1"></a>
[`envFrom`](#helm-value-envfrom)`(list)`: Specify alternative source for env variables
  ```helm-default
  []
  ```
   
<a id="helm-value-extraargs" href="#helm-value-extraargs" aria-hidden="true" tabindex="-1"></a>
[`extraArgs`](#helm-value-extraargs)`(object)`: Operator container additional commandline arguments
  ```helm-default
  {}
  ```
   
<a id="helm-value-extracontainers" href="#helm-value-extracontainers" aria-hidden="true" tabindex="-1"></a>
[`extraContainers`](#helm-value-extracontainers)`(list)`: Extra containers to run in a pod with operator
  ```helm-default
  []
  ```
   
<a id="helm-value-extrahostpathmounts" href="#helm-value-extrahostpathmounts" aria-hidden="true" tabindex="-1"></a>
[`extraHostPathMounts`](#helm-value-extrahostpathmounts)`(list)`: Additional hostPath mounts
  ```helm-default
  []
  ```
   
<a id="helm-value-extralabels" href="#helm-value-extralabels" aria-hidden="true" tabindex="-1"></a>
[`extraLabels`](#helm-value-extralabels)`(object)`: Labels to be added to the all resources
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
[`fullnameOverride`](#helm-value-fullnameoverride)`(string)`: Overrides the full name of server component resources
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
   
<a id="helm-value-hostnetwork" href="#helm-value-hostnetwork" aria-hidden="true" tabindex="-1"></a>
[`hostNetwork`](#helm-value-hostnetwork)`(bool)`: Enable hostNetwork on operator deployment
  ```helm-default
  false
  ```
   
<a id="helm-value-image" href="#helm-value-image" aria-hidden="true" tabindex="-1"></a>
[`image`](#helm-value-image)`(object)`: operator image configuration
  ```helm-default
  pullPolicy: IfNotPresent
  registry: ""
  repository: victoriametrics/operator
  tag: ""
  variant: ""
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
  victoriametrics/operator
  ```
   
<a id="helm-value-image-tag" href="#helm-value-image-tag" aria-hidden="true" tabindex="-1"></a>
[`image.tag`](#helm-value-image-tag)`(string)`: Image tag override Chart.AppVersion
  ```helm-default
  ""
  ```
   
<a id="helm-value-imagepullsecrets" href="#helm-value-imagepullsecrets" aria-hidden="true" tabindex="-1"></a>
[`imagePullSecrets`](#helm-value-imagepullsecrets)`(list)`: Secret to pull images
  ```helm-default
  []
  ```
   
<a id="helm-value-lifecycle" href="#helm-value-lifecycle" aria-hidden="true" tabindex="-1"></a>
[`lifecycle`](#helm-value-lifecycle)`(object)`: Operator lifecycle. See [this article](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) for details.
  ```helm-default
  {}
  ```
   
<a id="helm-value-loglevel" href="#helm-value-loglevel" aria-hidden="true" tabindex="-1"></a>
[`logLevel`](#helm-value-loglevel)`(string)`: VM operator log level. Possible values: info and error.
  ```helm-default
  info
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
   
<a id="helm-value-operator-disable-prometheus-converter" href="#helm-value-operator-disable-prometheus-converter" aria-hidden="true" tabindex="-1"></a>
[`operator.disable_prometheus_converter`](#helm-value-operator-disable-prometheus-converter)`(bool)`: By default, operator converts prometheus-operator objects.
  ```helm-default
  false
  ```
   
<a id="helm-value-operator-enable-converter-ownership" href="#helm-value-operator-enable-converter-ownership" aria-hidden="true" tabindex="-1"></a>
[`operator.enable_converter_ownership`](#helm-value-operator-enable-converter-ownership)`(bool)`: Enables ownership reference for converted prometheus-operator objects, it will remove corresponding victoria-metrics objects in case of deletion prometheus one.
  ```helm-default
  false
  ```
   
<a id="helm-value-operator-prometheus-converter-add-argocd-ignore-annotations" href="#helm-value-operator-prometheus-converter-add-argocd-ignore-annotations" aria-hidden="true" tabindex="-1"></a>
[`operator.prometheus_converter_add_argocd_ignore_annotations`](#helm-value-operator-prometheus-converter-add-argocd-ignore-annotations)`(bool)`: Compare-options and sync-options for prometheus objects converted by operator for properly use with ArgoCD
  ```helm-default
  false
  ```
   
<a id="helm-value-operator-usecustomconfigreloader" href="#helm-value-operator-usecustomconfigreloader" aria-hidden="true" tabindex="-1"></a>
[`operator.useCustomConfigReloader`](#helm-value-operator-usecustomconfigreloader)`(bool)`: Enables custom config-reloader, bundled with operator. It should reduce  vmagent and vmauth config sync-time and make it predictable.
  ```helm-default
  false
  ```
   
<a id="helm-value-poddisruptionbudget" href="#helm-value-poddisruptionbudget" aria-hidden="true" tabindex="-1"></a>
[`podDisruptionBudget`](#helm-value-poddisruptionbudget)`(object)`: See `kubectl explain poddisruptionbudget.spec` for more or check [these docs](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
  ```helm-default
  enabled: false
  labels: {}
  ```
   
<a id="helm-value-podlabels" href="#helm-value-podlabels" aria-hidden="true" tabindex="-1"></a>
[`podLabels`](#helm-value-podlabels)`(object)`: extra Labels for Pods only
  ```helm-default
  {}
  ```
   
<a id="helm-value-podsecuritycontext" href="#helm-value-podsecuritycontext" aria-hidden="true" tabindex="-1"></a>
[`podSecurityContext`](#helm-value-podsecuritycontext)`(object)`: Pod's security context. Details are [here](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  ```helm-default
  enabled: true
  fsGroup: 2000
  runAsNonRoot: true
  runAsUser: 1000
  ```
   
<a id="helm-value-priorityclassname" href="#helm-value-priorityclassname" aria-hidden="true" tabindex="-1"></a>
[`priorityClassName`](#helm-value-priorityclassname)`(string)`: Name of Priority Class
  ```helm-default
  ""
  ```
   
<a id="helm-value-probe-liveness" href="#helm-value-probe-liveness" aria-hidden="true" tabindex="-1"></a>
[`probe.liveness`](#helm-value-probe-liveness)`(object)`: Liveness probe
  ```helm-default
  failureThreshold: 3
  initialDelaySeconds: 5
  periodSeconds: 15
  tcpSocket:
      port: probe
  timeoutSeconds: 5
  ```
   
<a id="helm-value-probe-readiness" href="#helm-value-probe-readiness" aria-hidden="true" tabindex="-1"></a>
[`probe.readiness`](#helm-value-probe-readiness)`(object)`: Readiness probe
  ```helm-default
  failureThreshold: 3
  httpGet:
      port: probe
  initialDelaySeconds: 5
  periodSeconds: 15
  timeoutSeconds: 5
  ```
   
<a id="helm-value-probe-startup" href="#helm-value-probe-startup" aria-hidden="true" tabindex="-1"></a>
[`probe.startup`](#helm-value-probe-startup)`(object)`: Startup probe
  ```helm-default
  {}
  ```
   
<a id="helm-value-rbac-aggregatedclusterroles" href="#helm-value-rbac-aggregatedclusterroles" aria-hidden="true" tabindex="-1"></a>
[`rbac.aggregatedClusterRoles`](#helm-value-rbac-aggregatedclusterroles)`(object)`: Create aggregated clusterRoles for CRD readonly and admin permissions
  ```helm-default
  enabled: true
  labels:
      admin:
          rbac.authorization.k8s.io/aggregate-to-admin: "true"
      view:
          rbac.authorization.k8s.io/aggregate-to-view: "true"
  ```
   
<a id="helm-value-rbac-aggregatedclusterroles-labels" href="#helm-value-rbac-aggregatedclusterroles-labels" aria-hidden="true" tabindex="-1"></a>
[`rbac.aggregatedClusterRoles.labels`](#helm-value-rbac-aggregatedclusterroles-labels)`(object)`: Labels attached to according clusterRole
  ```helm-default
  admin:
      rbac.authorization.k8s.io/aggregate-to-admin: "true"
  view:
      rbac.authorization.k8s.io/aggregate-to-view: "true"
  ```
   
<a id="helm-value-rbac-create" href="#helm-value-rbac-create" aria-hidden="true" tabindex="-1"></a>
[`rbac.create`](#helm-value-rbac-create)`(bool)`: Specifies whether the RBAC resources should be created
  ```helm-default
  true
  ```
   
<a id="helm-value-replicacount" href="#helm-value-replicacount" aria-hidden="true" tabindex="-1"></a>
[`replicaCount`](#helm-value-replicacount)`(int)`: Number of operator replicas
  ```helm-default
  1
  ```
   
<a id="helm-value-resources" href="#helm-value-resources" aria-hidden="true" tabindex="-1"></a>
[`resources`](#helm-value-resources)`(object)`: Resource object
  ```helm-default
  {}
  ```
   
<a id="helm-value-securitycontext" href="#helm-value-securitycontext" aria-hidden="true" tabindex="-1"></a>
[`securityContext`](#helm-value-securitycontext)`(object)`: Security context to be added to server pods
  ```helm-default
  allowPrivilegeEscalation: false
  capabilities:
      drop:
          - ALL
  enabled: true
  readOnlyRootFilesystem: true
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
   
<a id="helm-value-service-externalips" href="#helm-value-service-externalips" aria-hidden="true" tabindex="-1"></a>
[`service.externalIPs`](#helm-value-service-externalips)`(string)`: Service external IPs. Check [here](https://kubernetes.io/docs/user-guide/services/#external-ips) for details
  ```helm-default
  ""
  ```
   
<a id="helm-value-service-externaltrafficpolicy" href="#helm-value-service-externaltrafficpolicy" aria-hidden="true" tabindex="-1"></a>
[`service.externalTrafficPolicy`](#helm-value-service-externaltrafficpolicy)`(string)`: Service external traffic policy. Check [here](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) for details
  ```helm-default
  ""
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
   
<a id="helm-value-service-labels" href="#helm-value-service-labels" aria-hidden="true" tabindex="-1"></a>
[`service.labels`](#helm-value-service-labels)`(object)`: Service labels
  ```helm-default
  {}
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
  8080
  ```
   
<a id="helm-value-service-type" href="#helm-value-service-type" aria-hidden="true" tabindex="-1"></a>
[`service.type`](#helm-value-service-type)`(string)`: Service type
  ```helm-default
  ClusterIP
  ```
   
<a id="helm-value-service-webhookport" href="#helm-value-service-webhookport" aria-hidden="true" tabindex="-1"></a>
[`service.webhookPort`](#helm-value-service-webhookport)`(int)`: Service webhook port
  ```helm-default
  9443
  ```
   
<a id="helm-value-serviceaccount-automountserviceaccounttoken" href="#helm-value-serviceaccount-automountserviceaccounttoken" aria-hidden="true" tabindex="-1"></a>
[`serviceAccount.automountServiceAccountToken`](#helm-value-serviceaccount-automountserviceaccounttoken)`(bool)`: Whether to automount the service account token. Note that token needs to be mounted manually if this is disabled.
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
  ""
  ```
   
<a id="helm-value-servicemonitor" href="#helm-value-servicemonitor" aria-hidden="true" tabindex="-1"></a>
[`serviceMonitor`](#helm-value-servicemonitor)`(object)`: Configures monitoring with serviceScrape. VMServiceScrape must be pre-installed
  ```helm-default
  annotations: {}
  basicAuth: {}
  enabled: false
  extraLabels: {}
  interval: ""
  relabelings: []
  scheme: ""
  scrapeTimeout: ""
  tlsConfig: {}
  ```
   
<a id="helm-value-terminationgraceperiodseconds" href="#helm-value-terminationgraceperiodseconds" aria-hidden="true" tabindex="-1"></a>
[`terminationGracePeriodSeconds`](#helm-value-terminationgraceperiodseconds)`(int)`: Graceful pod termination timeout. See [this article](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution) for details.
  ```helm-default
  30
  ```
   
<a id="helm-value-tolerations" href="#helm-value-tolerations" aria-hidden="true" tabindex="-1"></a>
[`tolerations`](#helm-value-tolerations)`(list)`: Array of tolerations object. Spec is [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
  ```helm-default
  []
  ```
   
<a id="helm-value-topologyspreadconstraints" href="#helm-value-topologyspreadconstraints" aria-hidden="true" tabindex="-1"></a>
[`topologySpreadConstraints`](#helm-value-topologyspreadconstraints)`(list)`: Pod Topology Spread Constraints. Spec is [here](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/)
  ```helm-default
  []
  ```
   
<a id="helm-value-watchnamespaces" href="#helm-value-watchnamespaces" aria-hidden="true" tabindex="-1"></a>
[`watchNamespaces`](#helm-value-watchnamespaces)`(list)`: By default, the operator will watch all the namespaces If you want to override this behavior, specify the namespace. Operator supports multiple namespaces for watching.
  ```helm-default
  []
  ```
   

