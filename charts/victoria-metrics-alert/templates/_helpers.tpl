{{- define "alertmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.alertmanager -}}
  {{- $args := dict -}}
  {{- $_ := set $args "config.file" "/config/alertmanager.yaml" -}}
  {{- $_ := set $args "storage.path" (ternary $app.persistentVolume.mountPath "/data" $app.persistentVolume.enabled) -}}
  {{- $_ := set $args "data.retention" $app.retention -}}
  {{- $_ := set $args "web.listen-address" $app.listenAddress -}}
  {{- $_ := set $args "cluster.advertise-address" "[$(POD_IP)]:6783" -}}
  {{- with $app.baseURL -}}
    {{- $_ := set $args "web.external-url" . -}}
  {{- end -}}
  {{ with $app.baseURLPrefix }}
    {{- $_ := set $args "web.route-prefix" . -}}
  {{- end -}}
  {{- $replicaCount := $app.replicaCount | default 1 | int }}
  {{- if gt $replicaCount 1 }}
    {{- $_ := set $args "cluster.listen-address" $app.cluster.listenAddress -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $app.cluster.listenAddress "default" "9094") -}}
    {{- $_ := set $args "cluster.advertise-address" (printf "[$(POD_IP)]:%s" $port) -}}
    {{- with $app.cluster.pushPullInterval -}}
      {{- $_ := set $args "cluster.pushpull-interval" . -}}
    {{- end -}}
    {{- with $app.cluster.gossipInterval -}}
      {{- $_ := set $args "cluster.gossip-interval" . -}}
    {{- end -}}
    {{- with $app.cluster.peerTimeout -}}
      {{- $_ := set $args "cluster.peer-timeout" . -}}
    {{- end -}}
    {{- with $app.cluster.settleTimeout -}}
      {{- $_ := set $args "cluster.settle-timeout" . -}}
    {{- end -}}
    {{- $ctx := . -}}
    {{- if not (hasKey . "helm") -}}
      {{- $ctx = dict "helm" . }}
    {{- end -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- $_ := set $ctx "style" "plain" -}}
    {{- $fullname := include "vm.plain.fullname" $ctx -}}
    {{- $alertmanager := deepCopy $app }}
    {{- $_ := set $alertmanager "fullnameOverride" (printf "%s-headless" $fullname) }}
    {{- $_ := set $ctx "headless" (dict "alertmanager" $alertmanager) }}
    {{- $_ := set $ctx "appKey" (list "headless" "alertmanager") }}
    {{- $port := include "vm.port.from.flag" (dict "flag" $app.cluster.listenAddress "default" "9094") -}}
    {{- $peers := list }}
    {{- range $idx := (until (int $replicaCount)) }}
      {{- $_ := set $ctx "appIdx" $idx }}
      {{- $peers = append $peers (printf "%s:%s" (include "vm.fqdn" $ctx) $port) -}}
    {{- end }}
    {{- $_ := unset $ctx "appIdx" }}
    {{- $_ := set $args "cluster.peer" $peers }}
  {{- end }}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmalert.fromLegacyArgs" -}}
  {{- $result := omit . "basicAuth" "bearer" }}
  {{- with .basicAuth }}
    {{- with .username }}
      {{- $_ := set $result "basicAuth.username" . }}
    {{- end }}
    {{- with .password }}
      {{- $_ := set $result "basicAuth.password" . }}
    {{- end }}
  {{- end -}}
  {{- with .bearer -}}
    {{- with .token }}
      {{- $_ := set $result "bearerToken" . -}}
    {{- end -}}
    {{- with .tokenFile -}}
      {{- $_ := set $result "bearerTokenFile" . -}}
    {{- end -}}
  {{- end }}
  {{- toYaml $result }}
{{- end -}}

{{- define "vmalert.subargs" }}
  {{- $args := .args }}
  {{- range $k, $vs := (omit . "args") }}
    {{- range $i, $v := $vs }}
      {{- with $v }}
        {{- if not .url -}}
          {{- fail (printf "`url` is not set for `%s` idx %d" $k $i) -}}
        {{- end -}}
        {{- range $vKey, $vValue := . -}}
          {{- if $vValue }}
            {{- $key := printf "%s.%s" $k $vKey -}}
            {{- $param := index $args $key | default list -}}
            {{- range until (int (sub $i (len $param))) }}
              {{- $param = append $param "" }}
            {{- end }}
            {{- if kindIs "map" $vValue }}
              {{- $values := list }}
              {{- range $mk, $mvs := $vValue }}
                {{- $mv := ternary (join "," $mvs | quote) $mvs (kindIs "slice" $mvs) }}
                {{- $values = append $values (printf "%s:%s" $mk $mv) }}
              {{- end }}
              {{- $param = append $param (join "^^" $values | squote) }}
            {{- else -}}
              {{- $param = append $param $vValue }}
            {{- end }}
            {{- $_ := set $args $key $param -}}
          {{- end }}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end }}
{{- end }}

