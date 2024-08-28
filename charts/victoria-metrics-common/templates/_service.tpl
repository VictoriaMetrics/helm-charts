{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $name := (include "vm.fullname" .) -}}
  {{- with .appKey -}}
    {{- $service := (index $Values .) | default dict -}}
    {{- $prefix := ternary . (printf "vm%s" .) (hasPrefix "vm" .) -}}
    {{- $name = ($service).name | default (printf "%s-%s" $prefix $name) -}}
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
  {{- $ns := $Release.Namespace -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := ternary false true (empty .appSecure) -}}
  {{- with .appKey -}}
    {{- $service := index $Values . | default dict -}}
    {{- $spec := $service.spec | default dict -}}
    {{- $isSecure = ($spec.extraArgs).tls | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default $port -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s.%s.svc:%d%s" $proto $name $ns (int $port) $path -}}
{{- end -}}
