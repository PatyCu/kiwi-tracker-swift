# iOS checks and tasks. Run from ios/. See ios/AGENTS.md.

PROJECT      := KiwiTracker.xcodeproj
SCHEME       := KiwiTracker
SIMULATOR    ?= iPhone 17 Pro
DESTINATION  := platform=iOS Simulator,name=$(SIMULATOR),OS=latest
DERIVED_DATA := .build/DerivedData
TEST_RESULTS := .build/TestResults.xcresult
DB_TYPES     := KiwiKit/Sources/KiwiData/Generated/DatabaseTypes.swift

# $(SIMULATOR) on the newest iOS runtime, by UDID, so an install never lands on
# another booted simulator.
SIMULATOR_ID = $(shell xcrun simctl list devices available -j | jq -r --arg name "$(SIMULATOR)" \
	'[.devices | to_entries | sort_by(.key)[] | select(.key | test("iOS")) | .value[] | select(.name == $$name)] | last | .udid')

.PHONY: format format-check lint build test run run-shared db-types

format:
	swift format format --in-place --recursive --parallel .

format-check:
	swift format lint --strict --recursive --parallel .

# format-check plus the mechanical rules in ios/AGENTS.md.
lint: format-check
	scripts/check-conventions.sh

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet build
	@echo "Build succeeded."

test:
	rm -rf $(TEST_RESULTS)
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet \
		-resultBundlePath $(TEST_RESULTS) test; status=$$?; \
	xcrun xcresulttool get test-results summary --path $(TEST_RESULTS) | \
		jq -r '"Tests \(.result): \(.passedTests) passed, \(.failedTests) failed, \(.skippedTests) skipped."'; \
	exit $$status

# Builds a scheme and opens it on $(SIMULATOR): `run` uses the local stack,
# `run-shared` the shared project.
run: RUN_SCHEME := KiwiTracker
run-shared: RUN_SCHEME := KiwiTracker Shared
run run-shared:
	@udid="$(SIMULATOR_ID)"; \
	test -n "$$udid" && test "$$udid" != null || { echo "No $(SIMULATOR) simulator found."; exit 1; }; \
	xcrun simctl bootstatus "$$udid" -b >/dev/null || exit 1; \
	xcodebuild -project $(PROJECT) -scheme "$(RUN_SCHEME)" -destination "id=$$udid" \
		-derivedDataPath $(DERIVED_DATA) -quiet build || exit 1; \
	app=$$(xcodebuild -project $(PROJECT) -scheme "$(RUN_SCHEME)" -destination "id=$$udid" \
		-derivedDataPath $(DERIVED_DATA) -showBuildSettings -json 2>/dev/null | \
		jq -r '.[] | select(.target == "KiwiTracker") | .buildSettings | .TARGET_BUILD_DIR + "/" + .FULL_PRODUCT_NAME'); \
	bundle=$$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$$app/Info.plist"); \
	xcrun simctl terminate "$$udid" "$$bundle" 2>/dev/null; \
	xcrun simctl install "$$udid" "$$app" && xcrun simctl launch "$$udid" "$$bundle" >/dev/null && \
	echo "$(RUN_SCHEME) is running on $(SIMULATOR) ($$udid)."

# Regenerates the Supabase row types from the local stack's schema.
# Pinned to CLI 2.121.0: later CLIs emit supabase-swift v3 `@Table` types, and
# KiwiData is on v2 (docs/architecture.md#ios-app).
SUPABASE_TYPEGEN_CLI := npx --yes supabase@2.121.0

db-types:
	mkdir -p KiwiKit/.build
	$(SUPABASE_TYPEGEN_CLI) gen types --lang swift --schema public --workdir .. > KiwiKit/.build/DatabaseTypes.swift
	mv KiwiKit/.build/DatabaseTypes.swift $(DB_TYPES)
	swift format format --in-place $(DB_TYPES)
