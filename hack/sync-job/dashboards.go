package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/VictoriaMetrics/metricsql"
	"gopkg.in/yaml.v3"
)

var dashboardNameRe = regexp.MustCompile(`[ /_-]+`)

// --- JSON types (unknown fields preserved via GOEXPERIMENT=jsonv2) ---

type dashboard struct {
	Title       string          `json:"title"`
	Editable    bool            `json:"editable"`
	Timezone    string          `json:"timezone"`
	Tags        []string        `json:"tags"`
	Targets     []dashTarget    `json:"targets,omitempty"`
	Annotations dashAnnotations `json:"annotations,omitempty"`
	Templating  dashTemplating  `json:"templating"`
	Panels      []dashPanel     `json:"panels"`
	XXX         map[string]any  `json:",unknown"`
}

type dashPanel struct {
	Title      string         `json:"title,omitempty"`
	Targets    []dashTarget   `json:"targets,omitempty"`
	Panels     []dashPanel    `json:"panels,omitempty"`
	Datasource *strOrMap      `json:"datasource,omitempty"`
	XXX        map[string]any `json:",unknown"`
}

type dashTarget struct {
	Datasource *strOrMap      `json:"datasource,omitempty"`
	Expr       string         `json:"expr,omitempty"`
	XXX        map[string]any `json:",unknown"`
}

type dashAnnotations struct {
	List []dashAnnotation `json:"list,omitempty"`
}

type dashAnnotation struct {
	Name       string         `json:"name,omitempty"`
	Expr       string         `json:"expr,omitempty"`
	Datasource *strOrMap      `json:"datasource,omitempty"`
	XXX        map[string]any `json:",unknown"`
}

type dashTemplating struct {
	List []dashVariable `json:"list"`
}

type dashVariable struct {
	Name       string         `json:"name"`
	Label      string         `json:"label,omitempty"`
	Type       string         `json:"type"`
	Query      *strOrMap      `json:"query,omitempty"`
	Definition string         `json:"definition,omitempty"`
	Datasource *strOrMap      `json:"datasource,omitempty"`
	Multi      *boolOrStr     `json:"multi,omitempty"`
	IncludeAll *boolOrStr     `json:"includeAll,omitempty"`
	Hide       intOrStr       `json:"hide,omitempty"`
	AllValue   string         `json:"allValue,omitempty"`
	XXX        map[string]any `json:",unknown"`
}

type strOrMap struct {
	StrVal string
	MapVal map[string]any
}

func (r strOrMap) MarshalJSON() ([]byte, error) {
	if len(r.StrVal) > 0 {
		return json.Marshal(r.StrVal)
	}
	if len(r.MapVal) > 0 {
		return json.Marshal(r.MapVal)
	}
	return []byte("null"), nil
}

func (r *strOrMap) UnmarshalJSON(raw []byte) error {
	var o any
	if err := json.Unmarshal(raw, &o); err != nil {
		return err
	}
	switch v := o.(type) {
	case string:
		r.StrVal = v
	case map[string]any:
		r.MapVal = v
	}
	return nil
}

type boolOrStr struct {
	BoolVal bool
	StrVal  string
	IsBool  bool
}

func (v boolOrStr) MarshalJSON() ([]byte, error) {
	if v.IsBool {
		return json.Marshal(v.BoolVal)
	}
	return json.Marshal(v.StrVal)
}

func (r *boolOrStr) UnmarshalJSON(raw []byte) error {
	var o any
	if err := json.Unmarshal(raw, &o); err != nil {
		return err
	}
	switch v := o.(type) {
	case bool:
		r.IsBool = true
		r.BoolVal = v
	case string:
		r.StrVal = v
	}
	return nil
}

type intOrStr struct {
	IntVal int
	StrVal string
	IsInt  bool
}

func (v intOrStr) MarshalJSON() ([]byte, error) {
	if v.IsInt {
		return json.Marshal(v.IntVal)
	}
	return json.Marshal(v.StrVal)
}

