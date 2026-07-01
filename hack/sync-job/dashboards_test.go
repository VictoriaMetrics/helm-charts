package main

import (
	"testing"
)

func TestPatchDashExpr(t *testing.T) {
	type opts struct {
		expr         string
		varName      string
		clusterLabel string
		want         string
	}
	f := func(o opts) {
		t.Helper()
		cl := o.clusterLabel
		if cl == "" {
			cl = "cluster"
		}
		got := patchDashExpr(o.expr, o.varName, cl)
		if got != o.want {
			t.Fatalf("patchDashExpr(%q, varName=%q, cl=%q)\ngot:  %s\nwant: %s", o.expr, o.varName, cl, got, o.want)
		}
	}

	// empty / invalid — returned unchanged
	f(opts{
		expr: "",
		want: "",
	})
	f(opts{
		expr: "not valid {{{{",
		want: "not valid {{{{",
	})
	// label_values is valid MetricsQL — cluster filter is injected
	f(opts{
		expr:    `label_values(up{job="$job"}, instance)`,
		varName: "panel",
		want:    `label_values(up{job="$job",cluster=~"$cluster"}, instance)`,
	})
	// when varName matches clusterLabel the cluster filter is NOT injected (cluster variable query)
	f(opts{
		expr:    `label_values(up{job="$job"}, instance)`,
		varName: "cluster",
		want:    `label_values(up{job="$job"}, instance)`,
	})

	// cluster label replacement in by/on modifiers
	f(opts{
		expr:         `sum(up) by (job, cluster)`,
		clusterLabel: "env",
		want:         `sum(up) by(job,env)`,
	})
	f(opts{
		expr: `sum(up) by (job)`,
		want: `sum(up) by(job,cluster)`,
	})
	f(opts{
		expr:         `rate(a[5m]) / on(cluster, job) rate(b[5m])`,
		clusterLabel: "env",
		want:         `rate(a[5m]) / on(env,job) rate(b[5m])`,
	})

	// cluster label added to bare aggr func (unless varName is the cluster variable)
	f(opts{
		expr:    `sum(up)`,
		varName: "panel",
		want:    `sum(up) by(cluster)`,
	})
	f(opts{
		expr:    `sum(up)`,
		varName: "cluster",
		want:    `sum(up)`,
	})
	f(opts{
		expr:         `sum(up)`,
		varName:      "env",
		clusterLabel: "env",
		want:         `sum(up)`,
	})

	// cluster filter in metric selector — label renamed, value stays $cluster, becomes regexp
	f(opts{
		expr:         `up{cluster="$cluster"}`,
		clusterLabel: "env",
		want:         `up{env=~"$cluster"}`,
	})
	f(opts{
		expr:         `up{cluster=~"$cluster"}`,
		clusterLabel: "env",
		want:         `up{env=~"$cluster"}`,
	})

	// selector with no cluster filter — cluster filter added (when len(filters) > 1 and varName != cl)
	f(opts{
		expr:    `up{job="$job"}`,
		varName: "panel",
		want:    `up{job="$job",cluster=~"$cluster"}`,
	})
	// single-filter metric — no cluster filter added (len(out) == 1)
	f(opts{
		expr:    `up`,
		varName: "panel",
		want:    `up`,
	})

	// grafana variables in range vectors preserved during transformation
	f(opts{
		expr:         `sum(rate(http_requests[$__rate_interval])) by (cluster)`,
		clusterLabel: "env",
		want:         `sum(rate(http_requests[$__rate_interval])) by(env)`,
	})
	f(opts{
		expr:    `sum(rate(http_requests[$__interval])) by (job)`,
		varName: "panel",
		want:    `sum(rate(http_requests[$__interval])) by(job,cluster)`,
	})
	f(opts{
		expr:         `sum(rate(metric{instance=~"$instance"}[$__rate_interval])) by (cluster, namespace)`,
		clusterLabel: "env",
		want:         `sum(rate(metric{instance=~"$instance",env=~"$cluster"}[$__rate_interval])) by(env,namespace)`,
	})
}

