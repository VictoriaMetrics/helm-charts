package main

import (
	"os"
	"testing"
)

func writeConfigFile(t *testing.T, content string) string {
	t.Helper()
	f, err := os.CreateTemp(t.TempDir(), "config-*.yaml")
	if err != nil {
		t.Fatalf("create temp config: %v", err)
	}
	if _, err := f.WriteString(content); err != nil {
		t.Fatalf("write temp config: %v", err)
	}
	f.Close()
	return f.Name()
}

func TestLoadConfigKnownFields(t *testing.T) {
	path := writeConfigFile(t, `
common:
  clusterLabel: env
  multicluster: true
rules:
  common:
    runbookUrl: https://my-runbooks.example.com
    grafanaUrl: https://grafana.example.com
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	if cfg.Common.ClusterLabel != "env" {
		t.Fatalf("clusterLabel: got %q, want %q", cfg.Common.ClusterLabel, "env")
	}
	if !cfg.Common.Multicluster {
		t.Fatal("multicluster: got false, want true")
	}
	if cfg.Rules.Common.RunbookURL != "https://my-runbooks.example.com" {
		t.Fatalf("runbookUrl: got %q", cfg.Rules.Common.RunbookURL)
	}
}

// TestLoadConfigGroupSpecParams is the regression test for issue #3149.
func TestLoadConfigGroupSpecParams(t *testing.T) {
	path := writeConfigFile(t, `
rules:
  common:
    group:
      spec:
        params:
          severity: critical
          team: platform
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	xxx := cfg.Rules.Common.Group.Spec.XXX
	if len(xxx) == 0 {
		t.Fatal("group.spec inline fields (XXX) are empty; expected params to be populated")
	}
	params, ok := xxx["params"]
	if !ok {
		t.Fatalf("group.spec.params missing from XXX; got keys: %v", mapKeys(xxx))
	}
	m, ok := params.(map[string]any)
	if !ok {
		t.Fatalf("group.spec.params: expected map[string]any, got %T", params)
	}
	if m["severity"] != "critical" {
		t.Fatalf("params.severity: got %v, want %q", m["severity"], "critical")
	}
	if m["team"] != "platform" {
		t.Fatalf("params.team: got %v, want %q", m["team"], "platform")
	}
}

func TestLoadConfigGroupSpecInterval(t *testing.T) {
	path := writeConfigFile(t, `
rules:
  common:
    group:
      spec:
        interval: 2m
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	if cfg.Rules.Common.Group.Spec.XXX["interval"] != "2m" {
		t.Fatalf("group.spec.interval: got %v, want %q", cfg.Rules.Common.Group.Spec.XXX["interval"], "2m")
	}
}

func TestLoadConfigRuleSpecInlineFields(t *testing.T) {
	path := writeConfigFile(t, `
rules:
  common:
    rule:
      spec:
        keep_firing_for: 5m
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	if cfg.Rules.Common.Rule.Spec.XXX["keep_firing_for"] != "5m" {
		t.Fatalf("rule.spec.keep_firing_for: got %v, want %q", cfg.Rules.Common.Rule.Spec.XXX["keep_firing_for"], "5m")
	}
}

func TestLoadConfigGroupSpecMixedKnownAndInline(t *testing.T) {
	path := writeConfigFile(t, `
rules:
  common:
    group:
      spec:
        interval: 1m
        params:
          foo: bar
    rule:
      spec:
        for: 10m
  groups:
    kubernetes-apps:
      spec:
        params:
          env: prod
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	commonGroup := cfg.Rules.Common.Group.Spec.XXX
	if commonGroup["interval"] != "1m" {
		t.Fatalf("common group interval: got %v, want %q", commonGroup["interval"], "1m")
	}
	if p, ok := commonGroup["params"].(map[string]any); !ok || p["foo"] != "bar" {
		t.Fatalf("common group params: got %v", commonGroup["params"])
	}
	if cfg.Rules.Common.Rule.Spec.For != "10m" {
		t.Fatalf("common rule.for: got %q, want %q", cfg.Rules.Common.Rule.Spec.For, "10m")
	}
	g, ok := cfg.Rules.Groups["kubernetes-apps"]
	if !ok {
		t.Fatal("groups[kubernetes-apps] missing")
	}
	if p, ok := g.Spec.XXX["params"].(map[string]any); !ok || p["env"] != "prod" {
		t.Fatalf("kubernetes-apps group params: got %v", g.Spec.XXX["params"])
	}
}

func TestLoadConfigDefaults(t *testing.T) {
	path := writeConfigFile(t, `{}`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	if cfg.Common.ClusterLabel != "cluster" {
		t.Errorf("default clusterLabel: got %q, want %q", cfg.Common.ClusterLabel, "cluster")
	}
	if cfg.Dashboards.Common.Grafana.Datasource != "prometheus" {
		t.Errorf("default datasource: got %q", cfg.Dashboards.Common.Grafana.Datasource)
	}
	if cfg.Dashboards.Common.Grafana.DatasourceUID != "prometheus" {
		t.Errorf("default datasourceUID: got %q", cfg.Dashboards.Common.Grafana.DatasourceUID)
	}
	if cfg.Dashboards.Common.Grafana.LabelName != "grafana_dashboard" {
		t.Errorf("default labelName: got %q", cfg.Dashboards.Common.Grafana.LabelName)
	}
	if cfg.Dashboards.Common.Grafana.LabelValue != "1" {
		t.Errorf("default labelValue: got %q", cfg.Dashboards.Common.Grafana.LabelValue)
	}
}

func TestLoadConfigDatasourceUIDDefaultsToDatasource(t *testing.T) {
	path := writeConfigFile(t, `
dashboards:
  common:
    grafana:
      datasource: my-prometheus
`)
	cfg, err := loadConfig(path)
	if err != nil {
		t.Fatalf("loadConfig: %v", err)
	}
	if cfg.Dashboards.Common.Grafana.DatasourceUID != "my-prometheus" {
		t.Errorf("datasourceUID should default to datasource value: got %q", cfg.Dashboards.Common.Grafana.DatasourceUID)
	}
}

func mapKeys(m map[string]any) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