func (r *intOrStr) UnmarshalJSON(raw []byte) error {
	var o any
	if err := json.Unmarshal(raw, &o); err != nil {
		return err
	}
	switch v := o.(type) {
	case float64:
		r.IsInt = true
		r.IntVal = int(v)
	case string:
		r.StrVal = v
	}
	return nil
}

// dashboardCRD is the multi-dashboard YAML format (e.g. grafana-dashboardDefinitions.yaml).
type dashboardCRD struct {
	Items []dashboardItem `yaml:"items"`
}

type dashboardItem struct {
	Data map[string]string `yaml:"data"`
}

// --- reconcile ---

func reconcileDashboards(ctx context.Context, kube *kubeClient, cfg *dashboardsConfig, common commonConfig, rawByURL map[string][]byte, prune bool) error {
	grafana := cfg.Common.Grafana
	useOperator := grafana.Operator != nil

	var existing []string
	var err error
	if useOperator {
		existing, err = kube.listManagedGrafanaDashboards(ctx)
	} else {
		existing, err = kube.listManagedConfigMaps(ctx)
	}
	if err != nil {
		return fmt.Errorf("list managed resources: %w", err)
	}
	seen := make(map[string]bool)

	for _, src := range cfg.Sources {
		raw, ok := rawByURL[src.URL]
		if !ok {
			continue
		}
		dashboards, err := parseDashboards(raw, src.URL)
		if err != nil {
			log.Printf("parse dashboards from %q: %v", src.URL, err)
			continue
		}

		for name, d := range dashboards {
			dc := cfg.Dashboards[name]
			if dc.Enabled != nil && !*dc.Enabled {
				continue
			}
			patchDashboard(d, name, dc.ClusterMetric, common, grafana)
			data, err := json.Marshal(d)
			if err != nil {
				log.Printf("marshal dashboard %q: %v", name, err)
				continue
			}
			resourceName := clampResourceName(kube.resourcePrefix + "-dashboard-" + name)
			if useOperator {
				if err := kube.applyGrafanaDashboard(ctx, resourceName, string(data), grafana.Operator.Spec, cfg.Common.Labels, cfg.Common.Annotations); err != nil {
					log.Printf("apply grafanadashboard %q: %v", resourceName, err)
					continue
				}
			} else {
				extraLabels := map[string]string{grafana.LabelName: grafana.LabelValue}
				for k, v := range cfg.Common.Labels {
					extraLabels[k] = v
				}
				if err := kube.applyConfigMap(ctx, resourceName, map[string]string{name + ".json": string(data)}, extraLabels, cfg.Common.Annotations); err != nil {
					log.Printf("apply configmap %q: %v", resourceName, err)
					continue
				}
			}
			log.Printf("applied dashboard %q", resourceName)
			seen[resourceName] = true
		}
	}

	if !prune {
		return nil
	}
	for _, name := range existing {
		if !seen[name] {
			if useOperator {
				if err := kube.deleteGrafanaDashboard(ctx, name); err != nil {
					log.Printf("delete orphaned grafanadashboard %q: %v", name, err)
				} else {
					log.Printf("deleted orphaned grafanadashboard %q", name)
				}
			} else {
				if err := kube.deleteConfigMap(ctx, name); err != nil {
					log.Printf("delete orphaned configmap %q: %v", name, err)
				} else {
					log.Printf("deleted orphaned configmap %q", name)
				}
			}
		}
	}
	return nil
}

