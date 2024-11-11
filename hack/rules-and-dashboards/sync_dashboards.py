#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
import json
import base64
import pathlib
import re
from urllib.parse import urlparse
from os import makedirs
from os.path import dirname, join, realpath

import _jsonnet
import requests
import yaml
from yaml.representer import SafeRepresenter


def dashboardsDir(chart):
    return join(
        dirname(realpath(__file__)),
        "..",
        "..",
        "charts",
        chart,
        "files",
        "dashboards",
        "generated",
    )


# https://stackoverflow.com/a/20863889/961092
class literal(str):
    pass


class CustomDumper(yaml.Dumper):
    def represent_data(self, data):
        # workaround for strings values, that are automatically transformed to "true" in fromYaml helm template function
        if isinstance(data, str) and data in ["y", "n", "yes", "no", "on", "off"]:
            return self.represent_scalar("tag:yaml.org,2002:str", data, style="'")

        return super(CustomDumper, self).represent_data(data)


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer


sources = [
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmagent.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics-cluster.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmalert.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/operator.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victorialogs.json",
        "charts": [
            "victoria-logs-single",
        ],
    },
    {
        "url": "./dashboards/vector.json",
        "charts": [
            "victoria-logs-single",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-api-server.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-nodes.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/backupmanager.json",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
    {
        "url": "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/grafana-dashboardDefinitions.yaml",
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
    {
        "url": "https://grafana.com/api/dashboards/1860/revisions/37/download",
        "charts": [
            "victoria-metrics-k8s-stack",
        ],
    },
]

allowed_dashboards = [
    "alertmanager-overview",
    "controller-manager",
    "etcd",
    "grafana-overview",
    "kubelet",
    "proxy",
    "scheduler",
]

# Additional conditions map
condition_map = {
    "victorialogs": "($Values.vlogs).enabled",
    "alertmanager-overview": "($Values.alertmanager).enabled",
    "apiserver": "($Values.kubeApiServer).enabled",
    "controller-manager": "($Values.kubeControllerManager).enabled",
    "etcd": "($Values.kubeEtcd).enabled",
    "grafana-coredns-k8s": "($Values.coreDns).enabled",
    "grafana-overview": "($Values.grafana).enabled",
    "kubelet": "($Values.kubelet).enabled",
    "kubernetes-system-api-server": "($Values.kubeApiServer).enabled",
    "kubernetes-system-coredns": "($Values.coreDns).enabled",
    "kubernetes-views-global": "($Values.kubelet).enabled",
    "kubernetes-views-namespaces": "($Values.kubelet).enabled",
    "kubernetes-views-nodes": "($Values.kubelet).enabled",
    "kubernetes-views-pods": "($Values.kubelet).enabled",
    "node-cluster-rsrc-use": '(index $Values "prometheus-node-exporter" "enabled")',
    "node-exporter-full": "false",
    "node-rsrc-use": '(index $Values "prometheus-node-exporter" "enabled")',
    "proxy": "$Values.kubeProxy.enabled",
    "scheduler": "$Values.kubeScheduler.enabled",
    "victoriametrics-backupmanager": "or (not (empty (((($Values).vmsingle).spec).vmBackup).destination)) (not (empty ((((($Values).vmcluster).spec).storage).vmBackup).destination))",
    "victoriametrics-cluster": "($Values.vmcluster).enabled",
    "victoriametrics-operator": '(index $Values "victoria-metrics-operator" "enabled")',
    "victoriametrics-single-node": "($Values.vmsingle).enabled",
    "victoriametrics-vmalert": "($Values.vmalert).enabled",
}


def escape(s):
    return (
        s.replace("{{", "{{`{{")
        .replace("}}", "}}`}}")
        .replace("{{`{{", "{{`{{`}}")
        .replace("}}`}}", "{{`}}`}}")
        .replace("'[[", "{{")
        .replace("[[", "{{")
        .replace("]]'", "}}")
        .replace("]]", "}}")
    )


def init_yaml_styles():
    represent_literal_str = change_style("|", SafeRepresenter.represent_str)
    yaml.add_representer(literal, represent_literal_str)


def fix_query(query):
    query = re.sub(
        '[\\s]*[\\w-]+[\\s]*=[~]*[\\s]*\\"\\$cluster\\"',
        ' [[ $clusterLabel ]]=~"$cluster"',
        query.rstrip(),
    )
    if "\n" in query:
        query = literal(query)
    return query


def fix_expr(target):
    """Remove trailing whitespaces and line breaks, which happen to creep in
    due to yaml import specifics;
    convert multiline expressions to literal style, |-"""
    if "expr" in target:
        target["expr"] = fix_query(target["expr"])


def replace_ds_type_in_panel(panel, dsName):
    if "datasource" in panel and panel["datasource"]:
        if "type" in panel["datasource"]:
            panel["datasource"]["type"] = "[[ $defaultDatasource ]]"
        if "uid" in panel["datasource"]:
            if (
                panel["datasource"]["uid"] == f"${{{dsName}}}"
                or panel["datasource"]["uid"] == dsName
            ):
                panel["datasource"]["uid"] = "$datasource"
    for target in panel.get("targets", []):
        if "expr" in target:
            fix_expr(target)
        if "datasource" in target:
            if "type" in target["datasource"]:
                target["datasource"]["type"] = "[[ $defaultDatasource ]]"
            if "uid" in panel["datasource"]:
                if (
                    target["datasource"]["uid"] == f"${{{dsName}}}"
                    or target["datasource"]["uid"] == dsName
                ):
                    target["datasource"]["uid"] = "$datasource"
    if "panels" in panel:
        for p in panel["panels"]:
            replace_ds_type_in_panel(p, dsName)


def patch_dashboard(dashboard, name, omitRows):
    skipPanels = False
    panels = dashboard.get("panels", [])
    dsName = ""
    for input in dashboard.get("__inputs", []):
        if input["type"] == "datasource":
            dsName = input["name"]
            break
    dashboard["panels"] = []
    for panel in panels:
        if panel["type"] == "row":
            if panel["title"] in omitRows:
                skipPanels = True
            else:
                skipPanels = False
        if skipPanels:
            continue
        replace_ds_type_in_panel(panel, dsName)
        dashboard["panels"].append(panel)

    ## multicluster
    hasDatasource = False
    if "templating" in dashboard:
        for variable in dashboard["templating"].get("list", []):
            if variable.get("name", "") == "cluster":
                if "definition" in variable and "cluster" in variable["definition"]:
                    variable["definition"] = variable["definition"].replace(
                        "cluster", "[[ $clusterLabel ]]"
                    )
                if "datasource" in variable and "uid" in variable["datasource"]:
                    if variable["datasource"]["uid"] == f"${{{dsName}}}":
                        variable["datasource"]["uid"] = "$datasource"
                variable["type"] = '[[ ternary "query" "constant" $multicluster ]]'
                variable["hide"] = "[[ ternary 0 2 $multicluster ]]"
                query = json.dumps(variable["query"])
                if re.match('"label_values\\(.*\\)"', query):
                    query = re.sub('\\w+\\)"$', 'cluster)"', query)
                variable["query"] = (
                    f'[[ ternary (b64dec "%(query)s" | replace "cluster" $clusterLabel) ".*" $multicluster ]]'
                    % {"query": base64.b64encode(query.encode("ascii")).decode("utf-8")}
                )
            else:
                if "definition" in variable:
                    variable["definition"] = fix_query(variable["definition"])
                if "datasource" in variable and "uid" in variable["datasource"]:
                    if variable["datasource"]["uid"] == f"${{{dsName}}}":
                        variable["datasource"]["uid"] = "$datasource"
                if "query" in variable:
                    if "query" in variable["query"]:
                        variable["query"]["query"] = fix_query(
                            variable["query"]["query"]
                        )
                    elif isinstance(variable["query"], str):
                        variable["query"] = fix_query(variable["query"])
                if variable.get("type", "") == "datasource":
                    hasDatasource = True
                    variable["query"] = "[[ $defaultDatasource ]]"
    if not hasDatasource:
        if "templating" not in dashboard:
            dashboard["templating"] = {}
        if "list" not in dashboard["templating"]:
            dashboard["templating"]["list"] = []
        dashboard["templating"]["list"].append(
            {
                "current": {},
                "hide": 0,
                "includeAll": False,
                "multi": False,
                "name": "datasource",
                "query": "[[ $defaultDatasource ]]",
                "queryValue": "",
                "refresh": 1,
                "regex": "",
                "skipUrlSync": False,
                "type": "datasource",
            }
        )

    ## fix drilldown links. see https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/659
    for row in dashboard.get("rows", []):
        for panel in row.get("panels", []):
            replace_ds_type_in_panel(panel, dsName)
            for style in panel.get("styles", []):
                if "linkUrl" in style and style["linkUrl"].startswith("./d"):
                    style["linkUrl"] = style["linkUrl"].replace("./d", "/d")

    if "tags" in dashboard:
        dashboard["tags"].append("vm-k8s-stack")

    timezone = dashboard["timezone"] if dashboard["timezone"] else "utc"
    dashboard["timezone"] = (
        f'[[ default "{timezone}" ($Values.defaultDashboards).defaultTimezone ]]'
    )
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
        Dumper=CustomDumper,
    )


def write_dashboard_to_file(resource_name, content, charts):
    for chart in charts:
        destination = dashboardsDir(chart)
        new_filename = f"{destination}/{resource_name}.yaml"

        # make sure directories to store the file exist
        makedirs(destination, exist_ok=True)

        # recreate the file
        with open(new_filename, "w") as f:
            output = ""
            output += "{{- $Values := (.helm).Values | default .Values }}\n"
            output += '{{- $clusterLabel := ($Values.global).clusterLabel | default "cluster" }}\n'
            output += "{{- $multicluster := ((($Values.grafana).sidecar).dashboards).multicluster | default false }}\n"
            output += '{{- $defaultDatasource := "prometheus" -}}\n'
            output += "{{- range (((($Values.grafana).sidecar).datasources).victoriametrics | default list) }}\n"
            output += "  {{- if and .isDefault .type }}{{ $defaultDatasource = .type }}{{- end }}\n"
            output += "{{- end }}\n" + escape(content)
            f.write(output)

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
        print(f"Generating dashboards from {url}")
        raw_text = ""
        if urlparse(url).scheme in ["http", "https"]:
            response = requests.get(url)
            if response.status_code != 200:
                print(
                    f"Skipping the file, response code {response.status_code} not equals 200"
                )
                continue
            raw_text = response.text
        else:
            with open(url) as f:
                raw_text = f.read()
        dashboards = {}
        path = pathlib.Path(url)
        suffix = path.suffix
        if not suffix:
            suffix = ".json"
        if suffix in [".json", ".libsonnet"]:
            if suffix == ".libsonnet":
                raw_text = _jsonnet.evaluate_snippet(
                    url,
                    "(" + raw_text + ").grafanaDashboards",
                    import_callback=jsonnet_import,
                )
            data = json.loads(raw_text)

            # is it already a dashboard structure or is it nested (etcd case)?
            flat_structure = bool(data.get("annotations"))
            if flat_structure:
                name = re.sub("[ /-]+", "-", data["title"].lower())
                dashboards[name] = data
            else:
                for r in data:
                    name = r.replace(".json", "")
                    if name not in allowed_dashboards:
                        continue
                    dashboards[name] = data[r]
        elif suffix == ".yaml":
            data = yaml.full_load(raw_text)
            for group in data["items"]:
                for r in group["data"]:
                    name = r.replace(".json", "")
                    if name not in allowed_dashboards:
                        continue
                    dashboards[name] = json.loads(group["data"][r])
        else:
            print(f"Format {suffix} is not supported")
            continue
        omitRows = src.get("omitRows", [])
        for d in dashboards:
            dashboard = dashboards[d]
            dashboard = patch_dashboard(dashboard, d, omitRows)
            write_dashboard_to_file(d, yaml_dump(dashboard), src["charts"])

    print("Finished")


if __name__ == "__main__":
    main()
