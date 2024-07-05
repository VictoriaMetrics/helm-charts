#!/usr/bin/env python3
"""Fetch alerting and aggregation rules from provided urls into this chart."""
from os import makedirs
from os.path import realpath, dirname, join

import requests
import yaml
from yaml.representer import SafeRepresenter
import re

rulesDir = join(dirname(realpath(__file__)), "..", "files", "rules", "generated")

# https://stackoverflow.com/a/20863889/961092
class literal(str):
    pass

class quoted(str):
    pass


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer


# Source files list
rules = [
    'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/alertmanager-prometheusRule.yaml',
    'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubernetesControlPlane-prometheusRule.yaml',
    'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubePrometheus-prometheusRule.yaml',
    'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubeStateMetrics-prometheusRule.yaml',
    'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/nodeExporter-prometheusRule.yaml',
    'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-cluster.yml',
    'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-health.yml',
    'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-vmagent.yml',
    'https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts.yml',
    'https://etcd.io/docs/v3.5/op-guide/etcd3_alert.rules.yml',
]

# Additional conditions map
condition_map = {
    'etcd': '.Values.kubeEtcd.enabled',
    'kube-apiserver-availability.rules': '.Values.kubeApiServer.enabled',
    'kube-apiserver-burnrate.rules': '.Values.kubeApiServer.enabled',
    'kube-apiserver-histogram.rules': '.Values.kubeApiServer.enabled',
    'kube-apiserver-slos': '.Values.kubeApiServer.enabled',
    'kube-apiserver.rules': '.Values.kubeApiServer.enabled',
    'kube-scheduler.rules': '.Values.kubeScheduler.enabled',
    'kubelet.rules': '.Values.kubelet.enabled',
    'kubernetes-system-controller-manager': '.Values.kubeControllerManager.enabled',
    'kubernetes-system-scheduler': '.Values.kubeScheduler.enabled'
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

skip_list = [
    # "kube-prometheus-general.rules",
    # "kube-prometheus-node-recording.rules"
]

def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")

replacement_map = {
    'https://runbooks.prometheus-operator.dev/runbooks': {
        'replacement': '{{ .Values.defaultRules.runbookUrl }}',
    },
    'job="kube-state-metrics"': {
        'replacement': 'job="kube-state-metrics", namespace=~"{{ .targetNamespace }}"',
        'limitGroup': ['kubernetes-apps'],
    },
    'job="kubelet"': {
        'replacement': 'job="kubelet", namespace=~"{{ .targetNamespace }}"',
        'limitGroup': ['kubernetes-storage'],
    },
    'http://localhost:3000': {
        'replacement': '{{ index .Values.grafana.ingress.hosts 0 }}',
        'init': ''},
    'job="alertmanager-main"': {
        'replacement': 'job="{{ include "victoria-metrics-k8s-stack.alertmanager.name" . }}"',
    },
    'namespace="monitoring"': {
        'replacement': 'namespace="{{ .Release.Namespace }}"',
        'limitGroup': ['alertmanager.rules'],
    },
}

def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    quoted_presenter = lambda dumper, data : dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    yaml.add_representer(literal, represent_literal_str)
    yaml.add_representer(quoted, quoted_presenter)


def fix_expr(rules):
    """Remove trailing whitespaces and line breaks, which happen to creep in
     due to yaml import specifics;
     convert multiline expressions to literal style, |-"""
    for rule in rules:
        rule['condition'] = "{{ true }}"
        if 'alert' in rule:
            if rule['alert'] in alert_condition_map:
                rule['condition'] = "{{ %(condition)s }}" % {"condition": alert_condition_map[rule['alert']]}
        rule['expr'] = rule['expr'].rstrip()
        if '\n' in rule['expr']:
            rule['expr'] = literal(rule['expr'])
        if 'annotations' in rule:
            for k in rule['annotations']:
               rule['annotations'][k] = quoted(escape(rule['annotations'][k]))


def yaml_dump(struct):
    """represent yaml as a string"""
    return yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )

def write_group_to_file(group, url, destination):
    fix_expr(group['rules'])
    group_name = group['name']
    group["condition"] = "{{ true }}"
    if group_name in condition_map:
        group["condition"] = "{{ %(condition)s }}" % {"condition": condition_map[group_name]}
    # prepare rules string representation
    rules = yaml_dump(group)
    # add replacements of custom variables and include their initialisation in case it's needed
    lines = ""
    for line in replacement_map:
        if group_name in replacement_map[line].get('limitGroup', [group_name]) and line in rules:
            print(f"Applying replace rule for '{line}' in {group_name}")
            rules = rules.replace(line, replacement_map[line]['replacement'])

    # rules themselves
    lines += rules

    new_filename = f"{destination}/{group['name']}.yaml"

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(lines)

    print(f"Generated {new_filename}")


def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for source in rules:
        print(f"Generating rules from {source}")
        response = requests.get(source)
        if response.status_code != 200:
            print(f"Skipping the file, response code {response.status_code} not equals 200")
            continue
        raw_text = response.text
        yaml_text = yaml.full_load(raw_text)

        # etcd workaround, their file don't have spec level
        groups = yaml_text['spec']['groups'] if yaml_text.get('spec') else yaml_text['groups']
        for group in groups:
            if group['name'] in skip_list:
                continue
            write_group_to_file(group, source, rulesDir)

    print("Finished")


if __name__ == '__main__':
    main()
