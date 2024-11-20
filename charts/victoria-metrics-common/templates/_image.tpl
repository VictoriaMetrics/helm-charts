{{/*
Victoria Metrics Image
*/}}
{{- define "vm.image" -}}
  {{- $image := (fromYaml (include "vm.internal.image" .)).image | default dict -}}
  {{- $tag := include "vm.image.tag" . -}}
  {{- if empty $image.repository -}}
    {{- fail "cannot create image without `.repository` defined" -}}
  {{- end -}}
  {{- $result := tpl (printf "%s:%s" $image.repository $tag) . -}}
  {{- with $image.registry | default "" -}}
    {{- $result = (printf "%s/%s" . $result) -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{- define "vm.image.tag" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $image := (fromYaml (include "vm.internal.image" .)).image | default dict -}}
  {{- $tag := $image.tag -}}
  {{- if empty $tag }}
    {{- $tag = $Chart.AppVersion -}}
    {{- $variant := $image.variant }}
    {{- if eq (include "vm.enterprise.disabled" .) "false" -}}
      {{- if $variant }}
        {{- $variant = printf "enterprise-%s" $variant }}
      {{- else }}
        {{- $variant = "enterprise" }}
      {{- end }}
    {{- end -}}
    {{- with $variant -}}
      {{- $tag = (printf "%s-%s" $tag .) -}}
    {{- end -}}
  {{- end -}}
  {{- $tag -}}
{{- end -}}

{{- define "vm.internal.image" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $values := $Values -}}
  {{- $ctx := . -}}
  {{- with .appKey -}}
    {{- $appKey := ternary (list .) . (kindIs "string" .) -}}
    {{- range $ak := $appKey -}}
      {{- $values = ternary (default dict) (index $values $ak | default dict) (empty $values) -}}
      {{- $ctx = ternary (default dict) (index $ctx $ak | default dict) (empty $ctx) -}}
      {{- if and (empty $values) (empty $ctx) -}}
        {{- fail (printf "No data for appKey %s" (join "->" $appKey)) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $image := ternary $ctx.image $values.image (hasKey $ctx "image") -}}
  {{- $image = mergeOverwrite (deepCopy (($Values.global).image | default dict)) ($image | default dict) -}}
  {{- toYaml (dict "image" $image) -}}
{{- end -}}
