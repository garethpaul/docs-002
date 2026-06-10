.PHONY: lint test build audit verify check

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
NPM ?= npm

lint:
	$(NPM) --prefix $(ROOT) run lint

test:
	$(NPM) --prefix $(ROOT) test

build:
	$(NPM) --prefix $(ROOT) run build

audit:
	$(NPM) --prefix $(ROOT) audit --audit-level=moderate

verify: test

check: verify
