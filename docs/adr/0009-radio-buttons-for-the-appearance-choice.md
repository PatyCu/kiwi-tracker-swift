# Radio buttons for the Appearance choice

Settings' Appearance section on iOS keeps the reference app's radio buttons, one
row per choice (System, Light, Dark), and adds an icon to each, instead of a
native checkmark list or segmented control. A prototype compared the native
options; the developer wanted an icon with each name, which a native segment
can't draw (it shows an image or text, not both), and chose the radio rows. The
cost is a custom control to maintain: its selected state, VoiceOver traits and
Dynamic Type sizing are this app's code rather than the system's. The variants
are on the branch `prototype/appearance-variants`.
