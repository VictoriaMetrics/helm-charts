{{- define "vm.enterprise.only" -}}
  {{- $license := .Values.license | default dict -}}
  {{- if and (empty $license.key) (empty (dig "secret" "name" "" $license)) (not .Values.eula) -}}
    {{ fail "Pass -eula command-line flag or valid license at .Values.license if you have an enterprise license for running this software. See https://victoriametrics.com/legal/esa/ for details"}}
  {{- end -}}
{{- end -}}

{{/*
Return license volume mount
*/}}
{{- define "vm.license.volume" -}}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
- name: license-key
  secret:
    secretName: {{ .Values.license.secret.name }}
{{- end -}}
{{- end -}}

{{/*
Return license volume mount for container
*/}}
{{- define "vm.license.mount" -}}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
- name: license-key
  mountPath: /etc/vm-license-key
  readOnly: true
{{- end -}}
{{- end -}}

{{/*
Return license flag if necessary.
*/}}
{{- define "vm.license.flag" -}}
{{- if .Values.license.key -}}
-license={{ .Values.license.key }}
{{- end }}
{{- if and .Values.license.secret.name .Values.license.secret.key -}}
-licenseFile=/etc/vm-license-key/{{ .Values.license.secret.key }}
{{- end -}}
{{- end -}}
