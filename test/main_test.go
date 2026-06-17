package test

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

func TestMain(m *testing.M) {
	workdir, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	cacheDir := filepath.Join(workdir, ".cache")
	chartsDir := filepath.Join(filepath.Dir(workdir), "charts")
	entries, err := os.ReadDir(chartsDir)
	if err != nil {
		panic(err)
	}
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		cmd := exec.Command("helm", "dep", "build", filepath.Join(chartsDir, e.Name()))
		cmd.Env = append(os.Environ(), "HELM_CACHE_HOME="+cacheDir)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Run() //nolint:errcheck // charts with local-only deps (crds) return non-zero; ignore
	}
	os.Exit(m.Run())
}
