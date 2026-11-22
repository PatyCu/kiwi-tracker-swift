# iOS app agent guidance

What only agents need for the iOS app. Read the root `AGENTS.md` first. The
iOS code follows [CONVENTIONS.md](CONVENTIONS.md), including its checks.

- Prefer the Xcode MCP server (`.mcp.json`) or the simulator tools for builds, previews and launches when available; `make` is the fallback and what wrap-up runs.
- `make run` builds the `KiwiTracker` scheme (local stack) and opens it on the iPhone 17 Pro on the newest iOS runtime, by UDID; `make run-shared` does the same with `KiwiTracker Shared`, for the developer's check on the shared project. Target simulators by UDID, never `booted`: the developer may have other simulators open.
- To tap through a flow, hand it to a subagent that loads the `drive-simulator` skill.
