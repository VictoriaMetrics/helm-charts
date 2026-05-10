package main

import (
	"context"
	"fmt"
	"log"
	"maps"
	"path/filepath"
	"slices"
	"strings"

	"github.com/VictoriaMetrics/metricsql"
	"gopkg.in/yaml.v3"
)

type ruleCRD struct {
	Spec ruleSpec `yaml:"spec"`
}

type ruleSpec struct {
	Groups []ruleGroup `yaml:"groups"`
}

type ruleGroup struct {
	Name  string         `yaml:"name"`
	Rules []rule         `yaml:"rules"`
	XXX   map[string]any `yaml:",inline"`
}

type rule struct {
	Record      string            `yaml:"record,omitempty"`
	Alert       string            `yaml:"alert,omitempty"`
	Expr        string            `yaml:"expr"`
	For         string            `yaml:"for,omitempty"`
	Labels      map[string]string `yaml:"labels,omitempty"`
	Annotations map[string]string `yaml:"annotations,omitempty"`
	XXX         map[string]any    `yaml:",inline"`
}

func reconcileRules(ctx context.Context, kube *kubeClient, cfg *rulesConfig, common commonConfig, rawByURL map[string][]byte, prune bool) error {
	existing, err := kube.listManagedVMRules(ctx)
	if err != nil {
		return fmt.Errorf("list managed vmrules: %w", err)
	}
	seen := make(map[string]bool)

	for _, src := range cfg.Sources {
		raw, ok := rawByURL[src.URL]
		if !ok {
			continue
		}
		groups, err := parseRuleGroups(raw, src.URL)
		if err != nil {
			log.Printf("parse rules from %q: %v", src.URL, err)
			continue
		}
		for _, g := range groups {
			gc, _ := lookupGroup(cfg.Groups, g.Name)
			if gc.Enabled != nil && !*gc.Enabled {
				log.Printf("skipping disabled rule group %q", g.Name)
				continue
			}
			filtered := make([]rule, 0, len(g.Rules))
			for _, r := range g.Rules {
				name := r.Alert
				if name == "" {
					name = r.Record
				}
				if ro, ok := cfg.Rules[name]; ok && ro.Enabled != nil && !*ro.Enabled {
					continue
				}
				if ro, ok := gc.Rules[name]; ok && ro.Enabled != nil && !*ro.Enabled {
					continue
				}
				filtered = append(filtered, r)
			}
			g.Rules = filtered
			patchRuleGroup(&g, cfg, common)
			vmruleName := ruleGroupVMRuleName(kube.resourcePrefix, g.Name)
			if err := kube.applyVMRule(ctx, vmruleName, ruleGroupToSpec(g, cfg.Common.Group.Spec.XXX), cfg.Common.Labels, cfg.Common.Annotations); err != nil {
				log.Printf("apply vmrule %q: %v", vmruleName, err)
				continue
			}
			log.Printf("applied vmrule %q (%d rules)", vmruleName, len(g.Rules))
			seen[vmruleName] = true
		}
	}

	if !prune {
		return nil
	}
	for _, name := range existing {
		if !seen[name] {
			if err := kube.deleteVMRule(ctx, name); err != nil {
				log.Printf("delete orphaned vmrule %q: %v", name, err)
			} else {
				log.Printf("deleted orphaned vmrule %q", name)
			}
		}
	}
	return nil
}

func parseRuleGroups(raw []byte, srcURL string) ([]ruleGroup, error) {
	raw = trimBOM(raw)
	ext := strings.ToLower(filepath.Ext(srcURL))
	switch ext {
	case ".yml", ".yaml":
		var crd ruleCRD
		if err := yaml.Unmarshal(raw, &crd); err != nil {
			return nil, fmt.Errorf("unmarshal: %w", err)
		}
		if len(crd.Spec.Groups) > 0 {
			return crd.Spec.Groups, nil
		}
		var spec ruleSpec
		if err := yaml.Unmarshal(raw, &spec); err != nil {
			return nil, fmt.Errorf("unmarshal spec: %w", err)
		}
		return spec.Groups, nil
	default:
		return nil, fmt.Errorf("unsupported extension %q for rules", ext)
	}
}

