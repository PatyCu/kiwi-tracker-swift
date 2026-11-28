# iOS checks and tasks. Run from ios/. See ios/CONVENTIONS.md.

PROJECT      := KiwiTracker.xcodeproj
SCHEME       := KiwiTracker
SIMULATOR    ?= iPhone 17 Pro
DESTINATION  := platform=iOS Simulator,name=$(SIMULATOR),OS=latest
DERIVED_DATA := .build/DerivedData
TEST_RESULTS := .build/TestResults.xcresult
TEST_LOG     := .build/test.log
DB_TYPES     := KiwiKit/Sources/KiwiData/Generated/DatabaseTypes.swift

# $(SIMULATOR) on the newest iOS runtime, by UDID, so an install never lands on
# another booted simulator.
SIMULATOR_ID = $(shell xcrun simctl list devices available -j | jq -r --arg name "$(SIMULATOR)" \
	'[.devices | to_entries | sort_by(.key)[] | select(.key | test("iOS")) | .value[] | select(.name == $$name)] | last | .udid')

.PHONY: format format-check lint build test run run-shared simulator-id db-types

format:
	swift format format --in-place --recursive --parallel .

format-check:
	swift format lint --strict --recursive --parallel .

# format-check plus the mechanical rules in ios/CONVENTIONS.md.
lint: format-check
	scripts/check-conventions.sh

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet build
	@echo "Build succeeded."

# Prints compile errors (not xcodebuild's command lines), each failing test with its failure
# messages, and the pass and fail counts. The full log is in $(TEST_LOG).
test:
	@mkdir -p .build
	@rm -rf $(TEST_RESULTS)
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet \
		-resultBundlePath $(TEST_RESULTS) $(if $(ONLY),-only-testing:$(ONLY)) test > $(TEST_LOG) 2>&1; \
	status=$$?; \
	grep -E '^[^ ]+:[0-9]+:[0-9]+: error:' $(TEST_LOG) | sort -u; \
	xcrun xcresulttool get test-results tests --path $(TEST_RESULTS) 2>/dev/null | \
		jq -r '.. | objects | select(.nodeType == "Test Case" and .result == "Failed") | \
			"FAILED \(.nodeIdentifier // .name)", (.children[]? | select(.nodeType == "Failure Message") | "  \(.name)")'; \
	xcrun xcresulttool get test-results summary --path $(TEST_RESULTS) 2>/dev/null | \
		jq -r '"Tests \(.result): \(.passedTests) passed, \(.failedTests) failed, \(.skippedTests) skipped."'; \
	if [ $$status -ne 0 ] && ! grep -qiE 'error:|test failed' $(TEST_LOG); then tail -20 $(TEST_LOG); fi; \
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
# KiwiData stays on stable v2 until v3 is released.
SUPABASE_TYPEGEN_CLI := npx --yes supabase@2.121.0

db-types:
	mkdir -p KiwiKit/.build
	$(SUPABASE_TYPEGEN_CLI) gen types --lang swift --schema public --workdir .. > KiwiKit/.build/DatabaseTypes.swift
	mv KiwiKit/.build/DatabaseTypes.swift $(DB_TYPES)
	swift format format --in-place $(DB_TYPES)

simulator-id:
	@echo $(SIMULATOR_ID)
