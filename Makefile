URL=https://victoriametrics.github.io/helm-charts/
HELM_IMAGE = alpine/helm:3.11.3
HELM_DOCS_IMAGE = jnorwood/helm-docs:v1.11.0
CT_IMAGE = quay.io/helmpack/chart-testing:v3.7.1
KNOWN_TARGETS=helm
HELM?=helm-docker
CT?=ct-docker

helm-docker:
	docker run --rm --name helm-exec  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-charts \
		-w /helm-charts \
		-e HELM_CACHE_HOME=/helm-charts/.helm/cache \
		-e HELM_CONFIG_HOME=/helm-charts/.helm/config \
		-e HELM_DATA_HOME=/helm-charts/.helm/data \
		$(HELM_IMAGE) \
		$(CMD)

helm-local:
	helm \
		$(CMD)

ct-docker:
	docker run --rm --name helm-exec  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-charts \
		-w /helm-charts \
		-e HELM_CACHE_HOME=/helm-charts/.helm/cache \
		-e HELM_CONFIG_HOME=/helm-charts/.helm/config \
		-e HELM_DATA_HOME=/helm-charts/.helm/data \
		--entrypoint 'ct' \
		$(CT_IMAGE) \
		$(CMD)

ct-local:
	ct \
		$(CMD)

# Run linter for helm chart
lint:
	CMD="lint charts/victoria-metrics-cluster -f hack/vmcluster-template-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-single -f hack/vmsingle-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-gateway -f hack/vmgateway-cluster-ratelimiting-minimum.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-auth -f hack/vmauth-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-anomaly -f hack/vmanomaly-lint-hack.yaml" $(MAKE) $(HELM)

# Run template for helm charts
template:
	CMD="template charts/victoria-metrics-cluster -f hack/vmcluster-template-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-single -f hack/vmsingle-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-gateway -f hack/vmgateway-cluster-ratelimiting-minimum.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-auth -f hack/vmauth-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-anomaly -f hack/vmanomaly-lint-hack.yaml" $(MAKE) $(HELM)

lint-ct:
	CMD="lint --config .github/ci/ct.yaml --all" $(MAKE) $(CT)

lint-ct-local:
	CT="ct-local" $(MAKE) lint-ct

lint-local:
	HELM="helm-local" $(MAKE) lint

template-local:
	HELM="helm-local" $(MAKE) template


# Package chart into zip file
package:
	CMD="dependency update charts/victoria-metrics-k8s-stack" $(MAKE) $(HELM)
	CMD="package charts/* -d packages" $(MAKE) $(HELM)

# Create index file (use only for initial setup)
index:
	CMD="repo index --url ${URL} ." $(MAKE) $(HELM)

init:
	CMD="repo add prometheus-community https://prometheus-community.github.io/helm-charts" $(MAKE) $(HELM)
	CMD="repo add grafana https://grafana.github.io/helm-charts" $(MAKE) $(HELM)
	CMD="repo update" $(MAKE) $(HELM)

# Update index file add new version of package into it
merge:
	CMD="repo index --url ${URL} --merge index.yaml ." $(MAKE) $(HELM)

gen-docs:
	docker run --rm --name helm-docs  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-charts \
		-w /helm-charts \
		$(HELM_DOCS_IMAGE) \
		helm-docs
