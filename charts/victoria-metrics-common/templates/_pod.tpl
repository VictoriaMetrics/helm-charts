{{- define "vm.port.from.flag" -}}
{{- $port := .default -}}
{{- with .flag -}}
{{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" -}}
{{- end -}}
{{- $port -}}
{{- end }}

{{/*
Return true if the detected platform is Openshift
Usage:
{{- include "vm.compatibility.isOpenshift" . -}}
*/}}
{{- define "vm.compatibility.isOpenshift" -}}
{{- if .Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Render a compatible securityContext depending on the platform. By default it is maintained as it is. In other platforms like Openshift we remove default user/group values that do not work out of the box with the restricted-v1 SCC
Usage:
{{- include "vm.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) -}}
*/}}
{{- define "vm.compatibility.renderSecurityContext" -}}
{{- $adaptedContext := .secContext -}}
{{- $adaptSecurityCtx := ((((.context.Values).global).compatibility).openshift).adaptSecurityContext | default "" -}}
{{- if or (eq $adaptSecurityCtx "force") (and (eq $adaptSecurityCtx "auto") (include "vm.compatibility.isOpenshift" .context)) -}}
  {{/* Remove incompatible user/group values that do not work in Openshift out of the box */}}
  {{- $adaptedContext = omit $adaptedContext "fsGroup" "runAsUser" "runAsGroup" -}}
  {{- if not .secContext.seLinuxOptions -}} 
    {{/* If it is an empty object, we remove it from the resulting context because it causes validation issues */}}
    {{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
  {{- end -}}
{{- end -}}
{{- omit $adaptedContext "enabled" | toYaml -}}
{{- end -}}
