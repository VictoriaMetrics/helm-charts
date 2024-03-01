#!/usr/bin/env python3
"""Fetch alerting and aggregation rules from provided urls into this chart."""
import textwrap
from os import makedirs

import requests
import yaml
from yaml.representer import SafeRepresenter
import re


# https://stackoverflow.com/a/20863889/961092
class LiteralStr(str):
    pass


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer


# Source files list
charts = [
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/alertmanager-prometheusRule.yaml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubernetesControlPlane-prometheusRule.yaml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubePrometheus-prometheusRule.yaml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubeStateMetrics-prometheusRule.yaml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/nodeExporter-prometheusRule.yaml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-cluster.yml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-health.yml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-vmagent.yml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts.yml',
        'destination': '../templates/rules',
    },
    {
        'source': 'https://etcd.io/docs/v3.4/op-guide/etcd3_alert.rules.yml',
        'destination': '../templates/rules',
    }
]

skip_list = [
    # "kube-prometheus-general.rules",
    # "kube-prometheus-node-recording.rules"
]
# Additional conditions map
condition_map = {
    'etcd': '.Values.kubeEtcd.enabled .Values.defaultRules.rules.etcd',
    'general.rules': '.Values.defaultRules.rules.general',
    'k8s.rules.container_cpu_usage_seconds_total': '.Values.defaultRules.rules.k8s',
    'k8s.rules.container_memory_cache': '.Values.defaultRules.rules.k8s',
    'k8s.rules.container_memory_rss': '.Values.defaultRules.rules.k8s',
    'k8s.rules.container_memory_swap': '.Values.defaultRules.rules.k8s',
    'k8s.rules.container_memory_working_set_bytes': '.Values.defaultRules.rules.k8s',
    'k8s.rules.container_resource': '.Values.defaultRules.rules.k8s',
    'k8s.rules.pod_owner': '.Values.defaultRules.rules.k8s',
    'kube-apiserver-availability.rules': '.Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverAvailability',
    'kube-apiserver-burnrate.rules': '.Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverBurnrate',
    'kube-apiserver-histogram.rules': '.Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverHistogram',
    'kube-apiserver-slos': '.Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverSlos',
    'kube-apiserver.rules': '.Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserver',
    'kube-prometheus-general.rules': '.Values.defaultRules.rules.kubePrometheusGeneral',
    'kube-prometheus-node-recording.rules': '.Values.defaultRules.rules.kubePrometheusNodeRecording',
    'kube-scheduler.rules': '.Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeScheduler',
    'kube-state-metrics': '.Values.defaultRules.rules.kubeStateMetrics',
    'kubelet.rules': '.Values.kubelet.enabled .Values.defaultRules.rules.kubelet',
    'kubernetes-apps': '.Values.defaultRules.rules.kubernetesApps',
    'kubernetes-resources': '.Values.defaultRules.rules.kubernetesResources',
    'kubernetes-storage': '.Values.defaultRules.rules.kubernetesStorage',
    'kubernetes-system': '.Values.defaultRules.rules.kubernetesSystem',
    'kubernetes-system-apiserver': '.Values.defaultRules.rules.kubernetesSystem',
    'kubernetes-system-controller-manager': '.Values.kubeControllerManager.enabled',
    'kubernetes-system-kubelet': '.Values.defaultRules.rules.kubernetesSystem',
    'kubernetes-system-scheduler': '.Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeScheduler',
    'node-exporter': '.Values.defaultRules.rules.node',
    'node-exporter.rules': '.Values.defaultRules.rules.node',
    'node-network': '.Values.defaultRules.rules.network',
    'node.rules': '.Values.defaultRules.rules.node',
    'vmagent': '.Values.vmagent.enabled .Values.defaultRules.rules.vmagent',
    'alertmanager.rules': '.Values.defaultRules.rules.alertmanager',
    'vmcluster': '.Values.defaultRules.rules.vmcluster',
    'vmsingle': '.Values.defaultRules.rules.vmsingle',
    'vm-health': '.Values.defaultRules.rules.vmhealth'
}

