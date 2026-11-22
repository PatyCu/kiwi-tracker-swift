# Radio buttons for the Appearance choice

Settings' Appearance section on iOS keeps the reference app's radio buttons, one
row per choice (System, Light, Dark), and adds an icon to each, instead of a
native checkmark list, segmented control or menu. An icon beside each name was
wanted, and a native segment can't draw both (it shows an image or text). The
cost is a custom control to maintain: its selected state, VoiceOver traits and
Dynamic Type sizing are this app's code rather than the system's.
