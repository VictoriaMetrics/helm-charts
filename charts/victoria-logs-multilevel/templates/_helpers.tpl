{{- define "vmauth.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.vmauth -}}
  {{- $args := dict -}}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlselect -}}
  {{- $args := dict -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
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
{{- $service := .service -}}
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9471") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}}
{{- $service := .service -}}
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8427") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- range $service.extraPorts }} 
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}
