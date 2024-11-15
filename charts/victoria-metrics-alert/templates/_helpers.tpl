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

{{- define "vmalert.alertmanager.passwords" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $password := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $password = append $password "" -}}
  {{- end -}}
  {{- $notifiers := append $Values.server.notifiers $Values.server.notifier }}
  {{- range $notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- if and .alertmanager.basicAuth .alertmanager.basicAuth.password -}}
        {{- $password = append $password .alertmanager.basicAuth.password -}}
      {{- else -}}
        {{- $password = append $password "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- ternary "" (join "," $password) (eq (len (compact $password)) 0) }}
{{- end -}}

{{- define "vmalert.alertmanager.usernames" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $usernames := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $usernames = append $usernames "" -}}
  {{- end -}}
  {{- $notifiers := append $Values.server.notifiers $Values.server.notifier }}
  {{- range $notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- if and .alertmanager.basicAuth .alertmanager.basicAuth.username -}}
        {{- $usernames = append $usernames .alertmanager.basicAuth.username -}}
      {{- else -}}
        {{- $usernames = append $usernames "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- ternary "" (join "," $usernames) (eq (len (compact $usernames)) 0) }}
{{- end -}}

{{- define "vmalert.alertmanager.bearerTokens" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $tokens := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $tokens = append $tokens "" -}}
  {{- end -}}
  {{- $notifiers := append $Values.server.notifiers $Values.server.notifier }}
  {{- range $notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- if and .alertmanager.bearer .alertmanager.bearer.token -}}
        {{- $tokens = append $tokens .alertmanager.bearer.token -}}
      {{- else -}}
        {{- $tokens = append $tokens "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- ternary "" (join "," $tokens) (eq (len (compact $tokens)) 0) }}
{{- end -}}

{{- define "vmalert.alertmanager.bearerTokenFiles" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $files := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- $files = append $files "" -}}
  {{- end -}}
  {{- $notifiers := append $Values.server.notifiers $Values.server.notifier }}
  {{- range $notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- if and .alertmanager.bearer .alertmanager.bearer.tokenFile -}}
        {{- $files = append $files .alertmanager.bearer.tokenFile -}}
      {{- else -}}
        {{- $files = append $files "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- ternary "" (join "," $files) (eq (len (compact $files)) 0) }}
{{- end -}}

{{- define "alertmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.alertmanager -}}
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
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.server -}}
  {{- $args := default dict -}}
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

{{- define "vmalert.rules.config.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $fullname := include "vm.plain.fullname" . -}}
  {{- $Values.server.configMap | default (printf "%s-alert-rules-config" $fullname) -}}
{{- end -}}

{{- define "alertmanager.config.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $fullname := include "vm.plain.fullname" . -}}
  {{- $Values.alertmanager.configMap | default (printf "%s-config" $fullname) -}}
{{- end -}}
