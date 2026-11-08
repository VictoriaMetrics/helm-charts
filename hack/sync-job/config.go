package main

import (
	"fmt"
	"log"
	"os"

	"go.yaml.in/yaml/v3"
)

type commonConfig struct {
	ClusterLabel string `yaml:"clusterLabel"`
	Multicluster bool   `yaml:"multicluster"`
}

type config struct {
	Common     commonConfig     `yaml:"common"`
	Dashboards dashboardsConfig `yaml:"dashboards"`
	Rules      rulesConfig      `yaml:"rules"`
}

type dashboardOverride struct {
	Enabled       *bool                       `yaml:"enabled,omitempty"`
	ClusterMetric string                      `yaml:"clusterMetric,omitempty"` // Deprecated: use Variables with a label_values(<metric>, cluster) query instead.
	Variables     map[string]variableOverride `yaml:"variables,omitempty"`
}

func (o dashboardOverride) variables(clusterLabel string) map[string]variableOverride {
	if o.ClusterMetric == "" || o.Variables != nil {
		return o.Variables
	}
	return map[string]variableOverride{clusterLabel: {Query: fmt.Sprintf("label_values(%s, %s)", o.ClusterMetric, clusterLabel)}}
}

type variableOverride struct {
	Query string  `yaml:"query,omitempty"`
	Regex *string `yaml:"regex,omitempty"`
}

type grafanaConfig struct {
	LabelName     string                 `yaml:"labelName"`
	LabelValue    string                 `yaml:"labelValue"`
	Operator      *grafanaOperatorConfig `yaml:"operator,omitempty"`
	Datasource    string                 `yaml:"datasource"`
	DatasourceUID string                 `yaml:"datasourceUID"`
}

type dashboardsCommonConfig struct {
	Grafana     grafanaConfig     `yaml:"grafana"`
	Labels      map[string]string `yaml:"labels,omitempty"`
	Annotations map[string]string `yaml:"annotations,omitempty"`
}

type dashboardsConfig struct {
	Common     dashboardsCommonConfig       `yaml:"common"`
	Dashboards map[string]dashboardOverride `yaml:"dashboards,omitempty"`
	Sources    []source                     `yaml:"sources"`
}

type grafanaOperatorConfig struct {
	Spec map[string]any `yaml:"spec"`
}

type source struct {
	URL     string `yaml:"url"`
	Enabled *bool  `yaml:"enabled,omitempty"`
}

type ruleOverride struct {
	Enabled *bool `yaml:"enabled,omitempty"`
	Spec    rule  `yaml:"spec"`
}

// labelRewrite is keyed in LabelRewrites by an identifier; if Name is empty,
// that key doubles as the label to rewrite.
type labelRewrite struct {
	Name  string `yaml:"name,omitempty"`
	Match string `yaml:"match"`
	Value string `yaml:"value"`
}

type groupOverride struct {
	Enabled            *bool                   `yaml:"enabled,omitempty"`
	Spec               ruleGroup               `yaml:"spec,omitempty"`
	ExtraGroupByLabels []string                `yaml:"extraGroupByLabels,omitempty"`
	JobNamespaces      map[string]string       `yaml:"jobNamespaces,omitempty"` // Deprecated: use LabelRewrites targeting "namespace" instead.
	LabelRewrites      map[string]labelRewrite `yaml:"labelRewrites,omitempty"`
	Rule               ruleOverride            `yaml:"rule,omitempty"`
	Alerting           ruleOverride            `yaml:"alerting,omitempty"`
	Recording          ruleOverride            `yaml:"recording,omitempty"`
	Rules              map[string]ruleOverride `yaml:"rules,omitempty"`
}

type rulesCommonConfig struct {
	ExtraGroupByLabels []string                `yaml:"extraGroupByLabels,omitempty"`
	JobNamespaces      map[string]string       `yaml:"jobNamespaces,omitempty"` // Deprecated: use LabelRewrites targeting "namespace" instead.
	LabelRewrites      map[string]labelRewrite `yaml:"labelRewrites,omitempty"`
	RunbookURL         string                  `yaml:"runbookUrl"`
	GrafanaURL         string                  `yaml:"grafanaUrl"`
	Labels             map[string]string       `yaml:"labels,omitempty"`
	Annotations        map[string]string       `yaml:"annotations,omitempty"`
	Group              groupOverride           `yaml:"group,omitempty"`
	Rule               ruleOverride            `yaml:"rule,omitempty"`
	Alerting           ruleOverride            `yaml:"alerting,omitempty"`
	Recording          ruleOverride            `yaml:"recording,omitempty"`
}

type rulesConfig struct {
	Common  rulesCommonConfig        `yaml:"common"`
	Rules   map[string]ruleOverride  `yaml:"rules,omitempty"`
	Groups  map[string]groupOverride `yaml:"groups,omitempty"`
	Sources []source                 `yaml:"sources"`
}

func loadConfig(path string) (*config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config: %w", err)
	}
	var cfg config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parse config: %w", err)
	}
	if cfg.Common.ClusterLabel == "" {
		cfg.Common.ClusterLabel = "cluster"
	}
	for name, dc := range cfg.Dashboards.Dashboards {
		if dc.ClusterMetric != "" {
			log.Printf("dashboards.dashboards.%s.clusterMetric is deprecated, use variables.%s.query instead", name, cfg.Common.ClusterLabel)
		}
	}
	if cfg.Dashboards.Common.Grafana.Datasource == "" {
		cfg.Dashboards.Common.Grafana.Datasource = "prometheus"
	}
	if cfg.Dashboards.Common.Grafana.DatasourceUID == "" {
		cfg.Dashboards.Common.Grafana.DatasourceUID = cfg.Dashboards.Common.Grafana.Datasource
	}
	if cfg.Dashboards.Common.Grafana.LabelName == "" {
		cfg.Dashboards.Common.Grafana.LabelName = "grafana_dashboard"
	}
	if cfg.Dashboards.Common.Grafana.LabelValue == "" {
		cfg.Dashboards.Common.Grafana.LabelValue = "1"
	}
	return &cfg, nil
}