func TestPatchDatasource(t *testing.T) {
	type opts struct {
		input         map[string]any
		datasource    string
		datasourceUID string
		wantType      string
		wantUID       string
	}
	f := func(o opts) {
		t.Helper()
		uid := o.datasourceUID
		if uid == "" {
			uid = o.datasource
		}
		d := &strOrMap{MapVal: o.input}
		patchDatasource(d, grafanaConfig{Datasource: o.datasource, DatasourceUID: uid})
		if o.wantType != "" {
			if got, _ := d.MapVal["type"].(string); got != o.wantType {
				t.Fatalf("type: got %q, want %q", got, o.wantType)
			}
		}
		if o.wantUID != "" {
			if got, _ := d.MapVal["uid"].(string); got != o.wantUID {
				t.Fatalf("uid: got %q, want %q", got, o.wantUID)
			}
		}
	}

	// type and uid replaced separately: type stays "prometheus", uid set to VictoriaMetrics
	f(opts{
		input:         map[string]any{"type": "prometheus", "uid": "${DS_PROMETHEUS}"},
		datasource:    "prometheus",
		datasourceUID: "VictoriaMetrics",
		wantType:      "prometheus",
		wantUID:       "VictoriaMetrics",
	})
	// plain uid replaced with datasourceUID, not datasource type
	f(opts{
		input:         map[string]any{"type": "prometheus", "uid": "prometheus"},
		datasource:    "prometheus",
		datasourceUID: "VictoriaMetrics",
		wantType:      "prometheus",
		wantUID:       "VictoriaMetrics",
	})
	// ${datasource} uid preserved (dashboard variable reference, not import input)
	f(opts{
		input:         map[string]any{"type": "prometheus", "uid": "${datasource}"},
		datasource:    "prometheus",
		datasourceUID: "VictoriaMetrics",
		wantType:      "prometheus",
		wantUID:       "${datasource}",
	})
	// no uid — only type replaced
	f(opts{
		input:         map[string]any{"type": "prometheus"},
		datasource:    "prometheus",
		datasourceUID: "VictoriaMetrics",
		wantType:      "prometheus",
	})
	// non-prometheus type — unchanged
	f(opts{
		input:      map[string]any{"type": "loki", "uid": "loki-uid"},
		datasource: "prometheus",
		wantType:   "loki",
		wantUID:    "loki-uid",
	})
	// custom datasource type (VM plugin): type replaced, uid replaced with datasourceUID
	f(opts{
		input:         map[string]any{"type": "prometheus", "uid": "${DS_PROMETHEUS}"},
		datasource:    "victoriametrics-metrics-datasource",
		datasourceUID: "VictoriaMetrics",
		wantType:      "victoriametrics-metrics-datasource",
		wantUID:       "VictoriaMetrics",
	})
}

func TestPatchVariableDatasource(t *testing.T) {
	type opts struct {
		query      *strOrMap
		datasource string
		wantStr    string
		wantMap    string
	}
	f := func(o opts) {
		t.Helper()
		v := &dashVariable{Query: o.query}
		patchVariableDatasource(v, o.datasource)
		if o.wantStr != "" && v.Query.StrVal != o.wantStr {
			t.Fatalf("StrVal: got %q, want %q", v.Query.StrVal, o.wantStr)
		}
		if o.wantMap != "" {
			if got, _ := v.Query.MapVal["query"].(string); got != o.wantMap {
				t.Fatalf("MapVal[query]: got %q, want %q", got, o.wantMap)
			}
		}
	}

	f(opts{
		query:      &strOrMap{StrVal: "prometheus"},
		datasource: "victoriametrics",
		wantStr:    "victoriametrics",
	})
	f(opts{
		query:      &strOrMap{StrVal: "loki"},
		datasource: "victoriametrics",
		wantStr:    "loki",
	})
	f(opts{
		query:      &strOrMap{MapVal: map[string]any{"query": "prometheus"}},
		datasource: "victoriametrics",
		wantMap:    "victoriametrics",
	})
	f(opts{
		query:      &strOrMap{MapVal: map[string]any{"query": "loki"}},
		datasource: "victoriametrics",
		wantMap:    "loki",
	})
}

func TestParseDashboards(t *testing.T) {
	type opts struct {
		raw       string
		srcURL    string
		wantNames []string
		wantErr   bool
	}
	f := func(o opts) {
		t.Helper()
		result, err := parseDashboards([]byte(o.raw), o.srcURL)
		if o.wantErr {
			if err == nil {
				t.Fatal("expected error, got nil")
			}
			return
		}
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		for _, name := range o.wantNames {
			if _, ok := result[name]; !ok {
				t.Fatalf("expected dashboard %q in result; got keys: %v", name, dashboardKeys(result))
			}
		}
	}

	f(opts{
		raw:       `{"title": "My Dashboard", "panels": [], "templating": {"list": []}}`,
		srcURL:    "my-dashboard.json",
		wantNames: []string{"my-dashboard"},
	})
	f(opts{
		raw:       `{"title": "Kubernetes / Pods", "panels": [], "templating": {"list": []}}`,
		srcURL:    "pods.json",
		wantNames: []string{"kubernetes-pods"},
	})
	f(opts{
		raw: `
items:
- data:
    overview.json: '{"title":"Overview","panels":[],"templating":{"list":[]}}'
- data:
    detail.json: '{"title":"Detail","panels":[],"templating":{"list":[]}}'
`,
		srcURL:    "dashboards.yaml",
		wantNames: []string{"overview", "detail"},
	})
	f(opts{
		raw:     `not valid json`,
		srcURL:  "bad.json",
		wantErr: true,
	})
}

