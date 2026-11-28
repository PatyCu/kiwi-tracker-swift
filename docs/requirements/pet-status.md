# Health status

### STAT-001: A Pet with nothing recent is green
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Pet with no Symptom in the last 7 days and no Diet change in the last 7 days is green, with "Everything looks calm." and "No recent symptoms or changes to review."

### STAT-002: A recent Symptom makes a Pet red
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Symptom logged today or up to 3 days ago makes its Pet red.

### STAT-003: A red Pet needs attention
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A red Pet reads "Something needs your attention." and lists each of those Symptoms as "‹symptom› was logged ‹when›."
Note: a Symptom of kind Other reads "Other was logged today."; possible bug, confirm

### STAT-004: Red outranks amber
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

While a Pet is red, its amber reasons, such as a Diet change, aren't listed.

### STAT-005: An older Symptom makes a Pet amber
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Symptom logged 4 to 7 days ago makes its Pet amber, unless something makes it red.

### STAT-006: A recent Diet change makes a Pet amber
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Diet change logged today or up to 7 days ago makes its Pet amber, unless something makes it red.

### STAT-007: An amber Pet is one to keep an eye on
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

An amber Pet reads "Something to keep an eye on." and lists each amber reason, a Diet change as "Diet changed ‹when›. Keep an eye out for new symptoms."

### STAT-008: Events older than 7 days don't count
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Symptom or Diet change logged 8 or more days ago doesn't affect its Pet's status.

### STAT-009: Other events never affect status
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Pet event of kind Other never changes its Pet's status, however recent.

### STAT-010: Only a Pet's own events count
Status: draft
Migration: same
Source: src/modules/today/buildTodayViewModel.ts

A Pet's status comes only from the Pet events logged about that Pet.

### STAT-011: Reasons are listed most recent first
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A status's reasons are listed from the most recent Pet event to the oldest.

### STAT-012: Reasons at the same moment keep a fixed order
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

Reasons logged at the same moment are listed in the same order every time.

### STAT-013: Each logged event is its own reason
Status: draft
Migration: same
Source: src/modules/today/ui/TodayScreen.test.tsx

Two Pet events with the same wording on the same day are listed as two lines.

### STAT-014: An event received twice is listed once
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

The same Pet event delivered twice in one load is counted and listed once.

### STAT-015: When reads today, 1 day ago or N days ago
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A reason's ‹when› reads "today", "1 day ago" or "‹N› days ago".

### STAT-016: Days are calendar days, not 24-hour spans
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

Days ago counts calendar days, so an event from 23:00 yesterday is "1 day ago" at 01:00 today.

### STAT-017: Days follow the device's time zone
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

Calendar days are those of the device's current time zone, so Members in different time zones can see different statuses for the same Pet.

### STAT-018: Events later than now don't count yet
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Pet event whose time is after now, even later today, doesn't affect status until that time has passed.

### STAT-019: An event with an unreadable date is ignored
Status: draft
Migration: same
Source: src/modules/pet-status/calculatePetStatus.ts

A Pet event whose date can't be read doesn't affect status.

### STAT-020: The status colour is shown on a heart
Status: draft
Migration: same
Source: src/modules/pet-status/getPetStatusColor.ts

The status indicator is a heart in a ring, both in the status's colour: coral for red, amber for amber and kiwi green for green.
