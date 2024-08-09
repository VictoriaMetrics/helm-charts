#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
import json
import pathlib
from urllib.parse import urlparse
from os import makedirs
from os.path import dirname, join, realpath

import _jsonnet
import requests
import yaml
from yaml.representer import SafeRepresenter

dashboardsDir = join(
    dirname(realpath(__file__)), "..", "files", "dashboards", "generated"
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


sources = [
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics.json",
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmagent.json",
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics-cluster.json",
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmalert.json",
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/operator.json",
    "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json",
    "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json",
    "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json",
    "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json",
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/backupmanager.json",
    "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/grafana-dashboardDefinitions.yaml",
    "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet",
]

allowed_dashboards = [
    "alertmanager-overview",
    "grafana-overview",
    "etcd",
]

# Additional conditions map
condition_map = {
    "grafana-coredns-k8s": ".Values.coreDns.enabled",
    "etcd": ".Values.kubeEtcd.enabled",
    "apiserver": ".Values.kubeApiServer.enabled",
    "controller-manager": ".Values.kubeControllerManager.enabled",
    "kubelet": ".Values.kubelet.enabled",
    "proxy": ".Values.kubeProxy.enabled",
    "scheduler": ".Values.kubeScheduler.enabled",
    "node-rsrc-use": '(index .Values "prometheus-node-exporter" "enabled")',
    "node-cluster-rsrc-use": '(index .Values "prometheus-node-exporter" "enabled")',
    "victoriametrics-cluster": ".Values.vmcluster.enabled",
    "victoriametrics": ".Values.vmsingle.enabled",
    "vmalert": ".Values.vmalert.enabled",
    "operator": '(index .Values "victoria-metrics-operator" "enabled")',
    "k8s-system-coredns": "and .Values.experimentalDashboardsEnabled .Values.coreDns.enabled",
    "k8s-system-api-server": "and .Values.experimentalDashboardsEnabled .Values.kubeApiServer.enabled",
    "k8s-views-pods": "and .Values.experimentalDashboardsEnabled .Values.kubelet.enabled",
    "k8s-views-nodes": "and .Values.experimentalDashboardsEnabled .Values.kubelet.enabled",
    "k8s-views-namespace": "and .Values.experimentalDashboardsEnabled .Values.kubelet.enabled",
    "k8s-views-global": "and .Values.experimentalDashboardsEnabled .Values.kubelet.enabled",
}


def escape(s):
    return (
        s.replace("{{", "{{`{{")
        .replace("}}", "}}`}}")
        .replace("{{`{{", "{{`{{`}}")
        .replace("}}`}}", "{{`}}`}}")
        .replace("[[", "{{")
        .replace("]]", "}}")
    )


def quoted_presenter(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="'")


def init_yaml_styles():
    represent_literal_str = change_style("|", SafeRepresenter.represent_str)
    yaml.add_representer(literal, represent_literal_str)
    yaml.add_representer(quoted, quoted_presenter)


def fix_expr(target):
    """Remove trailing whitespaces and line breaks, which happen to creep in
    due to yaml import specifics;
    convert multiline expressions to literal style, |-"""
    if "expr" in target:
        target["expr"] = target["expr"].rstrip()
        if "\n" in target["expr"]:
            target["expr"] = literal(target["expr"])


def replace_ds_type_in_panel(panel):
    if "gridPos" in panel:

        # workaround for 'y' key, as it's automatically transformed to "true" in fromYaml helm template function
        if "y" in panel["gridPos"]:
            y = panel["gridPos"]["y"]
            del panel["gridPos"]["y"]
            panel["gridPos"]["[[ .yaxis ]]"] = y
    if "datasource" in panel:
        if "type" in panel["datasource"]:
            panel["datasource"][
                "type"
            ] = '[[ default "prometheus" .Values.grafana.defaultDatasourceType ]]'
    for target in panel.get("targets", []):
        if "expr" in target:
            fix_expr(target)
        if "datasource" in target:
            if "type" in target["datasource"]:
                target["datasource"][
                    "type"
                ] = '[[ default "prometheus" .Values.grafana.defaultDatasourceType ]]'
    if "panels" in panel:
        for p in panel["panels"]:
            replace_ds_type_in_panel(p)


def patch_dashboard(dashboard, name):
    ## multicluster
    if "templating" in dashboard:
        for variable in dashboard["templating"].get("list", []):
            if variable.get("name", "") == "cluster":
                variable["hide"] = (
                    "[[ ternary 0 2 $.Values.grafana.sidecar.dashboards.multicluster ]]"
                )
            if (
                variable.get("type", "") == "datasource"
                and variable.get("query", "") == "prometheus"
            ):
                variable["query"] = (
                    '[[ default "prometheus" .Values.grafana.defaultDatasourceType ]]'
                )

    ## fix drilldown links. see https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/659
    for row in dashboard.get("rows", []):
        for panel in row.get("panels", []):
            replace_ds_type_in_panel(panel)
            for style in panel.get("styles", []):
                if "linkUrl" in style and style["linkUrl"].startswith("./d"):
                    style["linkUrl"] = style["linkUrl"].replace("./d", "/d")

    for panel in dashboard.get("panels", []):
        replace_ds_type_in_panel(panel)

    if "tags" in dashboard:
        dashboard["tags"].append("vm-k8s-stack")

    dashboard["timezone"] = "[[ .Values.grafana.defaultDashboardsTimezone ]]"
    dashboard["editable"] = False
    dashboard["condition"] = "[[ %(condition)s ]]" % {
        "condition": condition_map.get(name, "true")
    }
    return dashboard


def yaml_dump(struct):
    """represent yaml as a string"""
    return yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False,  # to disable multiple items on single line
    )


def write_dashboard_to_file(resource_name, content, destination):
    new_filename = f"{destination}/{resource_name}.yaml"

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, "w") as f:
        f.write(escape(content))

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
        print(f"Generating dashboards from {src}")
        response = requests.get(src)
        if response.status_code != 200:
            print(
                f"Skipping the file, response code {response.status_code} not equals 200"
            )
            continue
        raw_text = response.text
        dashboards = {}
        path = pathlib.Path(src)
        if path.suffix in [".json", ".libsonnet"]:
            if path.suffix == ".libsonnet":
                raw_text = _jsonnet.evaluate_snippet(
                    src,
                    "(" + raw_text + ").grafanaDashboards",
                    import_callback=jsonnet_import,
                )
            data = json.loads(raw_text)

            # is it already a dashboard structure or is it nested (etcd case)?
            flat_structure = bool(data.get("annotations"))
            if flat_structure:
                dashboards[path.name.replace(path.suffix, "")] = data
            else:
                for r in data:
                    name = r.replace(".json", "")
                    if name not in allowed_dashboards:
                        continue
                    dashboards[name] = data[r]
        elif path.suffix == ".yaml":
            data = yaml.full_load(raw_text)
            for group in data["items"]:
                for r in group["data"]:
                    name = r.replace(".json", "")
                    if name not in allowed_dashboards:
                        continue
                    dashboards[name] = json.loads(group["data"][r])
        else:
            print(f"Format {path.suffix} is not supported")
            continue
        for d in dashboards:
            dashboard = dashboards[d]
            dashboard = patch_dashboard(dashboard, d)
            write_dashboard_to_file(d, yaml_dump(dashboard), dashboardsDir)

    print("Finished")


if __name__ == "__main__":
    main()
