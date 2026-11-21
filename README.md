# SUmmah

**CS310 Mobile Application Development – Group 35**

SUmmah is a Flutter app for Sabancı University students to see their campus
masjid's prayer and iqamah times, follow a live countdown to the next prayer,
check Jumu'ah information and read masjid announcements. Masjid volunteers get
a small admin area to publish announcements and edit the timetable.

## Project status

**Step 2.2 – UI implementation (complete).** All nine screens are built and
connected. Data is sample data held in memory, and sign-in / sign-up are UI
only; Firebase (Firestore + Authentication) comes in Step 3. The timetable is
illustrative and must be verified with the masjid administration before
real-world use.

## Group details

**Group number:** 35

| Member | Student ID |
| --- | --- |
| Alamin Bawa Idris | 32769 |
| Omer Faruk Eliuz | 32592 |
| Mustafa EsadHasozhan | 33800 |

**Assigned TA:** Egeman Ayrac

**Step 1 student coordinator:** Alamin Bawa Idris

### Step 1 responsibilities

| Person | Responsibility |
| --- | --- |
| Alamin Bawa Idris | Application overview, feature scope, proposal integration |
| Omer Faruk Eliuz | Data requirements and technical challenges |
| Mustafa EsadHasozhan | GitHub repository, README, .gitignore, repository verification |

### Step 2.2 responsibilities

| Person | Screens |
| --- | --- |
| Alamin Bawa Idris | S1 Home, S2 Prayer timetable, S3 Announcements (+ S3.1 detail) |
| Mustafa EsadHasozhan | S4 Jumu'ah, S5 Admin sign in, S6 Create account |
| Omer Faruk Eliuz | S7 Admin dashboard, S8 Announcement form, S9 Timetable form |

Planning notes from Step 2.1 are in [`docs/step2/`](docs/step2/).

## Requirements

- Flutter **3.x stable** (tested by the team on Flutter `3.50.0` • Dart `3.14.0`)
- An Android emulator, iOS simulator or Chrome

## Run

```bash
git clone https://github.com/CodeAlamin2024/SUmmah-cs310.git
cd SUmmah-cs310        # or the unzipped "summah" folder
flutter pub get
flutter run            # or: flutter run -d chrome
```

Checks (all 22 tests should pass):

```bash
flutter analyze
flutter test
```

Admin area: tap the shield icon at the top of Home, then sign in with any
valid email address and any password (sign-in is UI only until Step 3).

## Project structure

```
lib/
  main.dart                 App entry, theme and named routes
  utils/
    app_colors.dart         Shared colour palette
    app_text_styles.dart    Shared text styles (custom font: Plus Jakarta Sans)
    app_spacing.dart        Shared spacing / radius / size tokens + Gap widget
    app_theme.dart          ThemeData built from the files above
    app_routes.dart         Route names
    validators.dart         Form validators (inline error messages)
    date_format.dart        Date and 24-hour time helpers
  models/                   Model classes (PrayerSchedule, Announcement, FridayUpdate, JumuahInfo, ...)
  data/                     Placeholder data for Step 2 (timetable, announcements, Jumu'ah)
  services/prayer_service.dart  Next-prayer and countdown logic (always Türkiye time, UTC+3)
  state/app_state.dart      Shared timetable + announcements (one ChangeNotifier, no packages)
  widgets/                  Reusable widgets (buttons, text field, cards, dialog, ...)
  screens/                  One file per screen
assets/
  fonts/                    Plus Jakarta Sans (SIL OFL 1.1)
  images/                   Local (bundled) images
```

## Screens

| ID | Screen | File |
|----|--------|------|
| S1 | Home dashboard | `screens/home_screen.dart` |
| S2 | Prayer timetable | `screens/timetable_screen.dart` |
| S3 | Announcements | `screens/announcements_screen.dart` |
| S3.1 | Announcement detail | `screens/announcement_detail_screen.dart` |
| S4 | Jumu'ah | `screens/jumuah_screen.dart` |
| S5 | Admin sign in | `screens/admin_sign_in_screen.dart` |
| S6 | Create account | `screens/create_account_screen.dart` |
| S7 | Admin dashboard | `screens/admin_dashboard_screen.dart` |
| S8 | Announcement form | `screens/announcement_form_screen.dart` |
| S9 | Timetable form | `screens/timetable_form_screen.dart` |

## Step 2.2 requirement checklist (S1–S3)

- **Network images:** announcement images on S3 and S3.1 load from our GitHub repo (`docs/images/halaqa.jpg`, `docs/images/tea.jpg`), with a placeholder while loading and a fallback if offline
- **Model objects in Cards with remove:** `Announcement` cards on S3; the X button or a swipe hides a card and the SnackBar offers Undo; "Show all" brings everything back
- **Lists from model objects:** `PrayerSchedule` rows on S1 and S2, built from `DaySchedule` objects
- **Navigation:** bottom tabs (S1–S4) plus named routes; S1 links to S2, S3, S4 and S3.1; S4 "All Friday updates" opens S3 filtered to Jumu'ah
- **Live countdown:** S1 counts down to the next adhan or iqamah every second in Türkiye time (works on phones set to any time zone)
- **Empty states:** S2 dates without published times, S3 filters with no results
- **No overflow:** S1–S3 use `ResponsiveScrollBody` and text that wraps, ellipsises or scales down

## Step 2.2 requirement checklist (S4–S6)

- **Local image:** masjid illustration on S4 (`assets/images/jumuah_mosque.png`)
- **Custom font:** Plus Jakarta Sans, bundled and declared in `pubspec.yaml`
- **Model objects in Cards with remove:** `FridayUpdate` list on S4; the X button removes a card and the SnackBar offers Undo
- **Form with inline validation + confirmation dialog:** S6 Create account (4 fields, inline errors, D1 dialog after a valid submit); S5 also validates inline
- **No overflow:** every screen uses `ResponsiveScrollBody` (scrollable, max width 480) and text that wraps or scales down

## Step 2.2 requirement checklist (S7–S9)

- **Model objects in Cards with edit/delete:** `Announcement` and `DaySchedule` lists on S7, each with edit (S8/S9) and delete after a confirmation dialog (D3)
- **Forms with inline validation + confirmation dialogs:**
  - S8 Announcement form (create/edit, inline errors, date picker, discard prompt, D2 dialog)
  - S9 Timetable form (10 24-hour time pickers, iqamah/order and duplicate-date checks, optional notes, discard prompt, D4 dialog)
- **Shared state:** publishing on S8 or saving on S9 updates S1–S3 immediately

## How the screens share data

`lib/state/app_state.dart` holds one shared copy of the timetable and the
announcements (a `ChangeNotifier`, no extra packages). The student screens
(S1–S3) read it, and the admin screens (S7–S9) change it, so anything an admin
publishes, edits or deletes appears on Home, the timetable and the
announcements feed straight away. Nothing is saved between app launches yet;
Firebase replaces this in Step 3.
