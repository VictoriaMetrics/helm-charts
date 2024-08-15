{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-metrics-k8s-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "victoria-metrics-k8s-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "victoria-metrics-k8s-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "victoria-metrics-k8s-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name for VMSingle
*/}}
{{- define "victoria-metrics-k8s-stack.vmsingleName" -}}
{{- .Values.vmsingle.name | default (printf "vmsingle-%s" (include "victoria-metrics-k8s-stack.fullname" .))}}
{{- end }}

{{/*
Create the name for VMCluster and its components
*/}}
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


{{/*
Common labels
*/}}
{{- define "victoria-metrics-k8s-stack.labels" -}}
helm.sh/chart: {{ include "victoria-metrics-k8s-stack.chart" . }}
{{ include "victoria-metrics-k8s-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "victoria-metrics-k8s-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "victoria-metrics-k8s-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "victoria-metrics-k8s-stack.vmReadEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
url: {{ printf "http://%s.%s.svc:%s%s" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default "8429") (index .Values "vmsingle" "spec" "extraArgs" "http.pathPrefix" | default "/") }}
{{- else if .Values.vmcluster.enabled -}}
url: {{ printf "http://%s.%s.svc:%s%s/select/%s/prometheus" (include "victoria-metrics-k8s-stack.vmselectName" .) .Release.Namespace (.Values.vmcluster.spec.vmselect.port | default "8481") (index .Values "vmcluster" "spec" "vmselect" "extraArgs" "http.pathPrefix" | default "") (.Values.tenant | default "0") }}
{{- else if .Values.externalVM.read.url -}}
{{ .Values.externalVM.read | toYaml }}
{{- end }}
{{- end }}

{{- define "victoria-metrics-k8s-stack.vmWriteEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
url: {{ printf "http://%s.%s.svc:%s%s/api/v1/write" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default "8429") (index .Values "vmsingle" "spec" "extraArgs" "http.pathPrefix" | default "") }}
{{- else if .Values.vmcluster.enabled -}}
url: {{ printf "http://%s.%s.svc:%s%s/insert/%s/prometheus/api/v1/write" (include "victoria-metrics-k8s-stack.vminsertName" .) .Release.Namespace (.Values.vmcluster.spec.vminsert.port | default "8480") (index .Values "vmcluster" "spec" "vminsert" "extraArgs" "http.pathPrefix" | default "") (.Values.tenant | default "0")  }}
{{- else if .Values.externalVM.write.url -}}
{{ .Values.externalVM.write | toYaml }}
{{- end }}
{{- end }}

{{/*
VMAlert remotes 
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertRemotes" -}}
remoteWrite:
{{- if or .Values.vmalert.remoteWriteVMAgent }}
     url: {{ printf "http://vmagent-%s.%s.svc:%s%s/api/v1/write" (.Values.vmagent.name | default (include "victoria-metrics-k8s-stack.fullname" .)) .Release.Namespace (.Values.vmagent.spec.port | default "8429") (index .Values "vmsingle" "spec" "extraArgs" "http.pathPrefix" | default "") }}
{{- else }}
     {{- include "victoria-metrics-k8s-stack.vmWriteEndpoint" . | nindent 2 }}
{{- end }}
remoteRead: {{ include "victoria-metrics-k8s-stack.vmReadEndpoint" . | nindent 2 }}
datasource: {{ include "victoria-metrics-k8s-stack.vmReadEndpoint" . | nindent 2 }}
{{- if .Values.vmalert.additionalNotifierConfigs }}
notifierConfigRef:
    name: {{ printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "vmalert-additional-notifier" | trimSuffix "-" }}
    key: notifier-configs.yaml
{{- else if .Values.alertmanager.enabled }}
{{- $alertManagerReplicas := .Values.alertmanager.spec.replicaCount | default 1 }}
notifiers:
    {{- range $n := until (int $alertManagerReplicas) }}
    - url: {{ printf "http://%s-%s-%d.%s-%s.%s.svc:9093" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" $) $n "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" $) $.Release.Namespace }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
VMAlert templates
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertTemplates" -}}
{{- if or .Values.vmalert.spec.configMaps .Values.vmalert.templateFiles }}
{{- $list := .Values.vmalert.spec.configMaps | default (list "") }}
{{- if .Values.vmalert.templateFiles }}
{{- $list = append $list (printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "vmalert-extra-tpl" | trunc 63 | trimSuffix "-") }}
{{- end }}
configMaps:
{{- range compact $list }}
- {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
VMAlert spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertSpec" -}}
{{- $extraArgs := default dict -}}
{{- if .Values.vmalert.templateFiles -}}
{{- $_ := set $extraArgs "rule.templates" (print "/etc/vm/configs/" (printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "vmalert-extra-tpl" | trunc 63 | trimSuffix "-" ) "/*.tmpl") -}}
{{- end -}}
{{- $_ := set $extraArgs "remoteWrite.disablePathAppend" "true" -}}
{{ tpl (deepCopy .Values.vmalert.spec | mergeOverwrite (include "victoria-metrics-k8s-stack.vmAlertRemotes" . | fromYaml) | mergeOverwrite (include "victoria-metrics-k8s-stack.vmAlertTemplates" . | fromYaml) | mergeOverwrite (dict "extraArgs" $extraArgs) | toYaml) . }}
{{- end }}


{{/*
VM Agent remoteWrites
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentRemoteWrite" -}}
remoteWrite:
{{- if or .Values.vmsingle.enabled .Values.vmcluster.enabled .Values.externalVM.write.url }}
- {{ include "victoria-metrics-k8s-stack.vmWriteEndpoint" . | nindent 2 }}
{{- end }}
{{ range .Values.vmagent.additionalRemoteWrites }}
-{{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
VMAgent spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentSpec" -}}
{{ tpl (deepCopy .Values.vmagent.spec | mergeOverwrite ( include "victoria-metrics-k8s-stack.vmAgentRemoteWrite" . | fromYaml) | toYaml) . }}
{{- end }}


{{/*
Alermanager spec
*/}}
{{- define "victoria-metrics-k8s-stack.alertmanagerSpec" -}}
{{ omit .Values.alertmanager.spec  "configMaps" "configSecret" | toYaml }}
{{- if not .Values.alertmanager.spec.configRawYaml }}
configSecret: {{ .Values.alertmanager.spec.configSecret | default (printf "%s-alertmanager" (include "victoria-metrics-k8s-stack.fullname" .)) }}
{{- end }}
{{- if .Values.alertmanager.spec.configMaps }}
configMaps:
{{- range compact .Values.alertmanager.spec.configMaps }}
- {{ . }}
{{- end }}
{{- end }}
{{- if or .Values.alertmanager.monzoTemplate.enabled .Values.alertmanager.templateFiles }}
templates:
{{- $monzoTplConfigMap := printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "alertmanager-monzo-tpl" | trunc 63 | trimSuffix "-" }}
{{- if .Values.alertmanager.monzoTemplate.enabled }}
- name: {{ $monzoTplConfigMap }}
  key: monzo.tmpl
{{- end }}
{{- if .Values.alertmanager.templateFiles }}
{{- $extraTplConfigMap := printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "alertmanager-extra-tpl" | trunc 63 | trimSuffix "-" }}
{{- range $key, $value := .Values.alertmanager.templateFiles }}
- name: {{ $extraTplConfigMap }}
  key: {{ $key }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}



{{ define "vmalertProxyURL" }}
{{- if .Values.vmalert.enabled }}
{{- printf "http://vmalert-%s.%s.svc:8080" (include "victoria-metrics-k8s-stack.fullname" . ) .Release.Namespace  -}}
{{- end }}
{{- end }}

{{/*
Single spec
*/}}
{{ define "victoria-metrics-k8s-stack.VMSingleSpec" }}
{{- $extraArgsProxy := default dict -}}
{{- if .Values.vmalert.enabled }}
{{- $_ := set $extraArgsProxy "vmalert.proxyURL" (include "vmalertProxyURL" . ) -}}
{{- end }}
{{ tpl (deepCopy .Values.vmsingle.spec | mergeOverwrite (dict "extraArgs" $extraArgsProxy) | toYaml) . }}
{{- end }}


{{/*
Cluster spec
*/}}
{{ define "vmselectSpec" }}
vmselect:
  extraArgs:
    vmalert.proxyURL: {{ include "vmalertProxyURL" . | quote }}
{{- end }}


{{ define "victoria-metrics-k8s-stack.VMClusterSpec"}}
{{ tpl (deepCopy .Values.vmcluster.spec | mergeOverwrite ( include "vmselectSpec" . | fromYaml) | toYaml) . }}
{{- end }}

{{/*
VictoriaMetrics Datasource
*/}}
{{ define "victoria-metrics-k8s-stack.VMDataSource"}}
{{- $vmDSPluginEnabled := false }}
{{- if .Values.grafana.plugins }}
{{- range $value := .Values.grafana.plugins }}
{{- if (contains "victoriametrics-datasource" $value) }}
{{- $vmDSPluginEnabled = true }}
{{- end }}
{{- end }}
{{- end }}
{{- $vmAllowUnsigned := contains "victoriametrics-datasource" (dig "grafana.ini" "plugins" "allow_loading_unsigned_plugins" "" .Values.grafana) }}
{{- if (and $vmDSPluginEnabled $vmAllowUnsigned) }}
    - name: VictoriaMetrics (DS)
      type: victoriametrics-datasource
      {{- $readEndpoint:= (include "victoria-metrics-k8s-stack.vmReadEndpoint" . | fromYaml) }}
      url: {{ $readEndpoint.url }}
      access: proxy
      isDefault: false
      jsonData: {{ toYaml .Values.grafana.sidecar.datasources.jsonData | nindent 8 }}
{{- end }}
{{- end }}

{{/*
VMRule name
*/}}
{{- define "victoria-metrics-k8s-stack.rulegroup.name" -}}
{{- $id := include "victoria-metrics-k8s-stack.rulegroup.id" . -}}
{{ printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" .) $id | trunc 63 | trimSuffix "-" | trimSuffix "." }}
{{- end -}}

{{/*
VMRule annotations
*/}}
{{- define "victoria-metrics-k8s-stack.rulegroup.annotations" -}}
{{- with .Values.defaultRules.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
VMRule labels
*/}}
{{- define "victoria-metrics-k8s-stack.rulegroup.labels" -}}
app: {{ include "victoria-metrics-k8s-stack.name" . }}
{{ include "victoria-metrics-k8s-stack.labels" . }}
{{- with .Values.defaultRules.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
VMRule key
*/}}
{{- define "victoria-metrics-k8s-stack.rulegroup.key" -}}
{{ without (regexSplit "[-_.]" .name -1) "exporter" "rules" | join "-" | camelcase | untitle }}
{{- end -}}

{{/* 
VMRule ID
*/}}
{{- define "victoria-metrics-k8s-stack.rulegroup.id" -}}
{{ .name | replace "_" "" | trunc 63 | trimSuffix "-" | trimSuffix "." }}
{{- end -}}

{{/*
VMAlertmanager name
*/}}
{{- define "victoria-metrics-k8s-stack.alertmanager.name" -}}
{{ .Values.alertmanager.name | default (printf "%s-%s" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") }}
{{- end -}}
