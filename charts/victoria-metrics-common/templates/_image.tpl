{{/*
Victoria Metrics Image
*/}}
{{- define "vm.image" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $image := (tpl (printf "%s:%s" .app.image.repository (.app.image.tag | default $Chart.AppVersion)) .) -}}
  {{- $license := $Values.license | default dict }}
  {{- $variant := .app.image.variant }}
  {{- if and (eq (include "vm.enterprise.disabled" .) "false") (empty .app.image.tag) -}}
    {{- if $variant }}
      {{- $variant = printf "enterprise-%s" $variant }}
    {{- else }}
      {{- $variant = "enterprise" }}
    {{- end }}
  {{- end -}}
  {{- with $variant -}}
    {{- $image = (printf "%s-%s" $image .) -}}
  {{- end -}}
  {{- with .app.image.registry | default (($Values.global).image).registry | default "" -}}
    {{- $image = (printf "%s/%s" . $image) -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
