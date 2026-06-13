{{- define "vm.port.from.flag" -}}
  {{- $port := .default -}}
  {{- with .flag -}}
    {{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" -}}
  {{- end -}}
  {{- $port -}}
{{- end }}

{{- /*
Return true if the detected platform is Openshift
Usage:
{{- include "vm.isOpenshift" . -}}
*/ -}}
{{- define "vm.isOpenshift" -}}
  {{- $Capabilities := (.helm).Capabilities | default .Capabilities -}}
  {{- if $Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{- /*
Render a compatible securityContext depending on the platform.
Usage:
{{- include "vm.securityContext" (dict "securityContext" .Values.containerSecurityContext "helm" .) -}}
*/ -}}
{{- define "vm.securityContext" -}}
  {{- $securityContext := omit .securityContext "enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $adaptMode := (((($Values).global).compatibility).openshift).adaptSecurityContext | default "" -}}
  {{- if or (eq $adaptMode "force") (and (eq $adaptMode "auto") (include "vm.isOpenshift" .)) -}}
    {{- $securityContext = omit $securityContext "fsGroup" "runAsUser" "runAsGroup" "seLinuxOptions" -}}
  {{- end -}}
  {{- toYaml $securityContext -}}
{{- end -}}

{{- /*
Render probe
*/ -}}
{{- define "vm.probe" -}}
  {{- /* undefined value */ -}}
  {{- $null := (fromYaml "value: null").value -}}
  {{- $probe := dig .type (dict) (.app.probe | default dict) -}}
  {{- /* port name from primary http item */ -}}
  {{- $port := "http" -}}
  {{- range (.app).http -}}
    {{- if .primary -}}
      {{- $port = .name -}}
    {{- end -}}
  {{- end -}}
  {{- $isSecure := false -}}
  {{- if and (.app).http (empty ((.app).extraArgs | default dict).httpListenAddr) -}}
    {{- range (.app).http -}}
      {{- if and .primary .tls -}}
        {{- $isSecure = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if not $isSecure -}}
    {{- with ((.app).extraArgs).tls -}}
      {{- $isSecure = eq (toString .) "true" -}}
    {{- end -}}
  {{- end -}}
  {{- $probeType := "" -}}
  {{- $defaultProbe := dict -}}
  {{- if ne (dig "httpGet" $null $probe) $null -}}
    {{- $httpGetConfig := dig "httpGet" (dict) $probe -}}
    {{- if and $isSecure (empty $httpGetConfig) -}}
      {{- /* TLS with default (empty) httpGet: use tcpSocket instead */ -}}
      {{- $defaultProbe = dict "port" $port -}}
      {{- $probeType = "tcpSocket" -}}
    {{- else -}}
      {{- $path := index ((.app).extraArgs | default dict) "http.pathPrefix" | default "" | trimSuffix "/" -}}
      {{- $defaultProbe = dict "path" (printf "%s/health" $path) "scheme" "HTTP" "port" $port -}}
      {{- $probeType = "httpGet" -}}
    {{- end -}}
  {{- else if ne (dig "tcpSocket" $null $probe) $null -}}
    {{- /* tcpSocket probe */ -}}
    {{- $defaultProbe = dict "port" $port -}}
    {{- $probeType = "tcpSocket" -}}
  {{- end -}}
  {{- $defaultProbe = ternary (dict) (dict $probeType $defaultProbe) (empty $probeType) -}}
  {{- $probe = mergeOverwrite $defaultProbe $probe -}}
  {{- range $key, $value := $probe -}}
    {{- if and (ne $key $probeType) (has (kindOf $value) (list "invalid" "object" "map")) -}}
      {{- $_ := unset $probe $key -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (toYaml $probe) . -}}
{{- end -}}

{{- define "vm.arg" -}}
  {{- if and (empty .value) (kindIs "string" .value) (ne (toString .list) "true") }}
    {{- .key -}}
  {{- else if eq (toString .value) "true" -}}
    -{{ ternary "" "-" (eq (len .key) 1) }}{{ .key }}
  {{- else -}}
    -{{ ternary "" "-" (eq (len .key) 1) }}{{ .key }}={{ ternary (toJson .value | squote) .value (has (kindOf .value) (list "map" "slice")) }}
  {{- end -}}
{{- end -}}

{{- /*
command line arguments
*/ -}}
{{- define "vm.args" -}}
  {{- $args := list -}}
  {{- range $key, $value := . -}}
    {{- if not $key -}}
      {{- fail "Empty key in command line args is not allowed" -}}
    {{- end -}}
    {{- if kindIs "slice" $value -}}
      {{- range $v := $value -}}
        {{- $args = append $args (include "vm.arg" (dict "key" $key "value" $v "list" true)) -}}
      {{- end -}}
    {{- else -}}
      {{- $args = append $args (include "vm.arg" (dict "key" $key "value" $value)) -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (dict "args" $args) -}}
{{- end -}}
