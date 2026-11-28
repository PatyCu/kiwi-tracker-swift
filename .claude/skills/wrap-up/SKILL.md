---
name: wrap-up
description: Finish the current piece of work, from final checks to a clean worktree. Validates, updates the GitHub issues and the plan, commits, pushes to main or opens a PR, confirms the shared Supabase project already has its migrations, and cleans up the branch. Use when the developer says "wrap up", "wrap it up" or "let's wrap up".
---

# Wrap up

Takes finished work from the working tree to published and cleaned up. Follow the rules in `CONTRIBUTING.md` and `AGENTS.md`; this skill only orders the steps and doesn't restate those rules.

Stop and report to the developer whenever a step fails. Don't skip ahead.

## 1. Check the work is done

- The developer's check on the shared project is done: they run it before saying "wrap up".
- Related bugs are part of done. If a bug caused by or tied to this change is still open, fix it first, or stop and ask the developer.
- Match the checks to what changed. Any failure or warning stops the wrap-up.
  - **iOS code or config** (`ios/**`: `.swift`, `.xcconfig`, project, package or asset files): run `make lint`, `make build` and `make test` in `ios/`.
  - **Supabase** (`supabase/**`: migrations, seed or tests): `supabase db reset`, `supabase db lint` and `supabase test db` pass, and after a migration the iOS row types were regenerated (`make db-types` in `ios/`).
  - **Only docs, skills or requirements** (`.md` files): no build checks apply; reread the changed files for broken links.
- Review `git status` and `git diff`. Commit only files that belong to this task. Point out unrelated or unexpected changes and leave them out unless the developer says to include them.

## 2. Update the tracker

The commit message closes the issues this work finishes (`CONTRIBUTING.md#commit`). Tick off the plan's features whose issue that closes in `docs/migration-plan.md`, and if that finishes the phase, update **Current phase**. See `docs/agents/issue-tracker.md`.

If the work touched tests or requirements, run `.claude/skills/req-coverage/scripts/req-coverage.sh`; it must pass.

## 3. Commit

One commit in the style `CONTRIBUTING.md#commit` describes (for example `feat: on iOS, edit a pet event's details from its details screen (closes #12)`). End the message with the attribution lines the environment asks for.

## 4. Publish

Check the branch with `git branch --show-current`.

- **On `main`:** push `main` following the GitHub publishing rules in `AGENTS.md`.
- **On another branch:** push the branch the same way, then open a PR against `main` with `gh pr create`. Give it a short summary of what changed and how it was validated. Don't merge it yourself; the developer reviews and merges.

## 5. Confirm the shared project has the migrations

Only when the published work adds files under `supabase/migrations/`. They were applied to the shared project during validation, so run `supabase db push --remote --dry-run`: it must list nothing. If it lists a migration, stop and tell the developer the shared project is missing it.

## 6. Clean up

Files left out of the commit in step 1 because they don't belong to this task aren't a failure. List them and ask the developer whether to commit them separately, gitignore them or leave them. Anything else left in `git status` is.

- **On `main`:** confirm `git status` is clean, apart from those left-out files, and `main` is level with `origin/main`. Done.
- **On a branch, PR not merged yet:** stop here. Give the developer the PR link and tell them to say "wrap up" again once it's merged.
- **On a branch, PR merged** (check with `gh pr view --json state,mergedAt`):
  1. Confirm `git status` is clean. If it isn't, stop and show what's left.
  2. `git switch main` and `git pull --ff-only`.
  3. Delete the local branch with `git branch -d <branch>`. If git refuses because the PR was squash-merged, confirm the PR is merged and then use `-D`.
  4. If the session runs in a worktree the app created, don't delete its branch or worktree by hand; the app cleans them up when the session is archived.

## 7. Report

Finish with a short summary: the commit hash and message, where it went (pushed to `main`, or the PR link), the issues it closed, and anything left out or still open.