func patchRuleGroup(g *ruleGroup, cfg *rulesConfig, common commonConfig) {
	additionalLabels := cfg.Common.ExtraGroupByLabels
	jobNamespaces := cfg.Common.JobNamespaces
	if gc, ok := lookupGroup(cfg.Groups, g.Name); ok {
		if gc.ExtraGroupByLabels != nil {
			additionalLabels = gc.ExtraGroupByLabels
		}
		if len(gc.JobNamespaces) > 0 {
			merged := make(map[string]string, len(jobNamespaces)+len(gc.JobNamespaces))
			maps.Copy(merged, jobNamespaces)
			maps.Copy(merged, gc.JobNamespaces)
			jobNamespaces = merged
		}
	}
	for i := range g.Rules {
		r := &g.Rules[i]
		patchRuleAnnotations(r, cfg, common.ClusterLabel)
		r.Expr = patchRuleExpr(r.Expr, additionalLabels, common, jobNamespaces)
		applyRuleDefaults(r, cfg, g.Name)
	}
}

func applyRuleDefaults(r *rule, cfg *rulesConfig, groupName string) {
	mergeRule(r, cfg.Common.Rule.Spec)
	if r.Alert != "" {
		mergeRule(r, cfg.Common.Alerting.Spec)
	} else if r.Record != "" {
		mergeRule(r, cfg.Common.Recording.Spec)
	}
	name := r.Alert
	if name == "" {
		name = r.Record
	}
	if ro, ok := cfg.Rules[name]; ok {
		mergeRule(r, ro.Spec)
	}
	gc, _ := lookupGroup(cfg.Groups, groupName)
	mergeRule(r, gc.Rule.Spec)
	if r.Alert != "" {
		mergeRule(r, gc.Alerting.Spec)
	} else if r.Record != "" {
		mergeRule(r, gc.Recording.Spec)
	}
	if ro, ok := gc.Rules[name]; ok {
		mergeRule(r, ro.Spec)
	}
}

// lookupGroup finds a groupOverride for the given upstream group name, trying:
// 1. exact match
// 2. without the ".rules" suffix (e.g. "kubelet.rules" → "kubelet")
// 3. camelCase of the above (e.g. "kubernetes-apps" → "kubernetesApps")
func lookupGroup(groups map[string]groupOverride, name string) (groupOverride, bool) {
	if g, ok := groups[name]; ok {
		return g, true
	}
	trimmed := strings.TrimSuffix(name, ".rules")
	if trimmed != name {
		if g, ok := groups[trimmed]; ok {
			return g, true
		}
		if cc := toCamelCase(trimmed); cc != trimmed {
			if g, ok := groups[cc]; ok {
				return g, true
			}
		}
	}
	if cc := toCamelCase(name); cc != name {
		if g, ok := groups[cc]; ok {
			return g, true
		}
	}
	return groupOverride{}, false
}

// toCamelCase converts a kebab-case / dot.case / snake_case string to camelCase.
func toCamelCase(s string) string {
	parts := strings.FieldsFunc(s, func(r rune) bool {
		return r == '.' || r == '-' || r == '_'
	})
	if len(parts) <= 1 {
		return s
	}
	var b strings.Builder
	b.WriteString(parts[0])
	for _, p := range parts[1:] {
		if len(p) > 0 {
			b.WriteString(strings.ToUpper(p[:1]))
			b.WriteString(p[1:])
		}
	}
	return b.String()
}

func mergeRule(dst *rule, src rule) {
	if src.For != "" {
		dst.For = src.For
	}
	if src.Expr != "" {
		dst.Expr = src.Expr
	}
	if len(src.Labels) > 0 {
		if dst.Labels == nil {
			dst.Labels = make(map[string]string, len(src.Labels))
		}
		maps.Copy(dst.Labels, src.Labels)
	}
	if len(src.Annotations) > 0 {
		if dst.Annotations == nil {
			dst.Annotations = make(map[string]string, len(src.Annotations))
		}
		maps.Copy(dst.Annotations, src.Annotations)
	}
	if len(src.XXX) > 0 {
		if dst.XXX == nil {
			dst.XXX = make(map[string]any, len(src.XXX))
		}
		maps.Copy(dst.XXX, src.XXX)
	}
}

