{{- define "victoria-logs-collector.image" }}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $registry := (($Values.global).image).registry | default "docker.io" }}
  {{- if $Values.native }}
    {{- $tag := required "'image' must be set when 'native' is true" ($Values.image).tag }}
    {{- printf "%s/%s:%s" $registry "victoriametrics/vlagent" $tag }}
  {{- else }}
    {{- printf "%s/%s:%s" $registry "timberio/vector" "0.51.1-alpine" }}
  {{- end }}
{{- end }}

{{- define "victoria-logs-collector.args" -}}
  {{- if empty .Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict "kubernetesCollector" true }}
  {{- $_ := set $args "envflag.enable" true }}
  {{- $_ := set $args "envflag.prefix" "VL_" }}
  {{- $_ := set $args "tmpDataPath" "/vl-collector" }}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/vl-collector/remotewrite-data" }}

  {{- with .Values.msgField }}
    {{- $_ := set $args "kubernetesCollector.msgField" . }}
  {{- end }}

  {{- with .Values.timeField }}
    {{- $_ := set $args "kubernetesCollector.timeField" . }}
  {{- end }}

  {{- $knownParams := list "accountID" "projectID" "msgField" "ignoreFields" "extraFields" "basicAuth" }}
  {{- $requiredParams := list "url" }}

  {{- range $i, $rw := .Values.remoteWrite }}
    {{- $headers := default list }}

    {{- if empty $rw.accountID }}
      {{- $headers = append $headers "AccountID:0" }}
    {{- end }}

    {{- if empty $rw.projectID }}
      {{- $headers = append $headers "ProjectID:0" }}
    {{- end }}

    {{- range $rwKey, $rwValue := $rw }}
      {{- if has $rwKey $requiredParams }}
        {{- if empty $rw }}
          {{- fail (printf "remoteWrite[%d].%s parameter is not set" $i $rwKey) }}
        {{- end }}
      {{- else if not (has $rwKey $knownParams) }}
        {{- fail (printf "remoteWrite[%d].%s parameter is not supported" $i $rwKey) }}
      {{- end }}

      {{- $key := printf "remoteWrite.%s" $rwKey }}
      {{- $value := $rwValue }}
      {{- if eq $rwKey "url" }}
        {{- $value = printf "%s/insert/native" (trimSuffix "/" $rwValue) }}
      {{- else if eq $rwKey "basicAuth" }}
        {{- fail "set VL_remoteWrite_basicAuth_username and VL_remoteWrite_basicAuth_password env vars instead" }}
      {{- else }}
        {{- $key = "remoteWrite.headers" }}
        {{- if eq $rwKey "accountID" }}
          {{- $value = printf "AccountID:%v" $rwValue }}
        {{- else if eq $rwKey "projectID" }}
          {{- $value = printf "ProjectID:%v" $rwValue }}
        {{- else if eq $rwKey "msgField" }}
          {{- $value = printf "VL-Msg-Field:%s" (join "," $rwValue) }}
        {{- else if eq $rwKey "ignoreFields" }}
          {{- $value = printf "VL-Ignore-Fields:%s" (join "," $rwValue) }}
        {{- else if eq $rwKey "extraFields" }}
          {{- $pairs := list }}
          {{- range $k, $v := $rwValue }}
            {{- $pairs = append $pairs (printf "%s=%s" $k $v) }}
          {{- end }}
          {{- $value = printf "VL-Extra-Fields:%s" (join "," $pairs) }}
        {{- end }}
      {{- end }}

      {{- if ne $key "remoteWrite.headers" }}
        {{- $argValue := index $args $key | default list }}
        {{- $argValue = append $argValue $value }}
        {{- $_ := set $args $key $argValue }}
      {{- else }}
        {{- $headers = append $headers $value }}
      {{- end }}
    {{- end }}

    {{- $argValue := index $args "remoteWrite.headers" | default list }}
    {{- $argValue = append $argValue (join "^^" $headers) }}
    {{- $_ := set $args "remoteWrite.headers" $argValue }}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}
