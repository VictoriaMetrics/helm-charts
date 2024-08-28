{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- $global := .global -}}
  {{- $value := (include "vm.fullname" $global) -}}
  {{- with .vmService -}}
    {{- $service := (index $global .) | default dict -}}
    {{- $prefix := ternary . (printf "vm%s" .) (hasPrefix "vm" .) -}}
    {{- $value = ($service).name | default (printf "%s-%s" $prefix $value) -}}
  {{- end -}}
  {{- if hasKey . "vmIdx" -}}
    {{- $value = (printf "%s-%d.%s" $value .vmIdx $value) -}}
  {{- end -}}
  {{- $value -}}
{{- end }}

{{- define "vm.url" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- $global := .global -}}
  {{- $ns := $global.Release.Namespace -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .vmRoute | default "/" -}}
  {{- $isSecure := false -}}
  {{- if .vmSecure -}}
    {{- $isSecure = .vmSecure -}}
  {{- end -}}
  {{- with .vmService -}}
    {{- $service := index ($global.Values) . | default dict -}}
    {{- $spec := $service.spec | default dict -}}
    {{- $isSecure = ($spec.extraArgs).tls | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default $port -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s.%s.svc:%d%s" $proto $name $ns (int $port) $path -}}
{{- end -}}
