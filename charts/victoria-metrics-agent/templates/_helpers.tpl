{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
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
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml .}}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "chart.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Defines the name of configuration map
*/}}
{{- define "chart.configname" -}}
{{- if .Values.configMap -}}
{{- .Values.configMap -}}
{{- else -}}
{{- include "chart.fullname" . -}}-config
{{- end -}}
{{- end -}}

{{- define "vmagent.args" -}}
  {{- $args := default dict -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if empty $Values.remoteWrite -}}
    {{- fail "Please define at least one remoteWrite" -}}
  {{- end -}}
  {{- $_ := set $args "promscrape.config" "/config/scrape/scrape.yml" -}}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/tmpData" -}}
  {{- range $i, $rw := $Values.remoteWrite -}}
    {{- if not $rw.url -}}
      {{- fail (printf "`url` is not set for `remoteWrite` idx %d" $i) -}}
    {{- end -}}
    {{- range $rwKey, $rwValue := $rw -}}
      {{- $key := printf "remoteWrite.%s" $rwKey -}}
      {{- $param := index $args $key | default list -}}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) -}}
        {{- $param = append $param (printf "/config/rw/%d-%s.yaml" $i $rwKey) -}}
      {{- else -}}
        {{- $param = append $param $rwValue -}}
      {{- end -}}
      {{- $_ := set $args $key $param -}}
    {{- end -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- if and $Values.statefulset.enabled $Values.statefulset.clusterMode }}
    {{- $_ := set $args "promscrape.cluster.membersCount" $Values.replicaCount -}}
    {{- $_ := set $args "promscrape.cluster.replicationFactor" $Values.statefulset.replicationFactor -}}
    {{- $_ := set $args "promscrape.cluster.memberNum" "$(POD_NAME)" -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "chart.rw.config" -}}
  {{- $rwcm := default dict }}
  {{- range $i, $rw := .Values.remoteWrite }}
    {{- range $rwKey, $rwValue := $rw }}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) }}
        {{- $_ := set $rwcm (printf "%d-%s.yaml" $i $rwKey) (toYaml $rwValue) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $rwcm -}}
{{- end -}}
