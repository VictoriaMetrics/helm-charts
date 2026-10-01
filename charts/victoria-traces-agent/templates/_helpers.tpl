{{- define "vtagent.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if empty $Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict "tmpDataPath" "/vtagent-data" }}
  {{- $_ := set $args "remoteWrite.maxDiskUsagePerURL" $Values.maxDiskUsagePerURL -}}
  {{- $rwItems := list -}}
  {{- range $i, $rw := $Values.remoteWrite -}}
    {{- if not $rw.url -}}
      {{- fail (printf "remoteWrite[%d].url parameter is not set" $i) -}}
    {{- end -}}
    {{- $item := dict -}}
    {{- range $rwKey, $rwValue := $rw -}}
      {{- $value := $rwValue -}}
      {{- if eq $rwKey "url" -}}
        {{- $url := urlParse $rwValue -}}
        {{- $isEmptyPath := empty (trimPrefix "/" $url.path) -}}
        {{- $isNativeFormat := or (empty $rw.format) (eq $rw.format "native") -}}
        {{- $_ = set $url "path" (ternary "/insert/native" $url.path (and $isEmptyPath $isNativeFormat)) -}}
        {{- $value = urlJoin $url -}}
      {{- else if eq $rwKey "headers" -}}
        {{- $headers := list -}}
        {{- range $hk, $hv := $rwValue -}}
          {{- $vs := "" -}}
          {{- if kindIs "slice" $hv -}}
            {{- $vs = join "," $hv -}}
          {{- else if kindIs "map" $hv -}}
            {{- $pairs := list -}}
            {{- range $k, $v := $hv -}}
              {{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
            {{- end -}}
            {{- $vs = join "," $pairs -}}
          {{- else -}}
            {{- $vs = toString $hv -}}
          {{- end -}}
          {{- $headers = append $headers (printf "%s:%s" $hk $vs) -}}
        {{- end -}}
        {{- $value = quote (join "^^" $headers) -}}
      {{- end -}}
      {{- $_ := set $item (printf "remoteWrite.%s" $rwKey) $value -}}
    {{- end -}}
    {{- $rwItems = append $rwItems $item -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $rwItems)) -}}
  {{- $extraArgs := $Values.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $Values.http)) -}}
  {{- end -}}
  {{- $otlpGRPC := $Values.otlpGRPC | default dict -}}
  {{- $otlpGRPCAddr := $extraArgs.otlpGRPCListenAddr | default $otlpGRPC.listenAddr -}}
  {{- if $otlpGRPCAddr -}}
    {{- $otlpGRPCArgs := dict "otlpGRPCListenAddr" $otlpGRPCAddr -}}
    {{- $_ := set $otlpGRPCArgs "otlpGRPC.tls" (ternary "true" "false" (eq (toString $otlpGRPC.tls) "true")) -}}
    {{- range $key, $value := omit $otlpGRPC "listenAddr" "tls" -}}
      {{- if $value -}}
        {{- $_ := set $otlpGRPCArgs (printf "otlpGRPC.%s" $key) $value -}}
      {{- end -}}
    {{- end -}}
    {{- range $key, $value := $otlpGRPCArgs -}}
      {{- if not (hasKey $extraArgs $key) -}}
        {{- $_ := set $args $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}

{{- define "vtagent.validate" -}}
  {{- if eq (include "vm.useLegacyNaming" (dict "helm" .)) "true" -}}
    {{- fail "useLegacyNaming: true is not supported by victoria-traces-agent chart" -}}
  {{- end -}}
{{- end -}}

{{- define "vtagent.otlpGRPC.addr" -}}
  {{- ((.Values.extraArgs | default dict).otlpGRPCListenAddr) | default ((.Values.otlpGRPC | default dict).listenAddr) -}}
{{- end -}}
