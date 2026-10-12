# BoardPocket - common tasks
#
# Run `make help` to see everything available.

FLUTTER ?= flutter
DART    ?= dart

# Extra flags forwarded to any target, e.g. `make run ARGS="-d chrome"`.
ARGS ?=

# Chromium inside a container/distrobox normally needs --no-sandbox, and a
# small /dev/shm needs --disable-dev-shm-usage. Set CHROME_FLAGS="" to pass
# none. If the binary is not on PATH, point CHROME_EXECUTABLE at it, e.g.
#   make run-web CHROME_EXECUTABLE=/usr/bin/chromium
CHROME_FLAGS ?= --no-sandbox --disable-dev-shm-usage

# Assembled in a variable so no target emits a dangling line continuation.
WEB_FLAGS = $(if $(strip $(CHROME_FLAGS)),--web-browser-flag="$(CHROME_FLAGS)") $(ARGS)

# Release signing reads these from android/.env or the environment.
ANDROID_APP_ID ?= com.oda2.boardpocket

.DEFAULT_GOAL := help
.PHONY: help deps outdated format format-check lint lint-strict analyze test \
        test-watch coverage run run-web build-android build-apk \
        build-appbundle build-ios build-web build-all clean clean-build doctor ci

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

## --- Setup -----------------------------------------------------------------

deps: ## Download dependencies
	$(FLUTTER) pub get

outdated: ## Show outdated dependencies
	$(FLUTTER) pub outdated

doctor: ## Check the local Flutter/Android/iOS toolchain
	$(FLUTTER) doctor -v

## --- Code quality ----------------------------------------------------------

format: ## Format the code
	$(DART) format lib test

format-check: ## Fail if the code is not formatted
	@echo "Note: the Dart formatter changes style between SDK releases, so this"
	@echo "can flag untouched files after a Flutter upgrade. Run 'make format'"
	@echo "once and commit the result."
	$(DART) format --output=none --set-exit-if-changed lib test

lint: analyze ## Alias for `analyze`

# Fails only on errors. The project carries a backlog of warnings and infos, so
# treating those as fatal would make this unusable as a gate. Use `lint-strict`
# when you actually want to work through the backlog.
analyze: ## Static analysis; fails only on errors
	$(FLUTTER) analyze --no-fatal-warnings --no-fatal-infos

lint-strict: ## Static analysis; fails on warnings and infos too
	$(FLUTTER) analyze

## --- Tests -----------------------------------------------------------------

test: ## Run every test
	$(FLUTTER) test

test-watch: ## Run tests in watch mode
	$(FLUTTER) test --watch

coverage: ## Run tests with coverage and print the summary
	$(FLUTTER) test --coverage
	@echo ""
	@echo "lcov report: coverage/lcov.info"
	@echo "html report: run 'genhtml coverage/lcov.info -o coverage/html' (needs lcov)"

## --- Run -------------------------------------------------------------------

run: ## Run the app (add `ARGS="-d chrome"` to pick a device)
	$(FLUTTER) run $(ARGS)

run-web: ## Run in Chrome with hot reload (CHROME_FLAGS="" to drop container flags)
	$(FLUTTER) run -d chrome $(WEB_FLAGS)

## --- Build -----------------------------------------------------------------

build-android: build-apk build-appbundle ## Build Android APK and App Bundle

build-apk: ## Build a debug Android APK
	$(FLUTTER) build apk --debug $(ARGS)

build-appbundle: ## Build a release Android App Bundle (Play Store)
	$(FLUTTER) build appbundle --release $(ARGS)

build-ios: ## Build a release iOS app (requires macOS + Xcode + signing)
	$(FLUTTER) build ios --release $(ARGS)

build-web: ## Build the release web bundle
	$(FLUTTER) build web --release $(ARGS)

build-all: build-android build-ios build-web ## Build every platform

## --- Housekeeping ----------------------------------------------------------

ci: analyze test ## Analyze + test, the same checks CI runs

clean: ## Remove build artefacts and generated files
	$(FLUTTER) clean
	rm -rf coverage build .dart_tool

clean-build: ## Remove only build artefacts
	rm -rf build
