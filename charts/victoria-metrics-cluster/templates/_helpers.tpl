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
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "victoria-metrics.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-metrics.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-metrics.common.podLabels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
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
{{- .Values.vmstorage.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.vmstorage.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.vmstorage.name | trunc 63 | trimSuffix "-" -}}
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
Create a fully qualified vminsert name.
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
  {{- $svc := include "victoria-metrics.vmstorage.fullname" . -}}
  {{- $namespace := (include "vm.namespace" .) -}}
  {{- $dnsSuffix := .Values.clusterDomainSuffix -}}
  {{- $storageNodes := default list -}}
  {{- range $i := until (.Values.vmstorage.replicaCount | int) -}}
    {{- $value := printf "%s-%d.%s.%s.svc.%s:8400" $svc $i $svc $namespace $dnsSuffix -}}
    {{- $storageNodes = append $storageNodes $value -}}
  {{- end -}}
  {{- toYaml (dict "storageNode" $storageNodes) -}}
{{- end -}}

{{- define "victoria-metrics.vmselect.vmstorage-pod-fqdn" -}}
  {{- $svc := include "victoria-metrics.vmstorage.fullname" . -}}
  {{- $namespace := (include "vm.namespace" .) -}}
  {{- $dnsSuffix := .Values.clusterDomainSuffix -}}
  {{- $storageNodes := default list -}}
  {{- range $i := until (.Values.vmstorage.replicaCount | int) -}}
    {{- $value := printf "%s-%d.%s.%s.svc.%s:8401" $svc $i $svc $namespace $dnsSuffix -}}
    {{- $storageNodes = append $storageNodes $value -}}
  {{- end -}}
  {{- toYaml (dict "storageNode" $storageNodes) -}}
{{- end -}}

{{- define "victoria-metrics.vmselect.vmselect-pod-fqdn" -}}
  {{- $svc := include "victoria-metrics.vmselect.fullname" . -}}
  {{- $namespace := (include "vm.namespace" .) -}}
  {{- $dnsSuffix := .Values.clusterDomainSuffix -}}
  {{- $port := "8481" }}
  {{- with .Values.vmselect.extraArgs.httpListenAddr }}
    {{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" }}
  {{- end -}}
  {{- $selectNodes := default list -}}
  {{- range $i := until (.Values.vmselect.replicaCount | int) -}}
    {{- $value := printf "%s-%d.%s.%s.svc.%s:%s" $svc $i $svc $namespace $dnsSuffix $port -}}
    {{- $selectNodes = append $selectNodes $value -}}
  {{- end -}}
  {{- toYaml (dict "selectNode" $selectNodes) -}}
{{- end -}}

{{- define "vminsert.args" -}}
  {{- $app := .Values.vminsert -}}
  {{- $args := default dict -}}
  {{- if not (or $app.suppresStorageFQDNsRender $app.suppressStorageFQDNsRender) }}
    {{- $args = (fromYaml (include "victoria-metrics.vminsert.vmstorage-pod-fqdn" .)) }}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmselect.args" -}}
  {{- $app := .Values.vmselect -}}
  {{- $args := default dict -}}
  {{- if not (or $app.suppressStorageFQDNsRender $app.suppresStorageFQDNsRender) }}
    {{- $args = (fromYaml (include "victoria-metrics.vmselect.vmstorage-pod-fqdn" .)) -}}
  {{- end -}}
  {{- if .Values.vmselect.statefulSet.enabled }}
    {{- with (include "victoria-metrics.vmselect.vmselect-pod-fqdn" .) -}}
      {{- $args = mergeOverwrite $args (fromYaml .) -}}
    {{- end -}}
  {{- end -}}
  {{- $_ := set $args "cacheDataPath" $app.cacheMountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmstorage.args" -}}
  {{- $app := .Values.vmstorage -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "retentionPeriod" (toString $app.retentionPeriod) -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.args" -}}
  {{- $app := .Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "disableHourly" $manager.disableHourly -}}
  {{- $_ := set $args "disableDaily" $manager.disableDaily -}}
  {{- $_ := set $args "disableWeekly" $manager.disableWeekly -}}
  {{- $_ := set $args "disableMonthly" $manager.disableMonthly -}}
  {{- $_ := set $args "keepLastHourly" $manager.retention.keepLastHourly -}}
  {{- $_ := set $args "keepLastDaily" $manager.retention.keepLastDaily -}}
  {{- $_ := set $args "keepLastWeekly" $manager.retention.keepLastWeekly -}}
  {{- $_ := set $args "keepLastMonthly" $manager.retention.keepLastMonthly -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $_ := set $args "dst" (printf "%s/$(POD_NAME)" $manager.destination) -}}
  {{- $_ := set $args "snapshot.createURL" "http://localhost:8482/snapshot/create" -}}
  {{- $_ := set $args "snapshot.deleteURL" "http://localhost:8482/snapshot/delete" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.restore.args" -}}
  {{- $app := .Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "restore") $output -}}
  {{- toYaml $output -}}
{{- end -}}
