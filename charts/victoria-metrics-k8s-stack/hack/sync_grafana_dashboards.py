#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
from ast import operator
from faulthandler import enable
import json
import re
import textwrap
from os import makedirs, path

import requests
import yaml
from yaml.representer import SafeRepresenter


# https://stackoverflow.com/a/20863889/961092
class LiteralStr(str):
    pass


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer

sources_json = [
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmagent.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics-cluster.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmalert.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/operator.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/backupmanager.json',
    }
]
# Source files list
sources_yaml = [
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/grafana-dashboardDefinitions.yaml',
    },
]

allow_dashboards_list = [
    "alertmanager-overview.json",
    "grafana-overview.json",
]

dashboards_destination = "../templates/grafana/dashboards"

# Additional conditions map
condition_map = {
    'grafana-coredns-k8s': '.Values.coreDns.enabled',
    'etcd': '.Values.kubeEtcd.enabled',
    'apiserver': '.Values.kubeApiServer.enabled',
    'controller-manager': '.Values.kubeControllerManager.enabled',
    'kubelet': '.Values.kubelet.enabled',
    'proxy': '.Values.kubeProxy.enabled',
    'scheduler': '.Values.kubeScheduler.enabled',
    'node-rsrc-use': '(index .Values "prometheus-node-exporter" "enabled")',
    'node-cluster-rsrc-use': '(index .Values "prometheus-node-exporter" "enabled")',
    'victoriametrics-cluster': '.Values.vmcluster.enabled',
    'victoriametrics': '.Values.vmsingle.enabled',
    'vmalert': '.Values.vmalert.enabled',
    'operator': '(index .Values "victoria-metrics-operator" "enabled")',
    'k8s-system-coredns': '.Values.experimentalDashboardsEnabled .Values.coreDns.enabled',
    'k8s-system-api-server': '.Values.experimentalDashboardsEnabled .Values.kubeApiServer.enabled',
    'k8s-views-pods': '.Values.experimentalDashboardsEnabled .Values.kubelet.enabled',
    'k8s-views-nodes': '.Values.experimentalDashboardsEnabled .Values.kubelet.enabled',
    'k8s-views-namespace': '.Values.experimentalDashboardsEnabled .Values.kubelet.enabled',
    'k8s-views-global': '.Values.experimentalDashboardsEnabled .Values.kubelet.enabled',
}

# standard header
header = '''{{- /*
Generated from '%(name)s' from %(url)s
Do not change in-place! In order to change this file first read following link:
https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack/hack
*/ -}}
{{- %(condition)s }}
{{- if .Values.grafanaOperatorDashboardsFormat.enabled }}
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ printf "%%s-%%s" (include "victoria-metrics-k8s-stack.fullname" $) "%(name)s" | replace "_" "" | trunc 63 | trimSuffix "-" | trimSuffix "." }}
  labels:
    app: {{ include "victoria-metrics-k8s-stack.name" $ }}-grafana
    {{- include "victoria-metrics-k8s-stack.labels" $ | nindent 4 }}
spec:
  {{- with .Values.grafanaOperatorDashboardsFormat.instanceSelector }}
  instanceSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.grafanaOperatorDashboardsFormat.allowCrossNamespaceImport }}
  allowCrossNamespaceImport: true
  {{- end }}
{{- else }}
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ printf "%%s-%%s" (include "victoria-metrics-k8s-stack.fullname" $) "%(name)s" | trunc 63 | trimSuffix "-" | trimSuffix "." }}
  labels:
    {{- if $.Values.grafana.sidecar.dashboards.label }}
    {{ $.Values.grafana.sidecar.dashboards.label }}: "1"
    {{- end }}
    {{- if $.Values.grafana.sidecar.dashboards.additionalDashboardLabels }}
    {{- range $key, $val := .Values.grafana.sidecar.dashboards.additionalDashboardLabels }}
    {{ $key }}: {{ $val | quote }}
    {{- end }}
    {{- end }}
    app: {{ include "victoria-metrics-k8s-stack.name" $ }}-grafana
    {{- include "victoria-metrics-k8s-stack.labels" $ | nindent 4 }}
    {{- if $.Values.grafana.sidecar.dashboards.additionalDashboardAnnotations }}
  annotations:
    {{- range $key, $val := .Values.grafana.sidecar.dashboards.additionalDashboardAnnotations }}
    {{ $key }}: {{ $val | quote }}
    {{- end }}
    {{- end }}
data:
{{- end }}
'''


def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(LiteralStr, represent_literal_str)


def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")


def unescape(s):
    return s.replace("\{\{", "{{").replace("\}\}", "}}")


def yaml_str_repr(struct, indent=2):
    """represent yaml as a string"""
    text = yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )
    text = escape(text)  # escape {{ and }} for helm
    text = unescape(text)  # unescape \{\{ and \}\} for templating
    text = textwrap.indent(text, ' ' * indent)
    return text


