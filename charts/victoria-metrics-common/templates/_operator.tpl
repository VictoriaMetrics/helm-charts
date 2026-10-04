{{- /*
vm.operator.enabled returns "true" when the chart renders a VictoriaMetrics operator custom resource
instead of its own workloads (`.Values.operator.enabled`).
*/ -}}
{{- define "vm.operator.enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if (($Values).operator).enabled -}}
    true
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.cr.name returns the custom resource name. The operator prefixes it with the kind,
so the resulting objects get the same `<kind>-<name>` names the chart renders with operator naming.
*/ -}}
{{- define "vm.operator.cr.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $name := $Values.fullnameOverride | default ($Values.global).fullnameOverride | default $Release.Name -}}
  {{- $name = tpl $name . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $name -}}
  {{- else -}}
    {{- $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.cr.spec returns the custom resource spec generated from chart values (`.spec`)
with `.Values.operator.spec` deep-merged over it.
Usage:
spec: {{ include "vm.operator.cr.spec" (dict "helm" . "spec" $spec) | nindent 2 }}
*/ -}}
{{- define "vm.operator.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- toYaml (mergeOverwrite (deepCopy (.spec | default dict)) (deepCopy ((($Values.operator).spec) | default dict))) -}}
{{- end -}}

{{- /*
vm.operator.cr.labels returns the custom resource labels: the chart labels of the context with `.Values.operator.labels`.
*/ -}}
{{- define "vm.operator.cr.labels" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- include "vm.labels" (merge (dict "extraLabels" ((($Values.operator).labels) | default dict)) (omit . "extraLabels")) -}}
{{- end -}}

{{- /*
vm.operator.license returns the custom resource `license` from `.Values.license` and `.Values.global.license`,
resolved the same way as the license flag.
*/ -}}
{{- define "vm.operator.license" -}}
  {{- $key := include "vm.license.key" . -}}
  {{- $secretName := include "vm.license.secret.name" . -}}
  {{- $secretKey := include "vm.license.secret.key" . -}}
  {{- if $key -}}
    {{- toYaml (dict "key" $key) -}}
  {{- else if and $secretName $secretKey -}}
    {{- toYaml (dict "keyRef" (dict "name" $secretName "key" $secretKey)) -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.app.spec converts the pod-level values of a chart component (`.app`) into the fields
shared by the operator custom resources: image, scheduling, resources, env, volumes, pod metadata,
security context, extra args, service account and license.
Usage:
{{ include "vm.operator.app.spec" (dict "helm" . "appKey" "server" "app" .Values.server) }}
*/ -}}
{{- define "vm.operator.app.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := .app | default dict -}}
  {{- $spec := dict -}}
  {{- $image := (fromYaml (include "vm.internal.image" .)).image | default dict -}}
  {{- $repository := $image.repository -}}
  {{- with $image.registry -}}
    {{- $repository = printf "%s/%s" . $repository -}}
  {{- end -}}
  {{- $_ := set $spec "image" (dict "repository" (tpl $repository .) "tag" (include "vm.image.tag" .)) -}}
  {{- with $image.pullPolicy -}}
    {{- $_ := set $spec.image "pullPolicy" . -}}
  {{- end -}}
  {{- with ($app.imagePullSecrets | default ($Values.global).imagePullSecrets) -}}
    {{- $_ := set $spec "imagePullSecrets" . -}}
  {{- end -}}
  {{- if hasKey $app "replicaCount" -}}
    {{- $_ := set $spec "replicaCount" $app.replicaCount -}}
  {{- end -}}
  {{- range $key := list "resources" "affinity" "tolerations" "nodeSelector" "topologySpreadConstraints" "priorityClassName" "schedulerName" "runtimeClassName" "dnsConfig" "dnsPolicy" "hostAliases" "hostNetwork" "terminationGracePeriodSeconds" "minReadySeconds" "initContainers" -}}
    {{- with index $app $key -}}
      {{- $_ := set $spec $key . -}}
    {{- end -}}
  {{- end -}}
  {{- with $app.extraContainers -}}
    {{- $_ := set $spec "containers" . -}}
  {{- end -}}
  {{- with $app.env -}}
    {{- $_ := set $spec "extraEnvs" . -}}
  {{- end -}}
  {{- with $app.envFrom -}}
    {{- $_ := set $spec "extraEnvsFrom" . -}}
  {{- end -}}
  {{- $volumes := concat ($app.extraVolumes | default list) list -}}
  {{- $mounts := concat ($app.extraVolumeMounts | default list) list -}}
  {{- range $app.extraHostPathMounts -}}
    {{- $volumes = append $volumes (dict "name" .name "hostPath" (dict "path" .hostPath)) -}}
    {{- $mount := dict "name" .name "mountPath" .mountPath -}}
    {{- with .subPath -}}
      {{- $_ := set $mount "subPath" . -}}
    {{- end -}}
    {{- with .readOnly -}}
      {{- $_ := set $mount "readOnly" . -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
  {{- range $app.extraSecretMounts -}}
    {{- $volumes = append $volumes (dict "name" .name "secret" (dict "secretName" .secretName)) -}}
    {{- $mount := dict "name" .name "mountPath" .mountPath -}}
    {{- with .subPath -}}
      {{- $_ := set $mount "subPath" . -}}
    {{- end -}}
    {{- with .readOnly -}}
      {{- $_ := set $mount "readOnly" . -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
  {{- with $volumes -}}
    {{- $_ := set $spec "volumes" . -}}
  {{- end -}}
  {{- with $mounts -}}
    {{- $_ := set $spec "volumeMounts" . -}}
  {{- end -}}
  {{- $podMetadata := dict -}}
  {{- with $app.podLabels -}}
    {{- $_ := set $podMetadata "labels" . -}}
  {{- end -}}
  {{- with $app.podAnnotations -}}
    {{- $_ := set $podMetadata "annotations" . -}}
  {{- end -}}
  {{- with $podMetadata -}}
    {{- $_ := set $spec "podMetadata" . -}}
  {{- end -}}
  {{- $securityContext := dict -}}
  {{- if ($app.podSecurityContext).enabled -}}
    {{- $securityContext = mergeOverwrite $securityContext (fromYaml (include "vm.securityContext" (dict "securityContext" $app.podSecurityContext "helm" .helm))) -}}
  {{- end -}}
  {{- if ($app.securityContext).enabled -}}
    {{- $securityContext = mergeOverwrite $securityContext (fromYaml (include "vm.securityContext" (dict "securityContext" $app.securityContext "helm" .helm))) -}}
  {{- end -}}
  {{- with $securityContext -}}
    {{- $_ := set $spec "securityContext" . -}}
  {{- end -}}
  {{- $extraArgs := dict -}}
  {{- range $k, $v := ($app.extraArgs | default dict) -}}
    {{- $_ := set $extraArgs $k (ternary (join "," $v) (toString $v) (kindIs "slice" $v)) -}}
  {{- end -}}
  {{- with $extraArgs -}}
    {{- $_ := set $spec "extraArgs" . -}}
  {{- end -}}
  {{- $sa := $Values.serviceAccount | default dict -}}
  {{- if $sa.name -}}
    {{- $_ := set $spec "serviceAccountName" (tpl $sa.name .helm) -}}
  {{- else if and (hasKey $sa "create") (not $sa.create) -}}
    {{- $_ := set $spec "serviceAccountName" "default" -}}
  {{- end -}}
  {{- if and (hasKey $sa "automountToken") (not $sa.automountToken) -}}
    {{- $_ := set $spec "disableAutomountServiceAccountToken" true -}}
  {{- end -}}
  {{- with (include "vm.operator.license" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.service.spec converts a chart Service config into the `serviceSpec` of a custom resource,
applied to the Service the operator creates. Returns nothing for a plain ClusterIP Service.
*/ -}}
{{- define "vm.operator.service.spec" -}}
  {{- $service := .service | default dict -}}
  {{- $spec := dict -}}
  {{- with $service.type -}}
    {{- if ne . "ClusterIP" -}}
      {{- $_ := set $spec "type" . -}}
    {{- end -}}
  {{- end -}}
  {{- range $key := list "externalIPs" "loadBalancerIP" "loadBalancerSourceRanges" "externalTrafficPolicy" "healthCheckNodePort" "ipFamilyPolicy" "ipFamilies" "trafficDistribution" -}}
    {{- with index $service $key -}}
      {{- $_ := set $spec $key . -}}
    {{- end -}}
  {{- end -}}
  {{- $metadata := dict -}}
  {{- with $service.labels -}}
    {{- $_ := set $metadata "labels" . -}}
  {{- end -}}
  {{- with $service.annotations -}}
    {{- $_ := set $metadata "annotations" . -}}
  {{- end -}}
  {{- if or $spec $metadata -}}
    {{- toYaml (dict "useAsDefault" true "metadata" $metadata "spec" $spec) -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.storage converts a chart persistentVolume config into a PersistentVolumeClaim spec.
*/ -}}
{{- define "vm.operator.storage" -}}
  {{- $pvc := .persistentVolume | default dict -}}
  {{- $spec := dict "resources" (dict "requests" (dict "storage" $pvc.size)) -}}
  {{- with $pvc.accessModes -}}
    {{- $_ := set $spec "accessModes" . -}}
  {{- end -}}
  {{- with $pvc.storageClassName -}}
    {{- $_ := set $spec "storageClassName" . -}}
  {{- end -}}
  {{- with $pvc.volumeAttributesClassName -}}
    {{- $_ := set $spec "volumeAttributesClassName" . -}}
  {{- end -}}
  {{- with $pvc.matchLabels -}}
    {{- $_ := set $spec "selector" (dict "matchLabels" .) -}}
  {{- end -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.tls.config converts a Prometheus tls_config into a VMScrapeConfig tlsConfig.
*/ -}}
{{- define "vm.operator.tls.config" -}}
  {{- $tls := dict -}}
  {{- range $from, $to := dict "ca_file" "caFile" "cert_file" "certFile" "key_file" "keyFile" "server_name" "serverName" "insecure_skip_verify" "insecureSkipVerify" -}}
    {{- if hasKey $.tls $from -}}
      {{- $_ := set $tls $to (index $.tls $from) -}}
    {{- end -}}
  {{- end -}}
  {{- range $key := keys .tls -}}
    {{- if not (has $key (list "ca_file" "cert_file" "key_file" "server_name" "insecure_skip_verify")) -}}
      {{- fail (printf "scrape job %q: `%s.%s` can't be converted to a VMScrapeConfig" $.job $.path $key) -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $tls -}}
{{- end -}}

{{- /*
vm.operator.relabel.configs normalizes Prometheus relabel rules for operator resources:
scalar `regex` and `replacement` values, such as `regex: true`, become strings.
*/ -}}
{{- define "vm.operator.relabel.configs" -}}
  {{- $rules := list -}}
  {{- range .rules -}}
    {{- $rule := deepCopy . -}}
    {{- range $key := list "regex" "replacement" -}}
      {{- if and (hasKey $rule $key) (not (kindIs "slice" (index $rule $key))) -}}
        {{- $_ := set $rule $key (toString (index $rule $key)) -}}
      {{- end -}}
    {{- end -}}
    {{- $rules = append $rules $rule -}}
  {{- end -}}
  {{- toYaml $rules -}}
{{- end -}}

{{- /*
vm.operator.scrape.spec converts a Prometheus-compatible scrape config job (`.job`) into a VMScrapeConfig spec.
A `job` label equal to `job_name` is set first, as Prometheus does, so relabeling and dashboards keep working.
Settings without a VMScrapeConfig equivalent, such as inline credentials, fail the rendering.
*/ -}}
{{- define "vm.operator.scrape.spec" -}}
  {{- $job := .job -}}
  {{- $name := required "scrape job must have `job_name`" $job.job_name -}}
  {{- $spec := dict -}}
  {{- $rename := dict
    "scrape_interval" "interval" "scrape_timeout" "scrapeTimeout" "metrics_path" "path" "scheme" "scheme"
    "params" "params" "honor_labels" "honorLabels" "honor_timestamps" "honorTimestamps"
    "follow_redirects" "follow_redirects" "sample_limit" "sampleLimit" "series_limit" "seriesLimit"
    "max_scrape_size" "max_scrape_size" "proxy_url" "proxyURL" "bearer_token_file" "bearerTokenFile"
    "static_configs" "staticConfigs"
    "file_sd_configs" "fileSDConfigs" "dns_sd_configs" "dnsSDConfigs"
  -}}
  {{- $vmParams := list "scrape_align_interval" "scrape_offset" "disable_compression" "disable_keepalive" "stream_parse" "headers" "no_stale_markers" -}}
  {{- range $key, $value := $job -}}
    {{- if eq $key "job_name" -}}
    {{- else if hasKey $rename $key -}}
      {{- $_ := set $spec (index $rename $key) $value -}}
    {{- else if has $key $vmParams -}}
      {{- $params := $spec.vm_scrape_params | default dict -}}
      {{- $_ := set $params (ternary "disable_keep_alive" $key (eq $key "disable_keepalive")) $value -}}
      {{- $_ := set $spec "vm_scrape_params" $params -}}
    {{- else if eq $key "metric_relabel_configs" -}}
      {{- $_ := set $spec "metricRelabelConfigs" (fromYamlArray (include "vm.operator.relabel.configs" (dict "rules" $value))) -}}
    {{- else if eq $key "relabel_configs" -}}
    {{- else if eq $key "tls_config" -}}
      {{- $_ := set $spec "tlsConfig" (fromYaml (include "vm.operator.tls.config" (dict "tls" $value "job" $name "path" $key))) -}}
    {{- else if eq $key "authorization" -}}
      {{- if $value.credentials -}}
        {{- fail (printf "scrape job %q: inline `authorization.credentials` can't be converted to a VMScrapeConfig, use `credentials_file`" $name) -}}
      {{- end -}}
      {{- $auth := dict -}}
      {{- with $value.type -}}
        {{- $_ := set $auth "type" . -}}
      {{- end -}}
      {{- with $value.credentials_file -}}
        {{- $_ := set $auth "credentialsFile" . -}}
      {{- end -}}
      {{- $_ := set $spec "authorization" $auth -}}
    {{- else if eq $key "http_sd_configs" -}}
      {{- $configs := list -}}
      {{- range $value -}}
        {{- if gt (len (omit . "url")) 0 -}}
          {{- fail (printf "scrape job %q: only `url` of `http_sd_configs` can be converted to a VMScrapeConfig" $name) -}}
        {{- end -}}
        {{- $configs = append $configs (dict "url" .url) -}}
      {{- end -}}
      {{- $_ := set $spec "httpSDConfigs" $configs -}}
    {{- else if eq $key "kubernetes_sd_configs" -}}
      {{- $configs := list -}}
      {{- range $value -}}
        {{- $sd := dict -}}
        {{- range $k, $v := . -}}
          {{- if has $k (list "role" "selectors" "attach_metadata") -}}
            {{- $_ := set $sd $k $v -}}
          {{- else if eq $k "api_server" -}}
            {{- $_ := set $sd "apiServer" $v -}}
          {{- else if eq $k "namespaces" -}}
            {{- $namespaces := dict -}}
            {{- with $v.names -}}
              {{- $_ := set $namespaces "names" . -}}
            {{- end -}}
            {{- if hasKey $v "own_namespace" -}}
              {{- $_ := set $namespaces "ownNamespace" $v.own_namespace -}}
            {{- end -}}
            {{- $_ := set $sd "namespaces" $namespaces -}}
          {{- else if eq $k "tls_config" -}}
            {{- $_ := set $sd "tlsConfig" (fromYaml (include "vm.operator.tls.config" (dict "tls" $v "job" $name "path" "kubernetes_sd_configs.tls_config"))) -}}
          {{- else -}}
            {{- fail (printf "scrape job %q: `kubernetes_sd_configs.%s` can't be converted to a VMScrapeConfig" $name $k) -}}
          {{- end -}}
        {{- end -}}
        {{- $configs = append $configs $sd -}}
      {{- end -}}
      {{- $_ := set $spec "kubernetesSDConfigs" $configs -}}
    {{- else -}}
      {{- fail (printf "scrape job %q: `%s` can't be converted to a VMScrapeConfig, configure it in a VMScrapeConfig resource instead" $name $key) -}}
    {{- end -}}
  {{- end -}}
  {{- $relabel := list (dict "action" "replace" "target_label" "job" "replacement" $name) -}}
  {{- $_ := set $spec "relabelConfigs" (concat $relabel (fromYamlArray (include "vm.operator.relabel.configs" (dict "rules" ($job.relabel_configs | default list))))) -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.scrape.configs renders a VMScrapeConfig per job of `.jobs`, labeled with `.selectorLabels`
so that the owning custom resource selects them with scrapeConfigSelector.
*/ -}}
{{- define "vm.operator.scrape.configs" -}}
  {{- $owner := include "vm.operator.cr.name" . -}}
  {{- $names := list -}}
  {{- range $job := .jobs -}}
    {{- $spec := fromYaml (include "vm.operator.scrape.spec" (dict "job" $job)) -}}
    {{- $name := printf "%s-%s" $owner (regexReplaceAll "[^a-z0-9-]+" (lower $job.job_name) "-") | trunc 63 | trimAll "-" -}}
    {{- if has $name $names -}}
      {{- fail (printf "scrape jobs produce a duplicate VMScrapeConfig name %q" $name) -}}
    {{- end -}}
    {{- $names = append $names $name }}
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMScrapeConfig
metadata:
  name: {{ $name }}
  namespace: {{ include "vm.namespace" $ }}
  labels: {{ include "vm.labels" (merge (dict "extraLabels" $.selectorLabels) (omit $ "jobs" "selectorLabels")) | nindent 4 }}
spec: {{ toYaml $spec | nindent 2 }}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.data.volume mounts the chart-managed claim (or `existingClaim`) of `.persistentVolume`
as the `data` volume of a custom resource at `mountPath`, so that switching to the operator keeps the data.
`.claim` is the name of the chart-managed claim.
*/ -}}
{{- define "vm.operator.data.volume" -}}
  {{- $pvc := .persistentVolume -}}
  {{- $claim := $pvc.existingClaim | default $pvc.name | default .claim -}}
  {{- $spec := dict "storageDataPath" $pvc.mountPath -}}
  {{- $_ := set $spec "volumes" (append (.volumes | default list) (dict "name" "data" "persistentVolumeClaim" (dict "claimName" (tpl $claim .helm)))) -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.self.scrape converts a chart VMServiceScrape toggle (`.scrape`, configured at `.path`) into the
self-scrape setting of a custom resource. The operator creates the VMServiceScrape itself, under the name the chart would use.
*/ -}}
{{- define "vm.operator.self.scrape" -}}
  {{- $scrape := .scrape | default dict -}}
  {{- if not $scrape.enabled -}}
    {{- toYaml (dict "disableSelfServiceScrape" true) -}}
  {{- else -}}
    {{- range $key := list "relabelings" "metricRelabelings" "port" "targetPort" "path" "interval" "scrapeTimeout" "scheme" "basicAuth" "tlsConfig" -}}
      {{- if index $scrape $key -}}
        {{- fail (printf "`%s.%s` is not converted with `operator.enabled: true`; set `operator.spec.serviceScrapeSpec` instead" $.path $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.syslog.spec converts chart syslog listeners (`.syslog` with `tcp` and `udp` lists) into a syslogSpec.
*/ -}}
{{- define "vm.operator.syslog.spec" -}}
  {{- $spec := dict -}}
  {{- range $kind, $listeners := .syslog -}}
    {{- $items := list -}}
    {{- range $i, $l := $listeners -}}
      {{- $item := dict "listenPort" (int (include "vm.port.from.flag" (dict "flag" (required (printf "`value` is not set for `syslog.%s` idx %d" $kind $i) $l.value)))) -}}
      {{- range $key := list "streamFields" "ignoreFields" "decolorizeFields" "tenantID" "compressMethod" -}}
        {{- with index $l $key -}}
          {{- $_ := set $item $key (toString .) -}}
        {{- end -}}
      {{- end -}}
      {{- if and $l.tls (eq $kind "tcp") -}}
        {{- $tls := dict -}}
        {{- range $from, $to := dict "tlsCertFile" "certFile" "tlsKeyFile" "keyFile" "tlsMinVersion" "minVersion" -}}
          {{- with index $l $from -}}
            {{- $_ := set $tls $to . -}}
          {{- end -}}
        {{- end -}}
        {{- $_ := set $item "tlsConfig" $tls -}}
      {{- end -}}
      {{- range $key, $value := omit $l "name" "value" "tls" "tlsCertFile" "tlsKeyFile" "tlsMinVersion" "streamFields" "ignoreFields" "decolorizeFields" "tenantID" "compressMethod" -}}
        {{- if $value -}}
          {{- fail (printf "`syslog.%s[%d].%s` is not converted with `operator.enabled: true`; set `operator.spec.syslogSpec` instead" $kind $i $key) -}}
        {{- end -}}
      {{- end -}}
      {{- $items = append $items $item -}}
    {{- end -}}
    {{- with $items -}}
      {{- $_ := set $spec (printf "%sListeners" $kind) . -}}
    {{- end -}}
  {{- end -}}
  {{- with $spec -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.remote.write converts chart remoteWrite entries (flag suffixes keyed by name, `.items`) into
operator remoteWrite specs. Credentials must be Secret references in operator resources, so inline
credentials fail the rendering, as does any setting without an operator field. `.supported` limits
the remoteWrite fields of the target resource, `.defaultPath` is appended to a native-format URL without a path.
*/ -}}
{{- define "vm.operator.remote.write" -}}
  {{- $items := list -}}
  {{- range $i, $rw := .items -}}
    {{- $url := required (printf "`url` is not set for `remoteWrite` idx %d" $i) $rw.url -}}
    {{- if $.defaultPath -}}
      {{- $parsed := urlParse $url -}}
      {{- if and (empty (trimPrefix "/" $parsed.path)) (or (empty $rw.format) (eq $rw.format "native")) -}}
        {{- $_ := set $parsed "path" $.defaultPath -}}
        {{- $url = urlJoin $parsed -}}
      {{- end -}}
    {{- end -}}
    {{- $item := dict "url" $url -}}
    {{- $tls := dict -}}
    {{- $aggr := dict -}}
    {{- range $key, $value := omit $rw "url" -}}
      {{- if eq $key "bearerTokenFile" -}}
        {{- $_ := set $item "bearerTokenPath" $value -}}
      {{- else if has $key (list "sendTimeout" "proxyURL" "forceVMProto") -}}
        {{- $_ := set $item $key $value -}}
      {{- else if has $key (list "maxDiskUsagePerURL" "maxDiskUsage") -}}
        {{- $_ := set $item "maxDiskUsage" (toString $value) -}}
      {{- else if eq $key "headers" -}}
        {{- $headers := list -}}
        {{- if kindIs "map" $value -}}
          {{- range $hk, $hv := $value -}}
            {{- $vs := toString $hv -}}
            {{- if kindIs "slice" $hv -}}
              {{- $vs = join "," $hv -}}
            {{- else if kindIs "map" $hv -}}
              {{- $pairs := list -}}
              {{- range $k, $v := $hv -}}
                {{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
              {{- end -}}
              {{- $vs = join "," $pairs -}}
            {{- end -}}
            {{- $headers = append $headers (printf "%s:%s" $hk $vs) -}}
          {{- end -}}
        {{- else -}}
          {{- $headers = ternary $value (splitList "^^" (toString $value)) (kindIs "slice" $value) -}}
        {{- end -}}
        {{- $_ := set $item "headers" $headers -}}
      {{- else if eq $key "format" -}}
        {{- $_ := set $item "format" $value -}}
      {{- else if eq $key "urlRelabelConfig" -}}
        {{- $_ := set $item "inlineUrlRelabelConfig" (fromYamlArray (include "vm.operator.relabel.configs" (dict "rules" $value))) -}}
      {{- else if hasKey (dict "tlsCAFile" 1 "tlsCertFile" 1 "tlsKeyFile" 1 "tlsServerName" 1 "tlsInsecureSkipVerify" 1) $key -}}
        {{- $_ := set $tls (get (dict "tlsCAFile" "caFile" "tlsCertFile" "certFile" "tlsKeyFile" "keyFile" "tlsServerName" "serverName" "tlsInsecureSkipVerify" "insecureSkipVerify") $key) $value -}}
      {{- else if eq $key "streamAggr.config" -}}
        {{- $_ := set $aggr "rules" $value -}}
      {{- else if hasPrefix "streamAggr." $key -}}
        {{- $_ := set $aggr (trimPrefix "streamAggr." $key) $value -}}
      {{- else if not (kindIs "invalid" $value) -}}
        {{- fail (printf "`remoteWrite[%d].%s` is not converted with `operator.enabled: true`; set `operator.spec.remoteWrite` instead (credentials must reference Secrets)" $i $key) -}}
      {{- end -}}
    {{- end -}}
    {{- with $tls -}}
      {{- $_ := set $item "tlsConfig" . -}}
    {{- end -}}
    {{- with $aggr -}}
      {{- $_ := set $item "streamAggrConfig" . -}}
    {{- end -}}
    {{- with $.supported -}}
      {{- range $field := keys $item -}}
        {{- if not (has $field $.supported) -}}
          {{- fail (printf "`remoteWrite[%d]`: `%s` is not supported by the operator resource; set `operator.spec.remoteWrite` instead" $i $field) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- $items = append $items $item -}}
  {{- end -}}
  {{- toYaml $items -}}
{{- end -}}

{{- /*
vm.operator.scrape converts a Prometheus-compatible scrape config (`.config`, at `.path`) and extra jobs (`.extra`)
into custom resource fields: `global` settings become spec fields and the jobs `.jobs` for vm.operator.scrape.configs.
Returns a dict with `spec` and `jobs`.
*/ -}}
{{- define "vm.operator.scrape" -}}
  {{- $config := .config | default dict -}}
  {{- $spec := dict -}}
  {{- range $key, $value := ($config.global | default dict) -}}
    {{- if eq $key "scrape_interval" -}}
      {{- $_ := set $spec "scrapeInterval" $value -}}
    {{- else if eq $key "scrape_timeout" -}}
      {{- $_ := set $spec "scrapeTimeout" $value -}}
    {{- else if eq $key "external_labels" -}}
      {{- $_ := set $spec "externalLabels" $value -}}
    {{- else -}}
      {{- fail (printf "`%s.global.%s` is not converted with `operator.enabled: true`; set it in `operator.spec`" $.path $key) -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (dict "spec" $spec "jobs" (concat ($config.scrape_configs | default list) (.extra | default list))) -}}
{{- end -}}

{{- /*
vm.operator.http.endpoint converts a chart endpoint config with flag-style keys (`.endpoint`, configured at `.path`)
into an operator endpoint spec: url, headers, TLS and bearer token file. Keys listed in `.passthrough` are copied as is.
Inline credentials fail the rendering, since operator resources reference Secrets.
*/ -}}
{{- define "vm.operator.http.endpoint" -}}
  {{- $spec := dict -}}
  {{- $tls := dict -}}
  {{- $tlsKeys := dict "tlsCAFile" "caFile" "tlsCertFile" "certFile" "tlsKeyFile" "keyFile" "tlsServerName" "serverName" "tlsInsecureSkipVerify" "insecureSkipVerify" -}}
  {{- range $key, $value := .endpoint -}}
    {{- if or (kindIs "invalid" $value) (and (kindIs "string" $value) (empty $value)) (and (kindIs "map" $value) (empty $value)) -}}
    {{- else if eq $key "url" -}}
      {{- $_ := set $spec "url" $value -}}
    {{- else if eq $key "bearerTokenFile" -}}
      {{- $_ := set $spec "bearerTokenFile" $value -}}
    {{- else if eq $key "headers" -}}
      {{- $headers := list -}}
      {{- if kindIs "map" $value -}}
        {{- range $hk, $hv := $value -}}
          {{- $headers = append $headers (printf "%s:%s" $hk (toString $hv)) -}}
        {{- end -}}
      {{- else -}}
        {{- $headers = ternary $value (splitList "^^" (toString $value)) (kindIs "slice" $value) -}}
      {{- end -}}
      {{- $_ := set $spec "headers" $headers -}}
    {{- else if hasKey $tlsKeys $key -}}
      {{- $_ := set $tls (get $tlsKeys $key) $value -}}
    {{- else if has $key ($.passthrough | default list) -}}
      {{- $_ := set $spec $key $value -}}
    {{- else -}}
      {{- fail (printf "`%s.%s` is not converted with `operator.enabled: true`; set it in `operator.spec` instead (credentials must reference Secrets)" $.path $key) -}}
    {{- end -}}
  {{- end -}}
  {{- with $tls -}}
    {{- $_ := set $spec "tlsConfig" . -}}
  {{- end -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.cluster.component converts the values of a cluster chart component (`.app`, at `.appKey`)
into a component spec of a cluster custom resource: the shared pod-level fields, HTTP listen port,
Service settings, PodDisruptionBudget, HPA and VPA. Service account, license and image pull secrets
belong to the cluster resource itself and are left out.
*/ -}}
{{- define "vm.operator.cluster.component" -}}
  {{- $app := .app -}}
  {{- $spec := omit (fromYaml (include "vm.operator.app.spec" .)) "serviceAccountName" "disableAutomountServiceAccountToken" "license" "imagePullSecrets" -}}
  {{- $extraArgs := $spec.extraArgs | default dict -}}
  {{- $addr := $extraArgs.httpListenAddr | default (include "vm.addr.primary" $app.http) -}}
  {{- $_ := unset $extraArgs "httpListenAddr" -}}
  {{- range $flag, $value := fromYaml (include "vm.http.args" $app.http) -}}
    {{- if ne $flag "httpListenAddr" -}}
      {{- $_ := set $extraArgs $flag (toString $value) -}}
    {{- end -}}
  {{- end -}}
  {{- if $extraArgs -}}
    {{- $_ := set $spec "extraArgs" $extraArgs -}}
  {{- else -}}
    {{- $_ := unset $spec "extraArgs" -}}
  {{- end -}}
  {{- $_ := set $spec "port" (include "vm.port.from.flag" (dict "flag" $addr)) -}}
  {{- with (include "vm.operator.service.spec" (dict "service" $app.service)) -}}
    {{- $_ := set $spec "serviceSpec" (fromYaml .) -}}
  {{- end -}}
  {{- $pdb := $app.podDisruptionBudget | default dict -}}
  {{- if $pdb.enabled -}}
    {{- $budget := dict -}}
    {{- range $key := list "minAvailable" "maxUnavailable" "unhealthyPodEvictionPolicy" -}}
      {{- with index $pdb $key -}}
        {{- $_ := set $budget $key . -}}
      {{- end -}}
    {{- end -}}
    {{- $_ := set $spec "podDisruptionBudget" $budget -}}
  {{- end -}}
  {{- $hpa := $app.horizontalPodAutoscaler | default dict -}}
  {{- if $hpa.enabled -}}
    {{- $_ := set $spec "hpa" (omit $hpa "enabled" "behavior") -}}
    {{- with $hpa.behavior -}}
      {{- $_ := set $spec.hpa "behaviour" . -}}
    {{- end -}}
  {{- end -}}
  {{- $vpa := $app.verticalPodAutoscaler | default dict -}}
  {{- if $vpa.enabled -}}
    {{- $_ := set $spec "vpa" (omit $vpa "enabled") -}}
  {{- end -}}
  {{- $spec = mergeOverwrite $spec (fromYaml (include "vm.operator.network.policy" (dict "networkPolicy" $app.networkPolicy "path" (printf "%s.networkPolicy" .appKey)))) -}}
  {{- with $app.strategy -}}
    {{- with .type -}}
      {{- $_ := set $spec "updateStrategy" . -}}
    {{- end -}}
    {{- with .rollingUpdate -}}
      {{- $_ := set $spec "rollingUpdate" . -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /*
vm.operator.backup converts chart vmbackupmanager values (`.manager`, image resolved at `.appKey`) into a vmBackup spec.
*/ -}}
{{- define "vm.operator.backup" -}}
  {{- $manager := .manager -}}
  {{- $backup := dict "destination" $manager.destination -}}
  {{- range $key := list "disableHourly" "disableDaily" "disableWeekly" "disableMonthly" -}}
    {{- if index $manager $key -}}
      {{- $_ := set $backup $key true -}}
    {{- end -}}
  {{- end -}}
  {{- $image := (fromYaml (include "vm.internal.image" .)).image -}}
  {{- $repository := $image.repository -}}
  {{- with $image.registry -}}
    {{- $repository = printf "%s/%s" . $repository -}}
  {{- end -}}
  {{- $_ := set $backup "image" (dict "repository" $repository "tag" (include "vm.image.tag" .)) -}}
  {{- $args := dict -}}
  {{- range $key, $value := ($manager.retention | default dict) -}}
    {{- $_ := set $args $key (toString $value) -}}
  {{- end -}}
  {{- range $key, $value := ($manager.extraArgs | default dict) -}}
    {{- $_ := set $args $key (toString $value) -}}
  {{- end -}}
  {{- with $args -}}
    {{- $_ := set $backup "extraArgs" . -}}
  {{- end -}}
  {{- with $manager.resources -}}
    {{- $_ := set $backup "resources" . -}}
  {{- end -}}
  {{- with $manager.env -}}
    {{- $_ := set $backup "extraEnvs" . -}}
  {{- end -}}
  {{- with $manager.extraVolumeMounts -}}
    {{- $_ := set $backup "volumeMounts" . -}}
  {{- end -}}
  {{- if (($manager.restore).onStart).enabled -}}
    {{- $_ := set $backup "restore" (dict "onStart" (dict "enabled" true)) -}}
  {{- end -}}
  {{- toYaml $backup -}}
{{- end -}}

{{- /*
vm.operator.network.policy converts a chart networkPolicy config (`.networkPolicy`, at `.path`) into the
`networkPolicy` field of a custom resource. The operator creates the NetworkPolicy with the resource selector.
*/ -}}
{{- define "vm.operator.network.policy" -}}
  {{- $np := .networkPolicy | default dict -}}
  {{- if $np.enabled -}}
    {{- range $key := list "labels" "annotations" "extraLabels" -}}
      {{- if index $np $key -}}
        {{- fail (printf "`%s.%s` is not converted with `operator.enabled: true`; the operator-managed NetworkPolicy has no custom metadata" $.path $key) -}}
      {{- end -}}
    {{- end -}}
    {{- $policy := dict -}}
    {{- with $np.ingress -}}
      {{- $_ := set $policy "ingress" . -}}
    {{- end -}}
    {{- with $np.egress -}}
      {{- $_ := set $policy "egress" . -}}
    {{- end -}}
    {{- toYaml (dict "networkPolicy" $policy) -}}
  {{- end -}}
{{- end -}}

