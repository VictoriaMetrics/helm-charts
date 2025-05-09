

![Version](https://img.shields.io/badge/0.46.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-operator%2Fchangelog%2F%230460)
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
    <th class="helm-vars-description">Description</th>
  </thead>
  <tbody>
    <tr id="admissionwebhooks">
      <td><a href="#admissionwebhooks"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">certManager</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">ca</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="l">ca.validation.victoriametrics</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">63800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">cert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">45800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">issuer</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabledCRDValidation</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vlogs</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmagent</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmalert</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmalertmanager</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmalertmanagerconfig</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmauth</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmcluster</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmrule</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmsingle</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmuser</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">keepTLSSecret</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">policy</span><span class="p">:</span><span class="w"> </span><span class="l">Fail</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tls</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">caCert</span><span class="p">:</span><span class="w"> </span><span class="kc">null</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">cert</span><span class="p">:</span><span class="w"> </span><span class="kc">null</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">key</span><span class="p">:</span><span class="w"> </span><span class="kc">null</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Configures resource validation</p>
</td>
    </tr>
    <tr id="admissionwebhooks-certmanager">
      <td><a href="#admissionwebhooks-certmanager"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.certManager</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">ca</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="l">ca.validation.victoriametrics</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">63800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">cert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">45800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">issuer</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Enables custom ca bundle, if you are not using cert-manager. In case of custom ca, you have to create secret - {chart-name}-validation with keys: tls.key, tls.crt, ca.crt</p>
</td>
    </tr>
    <tr id="admissionwebhooks-certmanager-ca">
      <td><a href="#admissionwebhooks-certmanager-ca"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.certManager.ca</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="l">ca.validation.victoriametrics</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">63800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Certificate Authority parameters</p>
</td>
    </tr>
    <tr id="admissionwebhooks-certmanager-cert">
      <td><a href="#admissionwebhooks-certmanager-cert"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.certManager.cert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">commonName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">duration</span><span class="p">:</span><span class="w"> </span><span class="l">45800h0m0s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">secretTemplate</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">subject</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Certificate parameters</p>
</td>
    </tr>
    <tr id="admissionwebhooks-certmanager-enabled">
      <td><a href="#admissionwebhooks-certmanager-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.certManager.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enables cert creation and injection by cert-manager.</p>
</td>
    </tr>
    <tr id="admissionwebhooks-certmanager-issuer">
      <td><a href="#admissionwebhooks-certmanager-issuer"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.certManager.issuer</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>If needed, provide own issuer. Operator will create self-signed if empty.</p>
</td>
    </tr>
    <tr id="admissionwebhooks-enabled">
      <td><a href="#admissionwebhooks-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enables validation webhook.</p>
</td>
    </tr>
    <tr id="admissionwebhooks-policy">
      <td><a href="#admissionwebhooks-policy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">admissionWebhooks.policy</span><span class="p">:</span><span class="w"> </span><span class="l">Fail</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>What to do in case, when operator not available to validate request.</p>
</td>
    </tr>
    <tr id="affinity">
      <td><a href="#affinity"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">affinity</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod affinity</p>
</td>
    </tr>
    <tr id="allowedmetricsendpoints[0]">
      <td><a href="#allowedmetricsendpoints[0]"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">allowedMetricsEndpoints[0]</span><span class="p">:</span><span class="w"> </span><span class="l">/metrics</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em></td>
    </tr>
    <tr id="allowedmetricsendpoints[1]">
      <td><a href="#allowedmetricsendpoints[1]"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">allowedMetricsEndpoints[1]</span><span class="p">:</span><span class="w"> </span><span class="l">/metrics/resources</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em></td>
    </tr>
    <tr id="annotations">
      <td><a href="#annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to be added to the all resources</p>
</td>
    </tr>
    <tr id="crds-annotations">
      <td><a href="#crds-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>additional CRD annotations, when <code>.Values.crds.plain: false</code></p>
</td>
    </tr>
    <tr id="crds-cleanup-enabled">
      <td><a href="#crds-cleanup-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.cleanup.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Tells helm to clean up all the vm resources under this release&rsquo;s namespace when uninstalling</p>
</td>
    </tr>
    <tr id="crds-cleanup-image">
      <td><a href="#crds-cleanup-image"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.cleanup.image</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">pullPolicy</span><span class="p">:</span><span class="w"> </span><span class="l">IfNotPresent</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">repository</span><span class="p">:</span><span class="w"> </span><span class="l">bitnami/kubectl</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tag</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Image configuration for CRD cleanup Job</p>
</td>
    </tr>
    <tr id="crds-cleanup-resources">
      <td><a href="#crds-cleanup-resources"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.cleanup.resources</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">limits</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">cpu</span><span class="p">:</span><span class="w"> </span><span class="l">500m</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">memory</span><span class="p">:</span><span class="w"> </span><span class="l">256Mi</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">requests</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">cpu</span><span class="p">:</span><span class="w"> </span><span class="l">100m</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">memory</span><span class="p">:</span><span class="w"> </span><span class="l">56Mi</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Cleanup hook resources</p>
</td>
    </tr>
    <tr id="crds-enabled">
      <td><a href="#crds-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>manages CRD creation. Disables CRD creation only in combination with <code>crds.plain: false</code> due to helm dependency conditions limitation</p>
</td>
    </tr>
    <tr id="crds-plain">
      <td><a href="#crds-plain"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">crds.plain</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>check if plain or templated CRDs should be created. with this option set to <code>false</code>, all CRDs will be rendered from templates. with this option set to <code>true</code>, all CRDs are immutable and require manual upgrade.</p>
</td>
    </tr>
    <tr id="env">
      <td><a href="#env"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">env</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra settings for the operator deployment. Full list <a href="https://docs.victoriametrics.com/operator/vars" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="envfrom">
      <td><a href="#envfrom"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">envFrom</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Specify alternative source for env variables</p>
</td>
    </tr>
    <tr id="extraargs">
      <td><a href="#extraargs"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Operator container additional commandline arguments</p>
</td>
    </tr>
    <tr id="extracontainers">
      <td><a href="#extracontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra containers to run in a pod with operator</p>
</td>
    </tr>
    <tr id="extrahostpathmounts">
      <td><a href="#extrahostpathmounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraHostPathMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional hostPath mounts</p>
</td>
    </tr>
    <tr id="extralabels">
      <td><a href="#extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Labels to be added to the all resources</p>
</td>
    </tr>
    <tr id="extraobjects">
      <td><a href="#extraobjects"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraObjects</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Add extra specs dynamically to this chart</p>
</td>
    </tr>
    <tr id="extravolumemounts">
      <td><a href="#extravolumemounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraVolumeMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volume Mounts for the container</p>
</td>
    </tr>
    <tr id="extravolumes">
      <td><a href="#extravolumes"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraVolumes</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volumes for the pod</p>
</td>
    </tr>
    <tr id="fullnameoverride">
      <td><a href="#fullnameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">fullnameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Overrides the full name of server component resources</p>
</td>
    </tr>
    <tr id="global-cluster-dnsdomain">
      <td><a href="#global-cluster-dnsdomain"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global.cluster.dnsDomain</span><span class="p">:</span><span class="w"> </span><span class="l">cluster.local.</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>K8s cluster domain suffix, uses for building storage pods&rsquo; FQDN. Details are <a href="https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="global-compatibility">
      <td><a href="#global-compatibility"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global.compatibility</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">openshift</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">adaptSecurityContext</span><span class="p">:</span><span class="w"> </span><span class="l">auto</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Openshift security context compatibility configuration</p>
</td>
    </tr>
    <tr id="global-image-registry">
      <td><a href="#global-image-registry"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global.image.registry</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image registry, that can be shared across multiple helm charts</p>
</td>
    </tr>
    <tr id="global-imagepullsecrets">
      <td><a href="#global-imagepullsecrets"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global.imagePullSecrets</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Image pull secrets, that can be shared across multiple helm charts</p>
</td>
    </tr>
    <tr id="hostnetwork">
      <td><a href="#hostnetwork"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">hostNetwork</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable hostNetwork on operator deployment</p>
</td>
    </tr>
    <tr id="image">
      <td><a href="#image"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">pullPolicy</span><span class="p">:</span><span class="w"> </span><span class="l">IfNotPresent</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">registry</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">repository</span><span class="p">:</span><span class="w"> </span><span class="l">victoriametrics/operator</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tag</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">variant</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>operator image configuration</p>
</td>
    </tr>
    <tr id="image-pullpolicy">
      <td><a href="#image-pullpolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.pullPolicy</span><span class="p">:</span><span class="w"> </span><span class="l">IfNotPresent</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image pull policy</p>
</td>
    </tr>
    <tr id="image-registry">
      <td><a href="#image-registry"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.registry</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image registry</p>
</td>
    </tr>
    <tr id="image-repository">
      <td><a href="#image-repository"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.repository</span><span class="p">:</span><span class="w"> </span><span class="l">victoriametrics/operator</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image repository</p>
</td>
    </tr>
    <tr id="image-tag">
      <td><a href="#image-tag"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.tag</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image tag override Chart.AppVersion</p>
</td>
    </tr>
    <tr id="imagepullsecrets">
      <td><a href="#imagepullsecrets"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">imagePullSecrets</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Secret to pull images</p>
</td>
    </tr>
    <tr id="lifecycle">
      <td><a href="#lifecycle"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">lifecycle</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Operator lifecycle. See <a href="https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/" target="_blank">this article</a> for details.</p>
</td>
    </tr>
    <tr id="loglevel">
      <td><a href="#loglevel"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">logLevel</span><span class="p">:</span><span class="w"> </span><span class="l">info</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VM operator log level. Possible values: info and error.</p>
</td>
    </tr>
    <tr id="nameoverride">
      <td><a href="#nameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">nameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override chart name</p>
</td>
    </tr>
    <tr id="nodeselector">
      <td><a href="#nodeselector"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">nodeSelector</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s node selector. Details are <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="operator-disable-prometheus-converter">
      <td><a href="#operator-disable-prometheus-converter"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">operator.disable_prometheus_converter</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>By default, operator converts prometheus-operator objects.</p>
</td>
    </tr>
    <tr id="operator-enable-converter-ownership">
      <td><a href="#operator-enable-converter-ownership"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">operator.enable_converter_ownership</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enables ownership reference for converted prometheus-operator objects, it will remove corresponding victoria-metrics objects in case of deletion prometheus one.</p>
</td>
    </tr>
    <tr id="operator-prometheus-converter-add-argocd-ignore-annotations">
      <td><a href="#operator-prometheus-converter-add-argocd-ignore-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">operator.prometheus_converter_add_argocd_ignore_annotations</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Compare-options and sync-options for prometheus objects converted by operator for properly use with ArgoCD</p>
</td>
    </tr>
    <tr id="operator-usecustomconfigreloader">
      <td><a href="#operator-usecustomconfigreloader"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">operator.useCustomConfigReloader</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enables custom config-reloader, bundled with operator. It should reduce  vmagent and vmauth config sync-time and make it predictable.</p>
</td>
    </tr>
    <tr id="poddisruptionbudget">
      <td><a href="#poddisruptionbudget"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podDisruptionBudget</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>See <code>kubectl explain poddisruptionbudget.spec</code> for more or check <a href="https://kubernetes.io/docs/tasks/run-application/configure-pdb/" target="_blank">these docs</a></p>
</td>
    </tr>
    <tr id="podlabels">
      <td><a href="#podlabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>extra Labels for Pods only</p>
</td>
    </tr>
    <tr id="podsecuritycontext">
      <td><a href="#podsecuritycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podSecurityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">fsGroup</span><span class="p">:</span><span class="w"> </span><span class="m">2000</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">runAsNonRoot</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">runAsUser</span><span class="p">:</span><span class="w"> </span><span class="m">1000</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s security context. Details are <a href="https://kubernetes.io/docs/tasks/configure-pod-container/security-context/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="priorityclassname">
      <td><a href="#priorityclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">priorityClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Name of Priority Class</p>
</td>
    </tr>
    <tr id="probe-liveness">
      <td><a href="#probe-liveness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">probe.liveness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">failureThreshold</span><span class="p">:</span><span class="w"> </span><span class="m">3</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tcpSocket</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">probe</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">timeoutSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Liveness probe</p>
</td>
    </tr>
    <tr id="probe-readiness">
      <td><a href="#probe-readiness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">probe.readiness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">failureThreshold</span><span class="p">:</span><span class="w"> </span><span class="m">3</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">probe</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">timeoutSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Readiness probe</p>
</td>
    </tr>
    <tr id="probe-startup">
      <td><a href="#probe-startup"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">probe.startup</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Startup probe</p>
</td>
    </tr>
    <tr id="rbac-aggregatedclusterroles">
      <td><a href="#rbac-aggregatedclusterroles"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.aggregatedClusterRoles</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">admin</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">rbac.authorization.k8s.io/aggregate-to-admin</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;true&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">view</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">rbac.authorization.k8s.io/aggregate-to-view</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;true&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Create aggregated clusterRoles for CRD readonly and admin permissions</p>
</td>
    </tr>
    <tr id="rbac-aggregatedclusterroles-labels">
      <td><a href="#rbac-aggregatedclusterroles-labels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.aggregatedClusterRoles.labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">admin</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">rbac.authorization.k8s.io/aggregate-to-admin</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;true&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">view</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">rbac.authorization.k8s.io/aggregate-to-view</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;true&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Labels attached to according clusterRole</p>
</td>
    </tr>
    <tr id="rbac-create">
      <td><a href="#rbac-create"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.create</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Specifies whether the RBAC resources should be created</p>
</td>
    </tr>
    <tr id="replicacount">
      <td><a href="#replicacount"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Number of operator replicas</p>
</td>
    </tr>
    <tr id="resources">
      <td><a href="#resources"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Resource object</p>
</td>
    </tr>
    <tr id="securitycontext">
      <td><a href="#securitycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">securityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">allowPrivilegeEscalation</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">capabilities</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">drop</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="l">ALL</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">readOnlyRootFilesystem</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Security context to be added to server pods</p>
</td>
    </tr>
    <tr id="service-annotations">
      <td><a href="#service-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service annotations</p>
</td>
    </tr>
    <tr id="service-clusterip">
      <td><a href="#service-clusterip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.clusterIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service ClusterIP</p>
</td>
    </tr>
    <tr id="service-externalips">
      <td><a href="#service-externalips"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.externalIPs</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service external IPs. Check <a href="https://kubernetes.io/docs/concepts/services-networking/service/#external-ips" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="service-externaltrafficpolicy">
      <td><a href="#service-externaltrafficpolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.externalTrafficPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service external traffic policy. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="service-healthchecknodeport">
      <td><a href="#service-healthchecknodeport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.healthCheckNodePort</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Health check node port for a service. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="service-ipfamilies">
      <td><a href="#service-ipfamilies"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.ipFamilies</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>List of service IP families. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="service-ipfamilypolicy">
      <td><a href="#service-ipfamilypolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.ipFamilyPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service IP family policy. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="service-labels">
      <td><a href="#service-labels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service labels</p>
</td>
    </tr>
    <tr id="service-loadbalancerip">
      <td><a href="#service-loadbalancerip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.loadBalancerIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service load balancer IP</p>
</td>
    </tr>
    <tr id="service-loadbalancersourceranges">
      <td><a href="#service-loadbalancersourceranges"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.loadBalancerSourceRanges</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Load balancer source range</p>
</td>
    </tr>
    <tr id="service-serviceport">
      <td><a href="#service-serviceport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.servicePort</span><span class="p">:</span><span class="w"> </span><span class="m">8080</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Service port</p>
</td>
    </tr>
    <tr id="service-type">
      <td><a href="#service-type"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.type</span><span class="p">:</span><span class="w"> </span><span class="l">ClusterIP</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service type</p>
</td>
    </tr>
    <tr id="service-webhookport">
      <td><a href="#service-webhookport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.webhookPort</span><span class="p">:</span><span class="w"> </span><span class="m">9443</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Service webhook port</p>
</td>
    </tr>
    <tr id="serviceaccount-automountserviceaccounttoken">
      <td><a href="#serviceaccount-automountserviceaccounttoken"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.automountServiceAccountToken</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Whether to automount the service account token. Note that token needs to be mounted manually if this is disabled.</p>
</td>
    </tr>
    <tr id="serviceaccount-create">
      <td><a href="#serviceaccount-create"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.create</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Specifies whether a service account should be created</p>
</td>
    </tr>
    <tr id="serviceaccount-name">
      <td><a href="#serviceaccount-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.name</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</p>
</td>
    </tr>
    <tr id="servicemonitor">
      <td><a href="#servicemonitor"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">annotations</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">basicAuth</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">extraLabels</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">interval</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">relabelings</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">scheme</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">scrapeTimeout</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tlsConfig</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vm</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Configures monitoring with serviceScrape using either <code>VMServiceScrape</code> or <code>ServiceMonitor</code>. For latter <a href="https://artifacthub.io/packages/helm/prometheus-community/prometheus-operator-crds" target="_blank">Prometheus Operator CRDs</a> should be preinstalled</p>
</td>
    </tr>
    <tr id="servicemonitor-vm">
      <td><a href="#servicemonitor-vm"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.vm</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Creates <code>VMServiceScrape</code> if <code>true</code> and <code>ServiceMonitor</code> otherwise. Make sure <a href="https://artifacthub.io/packages/helm/prometheus-community/prometheus-operator-crds" target="_blank">Prometheus Operator CRDs</a> are installed if it&rsquo;s set to <code>false</code></p>
</td>
    </tr>
    <tr id="terminationgraceperiodseconds">
      <td><a href="#terminationgraceperiodseconds"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">terminationGracePeriodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">30</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Graceful pod termination timeout. See <a href="https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution" target="_blank">this article</a> for details.</p>
</td>
    </tr>
    <tr id="tolerations">
      <td><a href="#tolerations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">tolerations</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of tolerations object. Spec is <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="topologyspreadconstraints">
      <td><a href="#topologyspreadconstraints"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">topologySpreadConstraints</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Pod Topology Spread Constraints. Spec is <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="watchnamespaces">
      <td><a href="#watchnamespaces"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">watchNamespaces</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>By default, the operator will watch all the namespaces If you want to override this behavior, specify the namespace. Operator supports multiple namespaces for watching.</p>
</td>
    </tr>
  </tbody>
</table>

