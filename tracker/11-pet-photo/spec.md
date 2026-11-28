# Pet photo from the library (KIW-24)

Status: in-progress

## Problem Statement

A Member can add and edit a Pet on iOS but can't give it a photo, so every Pet shows the same paw. In the reference app, the details sheet picks a photo from the library, and the Pet's photo then shows on its selector card for every Member, on iOS and in the Expo app.

## Solution

The details sheet shows the Pet's photo, or a camera placeholder, above the name, with "Add photo" or "Change photo" under it. Tapping it opens the system photo picker. The chosen photo is scaled to a 512px square JPEG and shows in the sheet at once. Saving stores the Pet first, then its photo, and the selector card on Pets shows the photo instead of the paw. Photos are kept on the device by their storage path, so each one is downloaded once, and signing out clears them. A photo stored on iOS shows in the Expo app, and the reverse.

## User Stories

1. As a Member adding a Pet, I want a camera placeholder with "Add photo" at the top of the sheet, so that I can give the Pet a photo as I add it.
2. As a Member editing a Pet with a photo, I want the sheet to show that photo with "Change photo", so that I see what's stored and can replace it.
3. As a Member editing a Pet without a photo, I want the camera placeholder with "Add photo".
4. As a Member, I want tapping the photo or its label to open the system photo picker, so that I choose from my library the way other apps do.
5. As a Member, I want to pick a photo without granting the app access to my whole library, so that the app sees only the photo I choose.
6. As a Member, I want cancelling the picker to leave the sheet as it was.
7. As a Member, I want the chosen photo shown in the sheet straight away, cropped to a square, so that I see what will be stored before saving.
8. As a Member whose chosen photo can't be read, I want the alert "Photo not selected" saying "The photo library could not be opened. Please try again.", and the sheet left as it was.
9. As a Member, I want to pick another photo before saving, so that I can change my mind; only the last one is saved.
10. As a Member, I want Cancel or swiping the sheet down to discard a picked photo, like the other changes.
11. As a Member, I want a photo stored at 512px, so that it uploads quickly and stays sharp at the sizes the app shows.
12. As a Member, I want a stored photo to carry no location or camera metadata, so that where it was taken isn't shared with the Household's storage.
13. As a Member who adds a Pet with a photo, I want the Pet and its photo saved together from one tap of "Add".
14. As a Member who saves a Pet with a new photo, I want the selector card to show the photo at once, without waiting for a download.
15. As a Member who saves a Pet without picking a photo, I want its stored photo kept as it is.
16. As a Member whose Pet saved but whose photo didn't, I want the alert "Photo not saved" saying "{name} was saved, but the photo could not be uploaded. Edit the pet to try again.", with the sheet closed, so that I never add the Pet twice.
17. As a Member whose Pet didn't save, I want no photo uploaded and the usual "Pet not added" or "Pet not updated" alert.
18. As a Member who replaces a photo, I want the Pet to keep showing its previous photo if the new one can't be recorded, so that it never points to nothing.
19. As a Member who replaces a photo, I want the file it replaces deleted, so that the Household's storage doesn't keep photos nobody sees.
20. As a Member, I want a photo saved even when its replaced file can't be deleted, since nobody sees that file.
21. As a Member, I want each Pet with a photo to show it on its selector card on Pets, and the paw otherwise.
22. As a Member using VoiceOver, I want a Pet's photo read as "{name} photo" and the paw as "{name} avatar", and the sheet's photo button read as "Add photo" or "Change photo".
23. As a Member, I want a photo shown once on this device to show again without downloading it, so that the Pets tab opens quickly and uses little data.
24. As a Member whose Pet's photo was changed on another device, I want the new photo the next time the Pets load, since a new photo has a new path.
25. As a Member, I want a Pet whose photo can't be fetched to show the paw, with no error, so that one missing photo never keeps me from my Pets; the next load tries again.
26. As a Member who signs out, I want the photos on this device cleared, so that the next Account on it can't see them.
27. As another Member of the same Household, I want a photo added on iOS to show in the Expo app, and one added there to show on iOS.
28. As a person outside a Household, I want to be unable to read, add, replace or delete its Pets' photos.
29. As a signed-out person, I want to be unable to reach any Pet's photo.
30. As a Member using Dynamic Type, I want the photo button's label to scale with the rest of the sheet.
31. As a Member in light or dark appearance, I want the camera placeholder and the paw in the app's palette.