func patchRuleAnnotations(r *rule, cfg *rulesConfig, clusterLabel string) {
	for k, v := range r.Annotations {
		switch {
		case cfg.Common.RunbookURL != "" && strings.HasPrefix(v, "https://runbooks.prometheus-operator.dev/runbooks"):
			r.Annotations[k] = strings.ReplaceAll(v, "https://runbooks.prometheus-operator.dev/runbooks", cfg.Common.RunbookURL)
		case cfg.Common.GrafanaURL != "" && strings.HasPrefix(v, "http://localhost:3000"):
			v = strings.ReplaceAll(v, "http://localhost:3000", cfg.Common.GrafanaURL)
			r.Annotations[k] = strings.ReplaceAll(v, "$labels.cluster", "$labels."+clusterLabel)
		case strings.Contains(v, "$labels.cluster"):
			r.Annotations[k] = strings.ReplaceAll(v, "$labels.cluster", "$labels."+clusterLabel)
		}
	}
}

func patchRuleExpr(expr string, extraGroupByLabels []string, common commonConfig, jobNamespaces map[string]string) string {
	if expr == "" {
		return expr
	}
	e, err := metricsql.ParseWithVars(expr, true)
	if err != nil {
		return expr
	}

	cl := common.ClusterLabel
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
		if common.Multicluster && !found {
			m.Args = append(m.Args, cl)
		}
		for _, label := range extraGroupByLabels {
			if !slices.Contains(m.Args, label) {
				m.Args = append(m.Args, label)
			}
		}
	}

	var allGroupLabels []string
	if common.Multicluster {
		allGroupLabels = append([]string{cl}, extraGroupByLabels...)
	} else {
		allGroupLabels = extraGroupByLabels
	}

	metricsql.VisitAll(e, func(ex metricsql.Expr) {
		switch t := ex.(type) {
		case *metricsql.BinaryOpExpr:
			modifierFn(&t.JoinModifier)
			modifierFn(&t.GroupModifier)
		case *metricsql.AggrFuncExpr:
			modifierFn(&t.Modifier)
			if t.Modifier.Op == "" && len(allGroupLabels) > 0 {
				t.Modifier.Op = "by"
				t.Modifier.Args = append(t.Modifier.Args, allGroupLabels...)
			}
		case *metricsql.MetricExpr:
			if len(jobNamespaces) == 0 {
				return
			}
			for i, group := range t.LabelFilterss {
				jobValue, hasNamespace := "", false
				for _, f := range group {
					switch f.Label {
					case "job":
						if !f.IsNegative && !f.IsRegexp {
							jobValue = f.Value
						}
					case "namespace":
						hasNamespace = true
					}
				}
				if ns, ok := jobNamespaces[jobValue]; ok && !hasNamespace {
					t.LabelFilterss[i] = append(group, metricsql.LabelFilter{
						Label:    "namespace",
						Value:    ns,
						IsRegexp: true,
					})
				}
			}
		}
	})
	return string(e.AppendString(nil))
}

const maxResourceNameLen = 253

func ruleGroupVMRuleName(prefix, groupName string) string {
	name := strings.ToLower(groupName)
	name = strings.NewReplacer(".", "-", "_", "-", " ", "-").Replace(name)
	return clampResourceName(prefix + "-rule-" + name)
}

func clampResourceName(name string) string {
	if len(name) <= maxResourceNameLen {
		return name
	}
	log.Printf("warning: resource name %q truncated to %d characters", name, maxResourceNameLen)
	return name[:maxResourceNameLen]
}

func ruleGroupToSpec(g ruleGroup, groupDefaults map[string]any) map[string]any {
	rules := make([]map[string]any, 0, len(g.Rules))
	for _, r := range g.Rules {
		m := map[string]any{"expr": r.Expr}
		if r.Alert != "" {
			m["alert"] = r.Alert
		}
		if r.Record != "" {
			m["record"] = r.Record
		}
		if r.For != "" {
			m["for"] = r.For
		}
		if len(r.Labels) > 0 {
			m["labels"] = r.Labels
		}
		if len(r.Annotations) > 0 {
			m["annotations"] = r.Annotations
		}
		maps.Copy(m, r.XXX)
		rules = append(rules, m)
	}
	group := map[string]any{"name": g.Name, "rules": rules}
	maps.Copy(group, groupDefaults)
	maps.Copy(group, g.XXX)
	return map[string]any{
		"groups": []map[string]any{group},
	}
}
