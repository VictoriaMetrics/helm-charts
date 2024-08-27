{{- /* Expand the name of the chart. */ -}}
{{- define "victoria-metrics-k8s-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "victoria-metrics-k8s-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "victoria-metrics-k8s-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* Create the name of the service account to use */ -}}
{{- define "victoria-metrics-k8s-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "victoria-metrics-k8s-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- /* Create the name for VMSingle */ -}}
{{- define "victoria-metrics-k8s-stack.vmsingleName" -}}
{{- .Values.vmsingle.name | default (printf "vmsingle-%s" (include "victoria-metrics-k8s-stack.fullname" .))}}
{{- end }}

{{- /* Create the name for VMCluster and its components */ -}}
{{- define "victoria-metrics-k8s-stack.vmclusterName" -}}
{{ .Values.vmcluster.name | default (include "victoria-metrics-k8s-stack.fullname" .) }}
{{- end }}
{{- define "victoria-metrics-k8s-stack.vmstorageName" -}}
{{- printf "%s-%s" "vmstorage" (include "victoria-metrics-k8s-stack.vmclusterName" $) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "victoria-metrics-k8s-stack.vmselectName" -}}
{{- printf "%s-%s" "vmselect" (include "victoria-metrics-k8s-stack.vmclusterName" $) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "victoria-metrics-k8s-stack.vminsertName" -}}
{{- printf "%s-%s" "vminsert" (include "victoria-metrics-k8s-stack.vmclusterName" $) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* Common labels */ -}}
{{- define "victoria-metrics-k8s-stack.labels" -}}
helm.sh/chart: {{ include "victoria-metrics-k8s-stack.chart" . }}
{{ include "victoria-metrics-k8s-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "vm.release" -}}
{{ default .Release.Name .Values.argocdReleaseOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "victoria-metrics-k8s-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "victoria-metrics-k8s-stack.name" . }}
app.kubernetes.io/instance: {{ include "vm.release" . }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- $global := .global -}}
  {{- $value := (include "victoria-metrics-k8s-stack.fullname" $global) -}}
  {{- with .vmService -}}
    {{- $service := (index $global .) | default dict -}}
    {{- $prefix := ternary . (printf "vm%s" .) (hasPrefix "vm" .) -}}
    {{- $value = ($service).name | default (printf "%s-%s" $prefix $value) -}}
  {{- end -}}
  {{- if hasKey . "vmIdx" -}}
    {{- $value = (printf "%s-%d.%s" $value .vmIdx $value) -}}
  {{- end -}}
  {{- $value -}}
{{- end }}

{{- define "vm.url" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- $global := .global -}}
  {{- $ns := $global.Release.Namespace -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .vmRoute | default "/" -}}
  {{- $isSecure := false -}}
  {{- if .vmSecure -}}
    {{- $isSecure = .vmSecure -}}
  {{- end -}}
  {{- with .vmService -}}
    {{- $service := index ($global.Values) . | default dict -}}
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
  {{- $values := $ctx.global.Values -}}
  {{- $endpoint := default dict -}}
  {{- if $values.vmsingle.enabled -}}
    {{- $_ := set $ctx "vmService" "vmsingle" -}}
    {{- $_ := set $endpoint "url" (include "vm.url" $ctx) -}}
  {{- else if $values.vmcluster.enabled -}}
    {{- $_ := set $values.vmcluster.spec.vmselect "name" $values.vmcluster.name -}}
    {{- $_ := set $values "vmselect" (dict "spec" $values.vmcluster.spec.vmselect) -}}
    {{- $_ := set $ctx "vmService" "vmselect" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/select/%d/prometheus" $baseURL (int $tenant)) -}}
  {{- else if $values.externalVM.read.url -}}
    {{- $endpoint := $values.externalVM.read -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end }}

{{- define "vm.write.endpoint" -}}
  {{- $ctx := . -}}
  {{- $values := $ctx.global.Values -}}
  {{- $endpoint := default dict -}}
  {{- if $values.vmsingle.enabled -}}
    {{- $_ := set $ctx "vmService" "vmsingle" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $_ := set $endpoint "url" (printf "%s/api/v1/write" $baseURL) -}}
  {{- else if $values.vmcluster.enabled -}}
    {{- $_ := set $values.vmcluster.spec.vminsert "name" $values.vmcluster.name -}}
    {{- $_ := set $values "vminsert" (dict "spec" $values.vmcluster.spec.vminsert) -}}
    {{- $_ := set $ctx "vmService" "vminsert" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/%d/prometheus/api/v1/write" $baseURL (int $tenant)) -}}
  {{- else if $values.externalVM.write.url -}}
    {{- $endpoint := $values.externalVM.write -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $remotes := default dict -}}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $ctx := dict "global" . -}}
  {{- $remoteWrite := (include "vm.write.endpoint" $ctx | fromYaml) -}}
  {{- if .Values.vmalert.remoteWriteVMAgent -}}
    {{- $ctx := dict "global" . "vmService" "vmagent" -}}
    {{- $remoteWrite = dict "url" (printf "%s/api/v1/write" (include "vm.url" $ctx)) -}}
  {{- end -}}
  {{- $ctx := dict "global" . -}}
  {{- $remoteRead := (fromYaml (include "vm.read.endpoint" $ctx)) -}}
  {{- $_ := set $remotes "remoteWrite" $remoteWrite -}}
  {{- $_ := set $remotes "remoteRead" $remoteRead -}}
  {{- $_ := set $remotes "datasource" $remoteRead -}}
  {{- if .Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := ((printf "%s-vmalert-additional-notifier" $fullname) | trunc 63 | trimSuffix "-") -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if .Values.alertmanager.enabled -}}
    {{- $notifiers := default list -}}
    {{- $vmSecure := (not (empty (((.Values.alertmanager).spec).webConfig).tls_server_config)) -}}
    {{- $ctx := dict "global" . "vmService" "alertmanager" "vmSecure" $vmSecure "vmRoute" ((.Values.alertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := (.Values.alertmanager.spec.replicaCount | default 1 | int) -}}
    {{- range until $alertManagerReplicas -}}
      {{- $_ := set $ctx "vmIdx" . -}}
      {{- $notifiers = append $notifiers (dict "url" (include "vm.url" $ctx)) -}}
    {{- end }}
    {{- $_ := set $remotes "notifiers" $notifiers -}}
  {{- end -}}
  {{- toYaml $remotes -}}
{{- end -}}

{{- /* VMAlert templates */ -}}
{{- define "vm.alert.templates" -}}
  {{- $cms :=  (.Values.vmalert.spec.configMaps | default list) -}}
  {{- if .Values.vmalert.templateFiles -}}
    {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
    {{- $cms = append $cms ((printf "%s-vmalert-extra-tpl" $fullname) | trunc 63 | trimSuffix "-") -}}
  {{- end -}}
  {{- $output := dict "configMaps" (compact $cms) -}}
  {{- toYaml $output -}}
{{- end -}}

{{- /* VMAlert spec */ -}}
{{- define "vm.alert.spec" -}}
  {{- $extraArgs := dict "remoteWrite.disablePathAppend" "true" -}}
  {{- if .Values.vmalert.templateFiles -}}
    {{- $ruleTmpl := (printf "/etc/vm/configs/%s-vmalert-extra-tpl/*.tmpl" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") -}}
    {{- $_ := set $extraArgs "rule.templates" $ruleTmpl -}}
  {{- end -}}
  {{- $vmAlertRemotes := (include "vm.alert.remotes" . | fromYaml) -}}
  {{- $vmAlertTemplates := (include "vm.alert.templates" . | fromYaml) -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- if or .Values.global.license.key .Values.global.license.keyRef.name -}}
    {{- with .Values.global.license -}}
      {{- $_ := set $spec "license" . -}}
    {{- end -}}
  {{- end -}}
  {{- $_ := set $vmAlertRemotes "notifiers" (concat $vmAlertRemotes.notifiers (.Values.vmalert.spec.notifiers | default list)) -}}
  {{- tpl (deepCopy (omit .Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VM Agent remoteWrites */ -}}
{{- define "vm.agent.remote.write" -}}
  {{- $remoteWrites := .Values.vmagent.additionalRemoteWrites | default list -}}
  {{- if or .Values.vmsingle.enabled .Values.vmcluster.enabled .Values.externalVM.write.url -}}
    {{- $ctx := dict "global" . -}}
    {{- $remoteWrites = append $remoteWrites (fromYaml (include "vm.write.endpoint" $ctx)) -}}
  {{- end -}}
  {{- toYaml (dict "remoteWrite" $remoteWrites) -}}
{{- end -}}

{{- /* VMAgent spec */ -}}
{{- define "vm.agent.spec" -}}
  {{- $spec := (include "vm.agent.remote.write" . | fromYaml) -}}
  {{- if or .Values.global.license.key .Values.global.license.keyRef.name -}}
    {{- with .Values.global.license -}}
      {{- $_ := set $spec "license" . -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (deepCopy .Values.vmagent.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $spec := .Values.alertmanager.spec -}}
  {{- if and (not .Values.alertmanager.spec.configRawYaml) (not .Values.alertmanager.spec.configSecret) -}}
    {{- $_ := set $spec "configSecret" (printf "%s-alertmanager" $fullname) -}}
  {{- end -}}
  {{- $templates := default list -}}
  {{- if .Values.alertmanager.monzoTemplate.enabled -}}
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
  {{- $extraArgs := default dict -}}
  {{- if .Values.vmalert.enabled }}
    {{- $ctx := dict "global" . "vmService" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- if or .Values.global.license.key .Values.global.license.keyRef.name -}}
    {{- with .Values.global.license -}}
      {{- $_ := set $spec "license" . -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (deepCopy .Values.vmsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vm.select.spec" -}}
  {{- $extraArgs := default dict -}}
  {{- if .Values.vmalert.enabled -}}
    {{- $ctx := dict "global" . "vmService" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vm.cluster.spec" -}}
{{- $spec := (include "vm.select.spec" . | fromYaml) -}}
{{- if or .Values.global.license.key .Values.global.license.keyRef.name -}}
  {{- with .Values.global.license -}}
    {{- $_ := set $spec "license" . -}}
  {{- end -}}
{{- end -}}
{{ tpl (deepCopy .Values.vmcluster.spec | mergeOverwrite $spec | toYaml) . }}
{{- end }}

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
  {{- $datasources := .Values.grafana.additionalDataSources | default list -}}
  {{- $vmDSPluginEnabled := false }}
  {{- if .Values.grafana.plugins }}
    {{- range $value := .Values.grafana.plugins }}
      {{- if (contains "victoriametrics-datasource" $value) }}
        {{- $vmDSPluginEnabled = true }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if or .Values.vmsingle.enabled  .Values.vmcluster.enabled -}}
    {{- $ctx := dict "global" . -}}
    {{- $readEndpoint:= (include "vm.read.endpoint" $ctx | fromYaml) -}}
    {{- $jsonData := .Values.grafana.sidecar.datasources.jsonData | default dict -}}
    {{- $dsType := (default "prometheus" .Values.grafana.defaultDatasourceType) -}}
    {{- $vmAllowUnsigned := contains "victoriametrics-datasource" (dig "grafana.ini" "plugins" "allow_loading_unsigned_plugins" "" .Values.grafana) -}}
    {{- if (and $vmDSPluginEnabled $vmAllowUnsigned) -}}
      {{- $args := dict "name" "VictoriaMetrics (DS)" "type" "victoriametrics-datasource" "url" $readEndpoint.url "jsonData" $jsonData -}}
      {{- $datasources = append $datasources (fromYaml (include "vm.data.source" $args)) -}}
    {{- else -}}
      {{- $dsType = "prometheus" -}}
    {{- end }}
    {{- if .Values.grafana.provisionDefaultDatasource -}}
      {{- $args := dict "type" $dsType "isDefault" true "url" $readEndpoint.url "jsonData" $jsonData -}}
      {{- $datasources = append $datasources (fromYaml (include "vm.data.source" $args)) -}}
    {{- end }}
    {{- if .Values.grafana.sidecar.datasources.createVMReplicasDatasources -}}
      {{- $ctx := dict "global" . -}}
      {{- range until (int .Values.vmsingle.spec.replicaCount) -}}
        {{- $_ := set $ctx "vmIdx" . -}}
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
{{ printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" .) $id | trunc 63 | trimSuffix "-" | trimSuffix "." }}
{{- end -}}

{{- /* VMRule labels */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.labels" -}}
app: {{ include "victoria-metrics-k8s-stack.name" . }}
{{ include "victoria-metrics-k8s-stack.labels" . }}
{{- with .Values.defaultRules.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- /* VMRule key */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.key" -}}
{{ without (regexSplit "[-_.]" .name -1) "exporter" "rules" | join "-" | camelcase | untitle }}
{{- end -}}

{{- /* VMRule ID */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.id" -}}
{{ .name | replace "_" "" | trunc 63 | trimSuffix "-" | trimSuffix "." }}
{{- end -}}

{{- /* VMAlertmanager name */ -}}
{{- define "victoria-metrics-k8s-stack.alertmanager.name" -}}
{{ .Values.alertmanager.name | default (printf "%s-%s" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") }}
{{- end -}}
