{{- define "vlogs.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $args := dict -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
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
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- if and (empty (index $extraArgs "syslog.listenAddr.tcp")) (empty (index $extraArgs "syslog.listenAddr.udp")) -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $app.syslog)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
