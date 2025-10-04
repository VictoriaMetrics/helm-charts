HACK_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CONTAINER ?= docker

hack-image:
	$(CONTAINER) build -t k8s-stack-hack:latest $(HACK_PATH)

# Synchronize rules and dashboards
hack: hack-image
	$(CONTAINER) run --rm \
		--volume "$(HACK_PATH)/../..:/vm" \
		-w /vm/hack/rules-and-dashboards \
		k8s-stack-hack:latest