## Implementation Decisions

- **Glossary**: a **Pet** may have a photo, and the photo is never called an avatar or a picture. Done during grilling.
- **Plan**: the feature's line no longer says "signed links", since iOS downloads photos by path. Done during grilling.
- **Schema**: no change. `pets.photo_path` exists, and the `pet-photos` bucket is private, takes JPEG up to 5 MB, and lets Members read, add, replace and delete files only in the folders of their Household's Pets (`private.accessible_pet_ids()`). The schema artifact needs no update.
- **Stored file**: matches the reference byte for byte in shape, so both apps read each other's photos and the Expo app's path-keyed cache keeps working.
  - Path `{petId}/{milliseconds since 1970}.jpg` in `pet-photos`, so every new photo has a new path. Uploading never overwrites.
  - Content type `image/jpeg`. JPEG, not HEIC, because browsers, and so the Expo web app and the later web app, can't show HEIC.
  - 512×512: the centre square of the photo, scaled down to 512px on its side, never up. The largest view is 92pt, under 300px on a 3x screen.
  - JPEG quality 0.72, with no metadata copied from the original.
- **Making the file**: ImageIO. A thumbnail sized so its shorter side is at most 512px is read straight from the picked data, applying the photo's orientation, without decoding the full-size image. Its centre square is cropped, then written with `CGImageDestination` as JPEG at 0.72 without the source's properties. It's one pure function from the picked data to the JPEG data, with a typed error for data it can't read. It runs when a photo is picked, so the sheet shows the stored result and a photo that can't be read is reported there ("Photo not selected"), not at save.
- **KiwiDomain**:
  - `Pet` gains an optional photo path: where its photo is in the Household's photo storage.
  - A new `PetPhotoStore` protocol: upload JPEG data for a Pet and return its new path, remove a path, and fetch the data at a path. Its errors are typed: could not upload, could not remove, could not fetch.
  - `PetStore` gains recording a Pet's photo path, returning the stored Pet.
- **KiwiData**:
  - `SupabasePetStore` reads `photo_path` on every load and stored row, and records a path by updating that column alone and selecting the row back, as the reference's `setPetPhotoPath`.
  - `SupabasePetPhotoStore` uploads, removes and downloads in `pet-photos` through the signed-in Session. No signed links, so no link lifetime or refresh timer.
  - The photo cache is ours, not a library's, since `URLCache` and `AsyncImage` key by URL. It wraps the photo store, keeps each photo's data by its path in the app's Caches folder, and fetches from storage only on a miss; an uploaded photo is kept as sent. Clearing it removes the folder. The in-memory copy is `PetsModel`'s, by path, so cards show it without an async lookup; each sign-in gets a new model. A new path means a new photo, so entries never go stale; a replaced photo's entry is removed when its file is.
- **State**:
  - `PetsModel.save(…)` takes an optional prepared photo, and mirrors the reference's `savePetProfile`. It saves the details first, since the bucket only accepts photos of existing Pets. Then it uploads the photo and records its path. Then it removes the replaced file, ignoring a failure. If the upload or recording fails, it returns the saved Pet with "photo not saved", and removes the new file if the Pet couldn't point to it; the Pet keeps its previous photo. A failed details save uploads nothing.
  - A Pet just saved with a new photo shows the prepared data at once: the model puts it in the cache under the new path, so the card needs no download.
  - The Pets' photos load as each card asks for them, through the cache. A fetch that fails leaves that card on the paw until the next load.
  - Sign-out clears the cache, after the Session ends, so a cancelled sign-out keeps it. Each sign-in already gets a new `PetsModel`.
- **Form**: `PetDetailsForm` holds the picked photo: none, or prepared data. Editing starts with the Pet's stored photo shown and nothing picked. Picking replaces the picked photo; Cancel drops it. On save it passes the picked photo, if any, to the model, and reports "photo not saved" so the sheet shows that alert after closing.
- **UI**:
  - The sheet's first row is a centred button: the photo at 92pt with a 28pt corner radius, or a camera placeholder (`camera`, kiwi on the second surface), with "Add photo" or "Change photo" in kiwi under it. It's a SwiftUI `PhotosPicker` filtered to images, so it needs no library permission.
  - `PetSelectorCard` shows the photo at 58pt with a 13pt corner radius, filling the square, or the paw.
  - One image view, `PetPhotoImage`, shows a Pet's photo from the cache or the paw, with the VoiceOver labels from story 22, at the size each place passes.
