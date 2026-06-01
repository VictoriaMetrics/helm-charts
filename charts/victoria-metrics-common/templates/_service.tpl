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

{{- define "vm.args.positional" -}}
  {{- $args := dict -}}
  {{- $boolKeys := dict -}}
  {{- $n := 0 -}}
  {{- range $i, $item := . -}}
    {{- $n = add $i 1 -}}
    {{- range $k, $v := $item -}}
      {{- if kindIs "bool" $v -}}
        {{- $_ := set $boolKeys $k true -}}
      {{- end -}}
      {{- $param := index $args $k | default list -}}
      {{- if or $v (kindIs "bool" $v) -}}
        {{- $gapFill := ternary false "" ((index $boolKeys $k) | default false) -}}
        {{- range until (int (sub $i (len $param))) }}
          {{- $param = append $param $gapFill }}
        {{- end }}
        {{- $param = append $param $v }}
        {{- $_ := set $args $k $param -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- range $k := keys $boolKeys -}}
    {{- $v := index $args $k | default list -}}
    {{- range until (int (sub $n (len $v))) }}
      {{- $v = append $v false }}
    {{- end }}
    {{- $_ := set $args $k $v -}}
  {{- end -}}
  {{- $dropKeys := list -}}
  {{- range $k, $v := $args -}}
    {{- $hasValue := false -}}
    {{- range $v -}}
      {{- if . -}}
        {{- $hasValue = true -}}
      {{- end -}}
    {{- end -}}
    {{- if not $hasValue -}}
      {{- $dropKeys = append $dropKeys $k -}}
    {{- end -}}
  {{- end -}}
  {{- range $k := $dropKeys -}}
    {{- $_ := unset $args $k -}}
  {{- end -}}
  {{- toYaml $args -}}
{{- end -}}

{{- define "vm.http.args" -}}
  {{- $hasPrimary := false -}}
  {{- $items := list -}}
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
    {{- $item := omit $hl "name" "primary" -}}
    {{- $_ := set $item "httpListenAddr" (index $item "value") -}}
    {{- $item = omit $item "value" -}}
    {{- $items = append $items $item -}}
  {{- end -}}
  {{- if not $hasPrimary -}}
    {{- fail "at least one item in `http` must have `primary: true`" -}}
  {{- end -}}
  {{- include "vm.args.positional" $items -}}
{{- end -}}

{{- define "vl.syslog.args" -}}
  {{- $args := dict -}}
  {{- range $kind, $sls := . -}}
    {{- $items := list -}}
    {{- range $i, $sl := $sls -}}
      {{- if not $sl.value -}}
        {{- fail (printf "`value` is not set for `syslog.%s` idx %d" $kind $i) -}}
      {{- end -}}
      {{- $item := dict -}}
      {{- range $k, $v := (omit $sl "name") -}}
        {{- if eq $k "value" -}}
          {{- $_ := set $item (printf "syslog.listenAddr.%s" $kind) $v -}}
        {{- else if hasPrefix "tls" $k -}}
          {{- $_ := set $item (printf "syslog.%s" $k) $v -}}
        {{- else -}}
          {{- $_ := set $item (printf "syslog.%s.%s" $k $kind) $v -}}
        {{- end -}}
      {{- end -}}
      {{- $items = append $items $item -}}
    {{- end -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $items)) -}}
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
    {{- if and $spec.http (empty ($spec.extraArgs).httpListenAddr) -}}
      {{- range $spec.http -}}
        {{- if and .primary .tls -}}
          {{- $isSecure = true -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- if not $isSecure -}}
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
