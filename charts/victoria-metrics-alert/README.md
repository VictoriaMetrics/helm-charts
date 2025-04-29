

![Version](https://img.shields.io/badge/0.18.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-alert%2Fchangelog%2F%230180)
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

<table class="helm-vars">
  <thead>
    <th class="helm-vars-key">Key</th>
    <th class="helm-vars-description">Description</th>
  </thead>
  <tbody>
    <tr id="alertmanager-baseurl">
      <td><a href="#alertmanager-baseurl"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.baseURL</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>External URL, that alertmanager will expose to receivers</p>
</td>
    </tr>
    <tr id="alertmanager-baseurlprefix">
      <td><a href="#alertmanager-baseurlprefix"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.baseURLPrefix</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>External URL Prefix, Prefix for the internal routes of web endpoints</p>
</td>
    </tr>
    <tr id="alertmanager-config">
      <td><a href="#alertmanager-config"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">global</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">resolve_timeout</span><span class="p">:</span><span class="w"> </span><span class="l">5m</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">receivers</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">devnull</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">route</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">group_by</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="l">alertname</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">group_interval</span><span class="p">:</span><span class="w"> </span><span class="l">10s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">group_wait</span><span class="p">:</span><span class="w"> </span><span class="l">30s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">receiver</span><span class="p">:</span><span class="w"> </span><span class="l">devnull</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">repeat_interval</span><span class="p">:</span><span class="w"> </span><span class="l">24h</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager configuration</p>
</td>
    </tr>
    <tr id="alertmanager-configmap">
      <td><a href="#alertmanager-configmap"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.configMap</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Use existing configmap if specified otherwise .config values will be used</p>
</td>
    </tr>
    <tr id="alertmanager-emptydir">
      <td><a href="#alertmanager-emptydir"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.emptyDir</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Empty dir configuration if persistence is disabled for Alertmanager</p>
</td>
    </tr>
    <tr id="alertmanager-enabled">
      <td><a href="#alertmanager-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create alertmanager resources</p>
</td>
    </tr>
    <tr id="alertmanager-envfrom">
      <td><a href="#alertmanager-envfrom"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.envFrom</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Specify alternative source for env variables</p>
</td>
    </tr>
    <tr id="alertmanager-extraargs">
      <td><a href="#alertmanager-extraargs"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.extraArgs</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Extra command line arguments for container of component</p>
</td>
    </tr>
    <tr id="alertmanager-extracontainers">
      <td><a href="#alertmanager-extracontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.extraContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra containers to run in a pod with alertmanager</p>
</td>
    </tr>
    <tr id="alertmanager-extrahostpathmounts">
      <td><a href="#alertmanager-extrahostpathmounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.extraHostPathMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional hostPath mounts</p>
</td>
    </tr>
    <tr id="alertmanager-extravolumemounts">
      <td><a href="#alertmanager-extravolumemounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.extraVolumeMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volume Mounts for the container</p>
</td>
    </tr>
    <tr id="alertmanager-extravolumes">
      <td><a href="#alertmanager-extravolumes"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.extraVolumes</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volumes for the pod</p>
</td>
    </tr>
    <tr id="alertmanager-fullnameoverride">
      <td><a href="#alertmanager-fullnameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.fullnameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override Alertmanager resources fullname</p>
</td>
    </tr>
    <tr id="alertmanager-image">
      <td><a href="#alertmanager-image"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.image</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">registry</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">repository</span><span class="p">:</span><span class="w"> </span><span class="l">prom/alertmanager</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tag</span><span class="p">:</span><span class="w"> </span><span class="l">v0.27.0</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager image configuration</p>
</td>
    </tr>
    <tr id="alertmanager-imagepullsecrets">
      <td><a href="#alertmanager-imagepullsecrets"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.imagePullSecrets</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Image pull secrets</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-annotations">
      <td><a href="#alertmanager-ingress-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress annotations</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-enabled">
      <td><a href="#alertmanager-ingress-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable deployment of ingress for alertmanager component</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-extralabels">
      <td><a href="#alertmanager-ingress-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress extra labels</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-hosts">
      <td><a href="#alertmanager-ingress-hosts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.hosts</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">alertmanager.local</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">path</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="l">/</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">web</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of host objects</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-ingressclassname">
      <td><a href="#alertmanager-ingress-ingressclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.ingressClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress controller class name</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-pathtype">
      <td><a href="#alertmanager-ingress-pathtype"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.pathType</span><span class="p">:</span><span class="w"> </span><span class="l">Prefix</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress path type</p>
</td>
    </tr>
    <tr id="alertmanager-ingress-tls">
      <td><a href="#alertmanager-ingress-tls"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.ingress.tls</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of TLS objects</p>
</td>
    </tr>
    <tr id="alertmanager-initcontainers">
      <td><a href="#alertmanager-initcontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.initContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional initContainers to initialize the pod</p>
</td>
    </tr>
    <tr id="alertmanager-listenaddress">
      <td><a href="#alertmanager-listenaddress"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.listenAddress</span><span class="p">:</span><span class="w"> </span><span class="m">0.0.0.0</span><span class="p">:</span><span class="m">9093</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Alertmanager listen address</p>
</td>
    </tr>
    <tr id="alertmanager-nodeselector">
      <td><a href="#alertmanager-nodeselector"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.nodeSelector</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s node selector. Details are <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-accessmodes">
      <td><a href="#alertmanager-persistentvolume-accessmodes"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.accessModes</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="l">ReadWriteOnce</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of access modes. Must match those of existing PV or dynamic provisioner. Details are <a href="https://kubernetes.io/docs/concepts/storage/persistent-volumes/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-annotations">
      <td><a href="#alertmanager-persistentvolume-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Persistent volume annotations</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-enabled">
      <td><a href="#alertmanager-persistentvolume-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create/use Persistent Volume Claim for alertmanager component. Empty dir if false</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-existingclaim">
      <td><a href="#alertmanager-persistentvolume-existingclaim"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.existingClaim</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Existing Claim name. If defined, PVC must be created manually before volume will be bound</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-mountpath">
      <td><a href="#alertmanager-persistentvolume-mountpath"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.mountPath</span><span class="p">:</span><span class="w"> </span><span class="l">/data</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Mount path. Alertmanager data Persistent Volume mount root path.</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-size">
      <td><a href="#alertmanager-persistentvolume-size"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.size</span><span class="p">:</span><span class="w"> </span><span class="l">50Mi</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Size of the volume. Better to set the same as resource limit memory property.</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-storageclassname">
      <td><a href="#alertmanager-persistentvolume-storageclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.storageClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>StorageClass to use for persistent volume. Requires alertmanager.persistentVolume.enabled: true. If defined, PVC created automatically</p>
</td>
    </tr>
    <tr id="alertmanager-persistentvolume-subpath">
      <td><a href="#alertmanager-persistentvolume-subpath"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.persistentVolume.subPath</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Mount subpath</p>
</td>
    </tr>
    <tr id="alertmanager-podannotations">
      <td><a href="#alertmanager-podannotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.podAnnotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager Pod annotations</p>
</td>
    </tr>
    <tr id="alertmanager-podlabels">
      <td><a href="#alertmanager-podlabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.podLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager Pod labels</p>
</td>
    </tr>
    <tr id="alertmanager-podsecuritycontext">
      <td><a href="#alertmanager-podsecuritycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.podSecurityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s security context. Details are <a href="https://kubernetes.io/docs/tasks/configure-pod-container/security-context/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="alertmanager-priorityclassname">
      <td><a href="#alertmanager-priorityclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.priorityClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Name of Priority Class</p>
</td>
    </tr>
    <tr id="alertmanager-probe-liveness">
      <td><a href="#alertmanager-probe-liveness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.probe.liveness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">path</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ ternary &#34;&#34; .app.baseURLPrefix (empty .app.baseURLPrefix) }}/-/healthy&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">web</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Liveness probe</p>
</td>
    </tr>
    <tr id="alertmanager-probe-readiness">
      <td><a href="#alertmanager-probe-readiness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.probe.readiness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">path</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ ternary &#34;&#34; .app.baseURLPrefix (empty .app.baseURLPrefix) }}/-/ready&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">web</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Readiness probe</p>
</td>
    </tr>
    <tr id="alertmanager-probe-startup">
      <td><a href="#alertmanager-probe-startup"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.probe.startup</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">path</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ ternary &#34;&#34; .app.baseURLPrefix (empty .app.baseURLPrefix) }}/-/ready&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">web</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Startup probe</p>
</td>
    </tr>
    <tr id="alertmanager-resources">
      <td><a href="#alertmanager-resources"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.resources</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Resource object. Details are <a href="https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="alertmanager-retention">
      <td><a href="#alertmanager-retention"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.retention</span><span class="p">:</span><span class="w"> </span><span class="l">120h</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Alertmanager retention</p>
</td>
    </tr>
    <tr id="alertmanager-securitycontext">
      <td><a href="#alertmanager-securitycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.securityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Security context to be added to server pods</p>
</td>
    </tr>
    <tr id="alertmanager-service-annotations">
      <td><a href="#alertmanager-service-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service annotations</p>
</td>
    </tr>
    <tr id="alertmanager-service-clusterip">
      <td><a href="#alertmanager-service-clusterip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.clusterIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service ClusterIP</p>
</td>
    </tr>
    <tr id="alertmanager-service-externalips">
      <td><a href="#alertmanager-service-externalips"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.externalIPs</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Service external IPs. Check <a href="https://kubernetes.io/docs/concepts/services-networking/service/#external-ips" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="alertmanager-service-externaltrafficpolicy">
      <td><a href="#alertmanager-service-externaltrafficpolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.externalTrafficPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service external traffic policy. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="alertmanager-service-healthchecknodeport">
      <td><a href="#alertmanager-service-healthchecknodeport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.healthCheckNodePort</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Health check node port for a service. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="alertmanager-service-ipfamilies">
      <td><a href="#alertmanager-service-ipfamilies"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.ipFamilies</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>List of service IP families. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="alertmanager-service-ipfamilypolicy">
      <td><a href="#alertmanager-service-ipfamilypolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.ipFamilyPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service IP family policy. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="alertmanager-service-labels">
      <td><a href="#alertmanager-service-labels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service labels</p>
</td>
    </tr>
    <tr id="alertmanager-service-loadbalancerip">
      <td><a href="#alertmanager-service-loadbalancerip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.loadBalancerIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service load balancer IP</p>
</td>
    </tr>
    <tr id="alertmanager-service-loadbalancersourceranges">
      <td><a href="#alertmanager-service-loadbalancersourceranges"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.loadBalancerSourceRanges</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Load balancer source range</p>
</td>
    </tr>
    <tr id="alertmanager-service-serviceport">
      <td><a href="#alertmanager-service-serviceport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.servicePort</span><span class="p">:</span><span class="w"> </span><span class="m">9093</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Service port</p>
</td>
    </tr>
    <tr id="alertmanager-service-type">
      <td><a href="#alertmanager-service-type"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.service.type</span><span class="p">:</span><span class="w"> </span><span class="l">ClusterIP</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service type</p>
</td>
    </tr>
    <tr id="alertmanager-templates">
      <td><a href="#alertmanager-templates"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.templates</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager extra templates</p>
</td>
    </tr>
    <tr id="alertmanager-tolerations">
      <td><a href="#alertmanager-tolerations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.tolerations</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Node tolerations for server scheduling to nodes with taints. Details are <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="alertmanager-webconfig">
      <td><a href="#alertmanager-webconfig"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">alertmanager.webConfig</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Alertmanager web configuration</p>
</td>
    </tr>
    <tr id="extraobjects">
      <td><a href="#extraobjects"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraObjects</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Add extra specs dynamically to this chart</p>
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
    <tr id="license">
      <td><a href="#license"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">license</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">key</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">secret</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">key</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Enterprise license key configuration for VictoriaMetrics enterprise. Required only for VictoriaMetrics enterprise. Check docs <a href="https://docs.victoriametrics.com/enterprise" target="_blank">here</a>, for more information, visit <a href="https://victoriametrics.com/products/enterprise/" target="_blank">site</a>. Request a trial license <a href="https://victoriametrics.com/products/enterprise/trial/" target="_blank">here</a> Supported starting from VictoriaMetrics v1.94.0</p>
</td>
    </tr>
    <tr id="license-key">
      <td><a href="#license-key"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">license.key</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>License key</p>
</td>
    </tr>
    <tr id="license-secret">
      <td><a href="#license-secret"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">license.secret</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">key</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Use existing secret with license key</p>
</td>
    </tr>
    <tr id="license-secret-key">
      <td><a href="#license-secret-key"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">license.secret.key</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Key in secret with license key</p>
</td>
    </tr>
    <tr id="license-secret-name">
      <td><a href="#license-secret-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">license.secret.name</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Existing secret name</p>
</td>
    </tr>
    <tr id="nameoverride">
      <td><a href="#nameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">nameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override chart name</p>
</td>
    </tr>
    <tr id="server-affinity">
      <td><a href="#server-affinity"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.affinity</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod affinity</p>
</td>
    </tr>
    <tr id="server-annotations">
      <td><a href="#server-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to be added to the deployment</p>
</td>
    </tr>
    <tr id="server-config">
      <td><a href="#server-config"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">alerts</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">groups</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAlert configuration</p>
</td>
    </tr>
    <tr id="server-configmap">
      <td><a href="#server-configmap"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.configMap</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VMAlert alert rules configuration. Use existing configmap if specified</p>
</td>
    </tr>
    <tr id="server-datasource">
      <td><a href="#server-datasource"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.datasource</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">bearer</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">url</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAlert reads metrics from source, next section represents its configuration. It can be any service which supports MetricsQL or PromQL.</p>
</td>
    </tr>
    <tr id="server-datasource-basicauth">
      <td><a href="#server-datasource-basicauth"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.datasource.basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Basic auth for datasource</p>
</td>
    </tr>
    <tr id="server-datasource-bearer-token">
      <td><a href="#server-datasource-bearer-token"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.datasource.bearer.token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token with Bearer token. You can use one of token or tokenFile. You don&rsquo;t need to add &ldquo;Bearer&rdquo; prefix string</p>
</td>
    </tr>
    <tr id="server-datasource-bearer-tokenfile">
      <td><a href="#server-datasource-bearer-tokenfile"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.datasource.bearer.tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token Auth file with Bearer token. You can use one of token or tokenFile</p>
</td>
    </tr>
    <tr id="server-env">
      <td><a href="#server-env"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.env</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional environment variables (ex.: secret tokens, flags). Check <a href="https://docs.victoriametrics.com/#environment-variables" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="server-envfrom">
      <td><a href="#server-envfrom"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.envFrom</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Specify alternative source for env variables</p>
</td>
    </tr>
    <tr id="server-extraargs">
      <td><a href="#server-extraargs"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.extraArgs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">envflag.enable</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">envflag.prefix</span><span class="p">:</span><span class="w"> </span><span class="l">VM_</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpListenAddr</span><span class="p">:</span><span class="w"> </span><span class="p">:</span><span class="m">8880</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">loggerFormat</span><span class="p">:</span><span class="w"> </span><span class="l">json</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">rule</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="l">/config/alert-rules.yaml</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Extra command line arguments for container of component</p>
</td>
    </tr>
    <tr id="server-extracontainers">
      <td><a href="#server-extracontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.extraContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional containers to run in the same pod</p>
</td>
    </tr>
    <tr id="server-extrahostpathmounts">
      <td><a href="#server-extrahostpathmounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.extraHostPathMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional hostPath mounts</p>
</td>
    </tr>
    <tr id="server-extravolumemounts">
      <td><a href="#server-extravolumemounts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.extraVolumeMounts</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volume Mounts for the container. Expects a lice of <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#volumemount-v1-core" target="_blank">volume mounts</a></p>
</td>
    </tr>
    <tr id="server-extravolumes">
      <td><a href="#server-extravolumes"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.extraVolumes</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra Volumes for the pod</p>
</td>
    </tr>
    <tr id="server-fullnameoverride">
      <td><a href="#server-fullnameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.fullnameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override vmalert resources fullname</p>
</td>
    </tr>
    <tr id="server-image">
      <td><a href="#server-image"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.image</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">pullPolicy</span><span class="p">:</span><span class="w"> </span><span class="l">IfNotPresent</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">registry</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">repository</span><span class="p">:</span><span class="w"> </span><span class="l">victoriametrics/vmalert</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tag</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">variant</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAlert image configuration</p>
</td>
    </tr>
    <tr id="server-imagepullsecrets">
      <td><a href="#server-imagepullsecrets"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.imagePullSecrets</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Image pull secrets</p>
</td>
    </tr>
    <tr id="server-ingress-annotations">
      <td><a href="#server-ingress-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress annotations</p>
</td>
    </tr>
    <tr id="server-ingress-enabled">
      <td><a href="#server-ingress-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable deployment of ingress for vmalert component</p>
</td>
    </tr>
    <tr id="server-ingress-extralabels">
      <td><a href="#server-ingress-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress extra labels</p>
</td>
    </tr>
    <tr id="server-ingress-hosts">
      <td><a href="#server-ingress-hosts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.hosts</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">vmalert.local</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">path</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="l">/</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">http</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of host objects</p>
</td>
    </tr>
    <tr id="server-ingress-ingressclassname">
      <td><a href="#server-ingress-ingressclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.ingressClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress controller class name</p>
</td>
    </tr>
    <tr id="server-ingress-pathtype">
      <td><a href="#server-ingress-pathtype"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.pathType</span><span class="p">:</span><span class="w"> </span><span class="l">Prefix</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress path type</p>
</td>
    </tr>
    <tr id="server-ingress-tls">
      <td><a href="#server-ingress-tls"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.ingress.tls</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of TLS objects</p>
</td>
    </tr>
    <tr id="server-initcontainers">
      <td><a href="#server-initcontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.initContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional initContainers to initialize the pod</p>
</td>
    </tr>
    <tr id="server-labels">
      <td><a href="#server-labels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Labels to be added to the deployment</p>
</td>
    </tr>
    <tr id="server-minreadyseconds">
      <td><a href="#server-minreadyseconds"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.minReadySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">0</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Specifies the minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing/terminating 0 is the standard k8s default</p>
</td>
    </tr>
    <tr id="server-name">
      <td><a href="#server-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.name</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override default <code>app</code> label name</p>
</td>
    </tr>
    <tr id="server-nodeselector">
      <td><a href="#server-nodeselector"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.nodeSelector</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s node selector. Details are <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="server-notifier">
      <td><a href="#server-notifier"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.notifier</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">alertmanager</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">bearer</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">url</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Notifier to use for alerts. Multiple notifiers can be enabled by using <code>notifiers</code> section</p>
</td>
    </tr>
    <tr id="server-notifier-alertmanager-basicauth">
      <td><a href="#server-notifier-alertmanager-basicauth"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.notifier.alertmanager.basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Basic auth for alertmanager</p>
</td>
    </tr>
    <tr id="server-notifier-alertmanager-bearer-token">
      <td><a href="#server-notifier-alertmanager-bearer-token"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.notifier.alertmanager.bearer.token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token with Bearer token. You can use one of token or tokenFile. You don&rsquo;t need to add &ldquo;Bearer&rdquo; prefix string</p>
</td>
    </tr>
    <tr id="server-notifier-alertmanager-bearer-tokenfile">
      <td><a href="#server-notifier-alertmanager-bearer-tokenfile"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.notifier.alertmanager.bearer.tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token Auth file with Bearer token. You can use one of token or tokenFile</p>
</td>
    </tr>
    <tr id="server-notifiers">
      <td><a href="#server-notifiers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.notifiers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional notifiers to use for alerts</p>
</td>
    </tr>
    <tr id="server-podannotations">
      <td><a href="#server-podannotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.podAnnotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to be added to pod</p>
</td>
    </tr>
    <tr id="server-poddisruptionbudget">
      <td><a href="#server-poddisruptionbudget"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.podDisruptionBudget</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>See <code>kubectl explain poddisruptionbudget.spec</code> for more. Or check <a href="https://kubernetes.io/docs/tasks/run-application/configure-pdb/" target="_blank">docs</a></p>
</td>
    </tr>
    <tr id="server-podlabels">
      <td><a href="#server-podlabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.podLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s additional labels</p>
</td>
    </tr>
    <tr id="server-podsecuritycontext">
      <td><a href="#server-podsecuritycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.podSecurityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Pod&rsquo;s security context. Details are <a href="https://kubernetes.io/docs/tasks/configure-pod-container/security-context/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="server-priorityclassname">
      <td><a href="#server-priorityclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.priorityClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Name of Priority Class</p>
</td>
    </tr>
    <tr id="server-probe-liveness">
      <td><a href="#server-probe-liveness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.probe.liveness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">failureThreshold</span><span class="p">:</span><span class="w"> </span><span class="m">3</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tcpSocket</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">timeoutSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Liveness probe</p>
</td>
    </tr>
    <tr id="server-probe-readiness">
      <td><a href="#server-probe-readiness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.probe.readiness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">failureThreshold</span><span class="p">:</span><span class="w"> </span><span class="m">3</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">timeoutSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Readiness probe</p>
</td>
    </tr>
    <tr id="server-probe-startup">
      <td><a href="#server-probe-startup"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.probe.startup</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Startup probe</p>
</td>
    </tr>
    <tr id="server-remote-read-basicauth">
      <td><a href="#server-remote-read-basicauth"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.read.basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Basic auth for remote read</p>
</td>
    </tr>
    <tr id="server-remote-read-bearer">
      <td><a href="#server-remote-read-bearer"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.read.bearer</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Auth based on Bearer token for remote read</p>
</td>
    </tr>
    <tr id="server-remote-read-bearer-token">
      <td><a href="#server-remote-read-bearer-token"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.read.bearer.token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token with Bearer token. You can use one of token or tokenFile. You don&rsquo;t need to add &ldquo;Bearer&rdquo; prefix string</p>
</td>
    </tr>
    <tr id="server-remote-read-bearer-tokenfile">
      <td><a href="#server-remote-read-bearer-tokenfile"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.read.bearer.tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token Auth file with Bearer token. You can use one of token or tokenFile</p>
</td>
    </tr>
    <tr id="server-remote-read-url">
      <td><a href="#server-remote-read-url"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.read.url</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VMAlert remote read URL</p>
</td>
    </tr>
    <tr id="server-remote-write-basicauth">
      <td><a href="#server-remote-write-basicauth"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.write.basicAuth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">password</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">username</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Basic auth for remote write</p>
</td>
    </tr>
    <tr id="server-remote-write-bearer">
      <td><a href="#server-remote-write-bearer"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.write.bearer</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Auth based on Bearer token for remote write</p>
</td>
    </tr>
    <tr id="server-remote-write-bearer-token">
      <td><a href="#server-remote-write-bearer-token"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.write.bearer.token</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token with Bearer token. You can use one of token or tokenFile. You don&rsquo;t need to add &ldquo;Bearer&rdquo; prefix string</p>
</td>
    </tr>
    <tr id="server-remote-write-bearer-tokenfile">
      <td><a href="#server-remote-write-bearer-tokenfile"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.write.bearer.tokenFile</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Token Auth file with Bearer token. You can use one of token or tokenFile</p>
</td>
    </tr>
    <tr id="server-remote-write-url">
      <td><a href="#server-remote-write-url"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.remote.write.url</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VMAlert remote write URL</p>
</td>
    </tr>
    <tr id="server-replicacount">
      <td><a href="#server-replicacount"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Replica count</p>
</td>
    </tr>
    <tr id="server-resources">
      <td><a href="#server-resources"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.resources</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Resource object. Details are <a href="https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="server-securitycontext">
      <td><a href="#server-securitycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.securityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Security context to be added to server pods</p>
</td>
    </tr>
    <tr id="server-service-annotations">
      <td><a href="#server-service-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service annotations</p>
</td>
    </tr>
    <tr id="server-service-clusterip">
      <td><a href="#server-service-clusterip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.clusterIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service ClusterIP</p>
</td>
    </tr>
    <tr id="server-service-externalips">
      <td><a href="#server-service-externalips"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.externalIPs</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Service external IPs. Check <a href="https://kubernetes.io/docs/concepts/services-networking/service/#external-ips" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="server-service-externaltrafficpolicy">
      <td><a href="#server-service-externaltrafficpolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.externalTrafficPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service external traffic policy. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="server-service-healthchecknodeport">
      <td><a href="#server-service-healthchecknodeport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.healthCheckNodePort</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Health check node port for a service. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="server-service-ipfamilies">
      <td><a href="#server-service-ipfamilies"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.ipFamilies</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>List of service IP families. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="server-service-ipfamilypolicy">
      <td><a href="#server-service-ipfamilypolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.ipFamilyPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service IP family policy. Check <a href="https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="server-service-labels">
      <td><a href="#server-service-labels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service labels</p>
</td>
    </tr>
    <tr id="server-service-loadbalancerip">
      <td><a href="#server-service-loadbalancerip"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.loadBalancerIP</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service load balancer IP</p>
</td>
    </tr>
    <tr id="server-service-loadbalancersourceranges">
      <td><a href="#server-service-loadbalancersourceranges"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.loadBalancerSourceRanges</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Load balancer source range</p>
</td>
    </tr>
    <tr id="server-service-serviceport">
      <td><a href="#server-service-serviceport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.servicePort</span><span class="p">:</span><span class="w"> </span><span class="m">8880</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Service port</p>
</td>
    </tr>
    <tr id="server-service-type">
      <td><a href="#server-service-type"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.service.type</span><span class="p">:</span><span class="w"> </span><span class="l">ClusterIP</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service type</p>
</td>
    </tr>
    <tr id="server-strategy">
      <td><a href="#server-strategy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.strategy</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">rollingUpdate</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">maxSurge</span><span class="p">:</span><span class="w"> </span><span class="m">25</span><span class="l">%</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">maxUnavailable</span><span class="p">:</span><span class="w"> </span><span class="m">25</span><span class="l">%</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">type</span><span class="p">:</span><span class="w"> </span><span class="l">RollingUpdate</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Deployment strategy, set to standard k8s default</p>
</td>
    </tr>
    <tr id="server-tolerations">
      <td><a href="#server-tolerations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.tolerations</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Node tolerations for server scheduling to nodes with taints. Details are <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="server-verticalpodautoscaler">
      <td><a href="#server-verticalpodautoscaler"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.verticalPodAutoscaler</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Vertical Pod Autoscaler</p>
</td>
    </tr>
    <tr id="server-verticalpodautoscaler-enabled">
      <td><a href="#server-verticalpodautoscaler-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">server.verticalPodAutoscaler.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Use VPA for vmalert</p>
</td>
    </tr>
    <tr id="serviceaccount-annotations">
      <td><a href="#serviceaccount-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to add to the service account</p>
</td>
    </tr>
    <tr id="serviceaccount-automounttoken">
      <td><a href="#serviceaccount-automounttoken"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.automountToken</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Mount API token to pod directly</p>
</td>
    </tr>
    <tr id="serviceaccount-create">
      <td><a href="#serviceaccount-create"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.create</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Specifies whether a service account should be created</p>
</td>
    </tr>
    <tr id="serviceaccount-name">
      <td><a href="#serviceaccount-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceAccount.name</span><span class="p">:</span><span class="w"> </span><span class="kc">null</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</p>
</td>
    </tr>
    <tr id="servicemonitor-annotations">
      <td><a href="#servicemonitor-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service Monitor annotations</p>
</td>
    </tr>
    <tr id="servicemonitor-basicauth">
      <td><a href="#servicemonitor-basicauth"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.basicAuth</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Basic auth params for Service Monitor</p>
</td>
    </tr>
    <tr id="servicemonitor-enabled">
      <td><a href="#servicemonitor-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable deployment of Service Monitor for server component. This is Prometheus operator object</p>
</td>
    </tr>
    <tr id="servicemonitor-extralabels">
      <td><a href="#servicemonitor-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service Monitor labels</p>
</td>
    </tr>
    <tr id="servicemonitor-metricrelabelings">
      <td><a href="#servicemonitor-metricrelabelings"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.metricRelabelings</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Service Monitor metricRelabelings</p>
</td>
    </tr>
    <tr id="servicemonitor-relabelings">
      <td><a href="#servicemonitor-relabelings"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.relabelings</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Service Monitor relabelings</p>
</td>
    </tr>
  </tbody>
</table>