func parseDashboards(raw []byte, srcURL string) (map[string]*dashboard, error) {
	raw = trimBOM(raw)
	result := make(map[string]*dashboard)

	ext := strings.ToLower(filepath.Ext(srcURL))
	switch ext {
	case ".yml", ".yaml":
		var crd dashboardCRD
		if err := yaml.Unmarshal(raw, &crd); err != nil {
			return nil, fmt.Errorf("unmarshal yaml CRD: %w", err)
		}
		for _, item := range crd.Items {
			for k, v := range item.Data {
				name := strings.TrimSuffix(k, filepath.Ext(k))
				var d dashboard
				if err := json.Unmarshal([]byte(v), &d); err != nil {
					log.Printf("unmarshal dashboard item %q: %v", k, err)
					continue
				}
				result[name] = &d
			}
		}
	default:
		var d dashboard
		if err := json.Unmarshal(raw, &d); err != nil {
			return nil, fmt.Errorf("unmarshal json: %w", err)
		}
		name := strings.TrimSuffix(filepath.Base(srcURL), filepath.Ext(srcURL))
		if d.Title != "" {
			name = dashboardNameRe.ReplaceAllString(strings.ToLower(d.Title), "-")
		}
		result[name] = &d
	}
	return result, nil
}

func patchDashboard(d *dashboard, name, clusterMetric string, common commonConfig, grafana grafanaConfig) {
	d.Editable = false
	d.Tags = appendUnique(d.Tags, "vm-k8s-stack")

	cl := common.ClusterLabel
	for i := range d.Annotations.List {
		a := &d.Annotations.List[i]
		patchDatasource(a.Datasource, grafana.Datasource)
		a.Expr = patchDashExpr(a.Expr, a.Name, cl)
	}
	for i := range d.Targets {
		t := &d.Targets[i]
		patchDatasource(t.Datasource, grafana.Datasource)
		t.Expr = patchDashExpr(t.Expr, name, cl)
	}
	for i := range d.Panels {
		patchPanel(&d.Panels[i], name, cl, grafana.Datasource)
	}

	hasCluster := false
	for i := range d.Templating.List {
		t := &d.Templating.List[i]
		patchDatasource(t.Datasource, grafana.Datasource)
		if t.Type == "datasource" {
			patchVariableDatasource(t, grafana.Datasource)
		}
		if t.Name == cl || t.Name == "cluster" {
			hasCluster = true
			t.Name = cl
			if t.Label == "cluster" {
				t.Label = cl
			}
			t.Multi = &boolOrStr{IsBool: true, BoolVal: common.Multicluster}
			t.IncludeAll = &boolOrStr{IsBool: true, BoolVal: common.Multicluster}
			if common.Multicluster {
				t.Type = "query"
				t.Hide = intOrStr{IsInt: true, IntVal: 0}
				if t.Query != nil {
					t.Query.StrVal = patchDashExpr(t.Query.StrVal, t.Name, cl)
					if t.Definition != "" {
						t.Definition = t.Query.StrVal
					}
				}
			} else {
				t.Type = "constant"
				t.Hide = intOrStr{IsInt: true, IntVal: 2}
				t.Query = &strOrMap{StrVal: ".*"}
				t.Definition = ".*"
			}
		} else if t.Type == "query" && t.Query != nil {
			t.Query.StrVal = patchDashExpr(t.Query.StrVal, t.Name, cl)
			if t.Definition != "" {
				t.Definition = t.Query.StrVal
			}
		}
	}

	if !hasCluster && clusterMetric != "" {
		d.Templating.List = append(d.Templating.List, buildClusterVariable(clusterMetric, common))
	}
}

func buildClusterVariable(metric string, common commonConfig) dashVariable {
	v := dashVariable{
		Name:       common.ClusterLabel,
		Label:      common.ClusterLabel,
		AllValue:   ".*",
		Multi:      &boolOrStr{IsBool: true, BoolVal: common.Multicluster},
		IncludeAll: &boolOrStr{IsBool: true, BoolVal: common.Multicluster},
	}
	if common.Multicluster {
		v.Type = "query"
		v.Hide = intOrStr{IsInt: true, IntVal: 0}
		v.Query = &strOrMap{StrVal: fmt.Sprintf("label_values(%s, %s)", metric, common.ClusterLabel)}
		v.Definition = v.Query.StrVal
	} else {
		v.Type = "constant"
		v.Hide = intOrStr{IsInt: true, IntVal: 2}
		v.Query = &strOrMap{StrVal: ".*"}
	}
	return v
}

