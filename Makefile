.PHONY: lint test build audit verify test-checkout-workflow-policy check

override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
NPM ?= npm

lint:
	$(NPM) --prefix $(ROOT) run lint

test:
	$(NPM) --prefix $(ROOT) test

build:
	$(NPM) --prefix $(ROOT) run build

audit:
	$(NPM) --prefix $(ROOT) audit --audit-level=moderate

test-checkout-workflow-policy:
	$(ROOT)scripts/test-checkout-workflow-policy.sh

verify: test test-checkout-workflow-policy

check: verify
