HELM_IMAGE = alpine/helm:3.15.3
HELM_DOCS_IMAGE = jnorwood/helm-docs:v1.14.144
CT_IMAGE = quay.io/helmpack/chart-testing:v3.11.0
HELM?=helm-docker
CT?=ct-docker
CONTAINER_TOOL ?= docker
REPODIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
WORKDIR := $(REPODIR)/..

include $(shell find hack -name Makefile)

ifeq ($(CONTAINER_TOOL),docker)
    CONTAINER_USER_OPTION = --user $(shell id -u):$(shell id -g)
    CONTAINER_VOLUME_OPTION_SUFFIX =
else
    ifeq ($(CONTAINER_TOOL),podman)
        CONTAINER_USER_OPTION =
        CONTAINER_VOLUME_OPTION_SUFFIX = :z
    else
        $(error CONTAINER values currently supported are: docker, podman)
    endif
endif

helm-docker:
	mkdir -p .helm/cache
	$(CONTAINER_TOOL) run --rm --name helm-exec  \
		$(CONTAINER_USER_OPTION) \
		--volume "$(PWD):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		--volume "$(PWD)/.github/ci/helm-repos.yaml:/helm-charts/.helm/config/repositories.yaml$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
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
	$(CONTAINER_TOOL) run --rm --name helm-exec  \
		$(CONTAINER_USER_OPTION) \
		--volume "$(PWD):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		--volume "$(PWD)/.github/ci/helm-repos.yaml:/helm-charts/.helm/config/repositories.yaml$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
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
		CMD="dep build charts/$(chart)" $(MAKE) $(HELM) || exit 1; \
		CMD="lint charts/$(chart) -f $(values)" $(MAKE) $(HELM) || exit 1; \
	)

update: helm-repo-update
	$(foreach values,$(wildcard hack/helm/*/lint/*.yaml), \
		$(eval chart := $(word 3, $(subst /, ,$(values)))) \
		CMD="dep update charts/$(chart)" $(MAKE) $(HELM) || exit 1; \
        )

# Run template for helm charts
template: helm-repo-update
	$(foreach values,$(wildcard hack/helm/*/lint/*.yaml), \
		$(eval chart := $(word 3, $(subst /, ,$(values)))) \
		CMD="dep build charts/$(chart)" $(MAKE) $(HELM) || exit 1; \
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

gen-docs:
	$(CONTAINER_TOOL) build $(PWD)/hack/docs \
		-t $(HELM_DOCS_IMAGE) && \
	$(CONTAINER_TOOL) run --rm \
		$(CONTAINER_USER_OPTION) \
		--volume "$(PWD):/helm-charts$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		-w /helm-charts \
                --entrypoint /bin/helm-docs \
		$(HELM_DOCS_IMAGE) \
		-t hack/docs/template.tmpl -t README.md.gotmpl

docs-image:
	if [ ! -d $(WORKDIR)/vmdocs ]; then \
		git clone --depth 1 git@github.com:VictoriaMetrics/vmdocs $(WORKDIR)/vmdocs; \
	fi; \
	cd $(WORKDIR)/vmdocs && \
	git checkout main && \
	git pull origin main && \
	cd $(REPODIR) && \
	$(CONTAINER_TOOL) build \
		-t vmdocs \
		$(WORKDIR)/vmdocs

docs-debug: gen-docs docs-image
	$(CONTAINER_TOOL) run \
		--rm \
		--name vmdocs \
		-p 1313:1313 \
		-v ./:/opt/docs/content/helm \
		$(foreach chart,$(wildcard charts/*), -v ./$(chart):/opt/docs/content/helm/$(basename $(chart))) \
		vmdocs

docs-images-to-webp: docs-image
	$(CONTAINER_TOOL) run \
		--rm \
		--entrypoint /usr/bin/find \
		--name vmdocs \
		-v ./:/opt/docs/content/helm \
                $(foreach chart,$(wildcard charts/*), -v ./$(chart):/opt/docs/content/helm/$(basename $(chart))) \
		vmdocs \
			content/helm \
				-regex ".*\.\(png\|jpg\|jpeg\)" \
				-exec sh -c 'cwebp -preset drawing -m 6 -o $$(echo {} | cut -f-1 -d.).webp {} && rm -rf {}' {} \;