func patchDatasource(d *strOrMap, datasource string) {
	if d == nil || d.MapVal == nil {
		return
	}
	if t, ok := d.MapVal["type"]; !ok || t != "prometheus" {
		return
	}
	d.MapVal["type"] = datasource
	uid, _ := d.MapVal["uid"].(string)
	if uid == "" {
		return
	}
	// Leave Grafana dashboard variable references (e.g. "${datasource}") intact;
	// replace import-time inputs (e.g. "${DS_PROMETHEUS}") and plain "prometheus".
	if strings.HasPrefix(uid, "${") && !strings.HasPrefix(uid, "${DS_") {
		return
	}
	d.MapVal["uid"] = datasource
}

func patchVariableDatasource(t *dashVariable, datasource string) {
	if t.Query == nil {
		return
	}
	if t.Query.StrVal == "prometheus" {
		t.Query.StrVal = datasource
	}
	if t.Query.MapVal != nil {
		if q, ok := t.Query.MapVal["query"]; ok && q == "prometheus" {
			t.Query.MapVal["query"] = datasource
		}
	}
}

func patchPanel(p *dashPanel, name, clusterLabel, datasource string) {
	patchDatasource(p.Datasource, datasource)
	for i := range p.Targets {
		t := &p.Targets[i]
		patchDatasource(t.Datasource, datasource)
		t.Expr = patchDashExpr(t.Expr, p.Title, clusterLabel)
	}
	for i := range p.Panels {
		patchPanel(&p.Panels[i], name, clusterLabel, datasource)
	}
}

func patchDashExpr(expr, varName, clusterLabel string) string {
	if expr == "" {
		return expr
	}
	e, err := metricsql.ParseWithVars(expr, true)
	if err != nil {
		return expr
	}
	cl := clusterLabel

	modifierFn := func(m *metricsql.ModifierExpr) {
		if m.Op != "by" && m.Op != "on" {
			return
		}
		found := false
		for i := range m.Args {
			switch m.Args[i] {
			case "cluster":
				m.Args[i] = cl
				found = true
			case cl:
				found = true
			}
		}
		if !found {
			m.Args = append(m.Args, cl)
		}
	}

	metricsql.VisitAll(e, func(ex metricsql.Expr) {
		switch t := ex.(type) {
		case *metricsql.BinaryOpExpr:
			modifierFn(&t.JoinModifier)
			modifierFn(&t.GroupModifier)
		case *metricsql.AggrFuncExpr:
			if varName == cl || varName == "cluster" {
				return
			}
			modifierFn(&t.Modifier)
			if t.Modifier.Op == "" {
				t.Modifier.Op = "by"
				t.Modifier.Args = append(t.Modifier.Args, cl)
			}
		case *metricsql.MetricExpr:
			for i := range t.LabelFilterss {
				var out []metricsql.LabelFilter
				found := false
				for _, f := range t.LabelFilterss[i] {
					if f.Label == "cluster" || f.Value == "$cluster" {
						f.Label = cl
						f.Value = "$cluster"
						f.IsRegexp = true
						found = true
					} else if f.Label == "__name__" && f.Value == "cluster" {
						f.Value = cl
						found = true
					}
					out = append(out, f)
				}
				if !found && len(out) > 1 && varName != cl && varName != "cluster" {
					out = append(out, metricsql.LabelFilter{Label: cl, Value: "$cluster", IsRegexp: true})
				}
				t.LabelFilterss[i] = out
			}
		}
	})
	return string(e.AppendString(nil))
}

func appendUnique(slice []string, val string) []string {
	for _, s := range slice {
		if s == val {
			return slice
		}
	}
	return append(slice, val)
}

func trimBOM(b []byte) []byte {
	if len(b) >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF {
		return b[3:]
	}
	return b
}
