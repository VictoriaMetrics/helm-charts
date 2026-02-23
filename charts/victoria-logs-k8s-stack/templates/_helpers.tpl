{{- define "vl.read.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vlsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vlsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vlcluster.enabled $Values.vlcluster.spec.vlselect.enabled -}}
    {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlselect") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" $baseURL -}}
  {{- else if $Values.external.vl.read.url -}}
    {{- $_ := set $endpoint "url" ((($Values.external).vl).read).url -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end }}

{{- define "vl.write.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vlsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vlsingle" "spec") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/native" $baseURL) -}}
  {{- else if and $Values.vlcluster.enabled $Values.vlcluster.spec.vlinsert.enabled -}}
    {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlinsert") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/native" $baseURL) -}}
  {{- else if $Values.external.vl.write.url -}}
    {{- $endpoint = $Values.external.vl.write -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $remotes := dict -}}
  {{- $fullname := include "vm.managed.fullname" . -}}
  {{- $_ := set $ctx "style" "managed" -}}

  {{- $remoteRead := (($Values.vmalert).spec).remoteRead | default dict -}}
  {{- if ((($Values.external).vm).read).url -}}
    {{- $_ := set $remoteRead "url" $Values.external.vm.read.url -}}
  {{- end -}}
  {{- with $remoteRead -}}
    {{- $_ := set $remotes "remoteRead" . -}}
  {{- end }}

  {{- $remoteWrite := (($Values.vmalert).spec).remoteWrite | default dict -}}
  {{- if ((($Values.external).vm).write).url -}}
    {{- $_ := set $remoteWrite "url" $Values.external.vm.write.url -}}
  {{- end -}}
  {{- with $remoteWrite -}}
    {{- $_ := set $remotes "remoteWrite" . -}}
  {{- end -}}

  {{- $datasource := (($Values.vmalert).spec).datasource | default dict -}}
  {{- $ds := fromYaml (include "vl.read.endpoint" $ctx) -}}
  {{- if $ds.url }}
    {{- $_ := set $datasource "url" $ds.url -}}
  {{- else if (not $datasource.url) -}}
    {{- fail "VL datasource required! Either set `vmalert.enabled: false` or provide `vmalert.spec.datasource.url`" -}}
  {{- end -}}
  {{- $_ := set $remotes "datasource" $datasource -}}

  {{- if $Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := printf "%s-additional-notifier" $fullname -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if $Values.vmalertmanager.enabled -}}
    {{- $notifiers := list -}}
    {{- $appSecure := not (empty ((($Values.vmalertmanager).spec).webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appKey" (list "vmalertmanager" "spec") -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" (($Values.vmalertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := $Values.vmalertmanager.spec.replicaCount | default 1 | int -}}
    {{- range until $alertManagerReplicas -}}
      {{- $_ := set $ctx "appIdx" . -}}
      {{- $notifiers = append $notifiers (dict "url" (include "vm.url" $ctx)) -}}
      {{- $_ := unset $ctx "appIdx" -}}
    {{- end }}
    {{- $_ := set $remotes "notifiers" $notifiers -}}
  {{- end -}}
  {{- toYaml $remotes -}}
{{- end -}}

{{- /* VMAlert templates */ -}}
{{- define "vm.alert.templates" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $cms :=  ($Values.vmalert.spec.configMaps | default list) -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $fullname := include "vm.managed.fullname" . -}}
    {{- $cms = append $cms (printf "%s-extra-tpl" $fullname) -}}
  {{- end -}}
  {{- $output := dict "configMaps" (compact $cms) -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vm.license.global" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $license := (deepCopy ($Values.global).license) | default dict -}}
  {{- if $license.key -}}
    {{- if hasKey $license "keyRef" -}}
      {{- $_ := unset $license "keyRef" -}}
    {{- end -}}
  {{- else if $license.keyRef.name -}}
    {{- if hasKey $license "key" -}}
      {{- $_ := unset $license "key" -}}
    {{- end -}}
  {{- else -}}
    {{- $license = dict -}}
  {{- end -}}
  {{- toYaml $license -}}
{{- end -}}

{{- /* VMAlert spec */ -}}
{{- define "vm.alert.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $extraArgs := dict "remoteWrite.disablePathAppend" "true" -}}
  {{- $fullname := include "vm.managed.fullname" . }}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $ruleTmpl := printf "/etc/vm/configs/%s-extra-tpl/*.tmpl" $fullname -}}
    {{- $_ := set $extraArgs "rule.templates" $ruleTmpl -}}
  {{- end -}}
  {{- $vmAlertTemplates := include "vm.alert.templates" . | fromYaml -}}
  {{- $vmAlertRemotes := include "vm.alert.remotes" . | fromYaml -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- with concat ($vmAlertRemotes.notifiers | default list) ($Values.vmalert.spec.notifiers | default list) }}
    {{- $_ := set $vmAlertRemotes "notifiers" . }}
  {{- end }}
  {{- $spec := deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec }}
  {{- if not (or (hasKey $spec "notifier") (hasKey $spec "notifiers") (hasKey $spec "notifierConfigRef") (hasKey $spec.extraArgs "notifier.blackhole")) }}
    {{- fail "Neither `notifier`, `notifiers` nor `notifierConfigRef` is set for vmalert. If it's intentionally please consider setting `.vmalert.spec.extraArgs.['notifier.blackhole']` to `'true'`"}}
  {{- end }}
  {{- $output := deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec -}}
  {{- if or $Values.grafana.enabled $Values.external.grafana.host }}
    {{- if not (index $output.extraArgs "external.alert.source") -}}
      {{- $alertSourceTpl := `{"datasource":%q,"queries":[{"expr":{{"{{"}} .Expr|jsonEscape|queryEscape {{"}}"}},"refId":"A"}],"range":{"from":"{{"{{"}} .ActiveAt.UnixMilli {{"}}"}}","to":"now"}}` -}}
      {{- $alertSource := "" -}}
      {{- if $Values.external.grafana.host -}}
        {{- $alertSource = printf $alertSourceTpl $Values.external.grafana.datasource -}}
      {{- else -}}
        {{- $alertSource = printf $alertSourceTpl (index $Values.defaultDatasources.victoriametrics.datasources 0 "name") -}}
      {{- end -}}
      {{- $_ := set $output.extraArgs "external.alert.source" (printf "explore?left=%s" $alertSource) -}}
    {{- end -}}
    {{- if not (index $output.extraArgs "external.url") -}}
      {{- $_ := set $output.extraArgs "external.url" (include "vm-k8s-stack.grafana.addr" .) -}}
    {{- end -}}
  {{- end -}}
  {{- tpl ($output | toYaml) . -}}
{{- end -}}

{{- /* VLAgent remoteWrites */ -}}
{{- define "vl.agent.remote.write" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $remoteWrites := $Values.vlagent.additionalRemoteWrites | default list }}
  {{- with include "vl.write.endpoint" . -}}
    {{- $rws := $Values.vlagent.spec.remoteWrite | default (list (dict)) }}
    {{- $rw := fromYaml . }}
    {{- $remoteWrites = append $remoteWrites (mergeOverwrite $rw (deepCopy (first $rws))) }}
  {{- end -}}
  {{- toYaml (dict "remoteWrite" $remoteWrites) -}}
{{- end -}}

{{- /* VLAgent spec */ -}}
{{- define "vl.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $spec := include "vl.agent.remote.write" . | fromYaml -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- $_ := set $spec "image" $image -}}
  {{- tpl (mergeOverwrite (deepCopy $Values.vlagent.spec) (deepCopy $spec) | toYaml) . -}}
{{- end }}

{{- /* VMAuth spec */ -}}
{{- define "vm.auth.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $_ := set . "style" "managed" -}}
  {{- $vl := dict -}}
  {{- if $Values.vlsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vlsingle" "spec") -}}
    {{- $url := urlParse (include "vm.url" .) -}}
    {{- $_ := set $vl "read" $url -}}
    {{- $_ := set $vl "write" $url -}}
  {{- else if $Values.vlcluster.enabled -}}
    {{- if $Values.vlcluster.spec.vlinsert.enabled -}}
      {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlinsert") -}}
      {{- $writeURL := urlParse (include "vm.url" .) -}}
      {{- $_ := set $writeURL "path" (printf "%s/insert" $writeURL.path) -}}
      {{- $_ := set $vl "write" $writeURL }}
    {{- else if $Values.external.vl.write.url -}}
      {{- $_ := set $vl "write" (urlParse $Values.external.vl.write.url) -}}
    {{- end -}}
    {{- if $Values.vlcluster.spec.vlselect.enabled -}}
      {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlselect") -}}
      {{- $readURL := urlParse (include "vm.url" .) -}}
      {{- $_ := set $readURL "path" (printf "%s/select" $readURL.path) -}}
      {{- $_ := set $vl "read" $readURL }}
    {{- else if $Values.external.vl.read.url -}}
      {{- $_ := set $vl "read" (urlParse $Values.external.vl.read.url) -}}
    {{- end -}}
    {{- $_ := set . "vl" $vl -}}
  {{- else if or $Values.external.vl.read.url $Values.external.vl.write.url -}}
    {{- with $Values.external.vl.read.url -}}
      {{- $_ := set $vl "read" (urlParse .) -}}
    {{- end -}}
    {{- with $Values.external.vl.write.url -}}
      {{- $_ := set $vl "write" (urlParse .) -}}
    {{- end -}}
  {{- end -}}
  {{- $_ := set . "vl" $vl -}}
  {{- $spec := deepCopy $Values.vmauth.spec }}
  {{- if $spec.unauthorizedUserAccessSpec }}
    {{- if $spec.unauthorizedUserAccessSpec.disabled }}
      {{- $_ := unset $spec "unauthorizedUserAccessSpec" }}
    {{- else -}}
      {{- $_ := unset $spec.unauthorizedUserAccessSpec "disabled" }}
    {{- end -}}
  {{- end -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (toYaml $spec) . -}}
{{- end -}}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $fullname := include "vm.managed.fullname" . -}}
  {{- $app := $Values.vmalertmanager }}
  {{- $spec := $app.spec -}}
  {{- if and (not $spec.configRawYaml) (not $spec.configSecret) (not $Values.vmalertmanager.useManagedConfig) -}}
    {{- $_ := set $spec "configSecret" $fullname -}}
  {{- end -}}
  {{- $templates := $spec.templates | default list -}}
  {{- if $Values.vmalertmanager.monzoTemplate.enabled -}}
    {{- $configMap := printf "%s-monzo-tpl" $fullname -}}
    {{- $templates = append $templates (dict "name" $configMap "key" "monzo.tmpl") -}}
  {{- end -}}
  {{- $configMap := printf "%s-extra-tpl" $fullname -}}
  {{- range $key, $value := $Values.vmalertmanager.templateFiles | default dict -}}
    {{- $templates = append $templates (dict "name" $configMap "key" $key) -}}
  {{- end -}}
  {{- if and ($app.useManagedConfig) (not (hasKey $spec "disableNamespaceMatcher")) }}
    {{- $_ := set $spec "disableNamespaceMatcher" true }}
  {{- end }}
  {{- $_ := set $spec "templates" $templates -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* Single spec */ -}}
{{- define "vl.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $extraArgs := dict -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" $image -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vlsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vl.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $extraArgs := dict -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vl.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $selectSpec := include "vl.select.spec" . | fromYaml -}}
  {{- $clusterSpec := deepCopy $Values.vlcluster.spec -}}
  {{- $clusterSpec = mergeOverwrite (dict "clusterVersion" (printf "%s-cluster" (include "vm.image.tag" .))) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- if ($clusterSpec.requestsLoadBalancer).enabled }}
    {{- $balancerSpec := $clusterSpec.requestsLoadBalancer.spec | default dict }}
    {{- $authImage := dict "image" (dict "tag" (include "vm.image.tag" .)) }}
    {{- $_ := set $clusterSpec.requestsLoadBalancer "spec" (mergeOverwrite $authImage $balancerSpec) }}
  {{- end }}
  {{- $clusterSpec = mergeOverwrite (dict "vlselect" $selectSpec) $clusterSpec }}
  {{- if not $clusterSpec.vlselect.enabled -}}
    {{- $_ := unset $clusterSpec "vlselect" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vlselect "enabled" -}}
  {{- end -}}
  {{- if not $clusterSpec.vlinsert.enabled -}}
    {{- $_ := unset $clusterSpec "vlinsert" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vlinsert "enabled" -}}
  {{- end -}}
  {{- tpl (toYaml $clusterSpec) . -}}
{{- end -}}

{{- define "vm.data.source.enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $grafana := $Values.grafana -}}
  {{- $installed := list }}
  {{- range $plugin := ($grafana.plugins | default list) -}}
    {{- $plugin = splitList "@" $plugin | first }}
    {{- $installed = append $installed $plugin }}
  {{- end -}}
  {{- $ds := .ds -}}
  {{- toString (or (not (hasKey $ds "version")) (has $ds.type $installed)) -}}
{{- end -}}

{{- /* Datasources */ -}}
{{- define "vm.data.sources" -}}
  {{- $ctx := . }}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $datasources := $Values.defaultDatasources.extra | default list -}}
  {{- $readURL := include "vl.read.endpoint" $ctx -}}
  {{- if $readURL -}}
    {{- $readEndpoint := fromYaml $readURL -}}
    {{- $defaultDatasources := list -}}
    {{- range $ds := $Values.defaultDatasources.victoriametrics.datasources }}
      {{- $_ := set $ds "url" $readEndpoint.url -}}
      {{- $defaultDatasources = append $defaultDatasources $ds -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
  {{- end -}}
  {{- if $Values.vmalertmanager.enabled -}}
    {{- range $ds := $Values.defaultDatasources.vmalertmanager.datasources }}
      {{- $appSecure := not (empty ((($Values.vmalertmanager).spec).webConfig).tls_server_config) -}}
      {{- $_ := set $ctx "appKey" (list "vmalertmanager" "spec") -}}
      {{- $_ := set $ctx "appSecure" $appSecure -}}
      {{- $_ := set $ctx "appRoute" (($Values.vmalertmanager).spec).routePrefix -}}
      {{- $_ := set $ds "url" (include "vm.url" $ctx) -}}
      {{- $_ := set $ds "type" "vmalertmanager" -}}
      {{- $datasources = append $datasources $ds -}}
    {{- end }}
  {{- end -}}
  {{- toYaml (dict "datasources" $datasources) -}}
{{- end }}

{{- /* VMRule name */ -}}
{{- define "vm-k8s-stack.rulegroup.name" -}}
  {{- printf "%s-%s" (include "vm.fullname" .) (.name | replace "_" "") -}}
{{- end -}}

{{- /* VMRule labels */ -}}
{{- define "vm-k8s-stack.rulegroup.labels" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $labels := fromYaml (include "vm.labels" .) -}}
  {{- $_ := set $labels "app" (include "vm.name" .) -}}
  {{- $labels = mergeOverwrite $labels (deepCopy $Values.defaultRules.labels) -}}
  {{- toYaml $labels -}}
{{- end }}

{{- /* VMRule key */ -}}
{{- define "vm-k8s-stack.rulegroup.key" -}}
  {{- without (regexSplit "[-_.]" .name -1) "exporter" "rules" | join "-" | camelcase | untitle -}}
{{- end -}}

{{- /* VMAlertmanager name */ -}}
{{- define "vm-k8s-stack.alertmanager.name" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $_ := set . "appKey" (list "vmalertmanager" "spec") -}}
  {{- $Values.vmalertmanager.name | default (include "vm.managed.fullname" .) -}}
{{- end -}}

{{- define "vm-k8s-stack.nodeExporter.name" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- (index $Values "prometheus-node-exporter").service.labels.jobLabel | default "node-exporter" }}
{{- end -}}

{{- define "vm-k8s-stack.grafana.addr" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $grafanaAddr := (($Values.external).grafana).host -}}
  {{- if not (or (hasPrefix "http://" $grafanaAddr) (hasPrefix "https://" $grafanaAddr)) -}}
    {{- $grafanaAddr = printf "http://%s" $grafanaAddr -}}
  {{- end -}}
  {{- if ($Values.grafana).enabled -}}
    {{- $grafanaScheme := ternary "https" "http" (gt (len (($Values.grafana).ingress).tls) 0) -}}
    {{- $grafanaHosts := (($Values.grafana).ingress).hosts | default list }}
    {{- if eq (len $grafanaHosts) 0 }}
      {{- fail ".Values.grafana.ingress.hosts should not be empty if .Values.grafana.enabled is true" }}
    {{- end }}
    {{- $grafanaAddr = printf "%s://%s" $grafanaScheme (index $grafanaHosts 0) -}}
  {{- end -}}
  {{- $grafanaAddr -}}
{{- end -}}