alert_condition_map = {
    'KubeAPIDown': '.Values.kubeApiServer.enabled',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'KubeControllerManagerDown': '.Values.kubeControllerManager.enabled',
    'KubeSchedulerDown': '.Values.kubeScheduler.enabled',
    'KubeStateMetricsDown': ' (index .Values "kube-state-metrics" "enabled")',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'KubeletDown': '.Values.kubelet.enabled',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'PrometheusOperatorDown': '.Values.prometheusOperator.enabled',
    'NodeExporterDown': '.Values.nodeExporter.enabled',
    'CoreDNSDown': '.Values.kubeDns.enabled',
    'AlertmanagerDown': '.Values.alertmanager.enabled',
    'KubeProxyDown': '.Values.kubeProxy.enabled',
}

replacement_map = {
    'https://runbooks.prometheus-operator.dev/runbooks': {
        'replacement': '{{ .Values.defaultRules.runbookUrl }}',
        'init': ''},
    'job="kube-state-metrics"': {
        'replacement': 'job="kube-state-metrics", namespace=~"{{ $targetNamespace }}"',
        'limitGroup': ['kubernetes-apps'],
        'init': '{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}'},
    'job="kubelet"': {
        'replacement': 'job="kubelet", namespace=~"{{ $targetNamespace }}"',
        'limitGroup': ['kubernetes-storage'],
        'init': '{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}'},
    'http://localhost:3000': {
        'replacement': '{{ index .Values.grafana.ingress.hosts 0 }}',
        'init': ''},
    'job="alertmanager-main"': {
        'replacement': 'job="{{ .Values.alertmanager.name | default (printf "%s-%s" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") }}"',
        'init': '',
    },
    'namespace="monitoring"': {
        'replacement': 'namespace="{{ .Release.Namespace }}"',
        'limitGroup': ['alertmanager.rules'],
        'init': '',
    },
}

# standard header
header = '''{{- /*
Generated from '%(name)s' group from %(url)s
Do not change in-place! In order to change this file first read following link:
https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack/hack
*/ -}}
{{- if and .Values.defaultRules.create %(condition)s }}%(init_line)s
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ printf "%%s-%%s" (include "victoria-metrics-k8s-stack.fullname" .) "%(name)s" | replace "_" "" | trunc 63 | trimSuffix "-" | trimSuffix "." }}
  labels:
    app: {{ include "victoria-metrics-k8s-stack.name" $ }}
{{ include "victoria-metrics-k8s-stack.labels" $ | indent 4 }}
{{- if .Values.defaultRules.labels }}
{{ toYaml .Values.defaultRules.labels | indent 4 }}
{{- end }}
{{- if .Values.defaultRules.annotations }}
  annotations:
{{ toYaml .Values.defaultRules.annotations | indent 4 }}
{{- end }}
spec:
  groups:
{{- if .Values.defaultRules.params }}
  - params:
{{ toYaml .Values.defaultRules.params | indent 6 }}
{{ indent 3 "" }}
{{- else }}
  -
{{- end }}'''


def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(LiteralStr, represent_literal_str)


def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")


def fix_expr(rules):
    """Remove trailing whitespaces and line breaks, which happen to creep in
     due to yaml import specifics;
     convert multiline expressions to literal style, |-"""
    for rule in rules:
        rule['expr'] = rule['expr'].rstrip()
        if '\n' in rule['expr']:
            rule['expr'] = LiteralStr(rule['expr'])


def yaml_str_repr(struct, indent=4):
    """represent yaml as a string"""
    text = yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )
    text = escape(text)  # escape {{ and }} for helm
    text = textwrap.indent(text, ' ' * indent)[indent - 1:]  # indent everything, and remove very first line extra indentation
    return text

def add_rules_conditions(rules, rules_map, indent=4):
    """Add if wrapper for rules, listed in rules_map"""
    rule_condition = '{{- if %s }}\n'
    for alert_name in rules_map:
        line_start = ' ' * indent + '- alert: '
        if line_start + alert_name in rules:
            rule_text = rule_condition % rules_map[alert_name]
            start = 0
            # to modify all alerts with same name
            while True:
                try:
                    # add if condition
                    index = rules.index(line_start + alert_name, start)
                    start = index + len(rule_text) + 1
                    rules = rules[:index] + rule_text + rules[index:]
                    # add end of if
                    try:
                        next_index = rules.index(line_start, index + len(rule_text) + 1)
                    except ValueError:
                        # we found the last alert in file if there are no alerts after it
                        next_index = len(rules)

                    # depending on the rule ordering in rules_map it's possible that an if statement from another rule is present at the end of this block.
                    found_block_end = False
                    last_line_index = next_index
                    while not found_block_end:
                        last_line_index = rules.rindex('\n', index, last_line_index - 1)  # find the starting position of the last line
                        last_line = rules[last_line_index + 1:next_index]

                        if last_line.startswith('{{- if'):
                            next_index = last_line_index + 1  # move next_index back if the current block ends in an if statement
                            continue

                        found_block_end = True
                    rules = rules[:next_index] + '{{- end }}\n' + rules[next_index:]
                except ValueError:
                    break
    return rules

