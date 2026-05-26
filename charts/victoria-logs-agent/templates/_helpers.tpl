{{- define "vl.syslog.args" -}}
  {{- $args := dict }}
  {{- range $kind, $sls := . }}
    {{- range $i, $sl := $sls -}}
      {{- if not $sl.value -}}
        {{- fail (printf "`value` is not set for `syslog.%s` idx %d" $kind $i) -}}
      {{- end -}}
      {{- range $slKey, $slValue := (omit $sl "name") -}}
        {{- $key := ternary "listenAddr" $slKey (eq $slKey "value") -}}
        {{- $key = ternary (printf "syslog.%s" $key) (printf "syslog.%s.%s" $key $kind) (hasPrefix "tls" $key) -}}
        {{- $param := index $args $key | default list -}}
        {{- if $slValue -}}
          {{- range until (int (sub $i (len $param))) }}
            {{- $param = append $param "" }}
          {{- end }}
          {{- $param = append $param $slValue }}
          {{- $_ := set $args $key $param -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $args -}}
{{- end -}}


{{- define "vlagent.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if empty $Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict "tmpDataPath" "/vlagent-data" }}
  {{- $_ := set $args "remoteWrite.maxDiskUsagePerURL" $Values.maxDiskUsagePerURL -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $Values.http)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $Values.syslog)) -}}

  {{- $requiredParams := list "url" }}

  {{- range $i, $rw := $Values.remoteWrite }}
    {{- range $rwKey, $rwValue := $rw }}
      {{- if has $rwKey $requiredParams }}
        {{- if empty $rw }}
          {{- fail (printf "remoteWrite[%d].%s parameter is not set" $i $rwKey) }}
        {{- end }}
      {{- end }}

      {{- $key := printf "remoteWrite.%s" $rwKey }}
      {{- $param := index $args $key | default list}}
      {{- range until (int (sub $i (len $param))) }}
        {{- $param = append $param "" }}
      {{- end }}
      {{- $value := $rwValue }}
      {{- if eq $rwKey "url" }}
        {{- $url := urlParse $rwValue }}
        {{- $isEmptyPath := empty (trimPrefix "/" $url.path) }}
        {{- $isNativeFormat := or (empty $rw.format) (eq $rw.format "native") }}
        {{- $_ = set $url "path" (ternary "/insert/native" $url.path (and $isEmptyPath $isNativeFormat)) }}
        {{- $value = urlJoin $url }}
      {{- else if eq $rwKey "headers" }}
        {{- $headers := list }}
        {{- range $hk, $hv := $rwValue }}
          {{- $vs := "" }}
          {{- if kindIs "slice" $hv }}
            {{- $vs = join "," $hv }}
          {{- else if kindIs "map" $hv }}
            {{- $pairs := list }}
            {{- range $k, $v := $hv }}
              {{- $pairs = append $pairs (printf "%s=%s" $k $v) }}
            {{- end }}
            {{- $vs = join "," $pairs }}
          {{- else }}
            {{- $vs = toString $hv }}
          {{- end }}
          {{- $headers = append $headers (printf "%s:%s" $hk $vs) }}
        {{- end }}
        {{- $value = quote (join "^^" $headers) }}
      {{- end }}
      {{- $param = append $param $value }}
      {{- $_ := set $args $key $param }}
    {{- end }}
  {{- end }}
  {{- include "vm.check.extraArgs" $Values.extraArgs -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}
