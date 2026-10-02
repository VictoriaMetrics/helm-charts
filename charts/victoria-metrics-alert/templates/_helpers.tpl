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
  {{- if $app.webConfig -}}
    {{- $_ := set $args "web.config.file" "/config/webconfig.yaml" -}}
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
    {{- $port := include "vm.port.from.flag" (dict "flag" $app.cluster.listenAddress "default" "9094") -}}
    {{- $ctx := dict "helm" (.helm | default .) "appKey" "alertmanager" "kindOverride" "vmalertmanager" "style" "plain" -}}
    {{- $peers := list }}
    {{- range $idx := (until (int $replicaCount)) }}
      {{- $_ := set $ctx "appIdx" $idx }}
      {{- $peers = append $peers (printf "%s:%s" (include "vm.fqdn" $ctx) $port) -}}
    {{- end }}
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
    {{- $items := list }}
    {{- range $i, $v := $vs }}
      {{- $prefixed := dict }}
      {{- if $v }}
        {{- if not $v.url }}
          {{- fail (printf "`url` is not set for `%s` idx %d" $k $i) }}
        {{- end }}
        {{- range $vKey, $vValue := $v }}
          {{- if $vValue }}
            {{- $serialized := $vValue }}
            {{- if kindIs "map" $vValue }}
              {{- $values := list }}
              {{- range $mk, $mvs := $vValue }}
                {{- $mv := ternary (join "," $mvs | quote) $mvs (kindIs "slice" $mvs) }}
                {{- $values = append $values (printf "%s:%s" $mk $mv) }}
              {{- end }}
              {{- $serialized = join "^^" $values | squote }}
            {{- end }}
            {{- $_ := set $prefixed (printf "%s.%s" $k $vKey) $serialized }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- $items = append $items $prefixed }}
    {{- end }}
    {{- range $rk, $rv := (fromYaml (include "vm.args.positional" $items)) }}
      {{- $_ := set $args $rk $rv }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "vmalert.args" -}}
  {{- $ctx := merge (dict) . }}
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
        {{- $n := deepCopy $notifier }}
        {{- $_ := set $n "url" . }}
        {{- $notifiers = append $notifiers $n }}
      {{- end }}
    {{- else }}
      {{- $notifiers = append $notifiers $notifier }}
    {{- end }}
  {{- else if $Values.alertmanager.enabled }}
    {{- $alertmanager := deepCopy $Values.alertmanager }}
    {{- $_ := set $ctx "style" "plain" -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- $_ := set $ctx "kindOverride" "vmalertmanager" -}}
    {{- $appSecure := not (empty ($alertmanager.webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" (include "alertmanager.routePrefix" $alertmanager) -}}
    {{- if gt (int ($alertmanager.replicaCount | default 1)) 1 }}
      {{- $proto := ternary "https" "http" $appSecure -}}
      {{- $port := include "alertmanager.port" $alertmanager -}}
      {{- $path := trimSuffix "/" (include "alertmanager.routePrefix" $alertmanager) -}}
      {{- range $idx := (until (int $alertmanager.replicaCount)) }}
        {{- $_ := set $ctx "appIdx" $idx }}
        {{- $n := deepCopy $notifier }}
        {{- $_ := set $n "url" (printf "%s://%s:%s%s" $proto (include "vm.fqdn" $ctx) $port $path) -}}
        {{- $notifiers = append $notifiers $n }}
      {{- end }}
      {{- $_ := unset $ctx "appIdx" }}
    {{- else }}
      {{- $_ := set $notifier "url" (include "vm.url" $ctx) -}}
      {{- $notifiers = append $notifiers $notifier }}
    {{- end }}
  {{- end }}
  {{- $args := dict }}
  {{- include "vmalert.subargs" (dict "args" $args "datasource" $datasource "remoteWrite" $remoteWrite "remoteRead" $remoteRead "notifier" $notifiers) }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
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
  {{- $Values.alertmanager.configSecret | default (printf "%s-config" $fullname) -}}
{{- end -}}

{{- /*
alertmanager.port returns the effective alertmanager web port.
`web.listen-address` set via extraArgs takes precedence over `listenAddress`, as it does in alertmanager args.
*/ -}}
{{- define "alertmanager.port" -}}
  {{- $addr := index (.extraArgs | default dict) "web.listen-address" | default .listenAddress -}}
  {{- include "vm.port.from.flag" (dict "flag" $addr "default" "9093") -}}
{{- end -}}

{{- /*
alertmanager.routePrefix returns the effective alertmanager route prefix.
`web.route-prefix` set via extraArgs takes precedence over `baseURLPrefix`, as it does in alertmanager args.
*/ -}}
{{- define "alertmanager.routePrefix" -}}
  {{- index (.extraArgs | default dict) "web.route-prefix" | default .baseURLPrefix | default "" -}}
{{- end -}}

{{- /*
alertmanager.volume.name returns the alertmanager storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "alertmanager.volume.name" -}}
  {{- if eq (include "vm.useLegacyNaming" .) "false" -}}
    {{- printf "%s-db" (include "vm.plain.fullname" . | trunc 60 | trimSuffix "-") -}}
  {{- else -}}
    server-volume
  {{- end -}}
{{- end -}}

{{- /*
vmalert.sa.name returns the service account name for the component of the given context.
With legacy naming a single account is shared by vmalert and alertmanager.
Otherwise each component gets its own account, as in the VictoriaMetrics operator.
*/ -}}
{{- define "vmalert.sa.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $default := include "vm.fullname" (.helm | default .) -}}
  {{- if eq (include "vm.useLegacyNaming" .) "false" -}}
    {{- $default = include "vm.plain.fullname" . -}}
  {{- end -}}
  {{- tpl (($Values.serviceAccount).name | default $default) . -}}
{{- end -}}
