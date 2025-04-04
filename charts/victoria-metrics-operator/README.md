

![Version](https://img.shields.io/badge/0.44.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-operator%2Fchangelog%2F%230440)
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

<table class="helm-vars">
  <thead>
    <th class="helm-vars-key">Key</th>
    <th class="helm-vars-type">Type</th>
    <th class="helm-vars-default">Default</th>
    <th class="helm-vars-description">Description</th>
  </thead>
  <tbody>
    <tr>
      <td>admissionWebhooks</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">certManager:
    ca:
        commonName: ca.validation.victoriametrics
        duration: 63800h0m0s
        secretTemplate: {}
        subject: {}
    cert:
        commonName: ""
        duration: 45800h0m0s
        secretTemplate: {}
        subject: {}
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
</code>
</pre>
</td>
      <td><p>Configures resource validation</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.certManager</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">ca:
    commonName: ca.validation.victoriametrics
    duration: 63800h0m0s
    secretTemplate: {}
    subject: {}
cert:
    commonName: ""
    duration: 45800h0m0s
    secretTemplate: {}
    subject: {}
enabled: false
issuer: {}
</code>
</pre>
</td>
      <td><p>Enables custom ca bundle, if you are not using cert-manager. In case of custom ca, you have to create secret - {chart-name}-validation with keys: tls.key, tls.crt, ca.crt</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.certManager.ca</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">commonName: ca.validation.victoriametrics
duration: 63800h0m0s
secretTemplate: {}
subject: {}
</code>
</pre>
</td>
      <td><p>Certificate Authority parameters</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.certManager.cert</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">commonName: ""
duration: 45800h0m0s
secretTemplate: {}
subject: {}
</code>
</pre>
</td>
      <td><p>Certificate parameters</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.certManager.enabled</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Enables cert creation and injection by cert-manager.</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.certManager.issuer</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>If needed, provide own issuer. Operator will create self-signed if empty.</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.enabled</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>Enables validation webhook.</p>
</td>
    </tr>
    <tr>
      <td>admissionWebhooks.policy</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">Fail
</code>
</pre>
</td>
      <td><p>What to do in case, when operator not available to validate request.</p>
</td>
    </tr>
    <tr>
      <td>affinity</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Pod affinity</p>
</td>
    </tr>
    <tr>
      <td>allowedMetricsEndpoints[0]</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">/metrics
</code>
</pre>
</td>
      <td></td>
    </tr>
    <tr>
      <td>allowedMetricsEndpoints[1]</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">/metrics/resources
</code>
</pre>
</td>
      <td></td>
    </tr>
    <tr>
      <td>annotations</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Annotations to be added to the all resources</p>
</td>
    </tr>
    <tr>
      <td>crds.annotations</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>additional CRD annotations, when <code>.Values.crds.plain: false</code></p>
</td>
    </tr>
    <tr>
      <td>crds.cleanup.enabled</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Tells helm to clean up all the vm resources under this release&rsquo;s namespace when uninstalling</p>
</td>
    </tr>
    <tr>
      <td>crds.cleanup.image</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">pullPolicy: IfNotPresent
repository: bitnami/kubectl
tag: ""
</code>
</pre>
</td>
      <td><p>Image configuration for CRD cleanup Job</p>
</td>
    </tr>
    <tr>
      <td>crds.cleanup.resources</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">limits:
    cpu: 500m
    memory: 256Mi
requests:
    cpu: 100m
    memory: 56Mi
</code>
</pre>
</td>
      <td><p>Cleanup hook resources</p>
</td>
    </tr>
    <tr>
      <td>crds.enabled</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>manages CRD creation. Disables CRD creation only in combination with <code>crds.plain: false</code> due to helm dependency conditions limitation</p>
</td>
    </tr>
    <tr>
      <td>crds.plain</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>check if plain or templated CRDs should be created. with this option set to <code>false</code>, all CRDs will be rendered from templates. with this option set to <code>true</code>, all CRDs are immutable and require manual upgrade.</p>
</td>
    </tr>
    <tr>
      <td>env</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Extra settings for the operator deployment. Full list <a href="https://docs.victoriametrics.com/operator/vars" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>envFrom</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Specify alternative source for env variables</p>
</td>
    </tr>
    <tr>
      <td>extraArgs</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Operator container additional commandline arguments</p>
</td>
    </tr>
    <tr>
      <td>extraContainers</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Extra containers to run in a pod with operator</p>
</td>
    </tr>
    <tr>
      <td>extraHostPathMounts</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Additional hostPath mounts</p>
</td>
    </tr>
    <tr>
      <td>extraLabels</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Labels to be added to the all resources</p>
</td>
    </tr>
    <tr>
      <td>extraObjects</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Add extra specs dynamically to this chart</p>
</td>
    </tr>
    <tr>
      <td>extraVolumeMounts</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Extra Volume Mounts for the container</p>
</td>
    </tr>
    <tr>
      <td>extraVolumes</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Extra Volumes for the pod</p>
</td>
    </tr>
    <tr>
      <td>fullnameOverride</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Overrides the full name of server component resources</p>
</td>
    </tr>
    <tr>
      <td>global.cluster.dnsDomain</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">cluster.local.
</code>
</pre>
</td>
      <td><p>K8s cluster domain suffix, uses for building storage pods&rsquo; FQDN. Details are <a href="https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>global.compatibility</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">openshift:
    adaptSecurityContext: auto
</code>
</pre>
</td>
      <td><p>Openshift security context compatibility configuration</p>
</td>
    </tr>
    <tr>
      <td>global.image.registry</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Image registry, that can be shared across multiple helm charts</p>
</td>
    </tr>
    <tr>
      <td>global.imagePullSecrets</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Image pull secrets, that can be shared across multiple helm charts</p>
</td>
    </tr>
    <tr>
      <td>hostNetwork</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Enable hostNetwork on operator deployment</p>
</td>
    </tr>
    <tr>
      <td>image</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">pullPolicy: IfNotPresent
registry: ""
repository: victoriametrics/operator
tag: ""
variant: ""
</code>
</pre>
</td>
      <td><p>operator image configuration</p>
</td>
    </tr>
    <tr>
      <td>image.pullPolicy</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">IfNotPresent
</code>
</pre>
</td>
      <td><p>Image pull policy</p>
</td>
    </tr>
    <tr>
      <td>image.registry</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Image registry</p>
</td>
    </tr>
    <tr>
      <td>image.repository</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">victoriametrics/operator
</code>
</pre>
</td>
      <td><p>Image repository</p>
</td>
    </tr>
    <tr>
      <td>image.tag</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Image tag override Chart.AppVersion</p>
</td>
    </tr>
    <tr>
      <td>imagePullSecrets</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Secret to pull images</p>
</td>
    </tr>
    <tr>
      <td>lifecycle</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Operator lifecycle. See <a href="https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/" target="_blank">this article</a> for details.</p>
</td>
    </tr>
    <tr>
      <td>logLevel</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">info
</code>
</pre>
</td>
      <td><p>VM operator log level. Possible values: info and error.</p>
</td>
    </tr>
    <tr>
      <td>nameOverride</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Override chart name</p>
</td>
    </tr>
    <tr>
      <td>nodeSelector</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Pod&rsquo;s node selector. Details are <a href="https://kubernetes.io/docs/user-guide/node-selection/" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>operator.disable_prometheus_converter</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>By default, operator converts prometheus-operator objects.</p>
</td>
    </tr>
    <tr>
      <td>operator.enable_converter_ownership</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Enables ownership reference for converted prometheus-operator objects, it will remove corresponding victoria-metrics objects in case of deletion prometheus one.</p>
</td>
    </tr>
    <tr>
      <td>operator.prometheus_converter_add_argocd_ignore_annotations</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Compare-options and sync-options for prometheus objects converted by operator for properly use with ArgoCD</p>
</td>
    </tr>
    <tr>
      <td>operator.useCustomConfigReloader</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">false
</code>
</pre>
</td>
      <td><p>Enables custom config-reloader, bundled with operator. It should reduce  vmagent and vmauth config sync-time and make it predictable.</p>
</td>
    </tr>
    <tr>
      <td>podDisruptionBudget</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">enabled: false
labels: {}
</code>
</pre>
</td>
      <td><p>See <code>kubectl explain poddisruptionbudget.spec</code> for more or check <a href="https://kubernetes.io/docs/tasks/run-application/configure-pdb/" target="_blank">these docs</a></p>
</td>
    </tr>
    <tr>
      <td>podLabels</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>extra Labels for Pods only</p>
</td>
    </tr>
    <tr>
      <td>podSecurityContext</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">enabled: true
fsGroup: 2000
runAsNonRoot: true
runAsUser: 1000
</code>
</pre>
</td>
      <td><p>Pod&rsquo;s security context. Details are <a href="https://kubernetes.io/docs/tasks/configure-pod-container/security-context/" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>priorityClassName</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Name of Priority Class</p>
</td>
    </tr>
    <tr>
      <td>probe.liveness</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">failureThreshold: 3
initialDelaySeconds: 5
periodSeconds: 15
tcpSocket:
    port: probe
timeoutSeconds: 5
</code>
</pre>
</td>
      <td><p>Liveness probe</p>
</td>
    </tr>
    <tr>
      <td>probe.readiness</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">failureThreshold: 3
httpGet:
    port: probe
initialDelaySeconds: 5
periodSeconds: 15
timeoutSeconds: 5
</code>
</pre>
</td>
      <td><p>Readiness probe</p>
</td>
    </tr>
    <tr>
      <td>probe.startup</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Startup probe</p>
</td>
    </tr>
    <tr>
      <td>rbac.aggregatedClusterRoles</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">enabled: true
labels:
    admin:
        rbac.authorization.k8s.io/aggregate-to-admin: "true"
    view:
        rbac.authorization.k8s.io/aggregate-to-view: "true"
</code>
</pre>
</td>
      <td><p>Create aggregated clusterRoles for CRD readonly and admin permissions</p>
</td>
    </tr>
    <tr>
      <td>rbac.aggregatedClusterRoles.labels</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">admin:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
view:
    rbac.authorization.k8s.io/aggregate-to-view: "true"
</code>
</pre>
</td>
      <td><p>Labels attached to according clusterRole</p>
</td>
    </tr>
    <tr>
      <td>rbac.create</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>Specifies whether the RBAC resources should be created</p>
</td>
    </tr>
    <tr>
      <td>replicaCount</td>
      <td>int</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">1
</code>
</pre>
</td>
      <td><p>Number of operator replicas</p>
</td>
    </tr>
    <tr>
      <td>resources</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Resource object</p>
</td>
    </tr>
    <tr>
      <td>securityContext</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">allowPrivilegeEscalation: false
capabilities:
    drop:
        - ALL
enabled: true
readOnlyRootFilesystem: true
</code>
</pre>
</td>
      <td><p>Security context to be added to server pods</p>
</td>
    </tr>
    <tr>
      <td>service.annotations</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Service annotations</p>
</td>
    </tr>
    <tr>
      <td>service.clusterIP</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Service ClusterIP</p>
</td>
    </tr>
    <tr>
      <td>service.externalIPs</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Service external IPs. Check <a href="https://kubernetes.io/docs/user-guide/services/#external-ips" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr>
      <td>service.externalTrafficPolicy</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Service external traffic policy. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr>
      <td>service.healthCheckNodePort</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Health check node port for a service. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr>
      <td>service.ipFamilies</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>List of service IP families. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr>
      <td>service.ipFamilyPolicy</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Service IP family policy. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr>
      <td>service.labels</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">{}
</code>
</pre>
</td>
      <td><p>Service labels</p>
</td>
    </tr>
    <tr>
      <td>service.loadBalancerIP</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>Service load balancer IP</p>
</td>
    </tr>
    <tr>
      <td>service.loadBalancerSourceRanges</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Load balancer source range</p>
</td>
    </tr>
    <tr>
      <td>service.servicePort</td>
      <td>int</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">8080
</code>
</pre>
</td>
      <td><p>Service port</p>
</td>
    </tr>
    <tr>
      <td>service.type</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">ClusterIP
</code>
</pre>
</td>
      <td><p>Service type</p>
</td>
    </tr>
    <tr>
      <td>service.webhookPort</td>
      <td>int</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">9443
</code>
</pre>
</td>
      <td><p>Service webhook port</p>
</td>
    </tr>
    <tr>
      <td>serviceAccount.automountServiceAccountToken</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>Whether to automount the service account token. Note that token needs to be mounted manually if this is disabled.</p>
</td>
    </tr>
    <tr>
      <td>serviceAccount.create</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>Specifies whether a service account should be created</p>
</td>
    </tr>
    <tr>
      <td>serviceAccount.name</td>
      <td>string</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">""
</code>
</pre>
</td>
      <td><p>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</p>
</td>
    </tr>
    <tr>
      <td>serviceMonitor</td>
      <td>object</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">annotations: {}
basicAuth: {}
enabled: false
extraLabels: {}
interval: ""
relabelings: []
scheme: ""
scrapeTimeout: ""
tlsConfig: {}
vm: true
</code>
</pre>
</td>
      <td><p>Configures monitoring with serviceScrape using either <code>VMServiceScrape</code> or <code>ServiceMonitor</code>. For latter <a href="https://artifacthub.io/packages/helm/prometheus-community/prometheus-operator-crds" target="_blank">Prometheus Operator CRDs</a> should be preinstalled</p>
</td>
    </tr>
    <tr>
      <td>serviceMonitor.vm</td>
      <td>bool</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">true
</code>
</pre>
</td>
      <td><p>Creates <code>VMServiceScrape</code> if <code>true</code> and <code>ServiceMonitor</code> otherwise. Make sure <a href="https://artifacthub.io/packages/helm/prometheus-community/prometheus-operator-crds" target="_blank">Prometheus Operator CRDs</a> are installed if it&rsquo;s set to <code>false</code></p>
</td>
    </tr>
    <tr>
      <td>terminationGracePeriodSeconds</td>
      <td>int</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="">
<code class="language-yaml">30
</code>
</pre>
</td>
      <td><p>Graceful pod termination timeout. See <a href="https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution" target="_blank">this article</a> for details.</p>
</td>
    </tr>
    <tr>
      <td>tolerations</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Array of tolerations object. Spec is <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>topologySpreadConstraints</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>Pod Topology Spread Constraints. Spec is <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/" target="_blank">here</a></p>
</td>
    </tr>
    <tr>
      <td>watchNamespaces</td>
      <td>list</td>
      <td><pre class="helm-vars-default-value language-yaml" lang="plaintext">
<code class="language-yaml">[]
</code>
</pre>
</td>
      <td><p>By default, the operator will watch all the namespaces If you want to override this behavior, specify the namespace. Operator supports multiple namespaces for watching.</p>
</td>
    </tr>
  </tbody>
</table>

