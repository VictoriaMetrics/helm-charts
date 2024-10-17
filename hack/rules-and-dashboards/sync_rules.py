#!/usr/bin/env python3
"""Fetch alerting and aggregation rules from provided urls into this chart."""
from os import makedirs
from os.path import realpath, dirname, join
from urllib.parse import urlparse

import json
import re
import pathlib
import _jsonnet
import requests
import yaml
from yaml.representer import SafeRepresenter


def rulesDir(chart):
    return join(
        dirname(realpath(__file__)),
        "..",
        "..",
        "charts",
        chart,
        "files",
        "rules",
        "generated",
    )


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
sources = [
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/alertmanager-prometheusRule.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubernetesControlPlane-prometheusRule.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubePrometheus-prometheusRule.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubeStateMetrics-prometheusRule.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/nodeExporter-prometheusRule.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-cluster.yml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-health.yml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-vmagent.yml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts-vlogs.yml",
        "charts": [
            "victoria-logs-single",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/alerts.yml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/operator/master/config/alerting/vmoperator-rules.yaml",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
]

# Additional conditions map
condition_map = {
    "alertmanager.rules": "($Values.alertmanager).enabled",
    "etcd": "($Values.kubeEtcd).enabled",
    "kube-apiserver-availability.rules": "($Values.kubeApiServer).enabled",
    "kube-apiserver-burnrate.rules": "($Values.kubeApiServer).enabled",
    "kube-apiserver-histogram.rules": "($Values.kubeApiServer).enabled",
    "kube-apiserver-slos": "($Values.kubeApiServer).enabled",
    "kube-apiserver.rules": "($Values.kubeApiServer).enabled",
    "kube-scheduler.rules": "($Values.kubeScheduler).enabled",
    "kubelet.rules": "($Values.kubelet).enabled",
    "kubernetes-system-controller-manager": "($Values.kubeControllerManager).enabled",
    "kubernetes-system-scheduler": "($Values.kubeScheduler).enabled",
}

alert_condition_map = {
    "KubeAPIDown": "($Values.kubeApiServer).enabled",  # there are more alerts which are left enabled, because they'll never fire without metrics
    "KubeControllerManagerDown": "($Values.kubeControllerManager).enabled",
    "KubeSchedulerDown": "($Values.kubeScheduler).enabled",
    "KubeStateMetricsDown": '(index $Values "kube-state-metrics" "enabled")',  # there are more alerts which are left enabled, because they'll never fire without metrics
    "KubeletDown": "($Values.kubelet).enabled",  # there are more alerts which are left enabled, because they'll never fire without metrics
    "PrometheusOperatorDown": "($Values.prometheusOperator).enabled",
    "NodeExporterDown": "($Values.nodeExporter).enabled",
    "CoreDNSDown": "($Values.kubeDns).enabled",
    "AlertmanagerDown": "($Values.alertmanager).enabled",
    "KubeProxyDown": "($Values.kubeProxy).enabled",
}

skip_list = []


def cluster_label_var(mo):
    labels = ["[[ $Values.global.clusterLabel ]]"]
    labelsStr = mo.group(2).strip()
    group = mo.group(1)
    if len(labelsStr) > 0:
        labels = [
            l.strip()
            for l in labelsStr.split(",")
            if l.strip() != "" and l.strip() != "cluster"
        ] + labels
    output = ",".join(labels)
    return f"{group} ({output})"


replacement_map = {
    "https://runbooks.prometheus-operator.dev/runbooks": {
        "replacement": "[[ $Values.defaultRules.runbookUrl ]]",
    },
    'job="kube-state-metrics"': {
        "replacement": 'job="kube-state-metrics", namespace=~"[[ .targetNamespace ]]"',
        "limitGroup": ["kubernetes-apps"],
    },
    'job="kubelet"': {
        "replacement": 'job="kubelet", namespace=~"[[ .targetNamespace ]]"',
        "limitGroup": ["kubernetes-storage"],
    },
    "http://localhost:3000": {
        "replacement": "[[ index (($Values.grafana).ingress).hosts 0 ]]",
        "init": "",
    },
    'job="alertmanager-main"': {
        "replacement": 'job="[[ include "victoria-metrics-k8s-stack.alertmanager.name" . ]]"',
    },
    'namespace="monitoring"': {
        "replacement": 'namespace="[[ include "vm.namespace" . ]]"',
        "limitGroup": ["alertmanager.rules"],
    },
    "(by|on)\\s*\\(([\\w\\s,]*)\\)": {
        "replacement": cluster_label_var,
    },
}


def escape(s):
    return (
        s.replace("{{", "{{`{{")
        .replace("}}", "}}`}}")
        .replace("{{`{{", "{{`{{`}}")
        .replace("}}`}}", "{{`}}`}}")
        .replace("]]", "}}")
        .replace("[[", "{{")
    )


def quoted_presenter(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="'")


def init_yaml_styles():
    represent_literal_str = change_style("|", SafeRepresenter.represent_str)
    yaml.add_representer(literal, represent_literal_str)
    yaml.add_representer(quoted, quoted_presenter)


def fix_expr(rules):
    """Remove trailing whitespaces and line breaks, which happen to creep in
    due to yaml import specifics;
    convert multiline expressions to literal style, |-"""
    for rule in rules:
        rule["condition"] = "[[ %(condition)s ]]" % {
            "condition": alert_condition_map.get(rule.get("alert", "empty"), "true")
        }
        rule["expr"] = rule["expr"].rstrip()
        if "\n" in rule["expr"]:
            rule["expr"] = literal(rule["expr"])
        if "annotations" in rule:
            for k in rule["annotations"]:
                rule["annotations"][k] = quoted(rule["annotations"][k])


def yaml_dump(struct):
    """represent yaml as a string"""
    return yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False,  # to disable multiple items on single line
    )


