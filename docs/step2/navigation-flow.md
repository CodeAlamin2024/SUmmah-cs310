# SUmmah — Step 2 Navigation Flow

CS310 Group 35 · Proposed navigation blueprint for Step 2.1 wireframes

## Student flow

```text
                  Home
             /      |       \
       Timetable  Announcements  Jumu'ah
           \          |          /
                Back to Home
```

- **Home → Timetable:** Tap “View full timetable” or the timetable navigation item.
- **Home → Announcements:** Tap “View announcements” or the announcements navigation item.
- **Home → Jumu'ah:** Tap the Friday prayer shortcut.
- **Detail screens → Home:** Use bottom navigation or the back action.
- Students can view public information without signing in.

## Administrative demo flow

```text
Home → Admin Login → Admin Dashboard → Edit Form
                ↘ Sign Up         ← Save / Back
```

- **Home → Admin Login:** Tap the admin entry (for example, an icon in Settings).
- **Admin Login → Sign Up:** Tap the sign-up link; registration is a UI-only demonstration in Step 2.2.
- **Admin Login → Admin Dashboard:** Demo navigation after entering mock credentials; no real authentication in Step 2.2.
- **Admin Dashboard → Edit Form:** Select an announcement or timetable entry to edit.
- **Edit Form → Confirmation dialog:** Validate at least two fields inline, then show a confirmation dialog after a valid submission.
- **Admin Dashboard → Home:** Use a back or exit control.

## Wireframe annotations
Each wireframe should identify:
1. Screen name and purpose.
2. Buttons, tabs, fields and visible content.
3. Destination of every navigation control.
4. Validation, empty/error states and any confirmation dialogs.

## Scope notes
- The optional physical masjid display is not part of the required mobile UI flow.
- Prayer times in wireframes are illustrative unless confirmed with the masjid.
- Firebase and real authentication are deferred to Step 3 per the course specification.
- The group must obtain TA feedback on Step 2.1 before implementing Step 2.2.
