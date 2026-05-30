{{- define "vm.fqdn" -}}
  {{- include "vm.validate.args" . -}}
  {{- $nameTpl := "" -}}
  {{- if eq .style "managed" -}}
    {{- $nameTpl = "vm.managed.fullname" -}}
  {{- else if eq .style "plain" -}}
    {{- $nameTpl = "vm.plain.fullname" -}}
  {{- else -}}
    {{- fail ".style argument should be either `plain` or `managed`" -}}
  {{- end -}}
  {{- $name := (include $nameTpl .) -}}
  {{- if hasKey . "appIdx" -}}
    {{- $name = (printf "%s-%d.%s" $name .appIdx $name) -}}
  {{- end -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ns := (include "vm.namespace" .) -}}
  {{- $fqdn := printf "%s.%s.svc" $name $ns -}}
  {{- with (($Values.global).cluster).dnsDomain -}}
    {{- $fqdn = printf "%s.%s" $fqdn . -}}
  {{- end -}}
  {{- $fqdn -}}
{{- end -}}

{{- define "vm.addr.primary" -}}
  {{- $addr := "" -}}
  {{- range $i, $hl := . -}}
    {{- if not $hl.value -}}
      {{- fail (printf "`value` is not set for `http` idx %d" $i) -}}
    {{- end -}}
    {{- if $hl.primary -}}
      {{- if $addr -}}
        {{- fail "found more than one primary address, which is not allowed" -}}
      {{- end -}}
      {{- $addr = $hl.value -}}
    {{- end -}}
  {{- end -}}
  {{- $addr -}}
{{- end -}}

{{- define "vm.http.args" -}}
  {{- $args := dict }}
  {{- $hasPrimary := false -}}
  {{- range $i, $hl := . -}}
    {{- if not $hl.value -}}
      {{- fail (printf "`value` is not set for `http` idx %d" $i) -}}
    {{- end -}}
    {{- if not $hl.name -}}
      {{- fail (printf "`name` is not set for `http` idx %d" $i) -}}
    {{- end -}}
    {{- if $hl.primary -}}
      {{- $hasPrimary = true -}}
    {{- end -}}
    {{- range $hlKey, $hlValue := (omit $hl "name" "primary") -}}
      {{- $key := ternary "httpListenAddr" $hlKey (eq $hlKey "value") -}}
      {{- $param := index $args $key | default list -}}
      {{- if $hlValue -}}
        {{- range until (int (sub $i (len $param))) }}
          {{- $param = append $param "" }}
        {{- end }}
        {{- $param = append $param $hlValue }}
        {{- $_ := set $args $key $param -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if not $hasPrimary -}}
    {{- fail "at least one item in `http` must have `primary: true`" -}}
  {{- end -}}
  {{- toYaml $args -}}
{{- end -}}

{{- define "vm.url" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $fqdn := (include "vm.fqdn" .) -}}
  {{- $proto := "http" -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := ternary false true (empty .appSecure) -}}
  {{- $port := 80 -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $values := $Values -}}
    {{- $ctx := . -}}
    {{- range $ak := $appKey -}}
      {{- $values = ternary (dict) (index $values $ak | default dict) (empty $values) -}}
      {{- $ctx = ternary (dict) (index $ctx $ak | default dict) (empty $ctx) -}}
    {{- end -}}
    {{- $spec := $values | default $ctx -}}
    {{- if $spec.http -}}
      {{- range $spec.http -}}
        {{- if and .primary .tls -}}
          {{- $isSecure = true -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- with ($spec.extraArgs).tls -}}
        {{- $isSecure = eq (toString .) "true" -}}
      {{- end -}}
    {{- end -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- with $spec.http -}}
      {{- with (include "vm.addr.primary" .) -}}
        {{- $port = include "vm.port.from.flag" (dict "flag" . "default" $port) -}}
      {{- end -}}
    {{- end -}}
    {{- $port = $spec.port | default ($spec.service).servicePort | default ($spec.service).port | default $port -}}
    {{- if hasKey . "appIdx" -}}
      {{- $port = (include "vm.port.from.flag" (dict "flag" ($spec.extraArgs).httpListenAddr "default" $port)) -}}
    {{- end -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s:%v%s" $proto $fqdn $port (trimSuffix "/" $path) -}}
{{- end -}}