func TestPatchDashboardClusterVariable(t *testing.T) {
	type opts struct {
		clusterLabel string
		multicluster bool
		wantName     string
		wantType     string
		wantQuery    string
		wantDef      string
		wantMulti    bool
		wantIncAll   bool
		wantHide     int
	}
	f := func(o opts) {
		t.Helper()
		cl := o.clusterLabel
		if cl == "" {
			cl = "cluster"
		}
		v := dashVariable{
			Name:       "cluster",
			Type:       "query",
			Query:      &strOrMap{StrVal: `label_values(up{job="kubelet"}, cluster)`},
			Definition: `label_values(up{job="kubelet"}, cluster)`,
			Multi:      &boolOrStr{IsBool: true, BoolVal: true},
			IncludeAll: &boolOrStr{IsBool: true, BoolVal: true},
			Hide:       intOrStr{IsInt: true, IntVal: 0},
		}
		common := commonConfig{ClusterLabel: cl, Multicluster: o.multicluster}
		d := &dashboard{Templating: dashTemplating{List: []dashVariable{v}}}
		patchDashboard(d, "test", "", common, grafanaConfig{
			Datasource:    "prometheus",
			DatasourceUID: "prometheus",
		})
		got := &d.Templating.List[0]
		if o.wantName != "" && got.Name != o.wantName {
			t.Fatalf("Name: got %q, want %q", got.Name, o.wantName)
		}
		if got.Type != o.wantType {
			t.Fatalf("Type: got %q, want %q", got.Type, o.wantType)
		}
		if o.wantQuery != "" {
			if got.Query == nil || got.Query.StrVal != o.wantQuery {
				t.Fatalf("Query.StrVal: got %q, want %q", got.Query.StrVal, o.wantQuery)
			}
		}
		if o.wantDef != "" && got.Definition != o.wantDef {
			t.Fatalf("Definition: got %q, want %q", got.Definition, o.wantDef)
		}
		if got.Multi == nil || got.Multi.BoolVal != o.wantMulti {
			t.Fatalf("Multi: got %v, want %v", got.Multi, o.wantMulti)
		}
		if got.IncludeAll == nil || got.IncludeAll.BoolVal != o.wantIncAll {
			t.Fatalf("IncludeAll: got %v, want %v", got.IncludeAll, o.wantIncAll)
		}
		if !got.Hide.IsInt || got.Hide.IntVal != o.wantHide {
			t.Fatalf("Hide: got %+v, want %d", got.Hide, o.wantHide)
		}
	}

	// multicluster:false — becomes constant with query=".*", multi=false, includeAll=false, hidden
	f(opts{
		multicluster: false,
		wantName:     "cluster",
		wantType:     "constant",
		wantQuery:    ".*",
		wantDef:      ".*",
		wantMulti:    false,
		wantIncAll:   false,
		wantHide:     2,
	})
	// multicluster:true — stays query type, multi=true, includeAll=true, visible
	f(opts{
		multicluster: true,
		wantName:     "cluster",
		wantType:     "query",
		wantMulti:    true,
		wantIncAll:   true,
		wantHide:     0,
	})
	// custom clusterLabel — variable name stays "cluster", query uses custom label
	f(opts{
		clusterLabel: "k8s_cluster",
		multicluster: true,
		wantName:     "cluster",
		wantType:     "query",
		wantQuery:    `label_values(up{job="kubelet"}, k8s_cluster)`,
		wantDef:      `label_values(up{job="kubelet"}, k8s_cluster)`,
		wantMulti:    true,
		wantIncAll:   true,
		wantHide:     0,
	})
}

