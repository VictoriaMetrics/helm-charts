HACK_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CONTAINER ?= docker
BLACK_OPTS ?= --check

hack-image:
	$(CONTAINER) build -t k8s-stack-hack:latest $(HACK_PATH)

# Synchronize alerting rules
sync-rules: SCRIPT=sync_rules.py
sync-rules: sync

# Synchronize grafana dashboards
sync-dashboards: SCRIPT=sync_grafana_dashboards.py
sync-dashboards: sync

sync:
	$(CONTAINER) run --rm \
		$(CONTAINER_USER_OPTION) \
		--volume "$(HACK_PATH)/../:/k8s-stack$(CONTAINER_VOLUME_OPTION_SUFFIX)" \
		-w /k8s-stack/hack/ \
		k8s-stack-hack:latest sh -c "\
			python3 -m black $(BLACK_OPTS) $(SCRIPT) && \
			python3 $(SCRIPT) \
		"
