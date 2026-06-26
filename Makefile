.DEFAULT_GOAL := check

.PHONY: __repository-make-authority audit authority-test build check lint test test-checkout-workflow-policy verify
.SECONDEXPANSION:

override SHELL := /bin/sh
override .SHELLFLAGS := -c
override NPM := npm
ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPOSITORY_MAKEFILE := $(value MAKEFILE_LIST)
override EXPECTED_MAKEFILE_LIST := $(value MAKEFILE_LIST)
override CURRENT_MAKEFILE_LIST = $(value MAKEFILE_LIST)
export REPOSITORY_MAKEFILE EXPECTED_MAKEFILE_LIST CURRENT_MAKEFILE_LIST
override ROOT :=

audit authority-test build check lint test test-checkout-workflow-policy verify:: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
audit authority-test build check lint test test-checkout-workflow-policy verify:: __repository-make-authority

__repository-make-authority::
	@if [ "$$CURRENT_MAKEFILE_LIST" != "$$EXPECTED_MAKEFILE_LIST" ]; then \
		printf '%s\n' 'multiple -f Makefiles are not supported' >&2; \
		exit 1; \
	fi

override define RUN_IN_REPO
if [ "$$CURRENT_MAKEFILE_LIST" != "$$EXPECTED_MAKEFILE_LIST" ]; then \
	printf '%s\n' 'multiple -f Makefiles are not supported' >&2; \
	exit 1; \
fi; \
makefile=$${REPOSITORY_MAKEFILE# }; \
if [ -z "$$makefile" ] || [ ! -f "$$makefile" ]; then \
	printf '%s\n' 'repository Makefile path could not be resolved' >&2; \
	exit 1; \
fi; \
case "$$makefile" in \
	*/*) repository_directory=$${makefile%/*} ;; \
	*) repository_directory=. ;; \
esac; \
ROOT=$$(CDPATH= cd -- "$$repository_directory" && pwd -P); \
export ROOT; \
cd "$$ROOT" &&
endef

lint::
	@$(RUN_IN_REPO) $(NPM) run lint

test::
	@$(RUN_IN_REPO) $(NPM) test

build::
	@$(RUN_IN_REPO) $(NPM) run build

audit::
	@$(RUN_IN_REPO) $(NPM) audit --audit-level=moderate

test-checkout-workflow-policy::
	@$(RUN_IN_REPO) /bin/sh scripts/test-checkout-workflow-policy.sh

authority-test::
	@$(RUN_IN_REPO) /bin/sh scripts/test-makefile-authority.sh

verify:: authority-test test test-checkout-workflow-policy

check:: verify
