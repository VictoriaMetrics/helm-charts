package main

import (
	"bytes"
	"context"
	"strings"
	"testing"

	"go.yaml.in/yaml/v3"
)

func newDryRunClient() *syncClient {
	var buf bytes.Buffer
	return &syncClient{
		namespace:      "monitoring",
		instance:       "test",
		resourcePrefix: "test-",
		out:            &buf,
	}
}

func parseSingleManifest(t *testing.T, out *bytes.Buffer) map[string]any {
	t.Helper()
	s := out.String()
	s = strings.TrimPrefix(s, "---\n")
	var m map[string]any
	if err := yaml.Unmarshal([]byte(s), &m); err != nil {
		t.Fatalf("unmarshal manifest: %v\nraw output:\n%s", err, out.String())
	}
	return m
}

func TestApplyConfigMapDryRun(t *testing.T) {
	kube := newDryRunClient()
	err := kube.applyConfigMap(context.Background(), "my-cm", map[string]string{"key": "value"}, nil, nil)
	if err != nil {
		t.Fatalf("applyConfigMap: %v", err)
	}

	m := parseSingleManifest(t, kube.out.(*bytes.Buffer))

	if m["apiVersion"] != "v1" {
		t.Errorf("apiVersion: got %v, want v1", m["apiVersion"])
	}
	if m["kind"] != "ConfigMap" {
		t.Errorf("kind: got %v, want ConfigMap", m["kind"])
	}
	meta, ok := m["metadata"].(map[string]any)
	if !ok {
		t.Fatalf("metadata is not a map: %T", m["metadata"])
	}
	if meta["name"] != "my-cm" {
		t.Errorf("metadata.name: got %v, want my-cm", meta["name"])
	}
	data, ok := m["data"].(map[string]any)
	if !ok {
		t.Fatalf("data is not a map: %T", m["data"])
	}
	if data["key"] != "value" {
		t.Errorf("data.key: got %v, want value", data["key"])
	}

	// Ensure Go struct field names are absent — the original bug.
	for _, badKey := range []string{"TypeMeta", "ObjectMeta"} {
		if _, exists := m[badKey]; exists {
			t.Errorf("manifest contains raw Go struct field %q — yaml marshaling is broken", badKey)
		}
	}
}

func TestApplyVMRuleDryRun(t *testing.T) {
	kube := newDryRunClient()
	spec := map[string]any{"groups": []any{map[string]any{"name": "test", "rules": []any{}}}}
	err := kube.applyVMRule(context.Background(), "my-rule", spec, nil, nil)
	if err != nil {
		t.Fatalf("applyVMRule: %v", err)
	}

	m := parseSingleManifest(t, kube.out.(*bytes.Buffer))

	if m["apiVersion"] != "operator.victoriametrics.com/v1beta1" {
		t.Errorf("apiVersion: got %v", m["apiVersion"])
	}
	if m["kind"] != "VMRule" {
		t.Errorf("kind: got %v, want VMRule", m["kind"])
	}
	meta, ok := m["metadata"].(map[string]any)
	if !ok {
		t.Fatalf("metadata is not a map: %T", m["metadata"])
	}
	if meta["name"] != "my-rule" {
		t.Errorf("metadata.name: got %v, want my-rule", meta["name"])
	}
}

func TestApplyGrafanaDashboardDryRun(t *testing.T) {
	kube := newDryRunClient()
	err := kube.applyGrafanaDashboard(context.Background(), "my-dash", `{"title":"Test"}`, nil, nil, nil)
	if err != nil {
		t.Fatalf("applyGrafanaDashboard: %v", err)
	}

	m := parseSingleManifest(t, kube.out.(*bytes.Buffer))

	if m["apiVersion"] != "grafana.integreatly.org/v1beta1" {
		t.Errorf("apiVersion: got %v", m["apiVersion"])
	}
	if m["kind"] != "GrafanaDashboard" {
		t.Errorf("kind: got %v, want GrafanaDashboard", m["kind"])
	}
}
