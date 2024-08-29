{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-logs.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-logs.fullname" -}}
{{- if .Values.global.victoriaLogs.server.fullnameOverride -}}
{{- .Values.global.victoriaLogs.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "victoria-logs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}

{{/*
Create unified labels for victoria-logs components
*/}}
{{- define "victoria-logs.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "victoria-logs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "victoria-logs.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-logs.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-logs.server.labels" -}}
{{ include "victoria-logs.server.matchLabels" . }}
{{ include "victoria-logs.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-logs.server.matchLabels" -}}
app: {{ .Values.global.victoriaLogs.server.name }}
{{ include "victoria-logs.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Use hardcoded default value as this template will be used in Fluent Bit chart
and .Chart.Name will be "fluent-bit" in sub-chart context.
*/}}
{{- define "victoria-logs.server.fullname" -}}
{{- if .Values.global.victoriaLogs.server.fullnameOverride -}}
{{- .Values.global.victoriaLogs.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}

{{- $name := default "victoria-logs-single" .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.global.victoriaLogs.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.global.victoriaLogs.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "vlogs.args" -}}
  {{- $app := .Values.server -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "retentionPeriod" $app.retentionPeriod -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
