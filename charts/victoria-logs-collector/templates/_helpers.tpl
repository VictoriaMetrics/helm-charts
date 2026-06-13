{{- define "victoria-logs-collector.headers" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $rw := .rw }}
  {{- $headers := deepCopy ($rw.headers | default dict) }}
  {{- $_ := set $headers "AccountID" (toString ($rw.accountID | default $headers.AccountID | default "0")) }}
  {{- $_ := set $headers "ProjectID" (toString ($rw.projectID | default $headers.ProjectID | default "0")) }}
  {{- with $Values.extraFields }}
    {{- $_ := set $headers "VL-Extra-Fields" . }}
  {{- end }}
  {{- with $Values.ignoreFields }}
    {{- $_ := set $headers "VL-Ignore-Fields" . }}
  {{- end }}
  {{- $output := dict }}
  {{- range $hk, $hv := $headers }}
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
    {{- $_ = set $output $hk $vs }}
  {{- end }}
  {{- toYaml $output }}
{{- end -}}

{{- define "victoria-logs-collector.tls" }}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $rw := .rw }}
  {{- $config := dict }}
  {{- with index $rw "tlsCAFile" }}
    {{- $_ := set $config "tlsCAFile" . }}
  {{- end }}
  {{- with index $rw "tlsInsecureSkipVerify" }}
    {{- $_ := set $config "tlsInsecureSkipVerify" true }}
  {{- end }}
  {{- with $rw.tls }}
    {{- with .caFile }}
      {{- $_ := set $config "tlsCAFile" . }}
    {{- end }}
    {{- with .insecureSkipVerify }}
      {{- $_ := set $config "tlsInsecureSkipVerify" true }}
    {{- end }}
  {{- end }}
  {{- with $config }}
    {{- toYaml . }}
  {{- end }}
{{- end }}

{{- define "victoria-logs-collector.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if empty $Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) }}

  {{- $collector := $Values.collector | default dict }}
  {{- with $collector }}
    {{- $_ := set $args "kubernetesCollector" true }}

    {{- $legacyProps := list "msgField" "timeField" "excludeFilter" "includePodLabels" "includePodAnnotations" "includeNodeLabels" "includeNodeAnnotations" }}
    {{- range $prop, $value := $collector }}
      {{- if and (has $prop $legacyProps) (hasKey $Values $prop) }}
        {{- $value = index $Values $prop }}
      {{- end }}
      {{- if or (kindIs "bool" $value) $value }}
        {{- $vs := "" }}
        {{- if kindIs "slice" $value }}
          {{- $vs = join "," $value }}
        {{- else }}
          {{- $vs = toString $value }}
        {{- end }}
        {{- $_ := set $args (printf "kubernetesCollector.%s" $prop) $vs }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- $rwItems := list }}
  {{- range $i, $oldRw := $Values.remoteWrite }}
    {{- $rw := fromYaml (tpl (toYaml (deepCopy $oldRw)) $) }}
    {{- $_ := set $ "rw" $rw }}
    {{- $_ := set $rw "headers" (fromYaml (include "victoria-logs-collector.headers" $)) }}
    {{- $_ := unset $rw "accountID" }}
    {{- $_ := unset $rw "projectID" }}
    {{- $_ := unset $rw "extraFields" }}
    {{- $_ := unset $rw "ignoreFields" }}
    {{- $rw = mergeOverwrite $rw (fromYaml (include "victoria-logs-collector.tls" $)) }}
    {{- $_ := unset $rw "tls" }}
    {{- if empty $rw.url }}
      {{- fail (printf "remoteWrite[%d].url parameter is not set" $i) }}
    {{- end }}
    {{- $url := urlParse $rw.url }}
    {{- $isEmptyPath := empty (trimPrefix "/" $url.path) }}
    {{- $isNativeFormat := or (empty $rw.format) (eq $rw.format "native") }}
    {{- $_ := set $url "path" (ternary "/insert/native" $url.path (and $isEmptyPath $isNativeFormat)) }}
    {{- $_ := set $rw "url" (urlJoin $url) }}
    {{- $headers := list }}
    {{- range $hk, $hv := $rw.headers }}
      {{- $headers = append $headers (printf "%s:%s" $hk $hv) }}
    {{- end }}
    {{- $_ := set $rw "headers" (quote (join "^^" $headers)) }}
    {{- $prefixed := dict }}
    {{- range $k, $v := $rw }}
      {{- $_ := set $prefixed (printf "remoteWrite.%s" $k) $v }}
    {{- end }}
    {{- $rwItems = append $rwItems $prefixed }}
  {{- end }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $rwItems)) }}

  {{- $fcItems := list }}
  {{- range $i, $fc := ($Values.fileCollector | default list) }}
    {{- if empty $fc.glob }}
      {{- fail (printf "fileCollector[%d].glob parameter is not set" $i) }}
    {{- end }}
    {{- $prefixed := dict }}
    {{- range $k, $v := $fc }}
      {{- $_ := set $prefixed (printf "fileCollector.%s" $k) $v }}
    {{- end }}
    {{- $fcItems = append $fcItems $prefixed }}
  {{- end }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $fcItems)) }}

  {{- toYaml (mergeOverwrite $args $Values.extraArgs) -}}
{{- end }}
