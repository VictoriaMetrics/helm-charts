{{/* Generate fullname */}}
{{- define "victoria-logs-collector.fullname" }}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "victoria-logs-collector.image" }}
{{- $registry := .Values.global.image.registry | default "docker.io" }}
{{- if .Values.native }}
  {{- if not .Values.image }}
  {{- fail "'image' must be set when 'native' is true" }}
  {{- end }}
{{- printf "%s/%s:%s" $registry "victoriametrics/vlagent" .Values.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" $registry "timberio/vector" "0.49.0-alpine" }}
{{- end }}
{{- end }}

{{- define "victoria-logs-collector.args" -}}
{{- if empty .Values.remoteWrite }}
  {{- fail "'remoteWrite' list is empty; at least one remoteWrite configuration must be provided" }}
{{- end }}

{{- $args := list }}
{{- /* Kubernetes integration args */ -}}
{{- $args = append $args "--kubernetes=true" }}
{{- $args = append $args "--kubernetes.checkpointsPath=/vl-collector/checkpoints.json" }}
{{- $args = append $args "--remoteWrite.tmpDataPath=/vl-collector/remotewrite-data" }}

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