func TestPatchVariableExpr(t *testing.T) {
	type opts struct {
		name       string
		queryStr   string
		queryMap   map[string]any
		definition string
		wantStr    string
		wantMap    string
		wantDef    string
	}
	f := func(o opts) {
		t.Helper()
		var q *strOrMap
		if o.queryStr != "" {
			q = &strOrMap{StrVal: o.queryStr}
		} else if o.queryMap != nil {
			q = &strOrMap{MapVal: o.queryMap}
		}
		v := dashVariable{
			Name:       o.name,
			Type:       "query",
			Query:      q,
			Definition: o.definition,
		}
		patchVariableExpr(&v, o.name, "cluster")
		if o.wantStr != "" && v.Query.StrVal != o.wantStr {
			t.Fatalf("Query.StrVal: got %q, want %q", v.Query.StrVal, o.wantStr)
		}
		if o.wantMap != "" {
			if s, _ := v.Query.MapVal["query"].(string); s != o.wantMap {
				t.Fatalf("Query.MapVal[query]: got %q, want %q", s, o.wantMap)
			}
		}
		if o.wantDef != "" && v.Definition != o.wantDef {
			t.Fatalf("Definition: got %q, want %q", v.Definition, o.wantDef)
		}
	}

	const (
		queryExpr = `label_values(coredns_build_info{cluster="$cluster"},job)`
		wantExpr  = `label_values(coredns_build_info{cluster=~"$cluster"}, job)`
	)

	// string-form query: cluster filter upgraded to =~, definition patched independently
	f(opts{
		name:       "job",
		queryStr:   queryExpr,
		definition: queryExpr,
		wantStr:    wantExpr,
		wantDef:    wantExpr,
	})
	// map-form query (newer Grafana format): MapVal["query"] patched, definition patched independently
	f(opts{
		name: "job",
		queryMap: map[string]any{
			"query": queryExpr,
			"refId": "PrometheusVariableQueryEditor-VariableQuery",
		},
		definition: queryExpr,
		wantMap:    wantExpr,
		wantDef:    wantExpr,
	})
	// map-form query: definition must not be erased when Query.StrVal is empty
	f(opts{
		name: "protocol",
		queryMap: map[string]any{
			"query": `label_values(coredns_dns_requests_total{cluster="$cluster"}, proto)`,
			"refId": "StandardVariableQuery",
		},
		definition: `label_values(coredns_dns_requests_total{cluster="$cluster"}, proto)`,
		wantDef:    `label_values(coredns_dns_requests_total{cluster=~"$cluster"}, proto)`,
	})
}

func TestPatchDashboardInjectClusterVariable(t *testing.T) {
	type opts struct {
		multicluster  bool
		clusterMetric string
		wantInjected  bool
		wantType      string
		wantHide      int
	}
	f := func(o opts) {
		t.Helper()
		common := commonConfig{ClusterLabel: "cluster", Multicluster: o.multicluster}
		d := &dashboard{Templating: dashTemplating{List: []dashVariable{}}}
		patchDashboard(d, "test", o.clusterMetric, common, grafanaConfig{
			Datasource:    "prometheus",
			DatasourceUID: "prometheus",
		})
		found := false
		for _, v := range d.Templating.List {
			if v.Name == "cluster" {
				found = true
				if v.Type != o.wantType {
					t.Fatalf("Type: got %q, want %q", v.Type, o.wantType)
				}
				if !v.Hide.IsInt || v.Hide.IntVal != o.wantHide {
					t.Fatalf("Hide: got %+v, want %d", v.Hide, o.wantHide)
				}
			}
		}
		if found != o.wantInjected {
			t.Fatalf("cluster variable injected=%v, want %v", found, o.wantInjected)
		}
	}

	// multicluster:false, no clusterMetric — hidden constant injected so $cluster resolves in patched queries
	f(opts{
		multicluster:  false,
		clusterMetric: "",
		wantInjected:  true,
		wantType:      "constant",
		wantHide:      2,
	})
	// multicluster:false, clusterMetric set — hidden constant injected
	f(opts{
		multicluster:  false,
		clusterMetric: "up",
		wantInjected:  true,
		wantType:      "constant",
		wantHide:      2,
	})
	// multicluster:true, clusterMetric set — visible query variable injected
	f(opts{
		multicluster:  true,
		clusterMetric: "up",
		wantInjected:  true,
		wantType:      "query",
		wantHide:      0,
	})
	// multicluster:true, no clusterMetric — cannot build query variable, nothing injected
	f(opts{
		multicluster:  true,
		clusterMetric: "",
		wantInjected:  false,
	})
}

func dashboardKeys(m map[string]*dashboard) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
