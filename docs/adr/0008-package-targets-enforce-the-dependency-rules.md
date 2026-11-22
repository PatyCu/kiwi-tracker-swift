# Package targets enforce the dependency rules

The iOS app target only composes. The code lives in one local Swift package,
`KiwiKit`, split into `KiwiDomain`, `KiwiData`, `KiwiDesign` and
`KiwiFeatures`, and each target declares what it may import, so the compiler
rejects a dependency that points the wrong way (the Expo app relied on lint).
The cost is a package to maintain beside the Xcode project, and `public` on
everything a target shares.
