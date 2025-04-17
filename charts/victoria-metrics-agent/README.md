

![Version](https://img.shields.io/badge/0.18.1-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-agent%2Fchangelog%2F%230181)
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

<table class="helm-vars">
  <thead>
    <th class="helm-vars-key">Key</th>
    <th class="helm-vars-description">Description</th>
  </thead>
  <tbody>
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
    <tr id="annotations">
      <td><a href="#annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to be added to the deployment</p>
</td>
    </tr>
    <tr id="config">
      <td><a href="#config"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">global</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">scrape_interval</span><span class="p">:</span><span class="w"> </span><span class="l">10s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">scrape_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">vmagent</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">static_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">targets</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">localhost:8429</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">bearer_token_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/token</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-apiservers</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">endpoints</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">default;kubernetes;https</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_endpoint_port_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">scheme</span><span class="p">:</span><span class="w"> </span><span class="l">https</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">tls_config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">ca_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/ca.crt</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">insecure_skip_verify</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">bearer_token_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/token</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-nodes</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">node</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_node_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes.default.svc:443</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">/api/v1/nodes/$1/proxy/metrics</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_node_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__metrics_path__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">scheme</span><span class="p">:</span><span class="w"> </span><span class="l">https</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">tls_config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">ca_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/ca.crt</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">insecure_skip_verify</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">bearer_token_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/token</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">honor_timestamps</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-nodes-cadvisor</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">node</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_node_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes.default.svc:443</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">/api/v1/nodes/$1/proxy/metrics/cadvisor</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_node_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__metrics_path__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">scheme</span><span class="p">:</span><span class="w"> </span><span class="l">https</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">tls_config</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">ca_file</span><span class="p">:</span><span class="w"> </span><span class="l">/var/run/secrets/kubernetes.io/serviceaccount/ca.crt</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">insecure_skip_verify</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-service-endpoints</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">endpointslices</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">drop</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_init</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep_if_equal</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_port_number</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_scrape</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(https?)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_scheme</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__scheme__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_path</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__metrics_path__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">([^:]+)(?::\d+)?;(\d+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">$1:$2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_service_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">pod</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">container</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">service</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">${1}</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">job</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_node_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">node</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-service-endpoints-slow</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">endpointslices</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">drop</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_init</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep_if_equal</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_port_number</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_scrape_slow</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(https?)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_scheme</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__scheme__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_path</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__metrics_path__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">([^:]+)(?::\d+)?;(\d+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">$1:$2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_service_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">pod</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">container</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">service</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">${1}</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">job</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_node_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">node</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">scrape_interval</span><span class="p">:</span><span class="w"> </span><span class="l">5m</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">scrape_timeout</span><span class="p">:</span><span class="w"> </span><span class="l">30s</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-services</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">service</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">metrics_path</span><span class="p">:</span><span class="w"> </span><span class="l">/probe</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">params</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">module</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">http_2xx</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_annotation_prometheus_io_probe</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__param_target</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">blackbox</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__param_target</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">instance</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_service_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_service_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">service</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">job_name</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes-pods</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">kubernetes_sd_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">role</span><span class="p">:</span><span class="w"> </span><span class="l">pod</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">relabel_configs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">drop</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_init</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep_if_equal</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_port_number</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">keep</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_annotation_prometheus_io_scrape</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_annotation_prometheus_io_path</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__metrics_path__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">([^:]+)(?::\d+)?;(\d+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">replacement</span><span class="p">:</span><span class="w"> </span><span class="l">$1:$2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_annotation_prometheus_io_port</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">__address__</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">labelmap</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">regex</span><span class="p">:</span><span class="w"> </span><span class="l">__meta_kubernetes_pod_label_(.+)</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">pod</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_container_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">container</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">namespace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">action</span><span class="p">:</span><span class="w"> </span><span class="l">replace</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">source_labels</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="l">__meta_kubernetes_pod_node_name</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">target_label</span><span class="p">:</span><span class="w"> </span><span class="l">node</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAgent scrape configuration</p>
</td>
    </tr>
    <tr id="configmap">
      <td><a href="#configmap"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">configMap</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VMAgent <a href="https://docs.victoriametrics.com/vmagent#how-to-collect-metrics-in-prometheus-format" target="_blank">scraping configuration</a> use existing configmap if specified otherwise .config values will be used</p>
</td>
    </tr>
    <tr id="containerworkingdir">
      <td><a href="#containerworkingdir"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">containerWorkingDir</span><span class="p">:</span><span class="w"> </span><span class="l">/</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Container working directory</p>
</td>
    </tr>
    <tr id="daemonset">
      <td><a href="#daemonset"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">daemonSet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">spec</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p><a href="https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/" target="_blank">K8s DaemonSet</a> specific variables</p>
</td>
    </tr>
    <tr id="deployment">
      <td><a href="#deployment"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">deployment</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">strategy</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p><a href="https://kubernetes.io/docs/concepts/workloads/controllers/deployment/" target="_blank">K8s Deployment</a> specific variables</p>
</td>
    </tr>
    <tr id="deployment-spec-strategy">
      <td><a href="#deployment-spec-strategy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">deployment.spec.strategy</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Deployment strategy. Check <a href="https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="emptydir">
      <td><a href="#emptydir"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">emptyDir</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Empty dir configuration for a case, when persistence is disabled</p>
</td>
    </tr>
    <tr id="env">
      <td><a href="#env"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">env</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Additional environment variables (ex.: secret tokens, flags). Check <a href="https://docs.victoriametrics.com/#environment-variables" target="_blank">here</a> for more details.</p>
</td>
    </tr>
    <tr id="envfrom">
      <td><a href="#envfrom"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">envFrom</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Specify alternative source for env variables</p>
</td>
    </tr>
    <tr id="extraargs">
      <td><a href="#extraargs"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraArgs</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">envflag.enable</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">envflag.prefix</span><span class="p">:</span><span class="w"> </span><span class="l">VM_</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpListenAddr</span><span class="p">:</span><span class="w"> </span><span class="p">:</span><span class="m">8429</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">loggerFormat</span><span class="p">:</span><span class="w"> </span><span class="l">json</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAgent extra command line arguments</p>
</td>
    </tr>
    <tr id="extracontainers">
      <td><a href="#extracontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra containers to run in a pod with vmagent</p>
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
      <td><em><code>(object)</code></em><p>Extra labels for Deployment and Statefulset</p>
</td>
    </tr>
    <tr id="extraobjects">
      <td><a href="#extraobjects"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraObjects</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Add extra specs dynamically to this chart</p>
</td>
    </tr>
    <tr id="extrascrapeconfigs">
      <td><a href="#extrascrapeconfigs"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extraScrapeConfigs</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Extra scrape configs that will be appended to <code>config</code></p>
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
      <td><em><code>(string)</code></em><p>Override resources fullname</p>
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
    <tr id="horizontalpodautoscaling">
      <td><a href="#horizontalpodautoscaling"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">horizontalPodAutoscaling</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">maxReplicas</span><span class="p">:</span><span class="w"> </span><span class="m">10</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">metrics</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">minReplicas</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Horizontal Pod Autoscaling. Note that it is not intended to be used for vmagents which perform scraping. In order to scale scraping vmagents check <a href="https://docs.victoriametrics.com/vmagent/#scraping-big-number-of-targets" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="horizontalpodautoscaling-enabled">
      <td><a href="#horizontalpodautoscaling-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">horizontalPodAutoscaling.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Use HPA for vmagent</p>
</td>
    </tr>
    <tr id="horizontalpodautoscaling-maxreplicas">
      <td><a href="#horizontalpodautoscaling-maxreplicas"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">horizontalPodAutoscaling.maxReplicas</span><span class="p">:</span><span class="w"> </span><span class="m">10</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Maximum replicas for HPA to use to to scale vmagent</p>
</td>
    </tr>
    <tr id="horizontalpodautoscaling-metrics">
      <td><a href="#horizontalpodautoscaling-metrics"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">horizontalPodAutoscaling.metrics</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Metric for HPA to use to scale vmagent</p>
</td>
    </tr>
    <tr id="horizontalpodautoscaling-minreplicas">
      <td><a href="#horizontalpodautoscaling-minreplicas"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">horizontalPodAutoscaling.minReplicas</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Minimum replicas for HPA to use to scale vmagent</p>
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
      <td><a href="#image-repository"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.repository</span><span class="p">:</span><span class="w"> </span><span class="l">victoriametrics/vmagent</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image repository</p>
</td>
    </tr>
    <tr id="image-tag">
      <td><a href="#image-tag"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.tag</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Image tag, set to <code>Chart.AppVersion</code> by default</p>
</td>
    </tr>
    <tr id="image-variant">
      <td><a href="#image-variant"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">image.variant</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Variant of the image to use. e.g. enterprise, scratch</p>
</td>
    </tr>
    <tr id="imagepullsecrets">
      <td><a href="#imagepullsecrets"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">imagePullSecrets</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Image pull secrets</p>
</td>
    </tr>
    <tr id="ingress-annotations">
      <td><a href="#ingress-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress annotations</p>
</td>
    </tr>
    <tr id="ingress-enabled">
      <td><a href="#ingress-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable deployment of ingress for agent</p>
</td>
    </tr>
    <tr id="ingress-extralabels">
      <td><a href="#ingress-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Ingress extra labels</p>
</td>
    </tr>
    <tr id="ingress-hosts">
      <td><a href="#ingress-hosts"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.hosts</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">vmagent.local</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">path</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="l">/</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">      </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="l">http</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of host objects</p>
</td>
    </tr>
    <tr id="ingress-ingressclassname">
      <td><a href="#ingress-ingressclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.ingressClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress controller class name</p>
</td>
    </tr>
    <tr id="ingress-pathtype">
      <td><a href="#ingress-pathtype"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.pathType</span><span class="p">:</span><span class="w"> </span><span class="l">Prefix</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Ingress path type</p>
</td>
    </tr>
    <tr id="ingress-tls">
      <td><a href="#ingress-tls"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">ingress.tls</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of TLS objects</p>
</td>
    </tr>
    <tr id="initcontainers">
      <td><a href="#initcontainers"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">initContainers</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Init containers for vmagent</p>
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
    <tr id="lifecycle">
      <td><a href="#lifecycle"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">lifecycle</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Specify pod lifecycle</p>
</td>
    </tr>
    <tr id="mode">
      <td><a href="#mode"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">mode</span><span class="p">:</span><span class="w"> </span><span class="l">deployment</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>VMAgent mode: daemonSet, deployment, statefulSet</p>
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
      <td><em><code>(object)</code></em><p>Pod&rsquo;s node selector. Details are <a href="https://kubernetes.io/docs/user-guide/node-selection/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="persistentvolume-accessmodes">
      <td><a href="#persistentvolume-accessmodes"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.accessModes</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="l">ReadWriteOnce</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Array of access modes. Must match those of existing PV or dynamic provisioner. Details are <a href="http://kubernetes.io/docs/user-guide/persistent-volumes/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="persistentvolume-annotations">
      <td><a href="#persistentvolume-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Persistent volume annotations</p>
</td>
    </tr>
    <tr id="persistentvolume-enabled">
      <td><a href="#persistentvolume-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create/use Persistent Volume Claim for server component. Empty dir if false</p>
</td>
    </tr>
    <tr id="persistentvolume-existingclaim">
      <td><a href="#persistentvolume-existingclaim"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.existingClaim</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Existing Claim name. If defined, PVC must be created manually before volume will be bound</p>
</td>
    </tr>
    <tr id="persistentvolume-extralabels">
      <td><a href="#persistentvolume-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Persistent volume additional labels</p>
</td>
    </tr>
    <tr id="persistentvolume-matchlabels">
      <td><a href="#persistentvolume-matchlabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.matchLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Bind Persistent Volume by labels. Must match all labels of targeted PV.</p>
</td>
    </tr>
    <tr id="persistentvolume-size">
      <td><a href="#persistentvolume-size"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.size</span><span class="p">:</span><span class="w"> </span><span class="l">10Gi</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Size of the volume. Should be calculated based on the logs you send and retention policy you set.</p>
</td>
    </tr>
    <tr id="persistentvolume-storageclassname">
      <td><a href="#persistentvolume-storageclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">persistentVolume.storageClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically</p>
</td>
    </tr>
    <tr id="podannotations">
      <td><a href="#podannotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podAnnotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Annotations to be added to pod</p>
</td>
    </tr>
    <tr id="poddisruptionbudget">
      <td><a href="#poddisruptionbudget"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podDisruptionBudget</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">labels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>See <code>kubectl explain poddisruptionbudget.spec</code> for more or check <a href="https://kubernetes.io/docs/tasks/run-application/configure-pdb/" target="_blank">official documentation</a></p>
</td>
    </tr>
    <tr id="podlabels">
      <td><a href="#podlabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Extra labels for Pods only</p>
</td>
    </tr>
    <tr id="podsecuritycontext">
      <td><a href="#podsecuritycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">podSecurityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Security context to be added to pod</p>
</td>
    </tr>
    <tr id="priorityclassname">
      <td><a href="#priorityclassname"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">priorityClassName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Priority class to be assigned to the pod(s)</p>
</td>
    </tr>
    <tr id="probe-liveness">
      <td><a href="#probe-liveness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">probe.liveness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">tcpSocket</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">timeoutSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Liveness probe</p>
</td>
    </tr>
    <tr id="probe-readiness">
      <td><a href="#probe-readiness"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">probe.readiness</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">httpGet</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">initialDelaySeconds</span><span class="p">:</span><span class="w"> </span><span class="m">5</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">periodSeconds</span><span class="p">:</span><span class="w"> </span><span class="m">15</span></span></span></code></pre>
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
    <tr id="rbac-annotations">
      <td><a href="#rbac-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Role/RoleBinding annotations</p>
</td>
    </tr>
    <tr id="rbac-create">
      <td><a href="#rbac-create"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.create</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enables Role/RoleBinding creation</p>
</td>
    </tr>
    <tr id="rbac-extralabels">
      <td><a href="#rbac-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Role/RoleBinding labels</p>
</td>
    </tr>
    <tr id="rbac-namespaced">
      <td><a href="#rbac-namespaced"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">rbac.namespaced</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>If true and <code>rbac.enabled</code>, will deploy a Role/RoleBinding instead of a ClusterRole/ClusterRoleBinding</p>
</td>
    </tr>
    <tr id="remotewrite">
      <td><a href="#remotewrite"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">remoteWrite</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Generates <code>remoteWrite.*</code> flags and config maps with value content for values, that are of type list of map. Each item should contain <code>url</code> param to pass validation.</p>
</td>
    </tr>
    <tr id="replicacount">
      <td><a href="#replicacount"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Replica count</p>
</td>
    </tr>
    <tr id="resources">
      <td><a href="#resources"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Resource object. Details are <a href="http://kubernetes.io/docs/user-guide/compute-resources/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="schedulername">
      <td><a href="#schedulername"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">schedulerName</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Use an alternate scheduler, e.g. &ldquo;stork&rdquo;. Check details <a href="https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="securitycontext">
      <td><a href="#securitycontext"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">securityContext</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Security context to be added to pod&rsquo;s containers</p>
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
    <tr id="service-enabled">
      <td><a href="#service-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable agent service</p>
</td>
    </tr>
    <tr id="service-externalips">
      <td><a href="#service-externalips"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.externalIPs</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Service external IPs. Check <a href="https://kubernetes.io/docs/user-guide/services/#external-ips" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="service-externaltrafficpolicy">
      <td><a href="#service-externaltrafficpolicy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.externalTrafficPolicy</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service external traffic policy. Check <a href="https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip" target="_blank">here</a> for details</p>
</td>
    </tr>
    <tr id="service-extralabels">
      <td><a href="#service-extralabels"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.extraLabels</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Service labels</p>
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
      <td><a href="#service-serviceport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.servicePort</span><span class="p">:</span><span class="w"> </span><span class="m">8429</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>Service port</p>
</td>
    </tr>
    <tr id="service-targetport">
      <td><a href="#service-targetport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.targetPort</span><span class="p">:</span><span class="w"> </span><span class="l">http</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Target port</p>
</td>
    </tr>
    <tr id="service-type">
      <td><a href="#service-type"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">service.type</span><span class="p">:</span><span class="w"> </span><span class="l">ClusterIP</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service type</p>
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
      <td><em><code>(bool)</code></em><p>mount API token to pod directly</p>
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
    <tr id="servicemonitor-targetport">
      <td><a href="#servicemonitor-targetport"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">serviceMonitor.targetPort</span><span class="p">:</span><span class="w"> </span><span class="l">http</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Service Monitor targetPort</p>
</td>
    </tr>
    <tr id="statefulset">
      <td><a href="#statefulset"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">statefulSet</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">clusterMode</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">replicationFactor</span><span class="p">:</span><span class="w"> </span><span class="m">1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">updateStrategy</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p><a href="https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/" target="_blank">K8s StatefulSet</a> specific variables</p>
</td>
    </tr>
    <tr id="statefulset-clustermode">
      <td><a href="#statefulset-clustermode"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">statefulSet.clusterMode</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>create cluster of vmagents. Check <a href="https://docs.victoriametrics.com/vmagent#scraping-big-number-of-targets" target="_blank">here</a> available since <a href="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/tag/v1.77.2" target="_blank">v1.77.2</a></p>
</td>
    </tr>
    <tr id="statefulset-replicationfactor">
      <td><a href="#statefulset-replicationfactor"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">statefulSet.replicationFactor</span><span class="p">:</span><span class="w"> </span><span class="m">1</span></span></span></code></pre>
</a></td>
      <td><em><code>(int)</code></em><p>replication factor for vmagent in cluster mode</p>
</td>
    </tr>
    <tr id="statefulset-spec-updatestrategy">
      <td><a href="#statefulset-spec-updatestrategy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">statefulSet.spec.updateStrategy</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>StatefulSet update strategy. Check <a href="https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies" target="_blank">here</a> for details.</p>
</td>
    </tr>
    <tr id="tolerations">
      <td><a href="#tolerations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">tolerations</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Node tolerations for server scheduling to nodes with taints. Details are <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="topologyspreadconstraints">
      <td><a href="#topologyspreadconstraints"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">topologySpreadConstraints</span><span class="p">:</span><span class="w"> </span><span class="p">[]</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Pod topologySpreadConstraints</p>
</td>
    </tr>
  </tbody>
</table>

