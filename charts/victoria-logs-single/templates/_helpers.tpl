
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

{{- define "vlogs.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $args := dict -}}
  {{- if and (empty $app.retentionPeriod) (empty $app.retentionDiskSpaceUsage) (empty $app.retentionMaxDiskUsagePercent) -}}
    {{- fail "either .Values.server.retentionPeriod, .Values.server.retentionDiskSpaceUsage or .Values.server.retentionMaxDiskUsagePercent should be defined" -}}
  {{- end -}}
  {{- with $app.retentionPeriod -}}
    {{- $_ := set $args "retentionPeriod" $app.retentionPeriod -}}
  {{- end -}}
  {{- with $app.retentionDiskSpaceUsage -}}
    {{- $retentionDiskSpaceUsage := int $app.retentionDiskSpaceUsage -}}
    {{- if $retentionDiskSpaceUsage -}}
      {{- $_ := set $args "retention.maxDiskSpaceUsageBytes" (printf "%dGiB" $retentionDiskSpaceUsage) -}}
    {{- else -}}
      {{- $_ := set $args "retention.maxDiskSpaceUsageBytes" $app.retentionDiskSpaceUsage -}}
    {{- end -}}
  {{- end -}}
  {{- with $app.retentionMaxDiskUsagePercent -}}
    {{- $_ := set $args "retention.maxDiskUsagePercent" $app.retentionMaxDiskUsagePercent -}}
  {{- end -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $app.syslog)) -}}
  {{- include "vm.check.extraArgs" $app.extraArgs -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
