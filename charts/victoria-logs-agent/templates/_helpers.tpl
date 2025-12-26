{{- define "vlagent.args" -}}
  {{- if empty .Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict "envflag.enable" true }}
  {{- $_ := set $args "envflag.prefix" "VL_" }}
  {{- $_ := set $args "tmpDataPath" "/vlagent-data" }}
  {{- $_ := set $args "remoteWrite.maxDiskUsagePerURL" .Values.maxDiskUsagePerURL -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}

  {{- $requiredParams := list "url" }}

  {{- range $i, $rw := .Values.remoteWrite }}
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
        {{- $_ = set $url "path" (ternary "/insert/native" $url.path (empty (trimPrefix "/" $url.path))) }}
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
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}
