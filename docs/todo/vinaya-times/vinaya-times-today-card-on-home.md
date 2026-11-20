# Vinaya times: the Today card on Home — plan

Started 2026-11-14 as a footer under the Tipiṭaka tree. On 2026-11-15 the user
dropped the footer, which made the reader busy, and moved straight to the
Today card on a Home section, hidden behind a toggle.
Built on branch `feat/buddhist-times`, committed, not merged.
Design: [Vinaya times canvas](https://claude.ai/artifact/LrBxRfjRcrCqE5nPcVJKfn),
the row titled *Phase 2 · Today card on Home*. The card's layout is *A · One
sky* on the [Today card surface canvas](https://claude.ai/artifact/SeTDHs2h6igsuBsJ32Mzj2),
chosen 2026-11-17. Its moon treatments and its 88 px moon are not taken yet.

**Goal:** a Home section with one card for today: the sun's day with midday
and vikāla, the moon's fortnight, and the next uposathas. A Settings tab picks
the city and the dawn method.

**Not in this plan:** the BE year, month names, special days (vassa entry,
Pavāraṇā), the Continue reading card, other Home elements, cities outside Sri
Lanka, GPS, a custom dawn angle, Nautical twilight, safety margins,
notifications.

## Handover

**2026-11-15 — the card is built, with the moon as a NASA photo.**

- **`kEnableHome` is on only in the macOS app**, off on web and mobile. The
  user chose to keep it so (2026-11-18). Main still has no Home.
- **Done:** sun times with sunset, the calendar, the providers, the Settings
  tab, the Today card, the Home screen, the toggle, the moon photos with
  their credit, web preload and script. The analyzer is clean.
- **Removed:** the tree footer and its ochre theme extension. The tree is as it
  was before this branch.
- **The `CHANGELOG.md` note is out.** A new one is owed when the toggle goes on.
- **Tests:** written and run, 2026-11-19. See *Tests*.
- **Still owed:** a look at the card running (see *Checked*), the
  Sinhala review, the colour check, one offline check of the photos on dev,
  *Validation* against a recent Na-Uyana sheet.
- **Do not** copy code or calendar files from Buddhist Sun (GPL-3.0), and do
  not take dawn logic from the canvas.

### Moon photos

The moon panel shows a NASA image at 64, not the 44 drawing.

- **Files:** `assets/moon/00.webp` to `29.webp`, 00 the new moon and 15 the
  full moon, 256 px: sharp at 64 on screens up to 4×. Re-cut from 384 px on
  2026-11-17, which took all thirty from 473 KiB to 263 KiB.
- **Script:** `assets/make_moon.sh` fetches NASA's frames and cuts the
  photos. A run on 2026-11-17 matches all thirty byte for byte. It sits
  outside `assets/moon/` because `pubspec.yaml` ships that whole folder.
- **Credit:** an Images section on Anumodanā, shown only with the toggle.
  See *Licences*.
- **Web, offline:** the offline worker stores a file only once it has
  loaded, so on an install (a first visit or a database update) the
  installer loads all thirty, once the app shows, with the toggle on or
  off. Other starts load none. Decided 2026-11-17: no requests for the
  photos on every start, and the user times the toggle against database
  updates.
  - A browser that installed before Home stores each photo the first time
    its day is opened online, and shows the drawn moon offline until then.
    The next database update loads all thirty.
  - A re-cut photo: the old copy offline until that day is opened online.
  - **Not checked on dev.**
- **Open:** the black dark side on the light card, worst near the new moon.
  If it looks wrong, the next try is the same photo inside a small dark tile.
- **If the photos go:** delete `assets/moon/`, `assets/make_moon.sh` and
  `moon_photos.dart`; take out the folder in `pubspec.yaml`, the photo
  loading in the installer, the Images section and its two strings;
  `_MoonSky` goes back to `_MoonPainter` alone.

### Checked

- Sun times and calendar on 14 Nov 2026: a throwaway script against the two
  tables in *Reference values*.
- The card's numbers for 14 Nov 2026 in Colombo, by script: sunset 17:49, day
  5 of 15, uposatha in 10 days, then 24 Nov, 9 Dec, 24 Dec. All as the canvas
  draws them. Day 15 of 15 on an uposatha, day 1 the day after, and nothing
  past 20 Jun 2035.
- **Not seen running:** the card itself, in any state, on any screen size, in
  either language. The Settings tab was not seen running either.

### Sinhala draft

For the user to correct. All in `app_si.arb`.

| English | Draft |
|---|---|
| Time | කාලය |
| Dawn, midday and uposatha days. | අරුණ, මධ්‍යාහ්නය සහ උපෝසථ දින. |
| Today | අද |
| Midday 11:54 | මධ්‍යාහ්නය 11:54 |
| Midday in 42 min | මධ්‍යාහ්නයට මිනි. 42 |
| Midday in 3 h 24 min | මධ්‍යාහ්නයට පැය 3 මිනි. 24 |
| Vikāla until aruṇa 05:31 | අරුණ 05:31 තෙක් විකාලය |
| Aruṇa / Sunset / Now, each with a time | අරුණ / හිරු බැසීම / දැන් |
| Waxing · day 5 of 15 | පුර පක්ෂය · 15න් 5 වන දිනය |
| Waning · day 5 of 15 | අව පක්ෂය · 15න් 5 වන දිනය |
| Uposatha in 10 days / tomorrow / today | උපෝසථයට දින 10 / හෙට උපෝසථ / අද උපෝසථ |
| Full moon / New moon | පුර පසළොස්වක / අමාවක |
| Aruṇa by Na-Uyana · Sangha calendar | අරුණ: නා උයන · සංඝ දින දර්ශනය |
| Location | ස්ථානය |
| Aruṇa (dawn) | අරුණ |
| Pa-Auk / Na-Uyana | පා-අවුක් / නා උයන |
| Civil twilight / Sunrise | සිවිල් අරුණාලෝකය / හිරු උදාව |
| Date order, with and without the year | `y MMM d, EEE` / `MMM d, EEE` |
| Images (Anumodanā section) | රූප |
| The images of the moon on Home. | මුල් පිටුවේ ඇති සඳෙහි රූප. |

The hints, the footnote, the screen-reader labels and the eight city names
are drafts too.

## The toggle

`kEnableHome` in `lib/core/constants/feature_flags.dart`, a getter that is on
only in the macOS app. Off:

- Home is not in the rail or the bottom bar, and is not built at all.
- Settings has no Time tab, and Anumodanā no Images section.

Web still loads the moon photos on an install (see *Moon photos*), so a
database update made while the toggle is off still counts.

Turning it on is that one line, plus a `CHANGELOG.md` note under *Unreleased*.
The app still opens on the Reader either way.

## What the user sees

### Home

A heading and the Today card, in one column no wider than a reading page.

### Today card

| Part | Shows |
|---|---|
| Header | `TODAY` on the left; on the right the date, weekday in bold, with the city under it, as one small button |
| Arc | A half circle: the sun's by day, the moon's by night |
| Headline | One of the two states below |
| Moon panel | The moon, its line, and the next uposatha |

The moon panel has no box of its own. One dashed horizon runs under the arc
and the moon. The moon's line sits under it, level with the arc's end labels,
and the next uposatha sits level with the arc's headline. On a narrow card the
moon panel drops under the arc, below a solid rule: a smaller photo with its
two lines beside it, and no horizon.

Arc:

| When | Runs | Coloured stretch | Marker |
|---|---|---|---|
| Aruṇa until sunset | Aruṇa to sunset, midday marked | Aruṇa to midday, kāla, in sky blue; the afternoon in slate grey | An orange disc, the sun |
| Sunset until aruṇa | Sunset to the next aruṇa | All of it, in midnight blue | An amber disc, the moon |

`Now 08:30` keeps a fixed spot outside the arc, centred on the line 45 degrees
up, halfway between the arc's end and its top: on the left in the arc's first
half, on the right in its second, mirrored. It sits as near the arc as it can
while its nearest corner stays past the marker's reach, so the marker never
touches it. On a narrow card the arc stands in a little to make room. At a
system text size where it still cannot fit, or would meet the midday label,
it is left out.

Headline:

| When | Headline |
|---|---|
| Aruṇa until midday | `Midday in 3 h 24 min`, bold; orange inside the hour, red inside the half hour |
| Midday until the next aruṇa | `Vikāla until aruṇa 05:31`, small and muted, the same style as the next uposatha's date |

Moon panel:

| Line | Shows |
|---|---|
| Moon photo | The moon on this day of its cycle; a drawing if the photo cannot load |
| Moon's line | `Waxing · day 5 of 15`, or `Waning` before a new moon. From five days out the countdown instead: `Uposatha in 3 days`, `Uposatha tomorrow`, `Uposatha today`, bold from two days out |
| Next uposatha | `Tue 24 Nov · Full moon uposatha` |

The day runs aruṇa to aruṇa, so the fortnight's day and "today" and
"tomorrow" switch at aruṇa, not at midnight. In Sinhala the word is උපෝසථ.

The date-and-city button opens Settings → Time. It is the card's only way
in; the dawn method is named there and not on the card.

### Settings → Time

A tab after General.

- **Intro line:** "Dawn, midday and uposatha days." The tab name alone
  could read as a clock setting.
- **Location:** eight Sri Lankan cities, each with today's midday. Anuradhapura
  until the user picks.
- **Aruṇa (dawn):** the four methods, each with tomorrow's time for the chosen
  city.
- **Summary box:** today's midday and "vikāla until" for the chosen city.
- **Footnote:** uposatha dates follow the Sangha calendar.

## Decisions

By the user on 2026-11-14 unless marked.

1. **Sangha calendar, not the government Poya day.** The two differ in 6 of
   the 12 months of 2026.
2. **We build the calendar ourselves from the counting rule.** No file from
   another project is shipped. See *The uposatha calendar*.
3. **Sun maths comes from the `nrel_spa` package** (MIT), the one Buddhist Sun
   uses. We do not write our own.
4. **Four dawn methods**, taken from Buddhist Sun and not from the canvas:

   | Method | Rule |
   |---|---|
   | Pa-Auk | sunrise − 40 min |
   | Na-Uyana (default) | sunrise − 30 min |
   | Civil twilight | sun 6° below the horizon |
   | Sunrise | sunrise itself |

   Sunrise is the almanac one: the sun's top edge on a flat sea-level horizon,
   with standard refraction (centre 0.833° below).
5. **Eight Sri Lankan cities with fixed coordinates.** No GPS, no cities
   abroad. The list is in *Reference values*.
6. **Anuradhapura is the default city.** The card names the city on its
   button, so a user elsewhere can see the times are not theirs.
   *(user, 2026-11-18)*
7. **No safety margin.** Rounding only: midday rounds down to the minute and
   dawn rounds up, so the shown time is never on the unsafe side. The
   countdown and the state changes use the shown times. Sunset times nothing,
   so it rounds to the nearest minute. *(sunset: my call)*
8. **Times are on the device clock.** A device set to another time zone shows
   the same moments as its own clock reads them. The card's date is the
   device's too. No time-zone package. *(my call)*
9. **The day switches at aruṇa**, by the chosen dawn method. *(my call)*
10. **The Sinhala label is උපෝසථ**, never පොහොය, which reads as the public
    Poya day.
11. **No BE year, no month names, no special days.** The canvas draws all
    three; they need calendar rules this plan does not have. *(user,
    2026-11-15)*
12. **Outside the calendar's range the moon panel is hidden.** No guessed
    dates.
13. **No tree footer.** It made the reader busy. *(user, 2026-11-15)*
14. **Home sits behind a toggle in code, on only in the macOS app.** *(user,
    2026-11-15; macOS only: user, 2026-11-18; in code and not a Settings
    switch: my call)*
15. **No Continue reading card for now.** *(user, 2026-11-15)*
16. **Colour-scheme roles only.** No theme extension. The card's accents
    are the scheme's "fixed" roles, the same in every theme. The arc is the
    sky and darkens through the day: sky blue for kāla, slate grey for the
    afternoon, midnight blue for the night, so light means kāla and dark
    vikāla. Sun and moon are both filled discs, the sun bright orange and the
    moon light amber. The drawn fallback moon keeps its own pale blue: the
    sky blue would make its lit side darker than its shadow. *(user,
    2026-11-15; the midnight-blue night and the amber moon: user,
    2026-11-17; the day's sky blue, slate afternoon and orange sun: user,
    2026-11-18; the fixed roles: my call)*
17. **One arc, swapped at sunset and at aruṇa**, and not two arcs side by
    side. *(user, 2026-11-15)*
18. **No small print and no Settings link on the card.** The date-and-city
    button is enough. *(user, 2026-11-15; which of the two buttons stays: my call)*
19. **The moon is a NASA image, thirty to a cycle.** The drawing stays only
    as the fallback. *(user, 2026-11-15, by committing it; the credit's
    section and wording: my call)*
20. **The tab is "Time" / කාලය**, the Pali *kāla*, with one intro line under
    it. Code and files say `VinayaTimes`. "Buddhist times" is dropped; the
    branch keeps its name. *(user, 2026-11-17)*

## Open question

**Cātuddasī / paṇṇarasī.** The card shows the fortnight's length as
`day 5 of 15`. Not decided: whether to name the uposatha's type as well, for
example `New moon · cātuddasī`.

## The uposatha calendar

### The rule

- A year is three seasons: Hemanta, Gimhāna, Vassāna. Each has eight
  fortnights, ending new moon, full moon, new moon, and so on.
- Every fortnight is 15 days, except the 3rd and 7th of a season: 14 days.
- **Extra-month year:** Gimhāna gets two more 15-day fortnights. Seven years
  in every 19.
- **Extra-day year:** one 14-day fortnight becomes 15.

### The inputs

| Input | Value | Standing |
|---|---|---|
| Start date | 2025-11-05, the Kattika full moon | from the Buddhist Sun table |
| Extra-month years | 2026, 2029, 2031, 2034 | the 19-year cycle |
| Extra day | 2032, Gimhāna's 7th fortnight | unconfirmed for Sri Lanka |
| Extra day | 2035, same place | doubtful — the table contradicts itself |

Extra days are a list in the code, so a correction is a one-line change.
The calendar runs from 2026 to 20 Jun 2035, the last date before the doubtful
fortnight.

### What was checked, 2026-11-14

- **The dawn-boundary hunch.** "Uposatha is the day that holds the real moon
  moment, with the day starting at aruṇa" matches 120 of the 248 table dates.
  The best of the six day-starts tried, 18:00, matches 148. Moon moments from
  the US Naval Observatory.
- **The counting rule** reproduces all 248 dates of Buddhist Sun's Sri Lanka
  table (2026–2035) and 39 of its 40 special days. The 40th is a typo in the
  table: a 2032 row dated 2030.
- **That table is date-for-date the same as its Thai table.** So it is not
  independent evidence for Sri Lanka.
- **Na-Uyana's 2017 sheet** follows the rule in 22 of 23 gaps. The exception
  is the fortnight ending 25 Feb 2017: 15 days where the rule gives 14. An
  extra day, in Hemanta and not in Jeṭṭha — so Na-Uyana can sit a day apart
  from the Thai table for some months.
- **[Ancient Buddhist Texts](https://ancient-buddhist-texts.net/Reference/Days-Months-Seasons.htm)**
  agrees: 15-day fortnights with six of 14, seven extra months in 19 years, an
  extra day in Jeṭṭha, and the day beginning at dawn.

### Validation, after the build

Get one recent Na-Uyana uposatha sheet (2025 or later). Compare every date.
A mismatch means the start date or an extra day is wrong; fix the input list.
Until then the dates rest on the Thai-identical table.

Every year after: in December and January, `scripts/deploy.sh --prod` prints
a reminder to check the coming year's dates the same way. It only reminds.
The card shows one uposatha, so ask for the year's dates to be printed.

## Licences

- **Buddhist Sun** is GPL-3.0. We take ideas only: which settings exist, the
  dawn methods, a rule-built calendar. No code and no data file is copied.
  Permission was not asked (user not in a position to, 2026-11-14).
  Checked against its repo on 2026-11-19: nothing of ours matches its code.
  Anumodanā credits it under *Inspiration*, with a link, as a courtesy
  (user, 2026-11-19).
- **SunCalc** (BSD-2-Clause): `moon_position.dart` follows its moon
  formulas, so `main.dart` registers its notice under Open-source licences.
- **`nrel_spa`** is MIT. Flutter lists it under Open-source licences without
  any work from us.
- **The moon images** are from NASA's Scientific Visualization Studio, "Moon
  Phase and Libration, 2026" (svs.gsfc.nasa.gov/5587). NASA asks for that
  credit line. Anumodanā carries it as text with a link. No NASA logo, which
  is protected, and no wording that reads as NASA endorsing the app. They
  are rendered from spacecraft data, so the English says "images", not
  "photographs". The Sinhala says ඡායාරූප: රූප alone reads as the Dhamma
  term (user, 2026-11-19).

## How it is built

Pure Dart for the maths, so it works on every platform. Nothing in
`static_site_generator/` changes.

### Core — `lib/core/`

- `constants/feature_flags.dart`: `kEnableHome`.
- `constants/moon_photos.dart`: how many moon photos there are and the path
  of each, for the card and the web installer.

### Domain — `lib/domain/`

- `entities/vinaya_times/city.dart`: an enum of the eight cities with their
  coordinates. The enum name is the saved key.
- `entities/vinaya_times/dawn_method.dart`: the four-value enum.
- `entities/vinaya_times/uposatha_day.dart`: date, full or new moon, and the
  fortnight's length (14 or 15).
- `entities/vinaya_times/uposatha_calendar.dart`: the rule and its inputs;
  `upcoming` returns the next few days.
- `repositories/sun_times_repository.dart`: midday, dawn and sunset for a
  date and city. Plain return values, no `Either`: it is maths on a fixed city
  list and cannot fail. *(my call)*

### Data — `lib/data/`

- `repositories/sun_times_repository_impl.dart`: the only file that imports
  `nrel_spa`. Applies the rounding in Decision 7.
- `database/web_database_installer.dart`: on an install, web loads the thirty
  moon photos so the offline worker stores them. It cannot fail the install.

### Presentation — `lib/presentation/`

- `providers/vinaya_times_provider.dart`:
  - a clock that ticks on the minute;
  - the saved city and dawn method, through `KeyValueStore` and two
    `StorageKeys`, sharing one `SavedChoiceNotifier`;
  - the card's state, derived from those three.
- `providers/vinaya_times_state.dart`: the card's state, in its own file
  like `search_state.dart`.
- `widgets/home/today_card.dart`: the card. The arc is a `CustomPainter`;
  its labels are ordinary text placed over it. The moon is an `Image.asset`,
  with a `CustomPainter` as its fallback.
- `widgets/settings/anumodana_page.dart`: the Images section, only with the
  toggle.
- `screens/home_screen.dart`: the heading and the card.
- `screens/app_shell.dart`: Home joins the navigation, and is built, only
  when the toggle is on.
- `widgets/common/vinaya_times_labels.dart`: the ARB string of each city,
  dawn method and moon phase, and `clockTime`, for the card and the Settings
  tab.
- `widgets/settings/vinaya_times_settings_page.dart`: the tab, rows with a
  tick and not the canvas's dropdowns, so every time stays in view.
- `widgets/settings/settings_tab.dart`: the tab shows only with the toggle.

### Colours and text

Colour-scheme roles and `AppTypography` only. The fixed roles pair up:
primary for the bodies (`primaryFixed` the moon marker, `primaryFixedDim` the
sun), secondary for the day's sky (`secondaryFixed` kāla, `secondaryFixedDim`
the afternoon), tertiary for the night's (`tertiaryFixedDim` the night arc,
`tertiaryFixed` the drawn fallback moon). `surface` for the card,
`outlineVariant` for the borders and the horizon. The fixed colours are
`FixedAccentColors` in `app_colors.dart`.

**Open:** the midnight blue almost vanishes on the dark and warm themes'
cards. Both are off today. When one comes back, its night arc needs a
lighter blue of its own.

### Strings

In `app_en.arb` and `app_si.arb`. The two date orders are ARB strings, so
Sinhala can order a date its own way.

### Dependency

`nrel_spa: ^1.2.0` in the root `pubspec.yaml`. It needs Dart 3.7; the lock is
already at 3.12. The SDK floor in `pubspec.yaml` is **not** raised.

## Reference values

Measured 2026-11-14 with an independent calculation (NOAA formulas). Colombo
also agrees with a public sunrise API to within 10 seconds. Midday is for
14 Nov 2026 and the dawn columns for 15 Nov 2026, in Sri Lanka time.
`nrel_spa` came within 3 seconds of every value here (step 1).

| City | Lat | Lng | Midday | Sunrise | Pa-Auk | Na-Uyana | Civil |
|---|---|---|---|---|---|---|---|
| Colombo | 6.9271 | 79.8612 | 11:54:54 | 06:00:46 | 05:21 | 05:31 | 05:39 |
| Kandy | 7.2906 | 80.6337 | 11:51:49 | 05:58:10 | 05:19 | 05:29 | 05:37 |
| Galle | 6.0535 | 80.2210 | 11:53:28 | 05:58:09 | 05:19 | 05:29 | 05:37 |
| Kurunegala | 7.4863 | 80.3623 | 11:52:54 | 05:59:31 | 05:20 | 05:30 | 05:38 |
| Anuradhapura | 8.3114 | 80.4037 | 11:52:44 | 06:00:28 | 05:21 | 05:31 | 05:39 |
| Jaffna | 9.6615 | 80.0255 | 11:54:15 | 06:03:49 | 05:24 | 05:34 | 05:42 |
| Trincomalee | 8.5874 | 81.2152 | 11:49:29 | 05:57:36 | 05:18 | 05:28 | 05:36 |
| Batticaloa | 7.7310 | 81.6747 | 11:47:39 | 05:54:36 | 05:15 | 05:25 | 05:33 |

Sunset is not in the table. `nrel_spa` gives Colombo 17:49 for 14 Nov 2026,
the figure the canvas draws; it has no independent check.

Uposatha dates the rule must give for 2026:

| Full moon | New moon |
|---|---|
| 3 Jan | 18 Jan |
| 2 Feb | 16 Feb |
| 3 Mar | 18 Mar |
| 2 Apr | 16 Apr |
| 1 May | 16 May |
| 31 May | 14 Jun |
| 29 Jun | 14 Jul |
| 29 Jul | 13 Aug |
| 28 Aug | 11 Sep |
| 26 Sep | 11 Oct |
| 26 Oct | 9 Nov |
| 24 Nov | 9 Dec |
| 24 Dec | |

## Tests

What can break a Vinaya rule: aruṇa, midday, kāla against vikāla, and which
day is the uposatha. Plus the card's midday countdown, the one set of words
the card works out itself. No integration test.

- `test/domain/entities/vinaya_times/uposatha_calendar_test.dart`: the 2026
  dates above, and every fortnight to 20 Jun 2035, one line per year. A
  changed input means changing its year's line too.
- `test/data/repositories/sun_times_repository_impl_test.dart`: every city
  against *Reference values*, aruṇa by all four methods. Every time must be a
  whole minute, and the seconds check that aruṇa rounds up and midday down.
- `test/presentation/providers/vinaya_times_provider_test.dart`: kāla from
  aruṇa to midday; the uposatha running aruṇa to aruṇa, as day 15 of 15 or 14
  of 14; Anuradhapura and Na-Uyana until chosen; each choice changing the
  open card at once, and kept after a restart.
- `test/presentation/widgets/home/today_card_test.dart`: the midday countdown
  rounds up (40 s reads "1 min") and says "1 h", not "1 h 0 min".
- `anumodana_page_test.dart`, run as macOS, where Home is on: seven links,
  and the Images section with its NASA link.

Left out on purpose: the sky, the moon photo, sunset, the arc, the card's
other words (they read the tested state as is), and the calendar's end on
the card.

`kEnableHome` is off under `flutter test`, where the platform is Android, so
only the Anumodanā checks above, run as macOS, see Home. When Home ships,
`app_shell_test.dart` (Home reads `keyValueStoreProvider`, the rail gains a
destination) and `settings_dialog_test.dart` ("three tabs" becomes four) need
work.

## Done when

- [ ] The card is seen running on desktop and on a phone, in kāla and in
      vikāla, in English and Sinhala.
- [ ] City and dawn method are saved and change the card at once.
- [x] The sun and calendar numbers agree with *Reference values*.
- [x] Every colour from the theme; every string in both ARB files.
- [ ] The user has checked the colours and the Sinhala.
- [ ] The moon photos show with no connection, checked once on dev.
- [ ] The open question is answered and moved into *Decisions*.
- [ ] *Validation* is done, or its absence is accepted in writing here.
- [ ] The toggle is on, with a `CHANGELOG.md` note.
