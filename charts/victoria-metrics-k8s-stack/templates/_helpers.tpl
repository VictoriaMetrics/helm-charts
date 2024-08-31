{{- /* Expand the name of the chart. */ -}}
{{- define "victoria-metrics-k8s-stack.name" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Chart.Name $Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "victoria-metrics-k8s-stack.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $fullname := $Values.fullnameOverride -}}
  {{- if .appKey -}}
    {{- if (index $Values .appKey).name -}}
      {{- $fullname = (index $Values .appKey).name -}}
    {{- else if (dig $Chart.Name .appKey "name" "" ($Values.global)) -}}
      {{- $fullname = (dig $Chart.Name .appKey "name" "" ($Values.global)) -}}
    {{- else if (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
      {{- $fullname = (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
    {{- end -}}
  {{- end -}}
  {{- if empty $fullname -}}
    {{- $name := default $Chart.Name $Values.nameOverride }}
    {{- if contains $name $Release.Name }}
      {{- $fullname = $Release.Name -}}
    {{- else }}
      {{- $fullname = (printf "%s-%s" $Release.Name $name) }}
    {{- end }}
  {{- end -}}
  {{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "victoria-metrics-k8s-stack.chart" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /* Create the name of the service account to use */ -}}
{{- define "victoria-metrics-k8s-stack.serviceAccountName" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.serviceAccount.create -}}
    {{- default (include "victoria-metrics-k8s-stack.fullname" .) $Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" $Values.serviceAccount.name -}}
  {{- end }}
{{- end }}

{{- /* Common labels */ -}}
{{- define "victoria-metrics-k8s-stack.labels" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $labels := (fromYaml (include "victoria-metrics-k8s-stack.selectorLabels" .)) -}}
  {{- $_ := set $labels "helm.sh/chart" (include "victoria-metrics-k8s-stack.chart" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- with $Chart.AppVersion }}
    {{- $_ := set $labels "app.kubernetes.io/version" . -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}

{{- define "vm.release" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Release.Name $Values.argocdReleaseOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "victoria-metrics-k8s-stack.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "app.kubernetes.io/name" (include "victoria-metrics-k8s-stack.name" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
  {{- toYaml $labels -}}
{{- end }}

{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $name := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- with .appKey -}}
    {{- $prefix := ternary . (printf "vm%s" .) (hasPrefix "vm" .) -}}
    {{- $name = printf "%s-%s" $prefix $name -}}
  {{- end -}}
  {{- if hasKey . "appIdx" -}}
    {{- $name = (printf "%s-%d.%s" $name .appIdx $name) -}}
  {{- end -}}
  {{- $name -}}
{{- end }}

{{- define "vm.url" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ns := $Release.Namespace -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := false -}}
  {{- if .appSecure -}}
    {{- $isSecure = .appSecure -}}
  {{- end -}}
  {{- with .appKey -}}
    {{- $service := index ($Values) . | default dict -}}
    {{- $spec := $service.spec | default dict -}}
    {{- $isSecure = ($spec.extraArgs).tls | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default $port -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s.%s.svc:%d%s" $proto $name $ns (int $port) $path -}}
{{- end -}}

{{- define "vm.read.endpoint" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set $ctx "appKey" "vmsingle" -}}
    {{- $_ := set $endpoint "url" (include "vm.url" $ctx) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set $Values.vmcluster.spec.vmselect "name" $Values.vmcluster.name -}}
    {{- $_ := set $Values "vmselect" (dict "spec" $Values.vmcluster.spec.vmselect) -}}
    {{- $_ := set $ctx "appKey" "vmselect" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($Values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/select/%d/prometheus" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.read.url -}}
    {{- $endpoint = $Values.externalVM.read -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end }}

{{- define "vm.write.endpoint" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set $ctx "appKey" "vmsingle" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $_ := set $endpoint "url" (printf "%s/api/v1/write" $baseURL) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set $Values.vmcluster.spec.vminsert "name" $Values.vmcluster.name -}}
    {{- $_ := set $Values "vminsert" (dict "spec" $Values.vmcluster.spec.vminsert) -}}
    {{- $_ := set $ctx "appKey" "vminsert" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($Values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/%d/prometheus/api/v1/write" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.write.url -}}
    {{- $endpoint = $Values.externalVM.write -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $remotes := default dict -}}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $ctx := dict "helm" . -}}
  {{- $remoteWrite := (include "vm.write.endpoint" $ctx | fromYaml) -}}
  {{- if $Values.vmalert.remoteWriteVMAgent -}}
    {{- $ctx := dict "helm" . "appKey" "vmagent" -}}
    {{- $remoteWrite = dict "url" (printf "%s/api/v1/write" (include "vm.url" $ctx)) -}}
  {{- end -}}
  {{- $ctx := dict "helm" . -}}
  {{- $remoteRead := (fromYaml (include "vm.read.endpoint" $ctx)) -}}
  {{- $_ := set $remotes "remoteWrite" $remoteWrite -}}
  {{- $_ := set $remotes "remoteRead" $remoteRead -}}
  {{- $_ := set $remotes "datasource" $remoteRead -}}
  {{- if $Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := ((printf "%s-vmalert-additional-notifier" $fullname) | trunc 63 | trimSuffix "-") -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if $Values.alertmanager.enabled -}}
    {{- $notifiers := default list -}}
    {{- $appSecure := (not (empty (((.Values.alertmanager).spec).webConfig).tls_server_config)) -}}
    {{- $ctx := dict "helm" . "appKey" "alertmanager" "appSecure" $appSecure "appRoute" ((.Values.alertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := (.Values.alertmanager.spec.replicaCount | default 1 | int) -}}
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
  {{- $Values := (.helm).Values | default .Values}}
  {{- $cms :=  ($Values.vmalert.spec.configMaps | default list) -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
    {{- $cms = append $cms ((printf "%s-vmalert-extra-tpl" $fullname) | trunc 63 | trimSuffix "-") -}}
  {{- end -}}
  {{- $output := dict "configMaps" (compact $cms) -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vm.license.global" -}}
  {{- $license := (deepCopy (.Values.global).license) | default dict -}}
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
  {{- $extraArgs := dict "remoteWrite.disablePathAppend" "true" -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $ruleTmpl := (printf "/etc/vm/configs/%s-vmalert-extra-tpl/*.tmpl" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") -}}
    {{- $_ := set $extraArgs "rule.templates" $ruleTmpl -}}
  {{- end -}}
  {{- $vmAlertRemotes := (include "vm.alert.remotes" . | fromYaml) -}}
  {{- $vmAlertTemplates := (include "vm.alert.templates" . | fromYaml) -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- $_ := set $vmAlertRemotes "notifiers" (concat ($vmAlertRemotes.notifiers | default list) (.Values.vmalert.spec.notifiers | default list)) -}}
  {{- tpl (deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VM Agent remoteWrites */ -}}
{{- define "vm.agent.remote.write" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $remoteWrites := $Values.vmagent.additionalRemoteWrites | default list -}}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled $Values.externalVM.write.url -}}
    {{- $ctx := dict "helm" . -}}
    {{- $remoteWrites = append $remoteWrites (fromYaml (include "vm.write.endpoint" $ctx)) -}}
  {{- end -}}
  {{- toYaml (dict "remoteWrite" $remoteWrites) -}}
{{- end -}}

{{- /* VMAgent spec */ -}}
{{- define "vm.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $spec := (include "vm.agent.remote.write" . | fromYaml) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmagent.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $spec := $Values.alertmanager.spec -}}
  {{- if and (not $Values.alertmanager.spec.configRawYaml) (not $Values.alertmanager.spec.configSecret) -}}
    {{- $_ := set $spec "configSecret" (printf "%s-alertmanager" $fullname) -}}
  {{- end -}}
  {{- $templates := default list -}}
  {{- if $Values.alertmanager.monzoTemplate.enabled -}}
    {{- $configMap := ((printf "%s-alertmanager-monzo-tpl" $fullname) | trunc 63 | trimSuffix "-") -}}
    {{- $templates = append $templates (dict "name" $configMap "key" "monzo.tmpl") -}}
  {{- end -}}
  {{- $configMap := ((printf "%s-alertmanager-extra-tpl" $fullname) | trunc 63 | trimSuffix "-") -}}
  {{- range $key, $value := (.Values.alertmanager.templateFiles | default dict) -}}
    {{- $templates = append $templates (dict "name" $configMap "key" $key) -}}
  {{- end -}}
  {{- $_ := set $spec "templates" $templates -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* Single spec */ -}}
{{- define "vm.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := default dict -}}
  {{- if $Values.vmalert.enabled }}
    {{- $ctx := dict "helm" . "appKey" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vm.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := default dict -}}
  {{- if $Values.vmalert.enabled -}}
    {{- $ctx := dict "helm" . "appKey" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vm.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $spec := (include "vm.select.spec" . | fromYaml) -}}
  {{- $clusterSpec := (deepCopy $Values.vmcluster.spec) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl ($clusterSpec | mergeOverwrite (dict "vmselect" $spec) | toYaml) . -}}
{{- end -}}

{{- define "vm.data.source" -}}
name: {{ .name | default "VictoriaMetrics" }}
type: {{ .type | default ""}}
url: {{ .url }}
access: proxy
isDefault: {{ .isDefault | default false }}
jsonData: {{ .jsonData | default dict | toYaml | nindent 2 }}
{{- end }}

{{- /* Datasources */ -}}
{{- define "vm.data.sources" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $datasources := $Values.grafana.additionalDataSources | default list -}}
  {{- $vmDSPluginEnabled := false }}
  {{- if $Values.grafana.plugins }}
    {{- range $value := $Values.grafana.plugins }}
      {{- if (contains "victoriametrics-datasource" $value) }}
        {{- $vmDSPluginEnabled = true }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled -}}
    {{- $ctx := dict "helm" . -}}
    {{- $readEndpoint:= (include "vm.read.endpoint" $ctx | fromYaml) -}}
    {{- $jsonData := $Values.grafana.sidecar.datasources.jsonData | default dict -}}
    {{- $dsType := (default "prometheus" $Values.grafana.defaultDatasourceType) -}}
    {{- $vmAllowUnsigned := contains "victoriametrics-datasource" (dig "grafana.ini" "plugins" "allow_loading_unsigned_plugins" "" $Values.grafana) -}}
    {{- if (and $vmDSPluginEnabled $vmAllowUnsigned) -}}
      {{- $args := dict "name" "VictoriaMetrics (DS)" "type" "victoriametrics-datasource" "url" $readEndpoint.url "jsonData" $jsonData -}}
      {{- $datasources = append $datasources (fromYaml (include "vm.data.source" $args)) -}}
    {{- else -}}
      {{- $dsType = "prometheus" -}}
    {{- end }}
    {{- if $Values.grafana.provisionDefaultDatasource -}}
      {{- $args := dict "type" $dsType "isDefault" true "url" $readEndpoint.url "jsonData" $jsonData -}}
      {{- $datasources = append $datasources (fromYaml (include "vm.data.source" $args)) -}}
    {{- end }}
    {{- if $Values.grafana.sidecar.datasources.createVMReplicasDatasources -}}
      {{- $ctx := dict "helm" . -}}
      {{- range until (int $Values.vmsingle.spec.replicaCount) -}}
        {{- $_ := set $ctx "appIdx" . -}}
        {{- $readEndpoint:= (include "vm.read.endpoint" $ctx | fromYaml) }}
        {{- $args := dict "name" (printf "VictoriaMetrics-%d" .) "type" $dsType "url" $readEndpoint.url "jsonData" $jsonData -}}
        {{- $datasources = append $datasources (fromYaml (include "vm.data.source" $args)) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $datasources -}}
{{- end }}

{{- /* VMRule name */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.name" -}}
  {{- $id := include "victoria-metrics-k8s-stack.rulegroup.id" . -}}
  {{- printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" .) $id | trunc 63 | trimSuffix "-" | trimSuffix "." -}}
{{- end -}}

{{- /* VMRule labels */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.labels" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $labels := (fromYaml (include "victoria-metrics-k8s-stack.labels" .)) -}}
  {{- $_ := set $labels "app" (include "victoria-metrics-k8s-stack.name" .) -}}
  {{- $labels = mergeOverwrite $labels (deepCopy $Values.defaultRules.labels) -}}
  {{- toYaml $labels -}}
{{- end }}

{{- /* VMRule key */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.key" -}}
  {{- without (regexSplit "[-_.]" .name -1) "exporter" "rules" | join "-" | camelcase | untitle -}}
{{- end -}}

{{- /* VMRule ID */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.id" -}}
  {{- .name | replace "_" "" | trunc 63 | trimSuffix "-" | trimSuffix "." -}}
{{- end -}}

{{- /* VMAlertmanager name */ -}}
{{- define "victoria-metrics-k8s-stack.alertmanager.name" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Values.alertmanager.name | default (printf "%s-%s" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") -}}
{{- end -}}
