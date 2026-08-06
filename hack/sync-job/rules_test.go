package main

import (
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

// TestParseRuleGroupsInlineFields is the regression test for issue #3149:
// group-level fields not modelled in ruleGroup (interval, params) and rule-level
// fields not modelled in rule (keep_firing_for) were silently dropped because
// sigs.k8s.io/yaml does not honour yaml:",inline" maps.
func TestParseRuleGroupsInlineFields(t *testing.T) {
	type opts struct {
		yaml      string
		srcURL    string
		checkFunc func(*testing.T, []ruleGroup)
	}
	f := func(o opts) {
		t.Helper()
		groups, err := parseRuleGroups([]byte(o.yaml), o.srcURL)
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
		srcURL: "test.yaml",
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) != 1 {
				t.Fatalf("expected 1 group, got %d", len(groups))
			}
			got := groups[0].XXX["interval"]
			if got != "5m" {
				t.Fatalf("group interval: got %v, want %q", got, "5m")
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
		srcURL: "test.yaml",
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) != 1 {
				t.Fatalf("expected 1 group, got %d", len(groups))
			}
			raw, ok := groups[0].XXX["params"]
			if !ok {
				t.Fatalf("group params missing from XXX; keys: %v", mapKeys(groups[0].XXX))
			}
			m, ok := raw.(map[string]any)
			if !ok {
				t.Fatalf("params: expected map[string]any, got %T", raw)
			}
			if m["severity"] != "warning" {
				t.Fatalf("params.severity: got %v, want %q", m["severity"], "warning")
			}
			if m["team"] != "infra" {
				t.Fatalf("params.team: got %v, want %q", m["team"], "infra")
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
		srcURL: "test.yaml",
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 || len(groups[0].Rules) == 0 {
				t.Fatal("expected at least one rule")
			}
			got := groups[0].Rules[0].XXX["keep_firing_for"]
			if got != "10m" {
				t.Fatalf("rule keep_firing_for: got %v, want %q", got, "10m")
			}
		},
	})

	// known group fields are still parsed alongside inline fields
	f(opts{
		yaml: `
groups:
- name: mixed.group
  interval: 2m
  params:
    env: prod
  rules:
  - alert: B
    expr: up == 1
    for: 5m
    keep_firing_for: 3m
`,
		srcURL: "test.yaml",
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 {
				t.Fatal("expected groups")
			}
			g := groups[0]
			if g.Name != "mixed.group" {
				t.Fatalf("name: got %q, want %q", g.Name, "mixed.group")
			}
			if g.XXX["interval"] != "2m" {
				t.Fatalf("interval: got %v, want %q", g.XXX["interval"], "2m")
			}
			if len(g.Rules) == 0 {
				t.Fatal("expected rules")
			}
			r := g.Rules[0]
			if r.For != "5m" {
				t.Fatalf("rule.for: got %q, want %q", r.For, "5m")
			}
			if r.XXX["keep_firing_for"] != "3m" {
				t.Fatalf("rule.keep_firing_for: got %v, want %q", r.XXX["keep_firing_for"], "3m")
			}
		},
	})

	// CRD format also preserves inline fields
	f(opts{
		yaml: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
spec:
  groups:
  - name: crd.group
    interval: 1m
    rules:
    - alert: C
      expr: up == 0
`,
		srcURL: "test.yaml",
		checkFunc: func(t *testing.T, groups []ruleGroup) {
			t.Helper()
			if len(groups) == 0 {
				t.Fatal("expected groups")
			}
			if groups[0].XXX["interval"] != "1m" {
				t.Fatalf("CRD format interval: got %v, want %q", groups[0].XXX["interval"], "1m")
			}
		},
	})
}

func TestRuleGroupToSpecWithGroupDefaults(t *testing.T) {
	g := ruleGroup{
		Name: "test.group",
		Rules: []rule{
			{Alert: "A", Expr: "up == 0"},
		},
	}
	defaults := map[string]any{
		"params":   map[string]any{"severity": "critical"},
		"interval": "5m",
	}
	spec := ruleGroupToSpec(g, defaults)
	groups, ok := spec["groups"].([]map[string]any)
	if !ok || len(groups) == 0 {
		t.Fatal("spec.groups missing or empty")
	}
	grp := groups[0]
	if grp["interval"] != "5m" {
		t.Fatalf("interval: got %v, want %q", grp["interval"], "5m")
	}
	p, ok := grp["params"].(map[string]any)
	if !ok || p["severity"] != "critical" {
		t.Fatalf("params: got %v", grp["params"])
	}
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
}
