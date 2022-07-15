URL=https://victoriametrics.github.io/helm-charts/
HELM_IMAGE = alpine/helm:3.9.1
HELM_DOCS_IMAGE = jnorwood/helm-docs:v1.11.0
KNOWN_TARGETS=helm


helm:
	docker run --rm --name helm-exec  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-charts \
		-w /helm-charts \
		-e HELM_CACHE_HOME=/helm-charts/.helm/cache \
		-e HELM_CONFIG_HOME=/helm-charts/.helm/config \
		-e HELM_DATA_HOME=/helm-charts/.helm/data \
		$(HELM_IMAGE) \
		$(CMD)

# Run linter for helm chart
lint:
	CMD="lint charts/victoria-metrics-cluster" $(MAKE) helm
	CMD="lint charts/victoria-metrics-single" $(MAKE) helm
	CMD="lint charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml" $(MAKE) helm
	CMD="lint charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml" $(MAKE) helm
	CMD="lint charts/victoria-metrics-gateway -f hack/vmgateway-cluster-ratelimiting-minimum.yaml" $(MAKE) helm
	CMD="lint charts/victoria-metrics-auth" $(MAKE) helm

# Package chart into zip file
package:
	CMD="dependency update charts/victoria-metrics-k8s-stack" $(MAKE) helm
	CMD="package charts/* -d packages" $(MAKE) helm

# Create index file (use only for initial setup)
index:
	CMD="repo index --url ${URL} ." $(MAKE) helm

init:
	CMD="repo add prometheus-community https://prometheus-community.github.io/helm-charts" $(MAKE) helm
	CMD="repo add grafana https://grafana.github.io/helm-charts" $(MAKE) helm
	CMD="repo update" $(MAKE) helm

# Update index file add new version of package into it
merge:
	CMD="repo index --url ${URL} --merge index.yaml ." $(MAKE) helm

gen-docs:
	docker run --rm --name helm-docs  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-charts \
		-w /helm-charts \
		$(HELM_DOCS_IMAGE) \
		helm-docs

