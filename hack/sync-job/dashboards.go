package main

import (
	"context"
	"encoding/json/v2"
	"fmt"
	"log"
	"maps"
	"path/filepath"
	"regexp"
	"slices"
	"strings"

	"github.com/VictoriaMetrics/metricsql"
	"go.yaml.in/yaml/v3"
)

var dashboardNameRe = regexp.MustCompile(`[ /_-]+`)

// --- JSON types (unknown fields preserved via json:",embed") ---

type dashboard struct {
	Title       string          `json:"title"`
	Editable    bool            `json:"editable"`
	Timezone    string          `json:"timezone"`
	Tags        []string        `json:"tags"`
	Targets     []dashTarget    `json:"targets,omitempty"`
	Annotations dashAnnotations `json:"annotations,omitempty"`
	Templating  dashTemplating  `json:"templating"`
	Panels      []dashPanel     `json:"panels"`
	XXX         map[string]any  `json:",embed"`
}

type dashPanel struct {
	Title      string         `json:"title,omitempty"`
	Targets    []dashTarget   `json:"targets,omitempty"`
	Panels     []dashPanel    `json:"panels,omitempty"`
	Datasource *strOrMap      `json:"datasource,omitempty"`
	XXX        map[string]any `json:",embed"`
}

type dashTarget struct {
	Datasource *strOrMap      `json:"datasource,omitempty"`
	Expr       string         `json:"expr,omitempty"`
	XXX        map[string]any `json:",embed"`
}

type dashAnnotations struct {
	List []dashAnnotation `json:"list,omitempty"`
}

type dashAnnotation struct {
	Name       string         `json:"name,omitempty"`
	Expr       string         `json:"expr,omitempty"`
	Datasource *strOrMap      `json:"datasource,omitempty"`
	XXX        map[string]any `json:",embed"`
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
	XXX        map[string]any `json:",embed"`
}

func marshalJSON(v any) ([]byte, error) {
	return json.Marshal(v, json.Deterministic(true))
}

type strOrMap struct {
	StrVal string
	MapVal map[string]any
}

func (r strOrMap) MarshalJSON() ([]byte, error) {
	if len(r.StrVal) > 0 {
		return marshalJSON(r.StrVal)
	}
	if len(r.MapVal) > 0 {
		return marshalJSON(r.MapVal)
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
		return marshalJSON(v.BoolVal)
	}
	return marshalJSON(v.StrVal)
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
		return marshalJSON(v.IntVal)
	}
	return marshalJSON(v.StrVal)
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

