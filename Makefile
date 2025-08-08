# Simple Makefile for metadata-handler
# Targets:
#   make help        - Show this help
#   make deps        - Install required utilities (jq, bats)
#   make deps-dev    - Install dev utilities (shellcheck) in addition to deps
#   make test        - Run Bats test suite
#   make examples    - Run examples.sh demonstration
#   make lint        - Run shellcheck if available (non-fatal if missing)
#   make check       - Run lint and tests
#   make clean       - Clean generated files

SHELL := bash
.DEFAULT_GOAL := help

PROJECT_FILES := metadata-handler examples.sh README.md tests/metadata_handler.bats

.PHONY: help deps deps-dev _install _install-dev test examples lint check clean

help:
	@echo "Available targets:"
	@echo "  make deps        - Install required utilities (jq, bats)"
	@echo "  make deps-dev    - Install dev utilities (shellcheck)"
	@echo "  make test        - Run tests (bats -r tests)"
	@echo "  make examples    - Run examples.sh"
	@echo "  make lint        - Run shellcheck if available"
	@echo "  make check       - Run lint and tests"
	@echo "  make clean       - Remove generated files"

# Detect and install packages using the available package manager
# Installs jq and bats; for dev also installs shellcheck

deps: _install

deps-dev: _install _install-dev

_install:
	@set -euo pipefail; \
	# Determine sudo availability
	SUDO=""; if [[ $$EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi; \
	# Determine package manager and install with correct package names
	if command -v apt-get >/dev/null 2>&1; then \
		$$SUDO apt-get update -y && $$SUDO apt-get install -y jq bats; \
	elif command -v dnf >/dev/null 2>&1; then \
		$$SUDO dnf install -y jq bats; \
	elif command -v yum >/dev/null 2>&1; then \
		$$SUDO yum install -y epel-release || true; \
		$$SUDO yum install -y jq bats; \
	elif command -v pacman >/dev/null 2>&1; then \
		$$SUDO pacman -Sy --noconfirm jq bats; \
	elif command -v zypper >/dev/null 2>&1; then \
		$$SUDO zypper install -y jq bats; \
	elif command -v apk >/dev/null 2>&1; then \
		$$SUDO apk add --no-cache jq bats; \
	elif command -v brew >/dev/null 2>&1; then \
		brew update && brew install jq bats-core; \
	else \
		echo "No supported package manager found. Please install: jq bats"; \
		exit 1; \
	fi; \
	echo "Dependencies installed: jq bats"

_install-dev:
	@set -euo pipefail; \
	SUDO=""; if [[ $$EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi; \
	if command -v apt-get >/dev/null 2>&1; then \
		$$SUDO apt-get update -y && $$SUDO apt-get install -y shellcheck; \
	elif command -v dnf >/dev/null 2>&1; then \
		$$SUDO dnf install -y ShellCheck; \
	elif command -v yum >/dev/null 2>&1; then \
		$$SUDO yum install -y ShellCheck; \
	elif command -v pacman >/dev/null 2>&1; then \
		$$SUDO pacman -Sy --noconfirm shellcheck; \
	elif command -v zypper >/dev/null 2>&1; then \
		$$SUDO zypper install -y ShellCheck; \
	elif command -v apk >/dev/null 2>&1; then \
		$$SUDO apk add --no-cache shellcheck; \
	elif command -v brew >/dev/null 2>&1; then \
		brew update && brew install shellcheck; \
	else \
		echo "No supported package manager found. Please install: shellcheck"; \
		exit 1; \
	fi; \
	echo "Dev dependencies installed: shellcheck"

# Run tests
# Requires: bats (installed via make deps)

test:
	@set -euo pipefail; \
	if ! command -v bats >/dev/null 2>&1; then \
		echo "bats not found. Run 'make deps' first."; \
		exit 1; \
	fi; \
	bats -r tests

# Run examples script (demo)
examples:
	@set -euo pipefail; \
	bash examples.sh

# Lint with shellcheck if present (non-fatal if missing)
lint:
	@set -euo pipefail; \
	if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -x $(PROJECT_FILES) || true; \
	else \
		echo "shellcheck not installed; run 'make deps-dev' to install (skipping lint)"; \
	fi

# Convenience target to run lint and tests
check: lint test

# Clean up generated files
clean:
	@rm -f test_metadata.json example_metadata.json metadata.json metadata_backup.json *.lock || true

