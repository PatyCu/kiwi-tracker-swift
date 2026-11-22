# Native rebuild, with the Expo app as the behavior reference

Kiwi Tracker started as an Expo (React Native) app, chosen for one stack across
web and mobile. With AI-assisted development, writing code is cheap, so that
benefit no longer outweighs what React Native costs users: an experience that
isn't as good as the native one. The app is being rebuilt as a native iOS app
(SwiftUI) and then a React web app, on the same backend. The Expo app is frozen
at `c6db92f` and stays the reference until it's retired: the new apps match
what it does and says, not how it's built, since its structure follows React
and Expo Router patterns that don't carry over to native code.
