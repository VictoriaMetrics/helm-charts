package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

func main() {
	configPath := envOrDefault("CONFIG", "/etc/config/config.yaml")
	namespace := envOrDefault("NAMESPACE", "default")
	instance := os.Getenv("RELEASE")
	resourcePrefix := envOrDefault("RESOURCE_PREFIX", instance)
	prune := envOrDefault("PRUNE", "true") != "false"
	useOwnerRef := envOrDefault("OWNER_REFERENCES", "true") != "false"

	cfg, err := loadConfig(configPath)
	if err != nil {
		log.Fatalf("load config: %v", err)
	}

	kube, err := newKubeClient(namespace, instance, resourcePrefix)
	if err != nil {
		log.Fatalf("create kube client: %v", err)
	}

	if useOwnerRef {
		saName := os.Getenv("SERVICE_ACCOUNT")
		if err := kube.resolveOwnerRef(context.Background(), saName); err != nil {
			log.Printf("warning: cannot resolve service account %q for owner references: %v", saName, err)
		}
	}

	if err := run(context.Background(), kube, cfg, prune); err != nil {
		log.Fatalf("sync: %v", err)
	}
	log.Println("sync complete")
}

func run(ctx context.Context, kube *kubeClient, cfg *config, prune bool) error {
	allURLs := make(map[string]struct{})
	for _, src := range cfg.Dashboards.Sources {
		if src.Enabled == nil || *src.Enabled {
			allURLs[src.URL] = struct{}{}
		}
	}
	for _, src := range cfg.Rules.Sources {
		if src.Enabled == nil || *src.Enabled {
			allURLs[src.URL] = struct{}{}
		}
	}

	rawByURL := make(map[string][]byte, len(allURLs))
	for url := range allURLs {
		data, err := fetch(url)
		if err != nil {
			log.Printf("fetch %q: %v", url, err)
			continue
		}
		rawByURL[url] = data
	}

	if len(cfg.Dashboards.Sources) > 0 {
		if err := reconcileDashboards(ctx, kube, &cfg.Dashboards, cfg.Common, rawByURL, prune); err != nil {
			return fmt.Errorf("dashboards: %w", err)
		}
	}
	if len(cfg.Rules.Sources) > 0 {
		if err := reconcileRules(ctx, kube, &cfg.Rules, cfg.Common, rawByURL, prune); err != nil {
			return fmt.Errorf("rules: %w", err)
		}
	}
	return nil
}

func fetch(rawURL string) ([]byte, error) {
	if strings.HasPrefix(rawURL, "./") || strings.HasPrefix(rawURL, "/") {
		return os.ReadFile(rawURL)
	}
	var lastErr error
	for i := 0; i < 3; i++ {
		if i > 0 {
			time.Sleep(time.Duration(1<<uint(i)) * time.Second)
		}
		data, retry, err := fetchOnce(rawURL)
		if err == nil {
			return data, nil
		}
		lastErr = err
		if !retry {
			break
		}
	}
	return nil, lastErr
}

func fetchOnce(rawURL string) ([]byte, bool, error) {
	resp, err := http.Get(rawURL) //nolint:noctx
	if err != nil {
		return nil, true, err
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusOK {
		data, err := io.ReadAll(resp.Body)
		return data, false, err
	}
	if resp.StatusCode >= 500 {
		return nil, true, fmt.Errorf("HTTP %d", resp.StatusCode)
	}
	return nil, false, fmt.Errorf("HTTP %d", resp.StatusCode)
}

func envOrDefault(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
