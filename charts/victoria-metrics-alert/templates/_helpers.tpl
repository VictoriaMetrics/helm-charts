{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "vmalert.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vmalert.fullname" -}}
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
{{- define "vmalert.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create unified labels for vmalert components
*/}}
{{- define "vmalert.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "vmalert.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "vmalert.common.metaLabels" -}}
helm.sh/chart: {{ include "vmalert.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "vmalert.server.labels" -}}
{{ include "vmalert.server.matchLabels" . }}
{{ include "vmalert.common.metaLabels" . }}
{{- end -}}

{{- define "vmalert.server.matchLabels" -}}
app: {{ .Values.server.name }}
{{ include "vmalert.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vmalert.server.fullname" -}}
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


{{- define "vmalert.server.configname" -}}
{{- if .Values.server.configMap -}}
{{- .Values.server.configMap -}}
{{- else -}}
{{- include "vmalert.server.fullname" . -}}-alert-rules-config
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "vmalert.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "vmalert.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}



{{- define "vmalert.alertmanager.labels" -}}
{{ include "vmalert.alertmanager.matchLabels" . }}
{{ include "vmalert.common.metaLabels" . }}
{{- end -}}

{{- define "vmalert.alertmanager.matchLabels" -}}
app: alertmanager
{{ include "vmalert.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vmalert.alertmanager.fullname" -}}
{{- printf "%s-%s" .Release.Name "alertmanager" -}}
{{- end -}}

{{- define "vmalert.alertmanager.configname" -}}
{{- if .Values.alertmanager.configMap -}}
{{- .Values.alertmanager.configMap -}}
{{- else -}}
{{- include "vmalert.alertmanager.fullname" . -}}-alertmanager-config
{{- end -}}
{{- end -}}


{{/*
Create base alertmanager url for notifers
*/}}
{{- define "vmalert.alertmanager.url" -}}
{{- if .Values.alertmanager.enabled -}}
http://{{- include "vmalert.alertmanager.fullname" . -}}:9093{{ .Values.alertmanager.baseURLPrefix }}
{{- else -}}
{{- .Values.server.notifier.alertmanager.url -}}
{{- end -}}
{{- end -}}

{{- define "vmalert.alertmanager.urls" -}}
{{- $urls := list -}}
{{- with (include "vmalert.alertmanager.url" .) -}}
{{- $urls = append $urls . -}}
{{- end -}}
{{- range .Values.server.notifiers }}
    {{- if not (eq .alertmanager.url "") -}}
        {{- $urls = append $urls .alertmanager.url -}}
    {{- end -}}
{{- end -}}
{{- join "," $urls }}
{{- end -}}

{{- define "vmalert.alertmanager.passwords" -}}
{{- $password := list -}}
{{- if .Values.alertmanager.enabled -}}
{{- $password = append $password "" -}}
{{- end -}}
{{- $notifiers := append .Values.server.notifiers .Values.server.notifier }}
{{- range $notifiers }}
    {{- if not (eq .alertmanager.url "") -}}
        {{- if and .alertmanager.basicAuth .alertmanager.basicAuth.password -}}
            {{- $password = append $password .alertmanager.basicAuth.password -}}
        {{- else -}}
            {{- $password = append $password "" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{ include "_vmalert.optionalPrintList" $password }}
{{- end -}}

{{- define "vmalert.alertmanager.usernames" -}}
{{- $usernames := list -}}
{{- if .Values.alertmanager.enabled -}}
{{- $usernames = append $usernames "" -}}
{{- end -}}
{{- $notifiers := append .Values.server.notifiers .Values.server.notifier }}
{{- range $notifiers }}
    {{- if not (eq .alertmanager.url "") -}}
        {{- if and .alertmanager.basicAuth .alertmanager.basicAuth.username -}}
            {{- $usernames = append $usernames .alertmanager.basicAuth.username -}}
        {{- else -}}
            {{- $usernames = append $usernames "" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{ include "_vmalert.optionalPrintList" $usernames }}
{{- end -}}

{{- define "vmalert.alertmanager.bearerTokens" -}}
{{- $tokens := list -}}
{{- if .Values.alertmanager.enabled -}}
{{- $tokens = append $tokens "" -}}
{{- end -}}
{{- $notifiers := append .Values.server.notifiers .Values.server.notifier }}
{{- range $notifiers }}
    {{- if not (eq .alertmanager.url "") -}}
        {{- if and .alertmanager.bearer .alertmanager.bearer.token -}}
            {{- $tokens = append $tokens .alertmanager.bearer.token -}}
        {{- else -}}
            {{- $tokens = append $tokens "" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{ include "_vmalert.optionalPrintList" $tokens }}
{{- end -}}


{{- define "vmalert.alertmanager.bearerTokenFiles" -}}
{{- $files := list -}}
{{- if .Values.alertmanager.enabled -}}
{{- $files = append $files "" -}}
{{- end -}}
{{- $notifiers := append .Values.server.notifiers .Values.server.notifier }}
{{- range $notifiers }}
    {{- if not (eq .alertmanager.url "") -}}
        {{- if and .alertmanager.bearer .alertmanager.bearer.tokenFile -}}
            {{- $files = append $files .alertmanager.bearer.tokenFile -}}
        {{- else -}}
            {{- $files = append $files "" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{ include "_vmalert.optionalPrintList" $files }}
{{- end -}}

{{- define "_vmalert.optionalPrintList" }}
{{- $str := join "," . -}}
{{- $cleared := $str | replace "," "" | trim -}}
{{- if eq $cleared "" -}}
{{ $cleared }}
{{- else -}}
{{ $str }}
{{- end -}}
{{- end -}}

{{- define "alertmanager.args" -}}
  {{- $app := .Values.alertmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "config.file" "/config/alertmanager.yaml" -}}
  {{- $_ := set $args "storage.path" (ternary $app.persistentVolume.mountPath "/data" $app.persistentVolume.enabled) -}}
  {{- $_ := set $args "data.retention" $app.retention -}}
  {{- $_ := set $args "web.listen-address" $app.listenAddress -}}
  {{- $_ := set $args "cluster.advertise-address" "[$(POD_IP)]:6783" -}}
  {{- with $app.baseURL -}}
    {{- $_ := set $args "web.external-url" $app.baseURL -}}
  {{- end -}}
  {{ with $app.baseURLPrefix }}
    {{- $_ := set $args "web.route-prefix" $app.baseURLPrefix -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmalert.args" -}}
  {{- $app := .Values.server -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "rule" "/config/alert-rules.yaml" -}}
  {{- $_ := set $args "datasource.url" $app.datasource.url -}}
  {{- if or $app.datasource.basicAuth.password $app.datasource.basicAuth.username -}}
    {{- $_ := set $args "datasource.basicAuth.password" $app.datasource.basicAuth.password -}}
    {{- $_ := set $args "datasource.basicAuth.username" $app.datasource.basicAuth.username -}}
  {{- end -}}
  {{- with $app.datasource.bearer.token -}}
    {{- $_ := set $args "datasource.bearerToken" . -}}
  {{- end -}}
  {{- with $app.datasource.bearer.tokenFile -}}
    {{- $_ := set $args "datasource.bearerTokenFile" . -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.urls" .) }}
    {{- $_ := set $args "notifier.url" . -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.passwords" .) -}}
    {{- $_ := set $args "notifier.basicAuth.password" . -}}
  {{- end }}
  {{- with (include "vmalert.alertmanager.usernames" .) -}}
    {{- $_ := set $args "notifier.basicAuth.username" . -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.bearerTokens" .) -}}
    {{- $_ := set $args "notifier.bearerToken" . -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.bearerTokenFiles" .) -}}
    {{- $_ := set $args "notifier.bearerTokenFile" . -}}
  {{- end -}}
  {{- with $app.remote.read.url }}
    {{- $_ := set $args "remoteRead.url" . -}}
  {{- end -}}
  {{- if or $app.remote.read.basicAuth.password $app.remote.read.basicAuth.username -}}
    {{- $_ := set $args "remoteRead.basicAuth.password" $app.remote.read.basicAuth.password -}}
    {{- $_ := set $args "remoteRead.basicAuth.username" $app.remote.read.basicAuth.username -}}
  {{- end -}}
  {{- with $app.remote.read.bearer.token }}
    {{- $_ := set $args "remoteRead.bearerToken" . -}}
  {{- end -}}
  {{- with $app.remote.read.bearer.tokenFile -}}
    {{- $_ := set $args "remoteRead.bearerTokenFile" . -}}
  {{- end -}}
  {{- with $app.remote.write.url -}}
    {{- $_ := set $args "remoteWrite.url" . -}}
  {{- end -}}
  {{- if or $app.remote.write.basicAuth.password $app.remote.write.basicAuth.username -}}
    {{- $_ := set $args "remoteWrite.basicAuth.password" $app.remote.write.basicAuth.password -}}
    {{- $_ := set $args "remoteWrite.basicAuth.username" $app.remote.write.basicAuth.username -}}
  {{- end -}}
  {{- with $app.remote.write.bearer.token -}}
    {{- $_ := set $args "remoteWrite.bearerToken" . -}}
  {{- end -}}
  {{- with $app.remote.write.bearer.tokenFile -}}
    {{- $_ := set $args "remoteWrite.bearerTokenFile" . -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
