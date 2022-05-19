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
Create the name of service account and clusterRole for cleanup-hook
*/}}
{{- define "victoria-metrics-k8s-stack.cleanupHookName" -}}
{{- if .Values.operator.cleanupSA.create }}
{{- default ("victoria-metrics-k8s-stack-cleanup-hook") .Values.operator.cleanupSA.name }}
{{- else }}
{{- default "default" .Values.operator.cleanupSA.name }}
{{- end }}
{{- end }}


{{/*
Create the name for VMSingle
*/}}
{{- define "victoria-metrics-k8s-stack.vmsingleName" -}}
{{- .Values.vmsingle.name | default (printf "vmsingle-%s" (include "victoria-metrics-k8s-stack.fullname" .))}}
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


{{- define "victoria-metrics-k8s-stack.vmSelectEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
{{ printf "http://%s.%s.svc:%s" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default "8429") }}
{{- else if .Values.vmcluster.enabled -}}
{{ printf "http://%s-%s.%s.svc:%s/select/0/prometheus" "vmselect" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace (.Values.vmcluster.spec.vmselect.port | default "8481") }}
{{- end }}
{{- end }}

{{- define "victoria-metrics-k8s-stack.vmSingleInsertEndpoint" -}}
{{ printf "http://%s.%s.svc:%s" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default "8429") }}
{{- end }}
{{- define "victoria-metrics-k8s-stack.vmClusterInsertEndpoint" -}}
{{ printf "http://%s-%s.%s.svc:%s/insert/0/prometheus" "vminsert" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace (.Values.vmcluster.spec.vminsert.port | default "8480") }}
{{- end }}

{{/*
  for VMAlert remote
*/}}
{{- define "victoria-metrics-k8s-stack.vmInsertEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
{{ include "victoria-metrics-k8s-stack.vmSingleInsertEndpoint" . }}
{{- else if .Values.vmcluster.enabled -}}
{{ include "victoria-metrics-k8s-stack.vmClusterInsertEndpoint" . }}
{{- end }}
{{- end }}


{{/*
VMAlert remotes 
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertRemotes" -}}
remoteWrite:
     url: {{ include "victoria-metrics-k8s-stack.vmInsertEndpoint" . }}
remoteRead:
     url: {{ include "victoria-metrics-k8s-stack.vmSelectEndpoint" . }}
datasource:
     url: {{ include "victoria-metrics-k8s-stack.vmSelectEndpoint" . }}
notifiers:
    - url: {{ printf "http://%s-%s.%s.svc:9093" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace }}
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
{{ deepCopy .Values.vmalert.spec | mergeOverwrite (include "victoria-metrics-k8s-stack.vmAlertRemotes" . | fromYaml) | mergeOverwrite (include "victoria-metrics-k8s-stack.vmAlertTemplates" . | fromYaml) | mergeOverwrite (dict "extraArgs" $extraArgs) | toYaml }}
{{- end }}


{{/*
VM Agent remoteWrites
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentRemoteWrite" -}}
remoteWrite:
{{- if .Values.vmsingle.enabled }}
- url: {{ include "victoria-metrics-k8s-stack.vmSingleInsertEndpoint" . }}/api/v1/write
{{- end }}
{{- if .Values.vmcluster.enabled }}
- url: {{  include "victoria-metrics-k8s-stack.vmClusterInsertEndpoint" . }}/api/v1/write
{{- end }}
{{ range .Values.vmagent.additionalRemoteWrites }}
-{{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
VMAgent spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentSpec" -}}
{{ deepCopy .Values.vmagent.spec | mergeOverwrite ( include "victoria-metrics-k8s-stack.vmAgentRemoteWrite" . | fromYaml) | toYaml }}
{{- end }}


{{/*
Alermanager spec
*/}}
{{- define "victoria-metrics-k8s-stack.alertmanagerSpec" -}}
{{ omit .Values.alertmanager.spec  "configMaps" "configSecret" | toYaml }}
configSecret: {{ .Values.alertmanager.spec.configSecret | default (printf "%s-alertmanager" (include "victoria-metrics-k8s-stack.fullname" .)) }}
{{- if or .Values.alertmanager.spec.configMaps .Values.alertmanager.monzoTemplate.enabled .Values.alertmanager.templateFiles }}
{{- $list := .Values.alertmanager.spec.configMaps | default (list "") }}
{{- if .Values.alertmanager.monzoTemplate.enabled }}
{{- $list = append $list (printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "alertmanager-monzo-tpl" | trunc 63 | trimSuffix "-") }}
{{- end }}
{{- if .Values.alertmanager.templateFiles }}
{{- $list = append $list (printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "alertmanager-extra-tpl" | trunc 63 | trimSuffix "-") }}
{{- end }}
configMaps:
{{- range compact $list }}
- {{ . }}
{{- end }}
{{- end }}
{{- end }}