def replace_ds_type_in_panel(panel):
    if 'datasource' in panel:
        if 'type' in panel['datasource']:
            panel['datasource']['type'] = '__VM_DEFAULT_DATASOURCE__'
    for target in panel.get('targets', []):
        if 'datasource' in target:
            if 'type' in target['datasource']:
                target['datasource']['type'] = '__VM_DEFAULT_DATASOURCE__'

def patch_dashboards_json(content):
    try:
        content_struct = json.loads(content)

        ## multicluster
        overwrite_list = []
        if 'templating' in content_struct:
            for variable in content_struct['templating'].get('list', []):
                if variable.get('name', '') == 'cluster':
                    variable['hide'] = ':multicluster:'
                if variable.get('type', '') == 'datasource' and variable.get('query', '') == 'prometheus':
                    variable['query'] = '__VM_DEFAULT_DATASOURCE__'
                overwrite_list.append(variable)
        content_struct['templating']['list'] = overwrite_list

        ## make dashboards readonly
        content_struct['editable'] = False

        ## add common tag
        if 'tags' in content_struct:
            content_struct['tags'].append('vm-k8s-stack')

        ## fix drilldown links. see https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/659
        for row in content_struct.get('rows', []):
            for panel in row.get('panels', []):
                replace_ds_type_in_panel(panel)
                for style in panel.get('styles', []):
                    if 'linkUrl' in style and style['linkUrl'].startswith('./d'):
                        style['linkUrl'] = style['linkUrl'].replace('./d', '/d')

        for panel in content_struct.get('panels', []):
            replace_ds_type_in_panel(panel)

        content_array = []
        original_content_lines = content.split('\n')
        for i, line in enumerate(json.dumps(content_struct, indent=4).split('\n')):
            if ('[]' not in line and '{}' not in line) or line == original_content_lines[i]:
                content_array.append(line)
                continue

            append = ''
            if line.endswith(','):
                line = line[:-1]
                append = ','

            if line.endswith('{}') or line.endswith('[]'):
                content_array.append(line[:-1])
                content_array.append('')
                content_array.append(' ' * (len(line) - len(line.lstrip())) + line[-1] + append)

        content = '\n'.join(content_array)

        multicluster = content.find(':multicluster:')
        if multicluster != -1:
            content = ''.join((
                content[:multicluster-1],
                '\{\{ if .Values.grafana.sidecar.dashboards.multicluster \}\}0\{\{ else \}\}2\{\{ end \}\}',
                content[multicluster + 15:]
            ))
    except (ValueError, KeyError) as err:
        print("Cannot update dashboard content: ", err)

    return content


def patch_json_set_timezone_as_variable(content):
    # content is no more in json format, so we have to replace using regex
    return re.sub(r'"timezone"\s*:\s*"(?:\\.|[^\"])*"', '"timezone": "\{\{ .Values.grafana.defaultDashboardsTimezone \}\}"', content, flags=re.IGNORECASE)


def write_group_to_file(resource_name, content, url, destination):
    if condition_map.get(resource_name, ""):
        cond = f'if and .Values.defaultDashboardsEnabled {condition_map.get(resource_name, "")}'
    else:
        cond = f'if .Values.defaultDashboardsEnabled'

    # initialize header
    lines = header % {
        'name': resource_name,
        'url': url,
        "condition": cond.strip()
    }

    content = patch_dashboards_json(content)
    content = patch_json_set_timezone_as_variable(content)

    # rules themselves
    lines += '  {{ if not .Values.grafanaOperatorDashboardsFormat.enabled }}' + resource_name + '.{{ end }}json:'
    lines += yaml_str_repr((LiteralStr(content)))

    # footer
    lines += '{{- end }}'

    # replace placeholders with datasource type variable
    lines = lines.replace("__VM_DEFAULT_DATASOURCE__", '{{ default \"prometheus\" .Values.grafana.defaultDatasourceType }}')

    filename = resource_name + '.yaml'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(lines)

    print("Generated %s" % new_filename)


def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for src in sources_json:
        print("Generating dashboards from %s" % src['source'])
        response = requests.get(src['source'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text
        json_text = json.loads(raw_text)
        # is it already a dashboard structure or is it nested (etcd case)?
        flat_structure = bool(json_text.get('annotations'))
        if flat_structure:
            resource = src.get('name', path.basename(src['source']).replace('.json', ''))
            write_group_to_file(resource, json.dumps(json_text, indent=4), src['source'], dashboards_destination)
        else:
            for resource, content in json_text.items():
                write_group_to_file(resource.replace('.json', ''), json.dumps(content, indent=4), src['source'], dashboards_destination)

    for src in sources_yaml:
        print("Generating dashboards from %s" % src['source'])
        response = requests.get(src['source'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text
        yaml_text = yaml.full_load(raw_text)
        groups = yaml_text['items']
        for group in groups:
            for resource, content in group['data'].items():
                if resource not in allow_dashboards_list:
                    continue
                write_group_to_file(resource.replace('.json', ''), content, src['source'], dashboards_destination)
       
    print("Finished")


if __name__ == '__main__':
    main()
