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

{{/*
VM endpoint
*/}}
{{- define "victoria-metrics-k8s-stack.vmEndpoint" -}}
{{- if .Values.vmsingle.enabled -}}
url: "http://{{ include "victoria-metrics-k8s-stack.vmsingleName" .}}.{{ .Release.Namespace }}.svc:{{ .Values.vmsingle.spec.port | default 8429 }}"
{{- end }}
{{- end }}


{{/*
Alermanager config secret name
*/}}
{{- define "victoria-metrics-k8s-stack.alertmanagerConfigSecret" -}}
{{- if .Values.alertmanager.secretName -}}
configSecret: {{ .Values.alertmanager.secretName | default (printf "%s-alertmanager" (include "victoria-metrics-k8s-stack.fullname" .)) }}
{{- else -}}
configSecret: {{ .Values.alertmanager.spec.configSecret | default (printf "%s-alertmanager" (include "victoria-metrics-k8s-stack.fullname" .)) }}
{{- end }}
{{- end }}

{{/*
Alermanager spec
*/}}
{{- define "victoria-metrics-k8s-stack.alertmanagerSpec" -}}
{{ deepCopy (include "victoria-metrics-k8s-stack.alertmanagerConfigSecret" . | fromYaml ) | mergeOverwrite ( .Values.alertmanager.spec ) | toYaml }}
{{- end }}

{{/*
VMAlert spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAlertSpec" -}}
{{- $vmAlertStackRemoteWrite := dict "remoteWrite" ( include "victoria-metrics-k8s-stack.vmEndpoint" . | fromYaml ) -}}
{{- $vmAlertStackRemoteRead := dict "remoteRead" ( include "victoria-metrics-k8s-stack.vmEndpoint" . | fromYaml ) -}}
{{- $vmAlertStackDatasource := dict "datasource" ( include "victoria-metrics-k8s-stack.vmEndpoint" . | fromYaml ) -}}
{{- $vmAlertStackNotifier := dict "notifier"  ( dict "url" ( printf "http://vmalertmanager-%s.%s.svc:9094" (include "victoria-metrics-k8s-stack.fullname" .) .Release.Namespace ) ) -}}
{{ deepCopy .Values.vmalert.spec | mergeOverwrite $vmAlertStackRemoteWrite $vmAlertStackRemoteRead $vmAlertStackDatasource $vmAlertStackNotifier | toYaml }}
{{- end }}


{{/*
VM remoteWrite
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentRemoteWrite" -}}
remoteWrite:
    - url: "http://{{ .Values.vmsingle.name | default (printf "vmsingle-%s" (include "victoria-metrics-k8s-stack.fullname" .))}}.{{ .Release.Namespace }}.svc:{{ .Values.vmsingle.spec.port | default 8429 }}/api/v1/write"
{{- end }}

{{/*
VMAgent spec
*/}}
{{- define "victoria-metrics-k8s-stack.vmAgentSpec" -}}
{{ deepCopy .Values.vmagent.spec | mergeOverwrite ( include "victoria-metrics-k8s-stack.vmAgentRemoteWrite" . | fromYaml ) | toYaml }}
{{- end }}