def add_rules_conditions_from_condition_map(rules, indent=4):
    """Add if wrapper for rules, listed in alert_condition_map"""
    rules = add_rules_conditions(rules, alert_condition_map, indent)
    return rules

def add_rules_per_rule_conditions(rules, group, indent=4):
    """Add if wrapper for rules, listed in alert_condition_map"""
    rules_condition_map = {}
    for rule in group['rules']:
        if 'alert' in rule:
            rules_condition_map[rule['alert']] = f"not (.Values.defaultRules.disabled.{rule['alert']} | default false)"

    rules = add_rules_conditions(rules, rules_condition_map, indent)
    return rules

def add_custom_labels(rules, indent=4):
    """Add if wrapper for additional rules labels"""
    rule_condition = '{{- if .Values.defaultRules.additionalRuleLabels }}\n{{ toYaml .Values.defaultRules.additionalRuleLabels | indent 8 }}\n{{- end }}'
    rule_condition_len = len(rule_condition) + 1

    separator = " " * indent + "- alert:.*"
    alerts_positions = re.finditer(separator, rules)
    alert = -1
    for alert_position in alerts_positions:
        # add rule_condition at the end of the alert block
        if alert >= 0:
            index = alert_position.start() + rule_condition_len * alert - 1
            rules = rules[:index] + "\n" + rule_condition + rules[index:]
        alert += 1

    # add rule_condition at the end of the last alert
    if alert >= 0:
        index = len(rules) - 1
        rules = rules[:index] + "\n" + rule_condition + rules[index:]
    return rules

def write_group_to_file(group, url, destination):
    fix_expr(group['rules'])
    group_name = group['name']

    # prepare rules string representation
    rules = yaml_str_repr(group)
    # add replacements of custom variables and include their initialisation in case it's needed
    init_line = ''
    for line in replacement_map:
        if group_name in replacement_map[line].get('limitGroup', [group_name]) and line in rules:
            print(f"Applying replace rule for '{line}' in {group_name}")
            rules = rules.replace(line, replacement_map[line]['replacement'])
            if replacement_map[line]['init']:
                init_line += '\n' + replacement_map[line]['init']
    # append per-alert rules
    rules = add_custom_labels(rules)
    rules = add_rules_conditions_from_condition_map(rules)
    rules = add_rules_per_rule_conditions(rules, group)
    # initialize header
    lines = header % {
        'name': group['name'],
        'url': url,
        'condition': condition_map.get(group['name'], ''),
        'init_line': init_line
    }

    # rules themselves
    lines += rules

    # footer
    lines += '{{- end }}'

    new_filename = f"{destination}/{group['name']}.yaml"

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(lines)

    print(f"Generated {new_filename}")

def write_rules_names_template():
    with open('../templates/victoria-metrics-operator/_rules.tpl', 'w') as f:
        f.write('''{{- /*
Generated file. Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}\n''')
        f.write('{{- define "rules.names" }}\n')
        f.write('rules:\n')
        for rule in condition_map:
            f.write('  - "%s"\n' % rule)
        f.write('{{- end }}')


def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for chart in charts:
        print(f"Generating rules from {chart['source']}")
        response = requests.get(chart['source'])
        if response.status_code != 200:
            print(f"Skipping the file, response code {response.status_code} not equals 200")
            continue
        raw_text = response.text
        yaml_text = yaml.full_load(raw_text)

        # etcd workaround, their file don't have spec level
        groups = yaml_text['spec']['groups'] if yaml_text.get('spec') else yaml_text['groups']
        for group in groups:
            # print(group['name'])
            if group['name'] in skip_list:
                continue
            write_group_to_file(group, chart['source'], chart['destination'])

    # write rules.names named template
    write_rules_names_template()

    print("Finished")


if __name__ == '__main__':
    main()