- **Copy**: "Add photo", "Change photo", "Photo not selected" / "The photo library could not be opened. Please try again." and "Photo not saved" / "{name} was saved, but the photo could not be uploaded. Edit the pet to try again." word for word from the reference.
- **Confirmed differences**, all confirmed by the developer:
  - The system photo picker runs outside the app, so there's no permission prompt and the reference's "Photo access needed" alert is left out.
  - The picker has no crop editor, so the centre square is kept, where the reference lets the Member move a 1:1 crop.
  - iOS downloads photos by path through the Session instead of signing links, so the reference's one-hour links, their refresh 10 minutes early and the retry a minute after a failure are left out.

## Testing Decisions

- **Good tests**: drive the form and the model the way the sheet does, and check what a Member sees (the photo shown, the paw, which alert) and what reaches the stores. Doubles stand in only for the stores. Don't check how the cache or the file maker work inside.
- **KiwiFeatures** (the main seam: `PetDetailsForm` over a real `PetsModel` with `RecordingPetStore` and a new `RecordingPetPhotoStore`). Prior art: `PetDetailsFormTests`, `PetsModelTests`.
  - Ported from the reference's `savePetProfile`, case for case: "uploads a new pet's photo after adding it and records where it is stored"; "points the pet at its new photo before deleting the file it replaces"; "keeps the shown photo when the details are saved without a new photo"; "does not upload the photo when the details are not saved"; "returns the saved pet when only its photo fails, so it is never added twice"; "keeps the previous photo and deletes the new file when the pet cannot point to it"; "still saves the new photo when the replaced file cannot be deleted". Its "saves nothing when the selected photo cannot be prepared" becomes a picking case, since preparing moves to picking.
  - Ported from `PetsProvider`: "clears cached photos when the Account signs out, and not while signed in".
  - New: a Pet just saved with a photo shows it without a fetch; a Pet whose photo can't be fetched shows the paw; Cancel drops a picked photo; editing starts with nothing picked.
- **KiwiData** (against `StubSupabaseServer`, and the cache in a temporary folder). Prior art: `SupabasePetStoreTests`.
  - Ported: "records where a pet photo is stored and touches nothing else"; "stores each new photo under its own name in the pet's folder"; "deletes one photo file by path"; "wraps a failed delete in a typed error"; "wraps a refused upload in a typed error".
  - Changed: "loads the household's pets by name" also reads the photo path.
  - New: a download is wrapped in a typed error when it fails; the cache fetches a path once and then serves it, fetches a new path, and fetches again after clearing.
  - The reference's signing cases ("signs a link for each stored photo in one request", "leaves a photo it cannot sign without a link", "makes no request when no pet has a photo", "wraps a failed signing request in a typed error") have no counterpart, since iOS doesn't sign links.
- **Making the file** (the pure function, tested directly with images made in the test). Ported from `preparePetPhotoUpload`: "scales a photo down to 512px and stores it as JPEG" (a 3000×4000 photo becomes a 512×512 JPEG), "keeps a small photo at its size" (a 300×200 photo becomes a 200×200 square), "reports a photo it cannot read". New: a photo with location metadata comes out with none.
- **Supabase** (pgTAP, a new test for the bucket in the shape of `pets_test.sql`): a Member can upload to, read, replace and delete in their Household's Pet's folder; a Member can't touch another Household's Pet's folder or a path outside any Pet's folder; a signed-out user can do none of it.
- **Previews**: the sheet with no photo, a stored photo and a picked one; the selector row with photos and paws; light and dark.
- **Simulator**: on the local stack, add a Pet with a photo, replace it, save details without a new photo, then sign out and in as another Account and check its Pets show no photos from the first. Then on the shared project: check an iOS photo in the Expo app and an Expo photo on iOS.

## Out of Scope

- Removing a Pet's photo; the reference can only replace it. It's in the after-parity list.
- The photo on Today, the pet picker, the calendar, pet event details and the overview; each gets it with its own feature (Phase 4 to 6, and KIW-26).
- Taking a photo with the camera.
- Cleaning up photo files no Pet points to.

## Further Notes

- A replaced file that couldn't be deleted stays in the bucket unseen, as in the reference. A later cleanup could remove files no Pet points to.
- Moving preparation to picking means a photo that can't be read never reaches Save, so the "Pet not added" alert for an unreadable photo can't appear on iOS.
