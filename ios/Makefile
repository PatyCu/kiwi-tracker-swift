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
		-destination 'generic/platform=iOS Simulator' -quiet build

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR)' -quiet test

# Regenerates the Supabase row types from the local stack's schema.
db-types:
	supabase gen types --lang swift --local --schema public --workdir .. > $(DB_TYPES)
	swift format format --in-place $(DB_TYPES)
