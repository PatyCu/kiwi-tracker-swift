# Pet photos

### PHOTO-001: The details sheet shows the Pet's photo
Status: draft
Migration: same
Source: src/modules/pets/ui/PetProfileModal.tsx

The details sheet shows the Pet's photo with "Change photo", or a camera placeholder with "Add photo", above the name.

### PHOTO-002: A photo is picked from the library without permission
Status: draft
Migration: changed
Source: src/modules/pets/media/pickPetPhoto.ts

Tapping the photo opens the system photo picker, with no library permission prompt.
Note: the reference asks for access and has a "Photo access needed" alert.

### PHOTO-003: Cancelling the picker changes nothing
Status: draft
Migration: same
Source: src/modules/pets/media/pickPetPhoto.ts

Closing the photo picker without choosing leaves the sheet as it was.

### PHOTO-004: A picked photo shows at once as stored
Status: draft
Migration: changed
Source: src/modules/pets/media/pickPetPhoto.ts

A picked photo shows in the sheet straight away, cropped to its centre square, exactly as it will be stored.
Note: the reference lets the Member move a square crop.

### PHOTO-005: A photo that can't be read is reported
Status: draft
Migration: same
Source: src/modules/pets/media/pickPetPhoto.ts

A picked photo that can't be read shows "Photo not selected" with "The photo library could not be opened. Please try again." and leaves the sheet as it was.

### PHOTO-006: Only the last picked photo is saved
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

Picking another photo before saving replaces the earlier pick.

### PHOTO-007: Cancel discards a picked photo
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

Cancel or swiping the sheet down discards a picked photo, and reopening the sheet shows the stored one.

### PHOTO-008: A photo is stored as a 512px square JPEG
Status: draft
Migration: same
Source: src/modules/pets/media/preparePetPhotoUpload.ts

A stored photo is a JPEG of the picked photo's centre square, scaled down to 512px on its side.

### PHOTO-009: A small photo is never scaled up
Status: draft
Migration: same
Source: src/modules/pets/media/preparePetPhotoUpload.ts

A photo whose shorter side is under 512px is stored as its centre square at that size.

### PHOTO-010: A stored photo carries no location
Status: draft
Migration: new
Source: decision

A stored photo carries no location or camera metadata from the original.

### PHOTO-011: Each new photo gets its own file
Status: draft
Migration: same
Source: src/modules/pets/persistence/petPhotoStore.ts

Every new photo is stored as a new file in its Pet's folder, never overwriting another, so both apps can read it.

### PHOTO-012: A Pet and its photo save from one tap
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

"Add" or "Save" stores the Pet's details first, then its picked photo.

### PHOTO-013: A failed details save uploads no photo
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

When the Pet's details can't be saved, no photo is uploaded.

### PHOTO-014: A photo that fails alone doesn't block the Pet
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

When the Pet saves but its photo doesn't, the sheet closes and shows "Photo not saved" with "‹name› was saved, but the photo could not be uploaded. Edit the pet to try again."

### PHOTO-015: Saving without a new photo keeps the stored one
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

Saving a Pet's details without picking a photo keeps its stored photo.

### PHOTO-016: A Pet never points to a missing photo
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

When a new photo uploads but the Pet can't be pointed to it, the Pet keeps its previous photo and the new file is deleted.

### PHOTO-017: A replaced photo's file is deleted
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

Once a Pet points to its new photo, the file it replaced is deleted.

### PHOTO-018: A photo saves even when its old file stays
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

A new photo is saved even when the file it replaces can't be deleted.

### PHOTO-019: Selector cards show the Pet's photo
Status: draft
Migration: same
Source: src/modules/pets/ui/PetAvatar.tsx

Each selector card shows its Pet's photo, or the paw when it has none.

### PHOTO-020: A just-saved photo shows without a download
Status: draft
Migration: same
Source: src/modules/pets/media/petPhotoCache.ts

A Pet just saved with a new photo shows it straight away, without downloading it.

### PHOTO-021: A photo is downloaded once per device
Status: draft
Migration: same
Source: src/modules/pets/media/petPhotoCache.ts

A photo shown once on this device shows again, including after a relaunch, without downloading it.

### PHOTO-022: A changed photo shows on the next load
Status: draft
Migration: same
Source: src/modules/pets/media/petPhotoCache.ts

A photo changed on another device shows the next time the Pets load.

### PHOTO-023: A photo that can't be fetched shows the paw
Status: draft
Migration: same
Source: src/modules/pets/media/petPhotoCache.ts

A Pet whose photo can't be fetched shows the paw with no error, and the next load tries again.

### PHOTO-024: Signing out clears photos from the device
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

Signing out removes the Pets' photos from the device, and a failed sign-out keeps them.

### PHOTO-025: Photos are read with the Pet's name
Status: draft
Migration: same
Source: src/modules/pets/ui/PetAvatar.tsx

VoiceOver reads a Pet's photo as "‹name› photo" and the paw as "‹name› avatar".

### PHOTO-026: Members manage their Household's Pet photos
Status: draft
Migration: same
Source: supabase/migrations

A Member can read, upload, replace and delete photos only in the folders of their Household's Pets.

### PHOTO-027: Outsiders can't reach a Household's Pet photos
Status: draft
Migration: same
Source: supabase/migrations

A Member of another Household can't read, upload, replace or delete a Household's Pet photos.

### PHOTO-028: Signed-out people can't reach any Pet photo
Status: draft
Migration: same
Source: supabase/migrations

A signed-out person can't read, upload, replace or delete any Pet photo.

### PHOTO-029: Photos keep showing while the app stays open
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

A Pet's photo keeps showing when the app stays open for more than an hour.

### PHOTO-030: Photo links that fail are retried a minute later
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

When the photos' links can't be fetched, the Pets show without them and the app tries again a minute later, without a reload.

### PHOTO-031: A photo link works for an hour at most
Status: draft
Migration: same
Source: src/modules/pets/persistence/petPhotoStore.ts

A link the app gets to show a photo opens it for at most an hour.

### PHOTO-032: A photo that can't be prepared saves nothing
Status: draft
Migration: same
Source: src/modules/pets/profile/savePetProfile.ts

When a picked photo can't be converted for storing, neither the Pet nor its photo is saved and the "Pet not added" or "Pet not updated" alert shows.

### PHOTO-033: An ended Session clears photos too
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

When a Session ends without signing out, such as one that can't refresh, the Pets' photos are removed from the device.

### PHOTO-034: The photo store takes only images up to 5 MB
Status: draft
Migration: same
Source: supabase/migrations

The server refuses a photo file over 5 MB, or one that isn't a JPEG, PNG, WebP or HEIC image.
