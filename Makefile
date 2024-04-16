URL=https://victoriametrics.github.io/helm-charts/
HELM_IMAGE = alpine/helm:3.12.3
HELM_DOCS_IMAGE = jnorwood/helm-docs:v1.11.0
PYTHON_IMAGE = python:3.11.5-alpine3.18
CT_IMAGE = quay.io/helmpack/chart-testing:v3.7.1
KNOWN_TARGETS=helm
HELM?=helm-docker
CT?=ct-docker
CONTAINER ?= docker

ifeq ($(CONTAINER),docker)
    CONTAINER_USER_OPTION = --user $(shell id -u):$(shell id -g)
    CONTAINER_VOLUME_OPTION_SUFFIX =
else
    ifeq ($(CONTAINER),podman)
        CONTAINER_USER_OPTION =
        CONTAINER_VOLUME_OPTION_SUFFIX = :z
    else
        $(error CONTAINER values currently supported are: docker, podman)
    endif
endif

helm-docker:
	mkdir -p .helm/cache
	$(CONTAINER) run --rm --name helm-exec  \
		$(CONTAINER_USER_OPTION) \
		--volume "$(shell pwd):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		--volume "$(shell pwd)/.github/ci/helm-repos.yaml:/helm-charts/.helm/config/repositories.yaml$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
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
	mkdir -p .helm/cache
	$(CONTAINER) run --rm --name helm-exec  \
		$(CONTAINER_USER_OPTION) \
		--volume "$(shell pwd):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		--volume "$(shell pwd)/.github/ci/helm-repos.yaml:/helm-charts/.helm/config/repositories.yaml$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
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

helm-repo-update:
	CMD="repo update" $(MAKE) $(HELM)

# Run linter for helm chart
lint: helm-repo-update
	CMD="lint charts/victoria-metrics-cluster -f hack/vmcluster-template-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-single -f hack/vmsingle-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-gateway -f hack/vmgateway-cluster-ratelimiting-minimum.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-auth -f hack/vmauth-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-anomaly -f hack/vmanomaly-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-k8s-stack -f hack/vm-k8s-stack-template-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-distributed"  $(MAKE) $(HELM)
	CMD="dependency build charts/victoria-logs-single" $(MAKE) $(HELM)
	CMD="lint charts/victoria-logs-single -f hack/vlsingle-lint-hack.yaml" $(MAKE) $(HELM)

# Run template for helm charts
template: helm-repo-update
	CMD="template charts/victoria-metrics-cluster -f hack/vmcluster-template-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-single -f hack/vmsingle-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-gateway -f hack/vmgateway-cluster-ratelimiting-minimum.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-auth -f hack/vmauth-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-anomaly -f hack/vmanomaly-lint-hack.yaml" $(MAKE) $(HELM)
	CMD="template charts/victoria-metrics-k8s-stack -f hack/vm-k8s-stack-template-hack.yaml" $(MAKE) $(HELM)
	CMD="lint charts/victoria-metrics-distributed"  $(MAKE) $(HELM)
	CMD="dependency build charts/victoria-logs-single" $(MAKE) $(HELM)
	CMD="template charts/victoria-logs-single -f hack/vlsingle-lint-hack.yaml" $(MAKE) $(HELM)

lint-ct:
	CMD="lint --config .github/ci/ct.yaml --all" $(MAKE) $(CT)

lint-ct-local:
	CT="ct-local" $(MAKE) lint-ct

lint-local:
	HELM="helm-local" $(MAKE) lint

template-local:
	HELM="helm-local" $(MAKE) template

# DEPRECATED: use release action instead
#package-chart:
#	if [ "$(CHART)" = "victoria-metrics-k8s-stack" ]; then \
#		CMD="dependency update charts/victoria-metrics-k8s-stack" $(MAKE) $(HELM); \
#    fi; \
#    if [ "$(CHART)" = "victoria-logs-single" ]; then \
#		CMD="dependency update charts/victoria-logs-single" $(MAKE) $(HELM); \
#    fi; \
#	CMD="package charts/$(CHART) -d packages" $(MAKE) $(HELM); \
#
# DEPRECATED: use release action instead
#package-new-chart-version:
#	@VERSION=$$(grep -m 1 -o 'version: .*' charts/"$$CHART"/Chart.yaml | cut -d ' ' -f 2); \
#	FILENAME="packages/$$CHART-$$VERSION.tgz"; \
#	if ! test -f "$$FILENAME"; then \
#		$(MAKE) package-chart CHART=$$CHART; \
#	else \
#		echo "No need to package $$FILENAME already exists"; \
#	fi
#
# DEPRECATED: use release action instead
# Package chart into zip file
#package:
#	@for CHART in $$(ls charts/); do \
#  		$(MAKE) package-new-chart-version CHART=$$CHART; \
#	done

# Create index file (use only for initial setup)
#index:
#	CMD="repo index --url ${URL} ." $(MAKE) $(HELM)

init:
	CMD="repo add prometheus-community https://prometheus-community.github.io/helm-charts" $(MAKE) $(HELM)
	CMD="repo add grafana https://grafana.github.io/helm-charts" $(MAKE) $(HELM)
	CMD="repo update" $(MAKE) $(HELM)

# DEPRECATED: use release action instead
# Update index file add new version of package into it
#merge:
#	CMD="repo index --url ${URL} --merge index.yaml ." $(MAKE) $(HELM)

gen-docs:
	$(CONTAINER) run --rm \
		$(CONTAINER_USER_OPTION) \
		--volume "$(shell pwd):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		-w /helm-charts \
		$(HELM_DOCS_IMAGE) \
		helm-docs

# Synchronize alerting rules in charts/victoria-metrics-k8s-stack/templates/rules
sync-rules:
	$(CONTAINER) run --rm \
		$(CONTAINER_USER_OPTION) \
		--volume "$(shell pwd)/charts/victoria-metrics-k8s-stack:/k8s-stack$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		-w /k8s-stack/hack/ \
		$(PYTHON_IMAGE) sh -c "\
			pip3 install --no-cache-dir --no-build-isolation -r requirements.txt --user && python3 sync_rules.py \
		"

# Synchronize grafana dashboards in charts/victoria-metrics-k8s-stack/templates/grafana/dashboards
sync-dashboards:
	$(CONTAINER) run --rm \
		$(CONTAINER_USER_OPTION) \
		--volume "$(shell pwd)/charts/victoria-metrics-k8s-stack:/k8s-stack$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		-w /k8s-stack/hack/ \
		$(PYTHON_IMAGE) sh -c "\
			pip3 install --no-cache-dir --no-build-isolation -r requirements.txt --user && python3 sync_grafana_dashboards.py \
		"
