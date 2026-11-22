# Kiwi Tracker (native)

The native iOS app and the Supabase backend of Kiwi Tracker, a pet care and
health tracker for households. This file gets it running; to change it, read
[CONTRIBUTING.md](CONTRIBUTING.md).

## Prerequisites

1. Install Xcode 27 with the iOS 27 simulator runtime (`xcodebuild -downloadPlatform iOS`).
   The app supports iOS 26; agents need iOS 27 to tap through the Simulator.
2. Install [Homebrew](https://brew.sh), then Colima (Docker runtime) and the
   Supabase CLI:

   ```bash
   brew install colima docker supabase
   ```

3. Turn on the repo's pre-commit hook, which runs `make lint`:

   ```bash
   git config core.hooksPath .githooks
   ```

## Run

1. Start the backend from the repo root. The first start downloads the Supabase
   images; every start applies the migrations and the seed, then prints the
   local URLs and keys. Studio runs at <http://127.0.0.1:54323>.

   ```bash
   colima start --cpu 4 --memory 6
   ```

   ```bash
   supabase start
   ```

   The Expo repo's stack uses the same Docker containers and ports, so stop it
   first if it's running (`supabase stop` in that folder). Stopping keeps the
   local data.

2. Open the project, pick the `KiwiTracker` scheme and an iPhone simulator,
   and press Run (⌘R). Or run `make run` in `ios/`.

   ```bash
   open ios/KiwiTracker.xcodeproj
   ```

3. Sign in as `alex@kiwi.test` with password `kiwi-local-dev`. The other seeded
   accounts, and what each one sees, are listed at the top of
   [supabase/seed.sql](supabase/seed.sql). `supabase db reset` rebuilds the
   local database and removes any account added to it by hand.

To run against the shared project instead, copy `ios/Config/Local.xcconfig` to
`ios/Config/Shared.xcconfig` (git-ignored), set the shared project's URL and
publishable key from **Project Settings → API**, and use the
`KiwiTracker Shared` scheme or `make run-shared`.

Stop with `supabase stop`, then `colima stop`.
