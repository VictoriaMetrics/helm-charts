package main

import (
	"maps"
	"strings"
	"testing"
)

func TestToCamelCase(t *testing.T) {
	type opts struct {
		input string
		want  string
	}
	f := func(o opts) {
		t.Helper()
		got := toCamelCase(o.input)
		if got != o.want {
			t.Fatalf("toCamelCase(%q) = %q, want %q", o.input, got, o.want)
		}
	}

	f(opts{
		input: "kubernetes-apps",
		want:  "kubernetesApps",
	})
	f(opts{
		input: "kube-state-metrics",
		want:  "kubeStateMetrics",
	})
	f(opts{
		input: "kube-apiserver-burnrate",
		want:  "kubeApiserverBurnrate",
	})
	f(opts{
		input: "kubernetes-system-controller-manager",
		want:  "kubernetesSystemControllerManager",
	})
	f(opts{
		input: "node-network",
		want:  "nodeNetwork",
	})
	f(opts{
		input: "vm-health",
		want:  "vmHealth",
	})
	f(opts{
		input: "node-exporter",
		want:  "nodeExporter",
	})
	f(opts{
		input: "general.rules",
		want:  "generalRules",
	})
	// no separator — unchanged
	f(opts{
		input: "vmagent",
		want:  "vmagent",
	})
	f(opts{
		input: "etcd",
		want:  "etcd",
	})
}

func TestLookupGroup(t *testing.T) {
	type opts struct {
		groups  map[string]groupOverride
		name    string
		wantOK  bool
		wantKey string // which key in groups was matched
	}
	enabled := func(b bool) *bool { return &b }
	f := func(o opts) {
		t.Helper()
		g, ok := lookupGroup(o.groups, o.name)
		if ok != o.wantOK {
			t.Fatalf("lookupGroup(%q) ok=%v, want %v", o.name, ok, o.wantOK)
		}
		if o.wantOK && o.wantKey != "" {
			want := o.groups[o.wantKey]
			if g.Enabled == nil || want.Enabled == nil || *g.Enabled != *want.Enabled {
				t.Fatalf("lookupGroup(%q) returned wrong entry", o.name)
			}
		}
	}

	// exact match
	f(opts{
		groups: map[string]groupOverride{
			"kubernetes-apps": {
				Enabled: enabled(false),
			},
		},
		name:    "kubernetes-apps",
		wantOK:  true,
		wantKey: "kubernetes-apps",
	})
	// camelCase key matches kebab-case upstream name
	f(opts{
		groups: map[string]groupOverride{
			"kubernetesApps": {
				Enabled: enabled(false),
			},
		},
		name:    "kubernetes-apps",
		wantOK:  true,
		wantKey: "kubernetesApps",
	})
	// key without .rules suffix matches upstream name with .rules
	f(opts{
		groups: map[string]groupOverride{
			"alertmanager": {
				Enabled: enabled(false),
			},
		},
		name:    "alertmanager.rules",
		wantOK:  true,
		wantKey: "alertmanager",
	})
	// camelCase without .rules suffix
	f(opts{
		groups: map[string]groupOverride{
			"kubeApiserverBurnrate": {
				Enabled: enabled(false),
			},
		},
		name:    "kube-apiserver-burnrate.rules",
		wantOK:  true,
		wantKey: "kubeApiserverBurnrate",
	})
	// no match
	f(opts{
		groups: map[string]groupOverride{
			"other": {
				Enabled: enabled(false),
			},
		},
		name:   "kubernetes-apps",
		wantOK: false,
	})
	// exact takes priority over camelCase
	f(opts{
		groups: map[string]groupOverride{
			"kubernetes-apps": {
				Enabled: enabled(true),
			},
			"kubernetesApps": {
				Enabled: enabled(false),
			},
		},
		name:    "kubernetes-apps",
		wantOK:  true,
		wantKey: "kubernetes-apps",
	})
}

