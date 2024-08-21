{{- define "vm.port.from.flag" -}}
{{- $port := .default -}}
{{- with .flag -}}
{{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" -}}
{{- end -}}
{{- $port -}}
{{- end }}
