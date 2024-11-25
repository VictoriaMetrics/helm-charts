{{- define "vm.read.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vmsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- if $Values.vmauth.enabled -}}
      {{- $_ := set . "appKey" (list "vmauth" "spec") -}}
    {{- else -}}
      {{- $_ := set . "appKey" (list "vmcluster" "spec" "vmselect") -}}
    {{- end -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $tenant := $Values.tenant | default 0 -}}
    {{- $_ := set $endpoint "url" (printf "%s/select/%d/prometheus" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.read.url -}}
    {{- $endpoint = $Values.externalVM.read -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end }}

{{- define "vm.write.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vmsingle" "spec") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" (printf "%s/api/v1/write" $baseURL) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set . "appKey" (list "vmcluster" "spec" "vminsert") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $tenant := $Values.tenant | default 0 -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/%d/prometheus/api/v1/write" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.write.url -}}
    {{- $endpoint = $Values.externalVM.write -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $remotes := default dict -}}
  {{- $fullname := include "vm.fullname" . -}}
  {{- $_ := set $ctx "style" "managed" -}}
  {{- $remoteWrite := include "vm.write.endpoint" $ctx | fromYaml -}}
  {{- if $Values.vmalert.remoteWriteVMAgent -}}
    {{- $_ := set $ctx "appKey" (list "vmagent" "spec") -}}
    {{- $remoteWrite = dict "url" (printf "%s/api/v1/write" (include "vm.url" $ctx)) -}}
    {{- $_ := unset $ctx "appKey" -}}
  {{- end -}}
  {{- $remoteRead := fromYaml (include "vm.read.endpoint" $ctx) -}}
  {{- $_ := set $remotes "remoteWrite" $remoteWrite -}}
  {{- $_ := set $remotes "remoteRead" $remoteRead -}}
  {{- $_ := set $remotes "datasource" $remoteRead -}}
  {{- if $Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := printf "%s-additional-notifier" $fullname -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if $Values.alertmanager.enabled -}}
    {{- $notifiers := default list -}}
    {{- $appSecure := not (empty ((($Values.alertmanager).spec).webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appKey" (list "alertmanager" "spec") -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" (($Values.alertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := $Values.alertmanager.spec.replicaCount | default 1 | int -}}
    {{- range until $alertManagerReplicas -}}
      {{- $_ := set $ctx "appIdx" . -}}
      {{- $notifiers = append $notifiers (dict "url" (include "vm.url" $ctx)) -}}
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
    {{- $license = default dict -}}
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
  {{- $vmAlertRemotes := include "vm.alert.remotes" . | fromYaml -}}
  {{- $vmAlertTemplates := include "vm.alert.templates" . | fromYaml -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" (dict "tag" $Chart.AppVersion) -}}
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
  {{- tpl (deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VM Agent remoteWrites */ -}}
{{- define "vm.agent.remote.write" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $remoteWrites := $Values.vmagent.additionalRemoteWrites | default list -}}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled $Values.externalVM.write.url -}}
    {{- $remoteWrites = append $remoteWrites (fromYaml (include "vm.write.endpoint" .)) -}}
  {{- end -}}
  {{- toYaml (dict "remoteWrite" $remoteWrites) -}}
{{- end -}}

{{- /* VMAgent spec */ -}}
{{- define "vm.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $spec := include "vm.agent.remote.write" . | fromYaml -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- $_ := set $spec "image" (dict "tag" $Chart.AppVersion) -}}
  {{- tpl (deepCopy $Values.vmagent.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VMAuth spec */ -}}
{{- define "vm.auth.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vmsingle" "spec") -}}
    {{- $url := urlParse (include "vm.url" .) -}}
    {{- $_ := set . "vm" (dict "read" $url "write" $url) }}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set . "appKey" (list "vmcluster" "spec" "vminsert") -}}
    {{- $writeURL := urlParse (include "vm.url" .) -}}
    {{- $_ := set $writeURL "path" (printf "%s/insert" $writeURL.path) -}}
    {{- $_ := set . "appKey" (list "vmcluster" "spec" "vmselect") -}}
    {{- $readURL := urlParse (include "vm.url" .) -}}
    {{- $_ := set $readURL "path" (printf "%s/select" $readURL.path) -}}
    {{- $_ := set . "vm" (dict "read" $readURL "write" $writeURL) -}}
  {{- else if or $Values.externalVM.read.url $Values.externalVM.write.url -}}
    {{- $_ := set . "vm" (default dict) -}}
    {{- with $Values.externalVM.read.url -}}
      {{- $_ := set $.vm "read" (urlParse .) -}}
    {{- end -}}
    {{- with $Values.externalVM.write.url -}}
      {{- $_ := set $.vm "write" (urlParse .) -}}
    {{- end -}}
  {{- end -}}
  {{- $spec := $Values.vmauth.spec }}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (toYaml $spec) . -}}
{{- end -}}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $fullname := include "vm.managed.fullname" . -}}
  {{- $spec := $Values.alertmanager.spec -}}
  {{- if and (not $Values.alertmanager.spec.configRawYaml) (not $Values.alertmanager.spec.configSecret) -}}
    {{- $_ := set $spec "configSecret" $fullname -}}
  {{- end -}}
  {{- $templates := default list -}}
  {{- if $Values.alertmanager.monzoTemplate.enabled -}}
    {{- $configMap := printf "%s-monzo-tpl" $fullname -}}
    {{- $templates = append $templates (dict "name" $configMap "key" "monzo.tmpl") -}}
  {{- end -}}
  {{- $configMap := printf "%s-extra-tpl" $fullname -}}
  {{- range $key, $value := $Values.alertmanager.templateFiles | default dict -}}
    {{- $templates = append $templates (dict "name" $configMap "key" $key) -}}
  {{- end -}}
  {{- $_ := set $spec "templates" $templates -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* Single spec */ -}}
{{- define "vm.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $extraArgs := default dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmalert.enabled }}
    {{- $_ := set . "appKey" (list "vmalert" "spec") }}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" (dict "tag" $Chart.AppVersion) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vm.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $extraArgs := default dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmalert.enabled -}}
    {{- $_ := set . "appKey" (list "vmalert" "spec") -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" (dict "tag" (printf "%s-cluster" $Chart.AppVersion)) -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vm.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $spec := include "vm.select.spec" . | fromYaml -}}
  {{- $clusterSpec := deepCopy $Values.vmcluster.spec -}}
  {{- $imageSpec := dict "image" (dict "tag" (printf "%s-cluster" $Chart.AppVersion)) -}}
  {{- $clusterSpec = mergeOverwrite (dict "vminsert" (deepCopy $imageSpec)) $clusterSpec -}}
  {{- $clusterSpec = mergeOverwrite (dict "vmstorage" (deepCopy $imageSpec)) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl ($clusterSpec | mergeOverwrite (dict "vmselect" $spec) | toYaml) . -}}
{{- end -}}

{{- define "vm.data.source.enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ds := .ds -}}
  {{- if hasPrefix "victoria" $ds.type -}}
    {{- $grafana := $Values.grafana -}}
    {{- $isEnabled := false -}}
    {{- if $grafana.plugins -}}
      {{- range $value := $grafana.plugins -}}
        {{- if contains $ds.type $value -}}
          {{- $isEnabled = true -}}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $unsignedPlugins := ((index $grafana "grafana.ini").plugins).allow_loading_unsigned_plugins | default "" -}}
    {{- $allowUnsigned := contains "victoriametrics-datasource" $unsignedPlugins -}}
    {{- ternary "true" "" (and $isEnabled $allowUnsigned) -}}
  {{- else -}}
    {{ "true" }}
  {{- end }}
{{- end -}}

{{- /* Datasources */ -}}
{{- define "vm.data.sources" -}}
  {{- $ctx := . }}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $datasources := $Values.defaultDatasources.extra | default list -}}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled $Values.externalVM.read -}}
    {{- $readEndpoint:= include "vm.read.endpoint" $ctx | fromYaml -}}
    {{- $defaultDatasources := default list -}}
    {{- range $ds := $Values.defaultDatasources.victoriametrics.datasources }}
      {{- $_ := set $ctx "ds" $ds }}
      {{- $allowedDatasource := ternary false true (empty (include "vm.data.source.enabled" $ctx)) -}}
      {{- if $allowedDatasource -}}
        {{- $_ := set $ds "url" $readEndpoint.url -}}
        {{- $defaultDatasources = append $defaultDatasources $ds -}}
      {{- end -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
    {{- if and $Values.defaultDatasources.victoriametrics.perReplica $defaultDatasources -}}
      {{- range $id := until (int $Values.vmsingle.spec.replicaCount) -}}
        {{- $_ := set $ctx "appIdx" $id -}}
        {{- $readEndpoint := include "vm.read.endpoint" $ctx | fromYaml -}}
        {{- range $ds := $defaultDatasources -}}
          {{- $ds = deepCopy $ds -}}
          {{- $_ := set $ds "url" $readEndpoint.url -}}
          {{- $_ := set $ds "name" (printf "%s-%d" $ds.name $id) -}}
          {{- $_ := set $ds "isDefault" false -}}
          {{- $datasources = append $datasources $ds -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- range $ds := $Values.defaultDatasources.alertmanager.datasources }}
      {{- $appSecure := not (empty ((($Values.alertmanager).spec).webConfig).tls_server_config) -}}
      {{- $_ := set $ctx "appKey" (list "alertmanager" "spec") -}}
      {{- $_ := set $ctx "appSecure" $appSecure -}}
      {{- $_ := set $ctx "appRoute" (($Values.alertmanager).spec).routePrefix -}}
      {{- $_ := set $ds "url" (include "vm.url" $ctx) -}}
      {{- $_ := set $ds "type" "alertmanager" -}}
      {{- $datasources = append $datasources $ds -}}
    {{- end }}
  {{- end -}}
  {{- toYaml $datasources -}}
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
  {{- $_ := set . "appKey" (list "alertmanager" "spec") -}}
  {{- $Values.alertmanager.name | default (include "vm.managed.fullname" .) -}}
{{- end -}}
