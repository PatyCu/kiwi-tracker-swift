---
name: next-task-prompt
description: Write the prompt the developer will hand to a fresh agent for the next task, carrying over this session's context. Use when the developer asks "what's next", "what's the next task" or for a prompt or handoff for the next agent.
---

# Next task prompt

Writes the prompt for the agent that picks up the next task. The developer reviews it, edits it if needed and sends it as their own message, so write it in their voice.

## 1. Check the tree is clean

Run `git status`. If it lists changes, stop: tell the developer what is uncommitted and to say "wrap up" first, so the next agent starts from a clean `main`.

## 2. Find the next task

The next task is the lowest-numbered open issue labelled `bug`; else the first open, unblocked sub-issue of the feature this session worked on; else the first unticked feature in the current phase of `docs/migration-plan.md` (its first open sub-issue, if it has an issue). Skip work this session finished. Read the issues as `docs/agents/issue-tracker.md` describes; don't edit the plan or any issue here.

If the work from this session is in an unmerged PR, say so to the developer above the prompt.

## 3. Write the prompt

Write in first person, as the developer ("I want to…", "We decided…"). Keep it short and include only what the next agent can't get from the repo, `AGENTS.md`, the tracker or git history:

- The task, named as it appears in the plan, with its issue number if it has one, and what done looks like.
- Decisions from this session that affect it, with the reason when the reason isn't obvious.
- Pitfalls found in this session: failing approaches, environment quirks, surprising behavior.
- What was deliberately left for this task or for later, so it isn't redone or pulled in early.
- Pointers to the relevant files, docs or artifacts instead of copying their content.

For each line, ask whether the next agent would lose real time or go the wrong way without it; leave it out otherwise. Base "done" on the plan's feature line, its issue and its phase's exit check; if you think it needs more scope than that says, tell the developer outside the prompt.

Leave out anything the next agent does anyway: reading `AGENTS.md`, following repo rules, running checks, syncing the tracker. The prompt carries the developer's approval, so write requested actions as approved and never add "ask me first" for something the prompt asks for. Add a stop-and-ask only for a decision the prompt really leaves open.

## 4. Share it

Give the prompt in one fenced `text` block so it can be copied as-is. Don't save it to a file.