def write_group_to_file(group, url, charts):
    fix_expr(group["rules"])
    group_name = group["name"]
    group["condition"] = "[[ %(condition)s ]]" % {
        "condition": condition_map.get(group_name, "true")
    }
    # prepare rules string representation
    rules = yaml_dump(group)
    # add replacements of custom variables and include their initialisation in case it's needed
    lines = ""
    for line in replacement_map:
        if group_name in replacement_map[line].get(
            "limitGroup", [group_name]
        ) and re.findall(line, rules):
            print(f"Applying replace rule for '{line}' in {group_name}")
            rules = re.sub(
                line, replacement_map[line]["replacement"], rules, flags=re.I
            )

    # rules themselves
    lines += rules

    for chart in charts:
        destination = rulesDir(chart)
        new_filename = f"{destination}/{group['name']}.yaml"

        # make sure directories to store the file exist
        makedirs(destination, exist_ok=True)

        # recreate the file
        with open(new_filename, "w") as f:
            content = "{{- $Values := (.helm).Values | default .Values }}\n" + escape(
                lines
            )
            f.write(content)

        print(f"Generated {new_filename}")


def jsonnet_import(directory, file_name):
    src = join(directory, file_name)
    if file_name.startswith("github.com"):
        (empty, repo_org, repo_name, repo_path) = urlparse(
            f"https://{file_name}"
        ).path.split("/", 3)
        repo_slug = f"{repo_org}/{repo_name}"
        repo_resp = requests.get(f"https://api.github.com/repos/{repo_slug}")
        if repo_resp.status_code != 200:
            raise Exception(
                f'Failed to get "{repo_slug}" repo status, response code {repo_resp.status_code} not equals 200'
            )
        default_branch = repo_resp.json()["default_branch"]
        src = f"https://raw.githubusercontent.com/{repo_slug}/{default_branch}/{repo_path}"
    if urlparse(src).scheme in ["http", "https"]:
        response = requests.get(src)
        if response.status_code != 200:
            raise Exception(
                f"Failed to download {src} jsonnet dependency, response code {response.status_code} not equals 200"
            )
        return src, response.content
    with open(src) as f:
        return src, f.read()


def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for src in sources:
        url = src["url"]
        print(f"Generating rules from {url}")
        response = requests.get(url)
        if response.status_code != 200:
            print(
                f"Skipping the file, response code {response.status_code} not equals 200"
            )
            continue
        raw_text = response.text
        if pathlib.Path(url).suffix == ".libsonnet":
            yaml_text = json.loads(
                _jsonnet.evaluate_snippet(
                    url,
                    f"({raw_text}).prometheusAlerts",
                    import_callback=jsonnet_import,
                )
            )
        else:
            yaml_text = yaml.full_load(raw_text)

        # etcd workaround, their file don't have spec level
        groups = (
            yaml_text["spec"]["groups"]
            if yaml_text.get("spec")
            else yaml_text["groups"]
        )
        for group in groups:
            if group["name"] in skip_list:
                continue
            write_group_to_file(group, url, src["charts"])

    print("Finished")


if __name__ == "__main__":
    main()
