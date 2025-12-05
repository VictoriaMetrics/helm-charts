{{- define "victoria-logs-collector.image" }}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.native }}
    {{- include "vm.image" . }}
  {{- else }}
    {{- $registry := $Values.global.image.registry | default "docker.io" }}
    {{- printf "%s/%s:%s" $registry "timberio/vector" "0.51.1-alpine" }}
  {{- end }}
{{- end }}

{{- define "victoria-logs-collector.args" -}}
  {{- if empty .Values.remoteWrite }}
    {{- fail "'remoteWrite' list is empty; at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := list }}
  {{- /* Kubernetes integration args */ -}}
  {{- $args = append $args "--kubernetesCollector" }}
  {{- $args = append $args "--kubernetesCollector.checkpointsPath=/vl-collector/checkpoints.json" }}
  {{- $args = append $args "--remoteWrite.tmpDataPath=/vl-collector/remotewrite-data" }}

  {{- /* Before 0.1.0, each remoteWrite could specify its own msgField. This was removed in favor of global msgField configuration. */}}
  {{- $msgField := list }}
  {{- range $rw := .Values.remoteWrite }}
    {{- $msgField = concat $msgField ($rw.msgField | default list) }}
  {{- end }}
  {{- $msgField = concat $msgField .Values.msgField }}
  {{- $msgField = uniq $msgField }}
  {{- if not (empty $msgField) }}
    {{- $args = append $args (printf "--kubernetesCollector.msgField=%s" (join "," $msgField)) }}
  {{- end }}
  {{- if not (empty .Values.timeField) }}
    {{- $args = append $args (printf "--kubernetesCollector.timeField=%s" (join "," .Values.timeField)) }}
  {{- end }}

  {{- range $i, $rw := .Values.remoteWrite }}
    {{- /* Validate remoteWrite object */ -}}
    {{- if empty $rw.url }}
      {{- fail (printf "'url' field must be set for remoteWrite[%d]" $i) }}
    {{- end }}
    {{- $knownFields := list "url" "accountID" "projectID" "msgField" "ignoreFields" "extraFields" }}
    {{- range $rwKey, $_ := $rw }}
      {{- if not (has $rwKey $knownFields) }}
        {{- fail (printf "unknown field %q for remoteWrite[%d]" $rwKey $i) }}
      {{- end }}
    {{- end }}
    {{- $args = append $args (printf "--remoteWrite.url=%s/internal/insert" (trimSuffix "/" $rw.url)) }}

    {{- /* Prepare headers */ -}}
    {{- $headers := list }}
    {{- $headers = append $headers (printf "AccountID:%v" ($rw.accountID | default "0")) }}
    {{- $headers = append $headers (printf "ProjectID:%v" ($rw.projectID | default "0")) }}

    {{- if not (empty $rw.msgField) }}
      {{- $headers = append $headers (printf "VL-Msg-Field:%s" (join "," $rw.msgField)) }}
    {{- end }}

    {{- if not (empty $rw.ignoreFields) }}
      {{- $headers = append $headers (printf "VL-Ignore-Fields:%s" (join "," $rw.ignoreFields)) }}
    {{- end }}

    {{- with $rw.extraFields }}
      {{- /* Convert object to 'key=value' pairs */ -}}
      {{- $pairs := list }}
      {{- range $k, $v := . }}
        {{- $pairs = append $pairs (printf "%s=%s" $k $v) }}
      {{- end }}
      {{- $headers = append $headers (printf "VL-Extra-Fields:%s" ($pairs | join ",")) }}
    {{- end }}

    {{- $args = append $args (printf "--remoteWrite.headers=%q" ($headers | join "^^")) }}
  {{- end }}
  {{- toYaml $args }}
{{- end }}
