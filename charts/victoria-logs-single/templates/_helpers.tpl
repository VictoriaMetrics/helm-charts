{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-logs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-logs.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
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
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "victoria-logs.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-logs.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "victoria-logs.server.labels" -}}
{{ include "victoria-logs.server.matchLabels" . }}
{{ include "victoria-logs.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-logs.server.matchLabels" -}}
app: {{ .Values.server.name }}
{{ include "victoria-logs.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "victoria-logs.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "split-host-port" -}}
{{- $hp := split ":" . -}}
{{- printf "%s" $hp._1 -}}
{{- end -}}

{{/*
Defines the name of scrape configuration map
*/}}
{{- define "victoria-logs.server.scrape.configname" -}}
{{- if .Values.server.scrape.configMap -}}
{{- .Values.server.scrape.configMap -}}
{{- else -}}
{{- include "victoria-logs.server.fullname" . -}}-scrapeconfig
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "victoria-logs.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "victoria-logs.ingress.isStable" -}}
  {{- eq (include "victoria-logs.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "victoria-logs.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "victoria-logs.ingress.isStable" .) "true") (and (eq (include "victoria-logs.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "victoria-logs.ingress.supportsPathType" -}}
  {{- or (eq (include "victoria-logs.ingress.isStable" .) "true") (and (eq (include "victoria-logs.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{- define "victoria-logs.hasInitContainer" -}}
    {{- (gt (len .Values.server.initContainers) 0) -}}
{{- end -}}

{{- define "victoria-logs.initContiners" -}}
{{- if eq (include "victoria-logs.hasInitContainer" . ) "true" -}}
{{- with .Values.server.initContainers -}}
{{ toYaml . }}
{{- end -}}
{{- else -}}
[]
{{- end -}}
{{- end -}}
