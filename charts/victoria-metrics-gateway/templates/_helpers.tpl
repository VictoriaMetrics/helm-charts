{{- define "vmgateway.args" -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "clusterMode" .Values.clusterMode -}}
  {{- if hasKey .Values.rateLimiter "enable" }}
    {{- fail "`rateLimiter.enable` is deprecated. Use `rateLimiter.enabled` instead" }}
  {{- end }}
  {{- if .Values.rateLimiter.enabled -}}
    {{- $_ := set $args "ratelimit.config" "/config/rate-limiter.yml" -}}
    {{- $_ := set $args "datasource.url" .Values.rateLimiter.datasource.url -}}
    {{- $_ := set $args "enable.rateLimit" .Values.rateLimiter.enabled -}}
  {{- end -}}
  {{- $_ := set $args "enable.auth" .Values.auth.enabled -}}
  {{- $_ := set $args "read.url" .Values.read.url -}}
  {{- $_ := set $args "write.url" .Values.write.url -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args .Values.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
