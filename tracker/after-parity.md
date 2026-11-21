# After parity

Improvements that would change the reference app's behaviour, so they wait until iOS parity (Phase 7). Phase 7 moves them to Linear with the rest of `tracker/`.

- **Remember the Appearance choice.** The reference keeps System, Light or Dark in memory only, so it resets to System on every launch; iOS matches that for parity (KIW-41). Keep the choice on the device instead, on iOS and web.
