{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $name := (include "vm.fullname" .) -}}
  {{- with .appKey -}}
    {{- $prefix := . -}}
    {{- $prefix := . -}}
    {{- if kindIs "slice" $prefix }}
      {{- $prefix = last $prefix -}}
    {{- end -}}
    {{- $prefix = ternary $prefix (printf "vm%s" $prefix) (hasPrefix "vm" $prefix) -}}
    {{- $name = printf "%s-%s" $prefix $name -}}
  {{- end -}}
  {{- if hasKey . "appIdx" -}}
    {{- $name = (printf "%s-%d.%s" $name .appIdx $name) -}}
  {{- end -}}
  {{- $name -}}
{{- end }}

{{- define "vm.url" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ns := (include "vm.namespace .) -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := ternary false true (empty .appSecure) -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $spec := $Values -}}
    {{- range $ak := $appKey -}}
      {{- if hasKey $spec $ak -}}
        {{- $spec = (index $spec $ak) -}}
      {{- end -}}
      {{- if hasKey $spec "spec" -}}
        {{- $spec = $spec.spec -}}
      {{- end -}}
    {{- end -}}
    {{- $isSecure = (eq ($spec.extraArgs).tls "true") | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default $port -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s.%s.svc:%d%s" $proto $name $ns (int $port) $path -}}
{{- end -}}
