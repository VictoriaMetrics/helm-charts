{{- define "vmauth.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.vmauth -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlselect -}}
  {{- $args := $app.extraArgs -}}
  {{- $storageNodes := $args.storageNodes | default list }}
  {{- with $Values.storageNodes }}
    {{- $storageNodes = concat $storageNodes . }}
  {{- end }}
  {{- if empty $storageNodes }}
    {{- fail "no storageNodes found. Please set at least one storage node using `.Values.storageNodes` property" }}
  {{- end }}
  {{- $_ := set $args "storageNode" $storageNodes }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.ports" -}}
{{- $service := .service }}
{{- $extraArgs := .extraArgs -}}
- name: http
  port: {{ $service.servicePort }}
  protocol: TCP
  targetPort: {{ $service.targetPort }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}}
{{- $service := .service -}}
- port: {{ $service.servicePort }}
  targetPort: http
  protocol: TCP 
  name: http 
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}
