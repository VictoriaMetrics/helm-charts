{{- define "victoria-logs-collector.headers" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $idx := .idx }}
  {{- $rw := index $Values.remoteWrite $idx }}
  {{- $headers := deepCopy ($rw.headers | default dict) }}
  {{- $_ := set $headers "AccountID" (toString ($rw.accountID | default $headers.AccountID | default "0")) }}
  {{- $_ := set $headers "ProjectID" (toString ($rw.projectID | default $headers.ProjectID | default "0")) }}
  {{- with $Values.extraFields }}
    {{- $_ := set $headers "VL-Extra-Fields" . }}
  {{- end }}
  {{- with $Values.ignoreFields }}
    {{- $_ := set $headers "VL-Ignore-Fields" . }}
  {{- end }}
  {{- $output := default dict }}
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
  {{- $idx := .idx }}
  {{- $rw := index $Values.remoteWrite $idx }}
  {{- $config := default dict }}
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

  {{- $args := dict "kubernetesCollector" true }}
  {{- $_ := set $args "kubernetesCollector.msgField" (join "," ($Values.msgField | default (list "message"))) }}
  {{- $_ := set $args "kubernetesCollector.timeField" (join "," ($Values.timeField | default (list "timestamp"))) }}
  {{- with $Values.excludeFilter }}
    {{- $_ := set $args "kubernetesCollector.excludeFilter" . }}
  {{- end }}
  {{- $_ := set $args "kubernetesCollector.includePodLabels" $Values.includePodLabels }}
  {{- $_ := set $args "kubernetesCollector.includePodAnnotations" $Values.includePodAnnotations }}
  {{- $_ := set $args "kubernetesCollector.includeNodeLabels" $Values.includeNodeLabels }}
  {{- $_ := set $args "kubernetesCollector.includeNodeAnnotations" $Values.includeNodeAnnotations }}
  {{- $_ := set $args "envflag.enable" true }}
  {{- $_ := set $args "envflag.prefix" "VL_" }}
  {{- $_ := set $args "tmpDataPath" "/vl-collector" }}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/vl-collector/remotewrite-data" }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) }}

  {{- $requiredParams := list "url" }}

  {{- range $i, $oldRw := $Values.remoteWrite }}
    {{- $rw := deepCopy $oldRw }}
    {{- $_ := set $ "idx" $i }}
    {{- $_ := set $rw "headers" (fromYaml (include "victoria-logs-collector.headers" $)) }}
    {{- $_ := unset $rw "accountID" }}
    {{- $_ := unset $rw "projectID" }}
    {{- $_ := unset $rw "extraFields" }}
    {{- $_ := unset $rw "ignoreFields" }}
    {{- $rw = mergeOverwrite $rw (fromYaml (include "victoria-logs-collector.tls" $)) }}
    {{- $_ := unset $rw "tls"}}

    {{- if hasKey $rw "basicAuth" }}
      {{- fail "set VL_remoteWrite_basicAuth_username and VL_remoteWrite_basicAuth_password env vars instead" }}
    {{- end }}

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
        {{- $value = printf "%s/insert/native" (trimSuffix "/" $rwValue) }}
      {{- else if eq $rwKey "headers" }}
        {{- $headers := list }}
        {{- range $hk, $hv := $rwValue }}
          {{- $headers = append $headers (printf "%s:%s" $hk $hv) }}
        {{- end }}
        {{- $value = quote (join "^^" $headers) }}
      {{- end }}
      {{- $param = append $param $value }}
      {{- $_ := set $args $key $param }}
    {{- end }}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}
