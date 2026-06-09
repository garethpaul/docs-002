.PHONY: lint test build audit verify check

NPM ?= npm

lint:
	$(NPM) run lint

test:
	$(NPM) test

build:
	$(NPM) run build

audit:
	$(NPM) audit --audit-level=high

verify: test

check: verify