func TestPatchRuleExpr(t *testing.T) {
	type opts struct {
		expr          string
		common        commonConfig
		labels        []string
		jobNamespaces map[string]string
		want          string
	}
	f := func(o opts) {
		t.Helper()
		if o.common.ClusterLabel == "" {
			o.common.ClusterLabel = "cluster"
		}
		got := patchRuleExpr(o.expr, o.labels, o.common, o.jobNamespaces)
		if got != o.want {
			t.Fatalf("patchRuleExpr(%q)\ngot:  %s\nwant: %s", o.expr, got, o.want)
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

	// cluster label replacement in by/on modifiers
	f(opts{
		expr: `sum(up) by (job, cluster)`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `sum(up) by(job,env)`,
	})
	f(opts{
		expr: `sum(up) by (job, env)`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `sum(up) by(job,env)`,
	})
	f(opts{
		expr: `rate(a[5m]) / on(cluster, job) rate(b[5m])`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `rate(a[5m]) / on(env,job) rate(b[5m])`,
	})

	// multicluster — cluster label added to by/on and bare aggr funcs
	f(opts{
		expr: `sum(up) by (job)`,
		common: commonConfig{
			ClusterLabel: "cluster",
			Multicluster: true,
		},
		want: `sum(up) by(job,cluster)`,
	})
	f(opts{
		expr: `sum(up) by (job, cluster)`,
		common: commonConfig{
			ClusterLabel: "cluster",
			Multicluster: true,
		},
		want: `sum(up) by(job,cluster)`,
	})
	f(opts{
		expr: `sum(up)`,
		common: commonConfig{
			ClusterLabel: "cluster",
			Multicluster: true,
		},
		want: `sum(up) by(cluster)`,
	})
	f(opts{
		expr: `rate(a[5m]) / on(job) rate(b[5m])`,
		common: commonConfig{
			ClusterLabel: "cluster",
			Multicluster: true,
		},
		want: `rate(a[5m]) / on(job,cluster) rate(b[5m])`,
	})

	// extraGroupByLabels injected into by modifier
	f(opts{
		expr:   `sum(up) by (job)`,
		labels: []string{"namespace"},
		want:   `sum(up) by(job,namespace)`,
	})
	f(opts{
		expr:   `sum(up) by (job, namespace)`,
		labels: []string{"namespace"},
		want:   `sum(up) by(job,namespace)`,
	})
	f(opts{
		expr:   `sum(up)`,
		labels: []string{"ns"},
		want:   `sum(up) by(ns)`,
	})

	// grafana variables — $__rate_interval / $__interval in range vectors are preserved;
	// label_values() is unparseable by metricsql and returned unchanged
	f(opts{
		expr: `sum(rate(http_requests[$__rate_interval])) by (job, cluster)`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `sum(rate(http_requests[$__rate_interval])) by(job,env)`,
	})
	f(opts{
		expr: `sum(rate(http_requests[$__interval])) by (cluster)`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `sum(rate(http_requests[$__interval])) by(env)`,
	})
	f(opts{
		expr: `sum(rate(metric{instance=~"$instance"}[$__rate_interval])) by (cluster, namespace)`,
		common: commonConfig{
			ClusterLabel: "env",
		},
		want: `sum(rate(metric{instance=~"$instance"}[$__rate_interval])) by(env,namespace)`,
	})
	f(opts{
		expr: `label_values(up{job="$job"}, instance)`,
		want: `label_values(up{job="$job"}, instance)`,
	})

	// jobNamespaces — namespace filter injected for exact job match only
	f(opts{
		expr: `up{job="kubelet"}`,
		jobNamespaces: map[string]string{
			"kubelet": "kube-system",
		},
		want: `up{job="kubelet",namespace=~"kube-system"}`,
	})
	f(opts{
		expr: `up{job="kubelet",namespace="kube-system"}`,
		jobNamespaces: map[string]string{
			"kubelet": "kube-system",
		},
		want: `up{job="kubelet",namespace="kube-system"}`,
	})
	f(opts{
		expr: `up{job="other"}`,
		jobNamespaces: map[string]string{
			"kubelet": "kube-system",
		},
		want: `up{job="other"}`,
	})
	f(opts{
		expr: `up{job=~"kubelet.*"}`,
		jobNamespaces: map[string]string{
			"kubelet": "kube-system",
		},
		want: `up{job=~"kubelet.*"}`,
	})
}

func TestPatchRuleAnnotations(t *testing.T) {
	type opts struct {
		key          string
		value        string
		common       rulesCommonConfig
		clusterLabel string
		want         string
	}
	f := func(o opts) {
		t.Helper()
		cl := o.clusterLabel
		if cl == "" {
			cl = "cluster"
		}
		cfg := &rulesConfig{Common: o.common}
		r := &rule{Annotations: map[string]string{o.key: o.value}}
		patchRuleAnnotations(r, cfg, cl)
		if got := r.Annotations[o.key]; got != o.want {
			t.Fatalf("annotation %q: got %q, want %q", o.key, got, o.want)
		}
	}

	f(opts{
		key:   "runbook",
		value: "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/down",
		common: rulesCommonConfig{
			RunbookURL: "https://my-runbooks.example.com/runbooks",
		},
		want: "https://my-runbooks.example.com/runbooks/alertmanager/down",
	})
	f(opts{
		key:   "dashboard",
		value: "http://localhost:3000/d/xyz?var-cluster=$labels.cluster",
		common: rulesCommonConfig{
			GrafanaURL: "https://grafana.example.com",
		},
		clusterLabel: "env",
		want:         "https://grafana.example.com/d/xyz?var-cluster=$labels.env",
	})
	f(opts{
		key:          "summary",
		value:        "Instance $labels.cluster is down",
		clusterLabel: "env",
		want:         "Instance $labels.env is down",
	})
	f(opts{
		key:   "description",
		value: "Something happened",
		want:  "Something happened",
	})
}

func TestParseRuleGroups(t *testing.T) {
	type opts struct {
		yaml       string
		srcURL     string
		wantGroups int
		wantName   string
		wantErr    bool
	}
	f := func(o opts) {
		t.Helper()
		groups, err := parseRuleGroups([]byte(o.yaml), o.srcURL)
		if o.wantErr {
			if err == nil {
				t.Fatal("expected error, got nil")
			}
			return
		}
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if len(groups) != o.wantGroups {
			t.Fatalf("expected %d groups, got %d", o.wantGroups, len(groups))
		}
		if o.wantGroups > 0 && groups[0].Name != o.wantName {
			t.Fatalf("group name: got %q, want %q", groups[0].Name, o.wantName)
		}
	}

	f(opts{
		yaml: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
spec:
  groups:
  - name: test.group
    rules:
    - alert: TestAlert
      expr: up == 0
`,
		srcURL:     "test.yaml",
		wantGroups: 1,
		wantName:   "test.group",
	})
	f(opts{
		yaml: `
groups:
- name: raw.group
  rules:
  - record: job:up:sum
    expr: sum(up) by (job)
`,
		srcURL:     "test.yaml",
		wantGroups: 1,
		wantName:   "raw.group",
	})
	f(opts{
		yaml:       "\xEF\xBB\xBF\ngroups:\n- name: bom.group\n  rules: []\n",
		srcURL:     "test.yml",
		wantGroups: 1,
		wantName:   "bom.group",
	})
	f(opts{
		yaml:    `groups: []`,
		srcURL:  "test.json",
		wantErr: true,
	})
}

func TestRuleGroupVMRuleName(t *testing.T) {
	type opts struct {
		prefix string
		input  string
		want   string
	}
	f := func(o opts) {
		t.Helper()
		prefix := o.prefix
		if prefix == "" {
			prefix = "my-release"
		}
		got := ruleGroupVMRuleName(prefix, o.input)
		if got != o.want {
			t.Fatalf("ruleGroupVMRuleName(%q, %q) = %q, want %q", prefix, o.input, got, o.want)
		}
	}

	f(opts{
		input: "kubernetes-apps",
		want:  "my-release-rule-kubernetes-apps",
	})
	f(opts{
		input: "kubernetes.apps",
		want:  "my-release-rule-kubernetes-apps",
	})
	f(opts{
		input: "kubernetes_apps",
		want:  "my-release-rule-kubernetes-apps",
	})
	f(opts{
		input: "Kubernetes Apps",
		want:  "my-release-rule-kubernetes-apps",
	})
	f(opts{
		input: "kubernetesApps",
		want:  "my-release-rule-kubernetesapps",
	})
	// name exceeding 253 chars is trimmed
	f(opts{
		input: strings.Repeat("a", 260),
		want:  "my-release-rule-" + strings.Repeat("a", 253-len("my-release-rule-")),
	})
}

// TestParseRuleGroupsInlineFields is the regression test for issue #3149.
func TestParseRuleGroupsInlineFields(t *testing.T) {
	type opts struct {
		yaml      string
		checkFunc func(*testing.T, []ruleGroup)
	}
	f := func(o opts) {
		t.Helper()
		groups, err := parseRuleGroups([]byte(o.yaml), "test.yaml")
		if err != nil {
			t.Fatalf("parseRuleGroups: %v", err)
		}
		o.checkFunc(t, groups)
	}

	// group-level interval preserved in XXX
	f(opts{
		yaml: `
groups:
- name: test.group
  interval: 5m
  rules:
  - alert: A
    expr: up == 0
`,
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 {
				t.Fatal("expected groups")
			}
			if groups[0].XXX["interval"] != "5m" {
				t.Fatalf("group interval: got %v, want %q", groups[0].XXX["interval"], "5m")
			}
		},
	})

	// group-level params map preserved in XXX
	f(opts{
		yaml: `
groups:
- name: test.group
  params:
    severity: warning
    team: infra
  rules:
  - alert: A
    expr: up == 0
`,
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 {
				t.Fatal("expected groups")
			}
			raw, ok := groups[0].XXX["params"]
			if !ok {
				t.Fatalf("group params missing from XXX; keys: %v", mapKeys(groups[0].XXX))
			}
			m, ok := raw.(map[string]any)
			if !ok {
				t.Fatalf("params: expected map[string]any, got %T", raw)
			}
			if m["severity"] != "warning" || m["team"] != "infra" {
				t.Fatalf("params: got %v", m)
			}
		},
	})

	// rule-level keep_firing_for preserved in XXX
	f(opts{
		yaml: `
groups:
- name: test.group
  rules:
  - alert: A
    expr: up == 0
    keep_firing_for: 10m
`,
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 || len(groups[0].Rules) == 0 {
				t.Fatal("expected rules")
			}
			if groups[0].Rules[0].XXX["keep_firing_for"] != "10m" {
				t.Fatalf("rule keep_firing_for: got %v, want %q", groups[0].Rules[0].XXX["keep_firing_for"], "10m")
			}
		},
	})

	// named fields must NOT appear in XXX — regression for issue #3151
	f(opts{
		yaml: `
groups:
- name: test.group
  interval: 5m
  rules:
  - alert: A
    expr: up == 0
    for: 5m
    keep_firing_for: 3m
  - alert: B
    expr: up == 1
`,
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 {
				t.Fatal("expected groups")
			}
			g := groups[0]
			for _, key := range []string{"name", "rules"} {
				if _, ok := g.XXX[key]; ok {
					t.Errorf("g.XXX must not contain named field %q", key)
				}
			}
			if len(g.Rules) == 0 {
				t.Fatal("expected rules")
			}
			r := g.Rules[0]
			for _, key := range []string{"alert", "expr", "for"} {
				if _, ok := r.XXX[key]; ok {
					t.Errorf("r.XXX must not contain named field %q", key)
				}
			}
			if r.XXX["keep_firing_for"] != "3m" {
				t.Fatalf("keep_firing_for: got %v, want %q", r.XXX["keep_firing_for"], "3m")
			}

			// end-to-end: filtering one rule out must not be undone by XXX
			g.Rules = g.Rules[:1]
			spec := ruleGroupToSpec(g, nil)
			specRules := spec["groups"].([]map[string]any)[0]["rules"].([]map[string]any)
			if len(specRules) != 1 {
				t.Fatalf("ruleGroupToSpec wrote %d rules after filtering to 1 — named fields leaked via XXX", len(specRules))
			}
		},
	})
}

func TestMergeRule(t *testing.T) {
	type opts struct {
		dst   rule
		src   rule
		check func(rule)
	}
	f := func(o opts) {
		t.Helper()
		mergeRule(&o.dst, o.src)
		o.check(o.dst)
	}

	f(opts{
		dst: rule{For: "1m"},
		src: rule{For: "5m"},
		check: func(r rule) {
			if r.For != "5m" {
				t.Fatalf("src For should override dst; got %q", r.For)
			}
		},
	})
	f(opts{
		dst: rule{For: "1m"},
		src: rule{},
		check: func(r rule) {
			if r.For != "1m" {
				t.Fatalf("empty src For should not override dst; got %q", r.For)
			}
		},
	})
	f(opts{
		dst: rule{Expr: "up == 0"},
		src: rule{Expr: "up == 1"},
		check: func(r rule) {
			if r.Expr != "up == 1" {
				t.Fatalf("src Expr should override dst; got %q", r.Expr)
			}
		},
	})
	f(opts{
		dst: rule{Expr: "up == 0"},
		src: rule{},
		check: func(r rule) {
			if r.Expr != "up == 0" {
				t.Fatalf("empty src Expr should not override dst; got %q", r.Expr)
			}
		},
	})
	f(opts{
		dst: rule{
			Labels: map[string]string{"a": "old"},
		},
		src: rule{
			Labels: map[string]string{"a": "new", "b": "2"},
		},
		check: func(r rule) {
			if r.Labels["a"] != "new" || r.Labels["b"] != "2" {
				t.Fatalf("unexpected labels: %v", r.Labels)
			}
		},
	})
	f(opts{
		dst: rule{
			Annotations: map[string]string{"x": "1"},
		},
		src: rule{
			Annotations: map[string]string{"y": "2"},
		},
		check: func(r rule) {
			if r.Annotations["x"] != "1" || r.Annotations["y"] != "2" {
				t.Fatalf("unexpected annotations: %v", r.Annotations)
			}
		},
	})
	// XXX fields are merged; src overrides same key in dst
	f(opts{
		dst: rule{XXX: map[string]any{"keep_firing_for": "1m", "own": "yes"}},
		src: rule{XXX: map[string]any{"keep_firing_for": "5m", "extra": "val"}},
		check: func(r rule) {
			if r.XXX["keep_firing_for"] != "5m" {
				t.Fatalf("src XXX should override dst for same key; got %v", r.XXX["keep_firing_for"])
			}
			if r.XXX["own"] != "yes" {
				t.Fatalf("dst-only XXX key should be preserved; got %v", r.XXX["own"])
			}
			if r.XXX["extra"] != "val" {
				t.Fatalf("src-only XXX key should be added; got %v", r.XXX["extra"])
			}
		},
	})
	// empty src XXX does not clear dst XXX
	f(opts{
		dst: rule{XXX: map[string]any{"keep_firing_for": "1m"}},
		src: rule{},
		check: func(r rule) {
			if r.XXX["keep_firing_for"] != "1m" {
				t.Fatalf("empty src XXX should not clear dst; got %v", r.XXX["keep_firing_for"])
			}
		},
	})
}

func TestRuleGroupToSpec(t *testing.T) {
	getGroup := func(t *testing.T, spec map[string]any) map[string]any {
		t.Helper()
		return spec["groups"].([]map[string]any)[0]
	}
	getRules := func(t *testing.T, spec map[string]any) []map[string]any {
		t.Helper()
		return getGroup(t, spec)["rules"].([]map[string]any)
	}

	t.Run("alert rule fields and XXX appear in output", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name: "test",
			Rules: []rule{{
				Alert:       "HighLatency",
				Expr:        `rate(http_requests[5m]) > 0.1`,
				For:         "5m",
				Labels:      map[string]string{"severity": "warning"},
				Annotations: map[string]string{"summary": "high latency"},
				XXX:         map[string]any{"keep_firing_for": "1m"},
			}},
		}, nil)
		rules := getRules(t, spec)
		if len(rules) != 1 {
			t.Fatalf("want 1 rule, got %d", len(rules))
		}
		r := rules[0]
		for k, want := range map[string]any{
			"alert":           "HighLatency",
			"expr":            `rate(http_requests[5m]) > 0.1`,
			"for":             "5m",
			"keep_firing_for": "1m",
		} {
			if r[k] != want {
				t.Errorf("rule[%q]: got %v, want %v", k, r[k], want)
			}
		}
		if r["labels"].(map[string]string)["severity"] != "warning" {
			t.Errorf("labels.severity: got %v", r["labels"])
		}
		if _, ok := r["record"]; ok {
			t.Error("record should not appear for alert rule")
		}
	})

	t.Run("record rule has no alert or for in output", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name:  "test",
			Rules: []rule{{Record: "job:up:sum", Expr: "sum(up) by (job)"}},
		}, nil)
		r := getRules(t, spec)[0]
		if r["record"] != "job:up:sum" {
			t.Errorf("record: got %v", r["record"])
		}
		for _, k := range []string{"alert", "for"} {
			if _, ok := r[k]; ok {
				t.Errorf("%q should not appear for record rule", k)
			}
		}
	})

	t.Run("groupDefaults applied; group XXX overrides defaults", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name:  "test",
			Rules: []rule{{Alert: "A", Expr: "up == 0"}},
			XXX:   map[string]any{"interval": "2m"},
		}, map[string]any{"interval": "1m", "limit": 100})
		g := getGroup(t, spec)
		if g["interval"] != "2m" {
			t.Errorf("group XXX should override defaults: got %v", g["interval"])
		}
		if g["limit"] != 100 {
			t.Errorf("default limit should be applied: got %v", g["limit"])
		}
	})

	t.Run("group name preserved and all rules present", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name: "mygroup",
			Rules: []rule{
				{Alert: "A", Expr: "up == 0"},
				{Alert: "B", Expr: "up == 1"},
			},
		}, nil)
		g := getGroup(t, spec)
		if g["name"] != "mygroup" {
			t.Errorf("name: got %v", g["name"])
		}
		if len(getRules(t, spec)) != 2 {
			t.Errorf("want 2 rules, got %d", len(getRules(t, spec)))
		}
	})

	t.Run("empty optional fields omitted from rule", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name:  "test",
			Rules: []rule{{Alert: "A", Expr: "up == 0"}},
		}, nil)
		r := getRules(t, spec)[0]
		for _, k := range []string{"for", "labels", "annotations", "record"} {
			if _, ok := r[k]; ok {
				t.Errorf("%q should not appear when empty", k)
			}
		}
	})

	t.Run("common group spec applied as groupDefaults", func(t *testing.T) {
		spec := ruleGroupToSpec(ruleGroup{
			Name:  "test",
			Rules: []rule{{Alert: "A", Expr: "up == 0"}},
		}, map[string]any{"interval": "60s"})
		g := getGroup(t, spec)
		if g["interval"] != "60s" {
			t.Errorf("interval: got %v, want 60s", g["interval"])
		}
	})

	t.Run("per-group spec overrides common group spec", func(t *testing.T) {
		commonDefaults := map[string]any{"interval": "30s", "limit": 100}
		groupOverrides := map[string]any{"interval": "60s"}
		merged := make(map[string]any, len(commonDefaults)+len(groupOverrides))
		maps.Copy(merged, commonDefaults)
		maps.Copy(merged, groupOverrides)
		spec := ruleGroupToSpec(ruleGroup{
			Name:  "test",
			Rules: []rule{{Alert: "A", Expr: "up == 0"}},
		}, merged)
		g := getGroup(t, spec)
		if g["interval"] != "60s" {
			t.Errorf("interval: got %v, want 60s (per-group should override common)", g["interval"])
		}
		if g["limit"] != 100 {
			t.Errorf("limit: got %v, want 100 (common should be preserved when not overridden)", g["limit"])
		}
	})
}

func TestApplyRuleDefaults(t *testing.T) {
	forRule := func(d string) rule { return rule{For: d} }

	t.Run("common rule spec applied", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{Common: rulesCommonConfig{Rule: ruleOverride{Spec: forRule("5m")}}}
		applyRuleDefaults(&r, cfg, "")
		if r.For != "5m" {
			t.Fatalf("got %q, want 5m", r.For)
		}
	})

	t.Run("alerting spec not applied to record rules", func(t *testing.T) {
		r := rule{Record: "job:up:sum", Expr: "sum(up) by (job)"}
		cfg := &rulesConfig{Common: rulesCommonConfig{Alerting: ruleOverride{Spec: forRule("5m")}}}
		applyRuleDefaults(&r, cfg, "")
		if r.For != "" {
			t.Fatalf("alerting spec must not apply to record rules; got %q", r.For)
		}
	})

	t.Run("recording spec not applied to alert rules", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{Common: rulesCommonConfig{Recording: ruleOverride{Spec: forRule("5m")}}}
		applyRuleDefaults(&r, cfg, "")
		if r.For != "" {
			t.Fatalf("recording spec must not apply to alert rules; got %q", r.For)
		}
	})

	t.Run("alerting spec overrides common rule spec for alert rules", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{Common: rulesCommonConfig{
			Rule:     ruleOverride{Spec: forRule("5m")},
			Alerting: ruleOverride{Spec: forRule("10m")},
		}}
		applyRuleDefaults(&r, cfg, "")
		if r.For != "10m" {
			t.Fatalf("alerting spec should override rule spec; got %q", r.For)
		}
	})

	t.Run("per-rule global override beats common", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{
			Common: rulesCommonConfig{Rule: ruleOverride{Spec: forRule("5m")}},
			Rules:  map[string]ruleOverride{"A": {Spec: forRule("10m")}},
		}
		applyRuleDefaults(&r, cfg, "")
		if r.For != "10m" {
			t.Fatalf("got %q, want 10m", r.For)
		}
	})

	t.Run("group rule spec beats common", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{
			Common: rulesCommonConfig{Rule: ruleOverride{Spec: forRule("5m")}},
			Groups: map[string]groupOverride{
				"mygroup": {Rule: ruleOverride{Spec: forRule("10m")}},
			},
		}
		applyRuleDefaults(&r, cfg, "mygroup")
		if r.For != "10m" {
			t.Fatalf("got %q, want 10m", r.For)
		}
	})

	t.Run("group per-rule override is highest priority", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0"}
		cfg := &rulesConfig{
			Common: rulesCommonConfig{Rule: ruleOverride{Spec: forRule("1m")}},
			Rules:  map[string]ruleOverride{"A": {Spec: forRule("2m")}},
			Groups: map[string]groupOverride{
				"mygroup": {
					Rule:  ruleOverride{Spec: forRule("3m")},
					Rules: map[string]ruleOverride{"A": {Spec: forRule("15m")}},
				},
			},
		}
		applyRuleDefaults(&r, cfg, "mygroup")
		if r.For != "15m" {
			t.Fatalf("got %q, want 15m", r.For)
		}
	})

	t.Run("existing rule fields not cleared when spec is empty", func(t *testing.T) {
		r := rule{Alert: "A", Expr: "up == 0", For: "5m"}
		applyRuleDefaults(&r, &rulesConfig{}, "")
		if r.For != "5m" {
			t.Fatalf("existing For should not be cleared; got %q", r.For)
		}
	})
}

func TestPatchRuleGroup(t *testing.T) {
	t.Run("group extraGroupByLabels replaces common", func(t *testing.T) {
		g := ruleGroup{
			Name:  "mygroup",
			Rules: []rule{{Alert: "A", Expr: "sum(up) by (job)"}},
		}
		cfg := &rulesConfig{
			Common: rulesCommonConfig{ExtraGroupByLabels: []string{"namespace"}},
			Groups: map[string]groupOverride{
				"mygroup": {ExtraGroupByLabels: []string{"region"}},
			},
		}
		patchRuleGroup(&g, cfg, commonConfig{ClusterLabel: "cluster"})
		expr := g.Rules[0].Expr
		if !strings.Contains(expr, "region") {
			t.Errorf("group extraGroupByLabels should replace common; expr: %s", expr)
		}
		if strings.Contains(expr, "namespace") {
			t.Errorf("common extraGroupByLabels should not appear after group override; expr: %s", expr)
		}
	})

	t.Run("group jobNamespaces merges with common", func(t *testing.T) {
		g := ruleGroup{
			Name: "mygroup",
			Rules: []rule{
				{Alert: "A", Expr: `up{job="kubelet"}`},
				{Alert: "B", Expr: `up{job="coredns"}`},
			},
		}
		cfg := &rulesConfig{
			Common: rulesCommonConfig{
				JobNamespaces: map[string]string{"kubelet": "kube-system"},
			},
			Groups: map[string]groupOverride{
				"mygroup": {
					JobNamespaces: map[string]string{"coredns": "kube-system"},
				},
			},
		}
		patchRuleGroup(&g, cfg, commonConfig{ClusterLabel: "cluster"})
		if !strings.Contains(g.Rules[0].Expr, "namespace") {
			t.Errorf("kubelet: expected namespace filter; expr: %s", g.Rules[0].Expr)
		}
		if !strings.Contains(g.Rules[1].Expr, "namespace") {
			t.Errorf("coredns: expected namespace filter; expr: %s", g.Rules[1].Expr)
		}
	})
}
