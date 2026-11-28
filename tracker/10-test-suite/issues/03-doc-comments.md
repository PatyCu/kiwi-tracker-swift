# Rewrite the KiwiKit doc comments that mention the reference

Status: done
Blocked by: 01

Code never mentions the reference app (see the spec's "Doc comments" decision). Rewrite each doc comment in the KiwiKit sources that says "as the reference app's X" (about 36 files), so it describes what the unit does. A comment that only justified matching the reference either states the behaviour and its reason in the app's own terms, or goes. The comments are the only edits: no behaviour changes.

- [x] A grep for the reference app, Expo and the reference's file names finds nothing in `ios/KiwiKit/Sources`, or in the app target's sources.
- [x] Each rewritten comment still explains why, where the old one did.
- [x] The build and `make test` pass.