{{- define "vmalert.args" -}}
  {{- $ctx := . }}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.server -}}
  {{- $datasource := list (include "vmalert.fromLegacyArgs" $app.datasource | fromYaml) -}}
  {{- $remoteWrite := list (mergeOverwrite (deepCopy ($app.remoteWrite | default dict)) (include "vmalert.fromLegacyArgs" ($app.remote).write | fromYaml)) -}}
  {{- $remoteRead := list (mergeOverwrite (deepCopy ($app.remoteRead | default dict)) (include "vmalert.fromLegacyArgs" ($app.remote).read | fromYaml)) -}}
  {{- $notifiers := list }}
  {{- range $rawNotifier := ($app.notifiers | default list) }}
    {{- $notifier := mergeOverwrite (deepCopy (omit ($rawNotifier | default dict) "alertmanager")) (include "vmalert.fromLegacyArgs" ($rawNotifier).alertmanager | fromYaml) }}
    {{- $notifiers = append $notifiers $notifier }}
  {{- end }}
  {{- $notifier := mergeOverwrite (deepCopy (omit ($app.notifier | default dict) "alertmanager")) (include "vmalert.fromLegacyArgs" ($app.notifier).alertmanager | fromYaml) }}
  {{- if $notifier.url }}
    {{- if kindIs "slice" $notifier.url }}
      {{- $urls := $notifier.url }}
      {{- range $urls }}
        {{- $_ := set $notifier "url" . }}
        {{- $notifiers = append $notifiers $notifier }}
      {{- end }}
    {{- else }}
      {{- $notifiers = append $notifiers $notifier }}
    {{- end }}
  {{- else if $Values.alertmanager.enabled }}
    {{- $alertmanager := deepCopy $Values.alertmanager }}
    {{- $_ := set $ctx "style" "plain" -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- $appSecure := not (empty ($alertmanager.webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" $alertmanager.baseURLPrefix -}}
    {{- if gt (int ($alertmanager.replicaCount | default 1)) 1 }}
      {{- $fullname := include "vm.plain.fullname" $ctx -}}
      {{- $_ := set $alertmanager "fullnameOverride" (printf "%s-headless" $fullname) }}
      {{- $_ := set $ctx "headless" (dict "alertmanager" $alertmanager) }}
      {{- $_ := set $ctx "appKey" (list "headless" "alertmanager") }}
      {{- range $idx := (until (int $alertmanager.replicaCount)) }}
        {{- $_ := set $ctx "appIdx" $idx }}
        {{- $_ := set $notifier "url" (include "vm.url" $ctx) -}}
        {{- $notifiers = append $notifiers $notifier }}
      {{- end }}
      {{- $_ := unset $ctx "appIdx" }}
    {{- else }}
      {{- $_ := set $notifier "url" (include "vm.url" $ctx) -}}
      {{- $notifiers = append $notifiers $notifier }}
    {{- end }}
  {{- end }}
  {{- $args := dict }}
  {{- include "vmalert.subargs" (dict "args" $args "datasource" $datasource "remoteWrite" $remoteWrite "remoteRead" $remoteRead "notifier" $notifiers) }}
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
