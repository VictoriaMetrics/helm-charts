{{- define "victoria-logs-agent.fullname" }}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "vlagent.args" -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "remoteWrite.maxDiskUsagePerURL" .Values.maxDiskUsagePerURL -}}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/vlagent-remotewrite-data" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlagent.remoteWriteArgs" -}}
  {{- if empty .Values.remoteWrite }}
    {{- fail "'remoteWrite' list is empty; at least one remoteWrite configuration must be provided" }}
  {{- end }}
  {{- $args := list }}
  {{- $knownFields := list "url" "basicAuth" "accountID" "projectID" "tls" "extraFields" "ignoreFields" "msgField" "streamFields" }}
  {{- range $i, $rw := .Values.remoteWrite }}
    {{- /* Validate remoteWrite object */ -}}
    {{- if empty $rw.url }}
      {{ fail (printf "'url' field must be set for remoteWrite[%d]" $i) }}
    {{- end }}
    {{- range $rwKey, $_ := $rw }}
      {{- if not (has $rwKey $knownFields) }}
        {{- fail (printf "unknown field %q for remoteWrite[%d]" $rwKey $i) }}
      {{- end }}
    {{- end }}

    {{- $args = append $args (printf "--remoteWrite.url=%s/internal/insert" (trimSuffix "/" $rw.url)) }}

    {{- $headers := list }}
    {{- $headers = append $headers (printf "AccountID:%v" ($rw.accountID | default "0")) }}
    {{- $headers = append $headers (printf "ProjectID:%v" ($rw.projectID | default "0")) }}
    {{- if not (empty $rw.streamFields) }}
      {{- $headers = append $headers (printf "VL-Stream-Fields:%s" (join "," $rw.streamFields)) }}
    {{- end }}
    {{- if not (empty $rw.msgField) }}
      {{- $headers = append $headers (printf "VL-Msg-Field:%s" (join "," $rw.msgField)) }}
    {{- end }}
    {{- if not (empty $rw.timeField) }}
      {{- $headers = append $headers (printf "VL-Time-Field:%s" (join "," $rw.timeField)) }}
    {{- end }}
    {{- if not (empty $rw.ignoreFields) }}
      {{- $headers = append $headers (printf "VL-Ignore-Fields:%s" (join "," $rw.ignoreFields)) }}
    {{- end }}

    {{- with $rw.extraFields }}
      {{- $pairs := list }}
      {{- range $k, $v := . }}
        {{- $pairs = append $pairs (printf "%s=%s" $k $v) }}
      {{- end }}
      {{- $headers = append $headers (printf "VL-Extra-Fields:%s" ($pairs | join ",")) }}
    {{- end }}
    {{- $args = append $args (printf "--remoteWrite.headers=%q" ($headers | join "^^")) }}
  {{- end }}
  {{- toYaml $args -}}
{{- end -}}
