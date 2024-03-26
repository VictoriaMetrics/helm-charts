{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-metrics.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-metrics.fullname" -}}
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
{{- define "victoria-metrics.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "victoria-metrics.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "victoria-metrics.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create unified labels for victoria-metrics components
*/}}
{{- define "victoria-metrics.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "victoria-metrics.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "victoria-metrics.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-metrics.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "victoria-metrics.common.podLabels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.labels" -}}
{{ include "victoria-metrics.vmstorage.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.podLabels" -}}
{{ include "victoria-metrics.vmstorage.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.matchLabels" -}}
app: {{ .Values.vmstorage.name }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.labels" -}}
{{ include "victoria-metrics.vmselect.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.podLabels" -}}
{{ include "victoria-metrics.vmselect.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.matchLabels" -}}
app: {{ .Values.vmselect.name }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.labels" -}}
{{ include "victoria-metrics.vminsert.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.podLabels" -}}
{{ include "victoria-metrics.vminsert.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.matchLabels" -}}
app: {{ .Values.vminsert.name }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified vmstorage name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "victoria-metrics.vmstorage.fullname" -}}
{{- if .Values.vmstorage.fullnameOverride -}}
{{- .Values.vmstorage.fullnameOverride | trunc 60 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.vmstorage.name | trunc 60 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.vmstorage.name | trunc 60 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified vmselect name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "victoria-metrics.vmselect.fullname" -}}
{{- if .Values.vmselect.fullnameOverride -}}
{{- .Values.vmselect.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.vmselect.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.vmselect.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified vmselect name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "victoria-metrics.vminsert.fullname" -}}
{{- if .Values.vminsert.fullnameOverride -}}
{{- .Values.vminsert.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.vminsert.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.vminsert.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "victoria-metrics.vminsert.vmstorage-pod-fqdn" -}}
{{- $pod := include "victoria-metrics.vmstorage.fullname" . -}}
{{- $svc := include "victoria-metrics.vmstorage.fullname" . -}}
{{- $namespace := .Release.Namespace -}}
{{- $dnsSuffix := .Values.clusterDomainSuffix -}}
{{- range $i := until (.Values.vmstorage.replicaCount | int) -}}
{{- printf "- --storageNode=%s-%d.%s.%s.svc.%s:8400\n" $pod $i $svc $namespace $dnsSuffix -}}
{{- end -}}
{{- end -}}

{{- define "victoria-metrics.vmselect.vmstorage-pod-fqdn" -}}
{{- $pod := include "victoria-metrics.vmstorage.fullname" . -}}
{{- $svc := include "victoria-metrics.vmstorage.fullname" . -}}
{{- $namespace := .Release.Namespace -}}
{{- $dnsSuffix := .Values.clusterDomainSuffix -}}
{{- range $i := until (.Values.vmstorage.replicaCount | int) -}}
{{- printf "- --storageNode=%s-%d.%s.%s.svc.%s:8401\n" $pod $i $svc $namespace $dnsSuffix -}}
{{- end -}}
{{- end -}}

{{- define "victoria-metrics.vmselect.vmselect-pod-fqdn" -}}
{{- $pod := include "victoria-metrics.vmselect.fullname" . -}}
{{- $svc := include "victoria-metrics.vmselect.fullname" . -}}
{{- $namespace := .Release.Namespace -}}
{{- $dnsSuffix := .Values.clusterDomainSuffix -}}
{{- range $i := until (.Values.vmselect.replicaCount | int) -}}
{{- printf "- --selectNode=%s-%d.%s.%s.svc.%s:8481\n" $pod $i $svc $namespace $dnsSuffix -}}
{{- end -}}
{{- end -}}

{{- define "split-host-port" -}}
{{- $hp := split ":" . -}}
{{- printf "%s" $hp._1 -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "victoria-metrics.ingress.apiVersion" -}}
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
{{- define "victoria-metrics.ingress.isStable" -}}
  {{- eq (include "victoria-metrics.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "victoria-metrics.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "victoria-metrics.ingress.isStable" .) "true") (and (eq (include "victoria-metrics.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "victoria-metrics.ingress.supportsPathType" -}}
  {{- or (eq (include "victoria-metrics.ingress.isStable" .) "true") (and (eq (include "victoria-metrics.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}


{{- define "victoria-metrics.storage.hasInitContainer" -}}
    {{- or (gt (len .Values.vmstorage.initContainers) 0)  .Values.vmstorage.vmbackupmanager.restore.onStart.enabled -}}
{{- end -}}

{{- define "victoria-metrics.storage.initContiners" -}}
{{- if eq (include "victoria-metrics.storage.hasInitContainer" . ) "true" -}}
{{- with .Values.vmstorage.initContainers -}}
{{ toYaml . }}
{{- end -}}
{{- if .Values.vmstorage.vmbackupmanager.restore.onStart.enabled }}
- name: {{ template "victoria-metrics.name" . }}-vmbackupmanager-restore
  image: "{{ .Values.vmstorage.vmbackupmanager.image.repository }}:{{ .Values.vmstorage.vmbackupmanager.image.tag }}"
  imagePullPolicy: "{{ .Values.vmstorage.image.pullPolicy }}"
  {{- with .Values.vmstorage.podSecurityContext }}
  securityContext:  {{ toYaml . | nindent 4 }}
  {{- end }}
  args:
    - restore
    - {{ printf "%s=%t" "--eula" .Values.vmstorage.vmbackupmanager.eula | quote}}
    - {{ printf "%s=%s" "--storageDataPath" .Values.vmstorage.persistentVolume.mountPath | quote}}
    {{- range $key, $value := .Values.vmstorage.vmbackupmanager.extraArgs }}
    - --{{ $key }}={{ $value }}
    {{- end }}
  {{- with .Values.vmstorage.vmbackupmanager.resources }}
  resources: {{ toYaml . | nindent 4 }}
  {{- end }}
  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
  {{- with .Values.vmstorage.vmbackupmanager.env }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
  ports:
    - name: manager-http
      containerPort: 8300
  volumeMounts:
    - name: vmstorage-volume
      mountPath: {{ .Values.vmstorage.persistentVolume.mountPath }}
      subPath: {{ .Values.vmstorage.persistentVolume.subPath }}
    {{- range .Values.vmstorage.vmbackupmanager.extraSecretMounts }}
    - name: {{ .name }}
      mountPath: {{ .mountPath }}
      subPath: {{ .subPath }}
    {{- end }}
{{- end }}
{{- else -}}
[]
{{- end -}}
{{- end -}}

{{/*
Return license flag if necessary.
*/}}
{{- define "chart.license.flag" -}}
{{- if .Values.license.key -}}
--license={{ .Values.license.key }}
{{- end }}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
--licenseFile=/etc/vm-license-key/{{ .Values.license.secret.key }}
{{- end -}}
{{- end -}}


{{/*
Return license volume mount
*/}}
{{- define "chart.license.volume" -}}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
- name: license-key
  secret:
    secretName: {{ .Values.license.secret.name }}
{{- end -}}
{{- end -}}

{{/*
Return license volume mount for container
*/}}
{{- define "chart.license.mount" -}}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
- name: license-key
  mountPath: /etc/vm-license-key
  readOnly: true
{{- end -}}
{{- end -}}

{{/*
Enforce license for vmbackupmanager
*/}}
{{- define "chart.vmbackupmanager.enforce_license" -}}
{{ if and .Values.vmstorage.vmbackupmanager.enable (not (or .Values.vmstorage.vmbackupmanager.eula .Values.license.key .Values.license.secret.name)) }}
{{ fail `Pass -eula command-line flag or valid license at .Values.license if you have an enterprise license for running this software.
  See https://victoriametrics.com/legal/esa/ for details.
  Documentation - https://docs.victoriametrics.com/enterprise.html
  for more information, visit https://victoriametrics.com/products/enterprise/
  To request a trial license, go to https://victoriametrics.com/products/enterprise/trial/`}}
{{- end -}}
{{- end -}}
