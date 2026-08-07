package test

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"sigs.k8s.io/yaml"
)

func TestMain(m *testing.M) {
	workdir, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	cacheDir := filepath.Join(workdir, ".cache")
	os.Setenv("HELM_CACHE_HOME", cacheDir) //nolint:errcheck
	chartsDir := filepath.Join(filepath.Dir(workdir), "charts")
	entries, err := os.ReadDir(chartsDir)
	if err != nil {
		panic(err)
	}
	commonDir := filepath.Join(chartsDir, "victoria-metrics-common")
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		chartDir := filepath.Join(chartsDir, e.Name())
		cmd := exec.Command("helm", "dep", "build", chartDir)
		cmd.Env = append(os.Environ(), "HELM_CACHE_HOME="+cacheDir)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Run() //nolint:errcheck // charts with local-only deps (crds) return non-zero; ignore
		if !dependsOnCommon(chartDir) {
			continue
		}
		bundled, err := filepath.Glob(filepath.Join(chartDir, "charts", "victoria-metrics-common-*.tgz"))
		if err != nil {
			panic(err)
		}
		for _, f := range bundled {
			if err := os.Remove(f); err != nil {
				panic(err)
			}
		}
		cmd = exec.Command("helm", "package", commonDir, "-d", filepath.Join(chartDir, "charts"))
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			panic(err)
		}
	}
	os.Exit(m.Run())
}

func dependsOnCommon(chartDir string) bool {
	data, err := os.ReadFile(filepath.Join(chartDir, "Chart.yaml"))
	if err != nil {
		panic(err)
	}
	var chart struct {
		Dependencies []struct {
			Name string `json:"name"`
		} `json:"dependencies"`
	}
	if err := yaml.Unmarshal(data, &chart); err != nil {
		panic(err)
	}
	for _, d := range chart.Dependencies {
		if d.Name == "victoria-metrics-common" {
			return true
		}
	}
	return false
}
