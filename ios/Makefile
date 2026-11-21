# iOS checks and tasks. Run from ios/. See ios/AGENTS.md.

PROJECT   := KiwiTracker.xcodeproj
SCHEME    := KiwiTracker
SIMULATOR ?= iPhone 17 Pro
DB_TYPES  := KiwiKit/Sources/KiwiData/Generated/DatabaseTypes.swift

.PHONY: format format-check build test db-types

format:
	swift format format --in-place --recursive --parallel .

format-check:
	swift format lint --strict --recursive --parallel .

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR)' -quiet build

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR)' -quiet test

# Regenerates the Supabase row types from the local stack's schema.
# Pinned to CLI 2.121.0: later CLIs emit supabase-swift v3 `@Table` types, and
# KiwiData is on v2 (docs/architecture.md#ios-app).
SUPABASE_TYPEGEN_CLI := npx --yes supabase@2.121.0

db-types:
	mkdir -p KiwiKit/.build
	$(SUPABASE_TYPEGEN_CLI) gen types --lang swift --schema public --workdir .. > KiwiKit/.build/DatabaseTypes.swift
	mv KiwiKit/.build/DatabaseTypes.swift $(DB_TYPES)
	swift format format --in-place $(DB_TYPES)