func reconcileDashboards(ctx context.Context, kube *syncClient, cfg *dashboardsConfig, common commonConfig, rawByURL map[string][]byte, prune bool) error {
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
			patchDashboard(d, name, dc, common, grafana)
			data, err := marshalJSON(d)
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

func patchDashboard(d *dashboard, name string, dc dashboardOverride, common commonConfig, grafana grafanaConfig) {
	d.Editable = false
	d.Tags = appendUnique(d.Tags, "vm-k8s-stack")

	cl := common.ClusterLabel
	patchVariables(d, dc.variables(cl))

	// Panel expressions must not reference the cluster variable unless it actually exists.
	cv := clusterVariable(d, cl)
	injectCluster := cv == "" && !common.Multicluster && !slices.ContainsFunc(d.Templating.List, func(t dashVariable) bool { return t.Name == cl })
	if injectCluster {
		cv = cl
	}

	for i := range d.Annotations.List {
		a := &d.Annotations.List[i]
		patchDatasource(a.Datasource, grafana)
		a.Expr = patchDashExpr(a.Expr, a.Name, cl, cv)
	}
	for i := range d.Targets {
		t := &d.Targets[i]
		patchDatasource(t.Datasource, grafana)
		t.Expr = patchDashExpr(t.Expr, name, cl, cv)
	}
	for i := range d.Panels {
		patchPanel(&d.Panels[i], name, cl, cv, grafana)
	}

	for i := range d.Templating.List {
		t := &d.Templating.List[i]
		patchDatasource(t.Datasource, grafana)
		if t.Type == "datasource" {
			patchVariableDatasource(t, grafana.Datasource)
		}
		if t.Name == cv {
			t.Multi = &boolOrStr{IsBool: true, BoolVal: common.Multicluster}
			t.IncludeAll = &boolOrStr{IsBool: true, BoolVal: common.Multicluster}
			if common.Multicluster {
				t.Type = "query"
				t.Hide = intOrStr{IsInt: true, IntVal: 0}
				patchVariableExpr(t, cv, cl, cv)
			} else {
				t.Type = "constant"
				t.Hide = intOrStr{IsInt: true, IntVal: 2}
				t.Query = &strOrMap{StrVal: ".*"}
				t.Definition = ".*"
			}
		} else if t.Type == "query" && t.Query != nil {
			patchVariableExpr(t, t.Name, cl, cv)
		}
	}

	if injectCluster {
		d.Templating.List = append(d.Templating.List, dashVariable{
			Name:       cv,
			Label:      cv,
			Type:       "constant",
			AllValue:   ".*",
			Query:      &strOrMap{StrVal: ".*"},
			Multi:      &boolOrStr{IsBool: true},
			IncludeAll: &boolOrStr{IsBool: true},
			Hide:       intOrStr{IsInt: true, IntVal: 2},
		})
	}
}

func patchVariables(d *dashboard, overrides map[string]variableOverride) {
	pos := 0
	for i, t := range d.Templating.List {
		if t.Type == "datasource" {
			pos = i + 1
		}
	}
	for _, name := range slices.Sorted(maps.Keys(overrides)) {
		o := overrides[name]
		i := slices.IndexFunc(d.Templating.List, func(t dashVariable) bool { return t.Name == name })
		if i < 0 {
			if o.Query == "" {
				log.Printf("dashboard %q: variable %q not found", d.Title, name)
				continue
			}
			d.Templating.List = slices.Insert(d.Templating.List, pos, dashVariable{Name: name, Label: name, Type: "query", AllValue: ".*"})
			i = pos
			pos++
		}
		v := &d.Templating.List[i]
		if o.Query != "" {
			v.Type = "query"
			v.Query = &strOrMap{StrVal: o.Query}
			v.Definition = o.Query
		}
		switch {
		case o.Regex == nil:
		case *o.Regex == "":
			delete(v.XXX, "regex")
		default:
			if v.XXX == nil {
				v.XXX = map[string]any{}
			}
			v.XXX["regex"] = *o.Regex
		}
	}
}

func clusterVariable(d *dashboard, cl string) string {
	for _, t := range d.Templating.List {
		if t.Type != "query" {
			continue
		}
		if l := labelValuesLabel(variableQuery(t)); l == cl || l == "cluster" {
			return t.Name
		}
	}
	return ""
}

func variableQuery(t dashVariable) string {
	if t.Query != nil {
		if t.Query.StrVal != "" {
			return t.Query.StrVal
		}
		if q, ok := t.Query.MapVal["query"].(string); ok {
			return q
		}
	}
	return t.Definition
}

func labelValuesLabel(query string) string {
	e, err := metricsql.ParseWithVars(query, true)
	if err != nil {
		return ""
	}
	fe, ok := e.(*metricsql.FuncExpr)
	if !ok || fe.Name != "label_values" || len(fe.Args) == 0 {
		return ""
	}
	me, ok := fe.Args[len(fe.Args)-1].(*metricsql.MetricExpr)
	if !ok || len(me.LabelFilterss) != 1 || len(me.LabelFilterss[0]) != 1 || me.LabelFilterss[0][0].Label != "__name__" {
		return ""
	}
	return me.LabelFilterss[0][0].Value
}

func patchVariableExpr(t *dashVariable, varName, cl, cv string) {
	if t.Query != nil {
		if t.Query.StrVal != "" {
			t.Query.StrVal = patchDashExpr(t.Query.StrVal, varName, cl, cv)
		} else if q, ok := t.Query.MapVal["query"].(string); ok {
			t.Query.MapVal["query"] = patchDashExpr(q, varName, cl, cv)
		}
	}
	if t.Definition != "" {
		t.Definition = patchDashExpr(t.Definition, varName, cl, cv)
	}
}

func patchDatasource(d *strOrMap, grafana grafanaConfig) {
	if d == nil || d.MapVal == nil {
		return
	}
	if t, ok := d.MapVal["type"]; !ok || t != "prometheus" {
		return
	}
	d.MapVal["type"] = grafana.Datasource
	uid, _ := d.MapVal["uid"].(string)
	if uid == "" {
		return
	}
	if strings.HasPrefix(uid, "$") {
		if !strings.HasPrefix(uid, "${DS_") && !strings.HasPrefix(uid, "$DS_") {
			return
		}
	}
	d.MapVal["uid"] = grafana.DatasourceUID
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

func patchPanel(p *dashPanel, name, clusterLabel, clusterVar string, grafana grafanaConfig) {
	patchDatasource(p.Datasource, grafana)
	for i := range p.Targets {
		t := &p.Targets[i]
		patchDatasource(t.Datasource, grafana)
		t.Expr = patchDashExpr(t.Expr, p.Title, clusterLabel, clusterVar)
	}
	for i := range p.Panels {
		patchPanel(&p.Panels[i], name, clusterLabel, clusterVar, grafana)
	}
}

func patchDashExpr(expr, varName, clusterLabel, clusterVar string) string {
	if expr == "" {
		return expr
	}
	e, err := metricsql.ParseWithVars(expr, true)
	if err != nil {
		return expr
	}
	cl := clusterLabel
	ref := "$" + clusterVar
	withCluster := clusterVar != ""
	isClusterVar := withCluster && varName == clusterVar
	isClusterRef := func(v string) bool { return withCluster && v == ref }

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
		if !found && withCluster {
			m.Args = append(m.Args, cl)
		}
	}

	metricsql.VisitAll(e, func(ex metricsql.Expr) {
		switch t := ex.(type) {
		case *metricsql.BinaryOpExpr:
			modifierFn(&t.JoinModifier)
			modifierFn(&t.GroupModifier)
		case *metricsql.AggrFuncExpr:
			if isClusterVar {
				return
			}
			modifierFn(&t.Modifier)
			if withCluster && t.Modifier.Op == "" {
				t.Modifier.Op = "by"
				t.Modifier.Args = append(t.Modifier.Args, cl)
			}
		case *metricsql.MetricExpr:
			for i := range t.LabelFilterss {
				var out []metricsql.LabelFilter
				found := false
				for _, f := range t.LabelFilterss[i] {
					if f.Label == "cluster" || isClusterRef(f.Value) {
						f.Label = cl
						if withCluster && !isClusterVar {
							f.Value = ref
							f.IsRegexp = true
						}
						found = true
					} else if f.Label == "__name__" && f.Value == "cluster" {
						f.Value = cl
						found = true
					}
					out = append(out, f)
				}
				if !found && withCluster && len(out) > 1 && !isClusterVar {
					out = append(out, metricsql.LabelFilter{Label: cl, Value: ref, IsRegexp: true})
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
