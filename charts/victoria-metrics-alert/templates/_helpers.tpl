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

{{- define "vmalert.alertmanager.cluster.urls" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $urls := list -}}
  {{- if and $Values.alertmanager.enabled $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
    {{- $ctx := . -}}
    {{- if not (hasKey . "helm") -}}
      {{- $ctx = dict "helm" . }}
    {{- end -}}
    {{- $_ := set $ctx "style" "plain" -}}
    {{- $_ := set $ctx "appKey" "alertmanager" -}}
    {{- $fullname := include "vm.plain.fullname" $ctx -}}
    {{- $ns := include "vm.namespace" $ctx -}}
    {{- $appSecure := not (empty (($Values.alertmanager).webConfig).tls_server_config) -}}
    {{- $scheme := ternary "https" "http" $appSecure -}}
    {{- $port := $Values.alertmanager.service.servicePort -}}
    {{- $baseURLPrefix := $Values.alertmanager.baseURLPrefix -}}
    {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
      {{- $podUrl := printf "%s://%s-%d.%s-headless.%s.svc.cluster.local:%d%s" $scheme $fullname $i $fullname $ns $port $baseURLPrefix -}}
      {{- $urls = append $urls $podUrl -}}
    {{- end -}}
  {{- else if $Values.alertmanager.enabled -}}
    {{- $urls = append $urls (include "vmalert.alertmanager.url" .) -}}
  {{- end -}}
  {{- join "," $urls -}}
{{- end -}}

{{- define "vmalert.alertmanager.urls" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $urls := list -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- $ctx := . -}}
      {{- if not (hasKey . "helm") -}}
        {{- $ctx = dict "helm" . }}
      {{- end -}}
      {{- $_ := set $ctx "style" "plain" -}}
      {{- $_ := set $ctx "appKey" "alertmanager" -}}
      {{- $fullname := include "vm.plain.fullname" $ctx -}}
      {{- $ns := include "vm.namespace" $ctx -}}
      {{- $appSecure := not (empty (($Values.alertmanager).webConfig).tls_server_config) -}}
      {{- $scheme := ternary "https" "http" $appSecure -}}
      {{- $port := $Values.alertmanager.service.servicePort | int -}}
      {{- $baseURLPrefix := $Values.alertmanager.baseURLPrefix -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $podUrl := printf "%s://%s-%d.%s-headless.%s.svc.cluster.local:%d%s" $scheme $fullname $i $fullname $ns $port $baseURLPrefix -}}
        {{- $urls = append $urls $podUrl -}}
      {{- end -}}
    {{- else -}}
      {{- with (include "vmalert.alertmanager.url" .) -}}
        {{- $urls = append $urls . -}}
      {{- end -}}
    {{- end -}}
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
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $password = append $password "" -}}
      {{- end -}}
    {{- else -}}
      {{- $password = append $password "" -}}
    {{- end -}}
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
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $usernames = append $usernames "" -}}
      {{- end -}}
    {{- else -}}
      {{- $usernames = append $usernames "" -}}
    {{- end -}}
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
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $tokens = append $tokens "" -}}
      {{- end -}}
    {{- else -}}
      {{- $tokens = append $tokens "" -}}
    {{- end -}}
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
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $files = append $files "" -}}
      {{- end -}}
    {{- else -}}
      {{- $files = append $files "" -}}
    {{- end -}}
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
  {{- $baseArgs := list -}}
  {{- $baseArgs = append $baseArgs "--config.file=/config/alertmanager.yaml" -}}
  {{- $baseArgs = append $baseArgs (printf "--storage.path=%s" (ternary $app.persistentVolume.mountPath "/data" $app.persistentVolume.enabled)) -}}
  {{- $baseArgs = append $baseArgs (printf "--data.retention=%s" $app.retention) -}}
  {{- $baseArgs = append $baseArgs (printf "--web.listen-address=%s" $app.listenAddress) -}}
  {{- if $app.cluster.enabled -}}
    {{- $baseArgs = append $baseArgs (printf "--cluster.listen-address=%s" $app.cluster.listenAddress) -}}
    {{- if $app.cluster.advertiseAddress -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.advertise-address=%s" $app.cluster.advertiseAddress) -}}
    {{- else -}}
      {{- $port := include "vm.port.from.flag" (dict "flag" $app.cluster.listenAddress "default" "9094") -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.advertise-address=[$(POD_IP)]:%s" $port) -}}
    {{- end -}}
    {{- if $app.cluster.peers -}}
      {{- range $peer := $app.cluster.peers -}}
        {{- $baseArgs = append $baseArgs (printf "--cluster.peer=%s" $peer) -}}
      {{- end -}}
    {{- else if gt ($app.replicaCount | default 1 | int) 1 -}}
      {{- $ctx := . -}}
      {{- $_ := set $ctx "appKey" "alertmanager" -}}
      {{- $fullname := include "vm.plain.fullname" $ctx -}}
      {{- $port := include "vm.port.from.flag" (dict "flag" $app.cluster.listenAddress "default" "9094") -}}
      {{- range $i := until ($app.replicaCount | default 1 | int) -}}
        {{- $peer := printf "%s-%d.%s-headless.$(NAMESPACE).svc.cluster.local:%s" $fullname $i $fullname $port -}}
        {{- $baseArgs = append $baseArgs (printf "--cluster.peer=%s" $peer) -}}
      {{- end -}}
    {{- end -}}
    {{- with $app.cluster.pushPullInterval -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.pushpull-interval=%s" .) -}}
    {{- end -}}
    {{- with $app.cluster.gossipInterval -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.gossip-interval=%s" .) -}}
    {{- end -}}
    {{- with $app.cluster.peerTimeout -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.peer-timeout=%s" .) -}}
    {{- end -}}
    {{- with $app.cluster.settleTimeout -}}
      {{- $baseArgs = append $baseArgs (printf "--cluster.settle-timeout=%s" .) -}}
    {{- end -}}
  {{- end -}}
  {{- with $app.baseURL -}}
    {{- $baseArgs = append $baseArgs (printf "--web.external-url=%s" .) -}}
  {{- end -}}
  {{- with $app.baseURLPrefix -}}
    {{- $baseArgs = append $baseArgs (printf "--web.route-prefix=%s" .) -}}
  {{- end -}}
  {{- range $key, $value := $app.extraArgs -}}
    {{- $baseArgs = append $baseArgs (printf "--%s=%v" $key $value) -}}
  {{- end -}}
  {{- toYaml $baseArgs -}}
{{- end -}}

{{- define "vmalert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.server -}}
  {{- $baseArgs := list -}}
  {{- $baseArgs = append $baseArgs (printf "--datasource.url=%s" $app.datasource.url) -}}
  {{- if or $app.datasource.basicAuth.password $app.datasource.basicAuth.username -}}
    {{- $baseArgs = append $baseArgs (printf "--datasource.basicAuth.password=%s" $app.datasource.basicAuth.password) -}}
    {{- $baseArgs = append $baseArgs (printf "--datasource.basicAuth.username=%s" $app.datasource.basicAuth.username) -}}
  {{- end -}}
  {{- with $app.datasource.bearer.token -}}
    {{- $baseArgs = append $baseArgs (printf "--datasource.bearerToken=%s" .) -}}
  {{- end -}}
  {{- with $app.datasource.bearer.tokenFile -}}
    {{- $baseArgs = append $baseArgs (printf "--datasource.bearerTokenFile=%s" .) -}}
  {{- end -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- if and $Values.alertmanager.cluster.enabled (gt ($Values.alertmanager.replicaCount | default 1 | int) 1) -}}
      {{- $ctx := . -}}
      {{- if not (hasKey . "helm") -}}
        {{- $ctx = dict "helm" . }}
      {{- end -}}
      {{- $_ := set $ctx "style" "plain" -}}
      {{- $_ := set $ctx "appKey" "alertmanager" -}}
      {{- $fullname := include "vm.plain.fullname" $ctx -}}
      {{- $ns := include "vm.namespace" $ctx -}}
      {{- $appSecure := not (empty (($Values.alertmanager).webConfig).tls_server_config) -}}
      {{- $scheme := ternary "https" "http" $appSecure -}}
      {{- $port := $Values.alertmanager.service.servicePort | int -}}
      {{- $baseURLPrefix := $Values.alertmanager.baseURLPrefix -}}
      {{- range $i := until ($Values.alertmanager.replicaCount | default 1 | int) -}}
        {{- $podUrl := printf "%s://%s-%d.%s-headless.%s.svc.cluster.local:%d%s" $scheme $fullname $i $fullname $ns $port $baseURLPrefix -}}
        {{- $baseArgs = append $baseArgs (printf "--notifier.url=%s" $podUrl) -}}
      {{- end -}}
    {{- else -}}
      {{- with (include "vmalert.alertmanager.url" .) -}}
        {{- $baseArgs = append $baseArgs (printf "--notifier.url=%s" .) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- range $Values.server.notifiers }}
    {{- if not (empty .alertmanager.url) -}}
      {{- $baseArgs = append $baseArgs (printf "--notifier.url=%s" .alertmanager.url) -}}
    {{- end -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.passwords" .) -}}
    {{- $baseArgs = append $baseArgs (printf "--notifier.basicAuth.password=%s" .) -}}
  {{- end }}
  {{- with (include "vmalert.alertmanager.usernames" .) -}}
    {{- $baseArgs = append $baseArgs (printf "--notifier.basicAuth.username=%s" .) -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.bearerTokens" .) -}}
    {{- $baseArgs = append $baseArgs (printf "--notifier.bearerToken=%s" .) -}}
  {{- end -}}
  {{- with (include "vmalert.alertmanager.bearerTokenFiles" .) -}}
    {{- $baseArgs = append $baseArgs (printf "--notifier.bearerTokenFile=%s" .) -}}
  {{- end -}}
  {{- with $app.remote.read.url }}
    {{- $baseArgs = append $baseArgs (printf "--remoteRead.url=%s" .) -}}
  {{- end -}}
  {{- if or $app.remote.read.basicAuth.password $app.remote.read.basicAuth.username -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteRead.basicAuth.password=%s" $app.remote.read.basicAuth.password) -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteRead.basicAuth.username=%s" $app.remote.read.basicAuth.username) -}}
  {{- end -}}
  {{- with $app.remote.read.bearer.token }}
    {{- $baseArgs = append $baseArgs (printf "--remoteRead.bearerToken=%s" .) -}}
  {{- end -}}
  {{- with $app.remote.read.bearer.tokenFile -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteRead.bearerTokenFile=%s" .) -}}
  {{- end -}}
  {{- with $app.remote.write.url -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteWrite.url=%s" .) -}}
  {{- end -}}
  {{- if or $app.remote.write.basicAuth.password $app.remote.write.basicAuth.username -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteWrite.basicAuth.password=%s" $app.remote.write.basicAuth.password) -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteWrite.basicAuth.username=%s" $app.remote.write.basicAuth.username) -}}
  {{- end -}}
  {{- with $app.remote.write.bearer.token -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteWrite.bearerToken=%s" .) -}}
  {{- end -}}
  {{- with $app.remote.write.bearer.tokenFile -}}
    {{- $baseArgs = append $baseArgs (printf "--remoteWrite.bearerTokenFile=%s" .) -}}
  {{- end -}}
  {{- range $key, $value := $app.extraArgs -}}
    {{- if eq $key "rule" -}}
      {{- if kindIs "slice" $value -}}
        {{- range $rule := $value -}}
          {{- $baseArgs = append $baseArgs (printf "--rule=%s" $rule) -}}
        {{- end -}}
      {{- else -}}
        {{- $baseArgs = append $baseArgs (printf "--rule=%v" $value) -}}
      {{- end -}}
    {{- else -}}
      {{- $baseArgs = append $baseArgs (printf "--%s=%v" $key $value) -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $baseArgs -}}
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
