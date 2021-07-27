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
{{ printf "http://%s.%s.svc:%d" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default 8429) }}
{{- end }}
{{- if .Values.vmcluster.enabled -}}
{{ printf "http://%s-%s.%s.svc:%d/select/0/prometheus" "vmselect" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace (.Values.vmcluster.spec.vmselect.port | default 8481) }}
{{- end }}
{{- end }}

{{- define "victoria-metrics-k8s-stack.vmInsertEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
{{ printf "http://%s.%s.svc:%d" (include "victoria-metrics-k8s-stack.vmsingleName" .) .Release.Namespace (.Values.vmsingle.spec.port | default 8429) }}
{{- end }}
{{- if .Values.vmcluster.enabled -}}
{{ printf "http://%s-%s.%s.svc:%d/insert/0" "vminsert" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace (.Values.vmcluster.spec.vminsert.port | default 8480) }}
{{- end }}
{{- end }}


{{/*
VMAlert remotes 
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertRemotes" -}}
remoteWrite:
    - url: {{ include "victoria-metrics-k8s-stack.vmInsertEndpoint" . }}
remoteRead:
    - url: {{ include "victoria-metrics-k8s-stack.vmSelectEndpoint" . }}
datasource:
    - url: {{ include "victoria-metrics-k8s-stack.vmSelectEndpoint" . }}
notifier:
    - url: {{ printf "http://%s-%s.%s.svc:9093" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace }}
{{- end }}

{{/*
VMAlert spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertSpec" -}}
{{ deepCopy .Values.vmalert.spec | mergeOverwrite (include "victoria-metrics-k8s-stack.vmAlertRemotes" . | fromYaml) | toYaml }}
{{- end }}


{{/*
VM Agent remoteWrite
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentRemoteWrite" -}}
remoteWrite:
    - url: {{ include "victoria-metrics-k8s-stack.vmInsertEndpoint" . }}/api/v1/write
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
{{- if or .Values.alertmanager.spec.configMaps .Values.alertmanager.monzoTemplate.enabled }}
{{- $list := .Values.alertmanager.spec.configMaps | default (list "") }}
{{- if .Values.alertmanager.monzoTemplate.enabled }}
{{- $list = append $list (printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" $) "alertmanager-monzo-tpl" | trunc 63 | trimSuffix "-") }}
{{- end }}
configMaps:
{{- range compact $list }}
- {{ . }}
{{- end }}
{{- end }}
{{- end }}