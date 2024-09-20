{{/*
Create unified labels for vmalert components
*/}}
{{- define "vmalert.common.matchLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "vmalert.common.metaLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
helm.sh/chart: {{ include "vm.chart" . }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "vmalert.server.labels" -}}
{{ include "vmalert.server.matchLabels" . }}
{{ include "vmalert.common.metaLabels" . }}
{{- end -}}

{{- define "vmalert.server.matchLabels" -}}
  {{- $ctx := . -}}
  {{- if not (hasKey . "helm") -}}
    {{- $ctx = dict "helm" . }}
  {{- end -}}
  {{- $_ := set $ctx "appKey" "server" -}}
app: {{ include "vm.app.name" $ctx }}
{{ include "vmalert.common.matchLabels" $ctx }}
{{- end -}}

{{- define "vmalert.server.configname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.server.configMap -}}
    {{- $Values.server.configMap -}}
  {{- else -}}
    {{- $ctx := . -}}
    {{- if not (hasKey . "helm") -}}
      {{- $ctx = dict "helm" . }}
    {{- end -}}
    {{- $_ := set $ctx "appKey" "server" -}}
    {{- include "vm.plain.fullname" $ctx -}}-rules-config
  {{- end -}}
{{- end -}}

{{- define "vmalert.alertmanager.labels" -}}
{{ include "vmalert.alertmanager.matchLabels" . }}
{{ include "vmalert.common.metaLabels" . }}
{{- end -}}

{{- define "vmalert.alertmanager.matchLabels" -}}
  {{- $ctx := . -}}
  {{- if not (hasKey . "helm") -}}
    {{- $ctx = dict "helm" . }}
  {{- end -}}
  {{- $_ := set $ctx "appKey" "alertmanager" -}}
app: {{ include "vm.app.name" $ctx }}
{{ include "vmalert.common.matchLabels" $ctx }}
{{- end -}}

{{- define "vmalert.alertmanager.configname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.alertmanager.configMap -}}
    {{- $Values.alertmanager.configMap -}}
  {{- else -}}
    {{- $ctx := . -}}
    {{- if not (hasKey . "helm") -}}
      {{- $ctx = dict "helm" . }}
    {{- end -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- include "vm.plain.fullname" $ctx -}}-config
  {{- end -}}
{{- end -}}

{{/*
Create base alertmanager url for notifers
*/}}
{{- define "vmalert.alertmanager.url" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $ctx := . -}}
    {{- if not (hasKey . "helm") -}}
      {{- $ctx = dict "helm" . }}
    {{- end -}}
    {{- $_ := set $ctx "style" "plain" -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- $appSecure := not (empty (($Values.alertmanager).webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" ($Values.alertmanager).baseURLPrefix -}}
    {{- include "vm.url" $ctx -}}
  {{- else -}}
    {{- $Values.server.notifier.alertmanager.url -}}
  {{- end -}}
{{- end -}}

{{- define "vmalert.alertmanager.urls" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $urls := list -}}
  {{- with (include "vmalert.alertmanager.url" .) -}}
    {{- $urls = append $urls . -}}
  {{- end -}}
  {{- range $Values.server.notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- $urls = append $urls .alertmanager.url -}}
    {{- end -}}
  {{- end -}}
  {{- join "," $urls }}
{{- end -}}

{{- define "vmalert.flag" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $flags := .flags | default list -}}
  {{- $flag := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $flag = append $flag "" -}}
  {{- end -}}
  {{- $notifiers := append $Values.server.notifiers $Values.server.notifier }}
  {{- $isEmpty := true -}}
  {{- range $notifiers }}
    {{- $notifier := . -}}
    {{- if not (empty $notifier.alertmanager.url) -}}
      {{- $value := (.alertmanager) -}}
      {{- range $flags -}}
        {{- $value = index $value . | default dict -}}
      {{- end -}}
      {{- if $value -}}
        {{- $isEmpty = false -}}
        {{- $flag = append $flag $value -}}
      {{- else -}}
        {{- $flag = append $flag "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if not $isEmpty -}}
    {{- join "," $flag -}}
  {{- end -}}
{{- end -}}

{{- define "alertmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.alertmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "config.file" "/config/alertmanager.yaml" -}}
  {{- if $app.webConfig -}}
    {{- $_ := set $args "web.config.file" "/config/webconfig.yaml" -}}
  {{- end -}}
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
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.server -}}
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
  {{- with (include "vmalert.flag" (dict "helm" . "flags" (list "basicAuth" "password"))) -}}
    {{- $_ := set $args "notifier.basicAuth.password" . -}}
  {{- end }}
  {{- with (include "vmalert.flag" (dict "helm" . "flags" (list "basicAuth" "username"))) -}}
    {{- $_ := set $args "notifier.basicAuth.username" . -}}
  {{- end -}}
  {{- with (include "vmalert.flag" (dict "helm" . "flags" (list "bearer" "token"))) -}}
    {{- $_ := set $args "notifier.bearerToken" . -}}
  {{- end -}}
  {{- with (include "vmalert.flag" (dict "helm" . "flags" (list "bearer" "tokenFile"))) -}}
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
