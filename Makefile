URL=https://victoriametrics.github.io/helm-charts/
HELM_IMAGE = alpine/helm:3.15.3
HELM_DOCS_IMAGE = jnorwood/helm-docs:v1.14.2
CT_IMAGE = quay.io/helmpack/chart-testing:v3.11.0
KNOWN_TARGETS=helm
HELM?=helm-docker
CT?=ct-docker
CONTAINER ?= docker

include $(shell find charts -name Makefile)

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
	$(foreach values,$(wildcard hack/helm/*/lint/*.yaml), \
		$(eval chart := $(word 3, $(subst /, ,$(values)))) \
		CMD="dependency build charts/$(chart)" $(MAKE) $(HELM) || exit 1; \
		CMD="lint charts/$(chart) -f $(values)" $(MAKE) $(HELM) || exit 1; \
	)

# Run template for helm charts
template: helm-repo-update
	$(foreach values,$(wildcard hack/helm/*/lint/*.yaml), \
		$(eval chart := $(word 3, $(subst /, ,$(values)))) \
		CMD="dependency build charts/$(chart)" $(MAKE) $(HELM) || exit 1; \
		CMD="template charts/$(chart) -f $(values)" $(MAKE) $(HELM) || exit 1; \
	)

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
