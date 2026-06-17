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
		input      map[string]any
		datasource string
		wantType   string
		wantUID    string
	}
	f := func(o opts) {
		t.Helper()
		d := &strOrMap{MapVal: o.input}
		patchDatasource(d, o.datasource)
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

	// prometheus type replaced, ${DS_*} uid replaced
	f(opts{
		input:      map[string]any{"type": "prometheus", "uid": "${DS_PROMETHEUS}"},
		datasource: "victoriametrics",
		wantType:   "victoriametrics",
		wantUID:    "victoriametrics",
	})
	// ${datasource} uid preserved (dashboard variable reference, not import input)
	f(opts{
		input:      map[string]any{"type": "prometheus", "uid": "${datasource}"},
		datasource: "victoriametrics",
		wantType:   "victoriametrics",
		wantUID:    "${datasource}",
	})
	// no uid — only type replaced
	f(opts{
		input:      map[string]any{"type": "prometheus"},
		datasource: "victoriametrics",
		wantType:   "victoriametrics",
	})
	// non-prometheus type — unchanged
	f(opts{
		input:      map[string]any{"type": "loki", "uid": "loki-uid"},
		datasource: "victoriametrics",
		wantType:   "loki",
		wantUID:    "loki-uid",
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

func dashboardKeys(m map[string]*dashboard) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
