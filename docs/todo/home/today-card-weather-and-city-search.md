# Today card: weather and city search — plan

Planned 2026-11-19, nothing built. Builds on the card's sky (A2,
`TodaySkyTheme`) on `feat/buddhist-times`. The Vinaya times plan
(`docs/todo/vinaya-times/vinaya-times-today-card-on-home.md`) left cities
outside Sri Lanka out; this plan takes them in.

**Goal:** the Today card shows the temperature, and its sky turns gloomy or
rainy with the weather, as subtly as the sky is now. A user anywhere can pick
their city. With no internet the card is exactly as it is today.

**Not in this plan:** GPS, a bundled world city list (declined 2026-11-19),
forecasts, the snow sky (later), a sky in the dark theme.

## Decided (2026-11-19)

- **Weather: Open-Meteo** (`api.open-meteo.com/v1/forecast`). Any lat/long,
  no key, no sign-up. Open to web pages (`access-control-allow-origin: *`,
  checked 2026-11-19). Ask for `current=temperature_2m,weather_code`.
  - Free for non-commercial use only: no ads, no subscriptions; donations are
    fine. Ads or subscriptions would need a paid plan.
  - Limits per IP: 600 a minute, 5,000 an hour, 10,000 a day. One device
    uses a few a day.
- **City search: Open-Meteo geocoding**
  (`geocoding-api.open-meteo.com/v1/search`), data from GeoNames. Search by
  name only, up to 100 results, each with name, lat/long, country, time zone
  and population. `language=si` gives Sinhala names where GeoNames has them
  (Kandy → මහනුවර).
- **Cities:** the 8 Sri Lankan cities stay built in, so the app works offline
  from the first start. "Search another city" works online; the picked city is
  saved on the device, and from then on everything works offline.
- **Clock: the device's, no saved time zone.** The fixed `City.utcOffset`
  (+5:30) gives way to the device's offset on that day; the device knows its
  own daylight saving.
  - Known gap, accepted: when the city and the device are in different zones
    (a traveller, someone abroad keeping Colombo), the times are the right
    moments on the device's clock, but near midnight "today" can be the
    city's wrong day. The fix is to pick the city you are in. Search results
    carry a `timezone` if this ever matters.
- **Sky moods: clear, gloomy, rain.** Weather is a layer over the five
  keyframes, not new sets of keyframes. Snow later: none of the 8 cities ever
  reports it.
- **No internet → no weather → today's card.** A reading older than 2 hours is
  dropped, not shown.
- **Credits on Anumodanā only:** "Weather data by Open-Meteo.com" and GeoNames
  for places, both CC BY 4.0. Shown only with the `kEnableHome` toggle, like
  the NASA credit.

## Open questions

- **Rain still or falling?** Recommended: still streaks, like the rest of the
  card. Falling needs an animation and must stop under reduce motion.
- **Where the temperature sits.** Beside the date and city in the header,
  e.g. `29°`. Look at it in screenshots first.
- **°C only, or °F for the US?** Open-Meteo takes `temperature_unit=fahrenheit`.
- **Far from the equator.** Decide before search opens to the world:
  - Pa-Auk and Na-Uyana are 40 and 30 minutes before sunrise, set for Sri
    Lanka. Far north the sky lightens much earlier. Whether they hold abroad
    is a Vinaya question, not a code one.
  - Past about 60° the summer sun may never reach 6° below (no civil
    twilight); past the polar circles some days have no sunrise.
  - The sky's timing offsets in `today_sky_theme.dart` suit the tropics.
  - Either limit results to a latitude band, or handle each case.
- **Which coordinates go out.** Simplest: only the picked city's. For a
  built-in city, asking for all 8 in one call hides which one is picked.

## Steps

### 1. The device's clock

- `City.dayAt` → the device's calendar day.
- `sun_times_repository_impl.dart` (`_spa`, `_micros`): the device's offset on
  that day, read at noon because some places change clocks at midnight:
  `DateTime(day.year, day.month, day.day, 12).timeZoneOffset`.
- Delete `City.utcOffset`.
- Tests that check times assume +5:30: run them with `TZ=Asia/Colombo`.
- **Done when:** in Sri Lanka nothing changes; with the Mac set to London,
  Colombo's times show on London's clock.

### 2. Any city

- The `City` enum → a `Place` (Freezed): name, latitude, longitude. The 8
  built-in ones stay as consts, named from the ARB files as now (`CityLabel`).
- Saved as JSON under a new `StorageKeys` key; `vinaya_times_city_v1` goes. No
  migration: the app is unreleased.
- `PlaceSearchRepository` (domain), its impl on `http` (data), returning
  `Either<Failure, List<Place>>`. A 5 s timeout. Two letters match exactly,
  three or more by prefix; ask only after a pause in typing.
- Names come in the app language (`language=si` or `en`). A searched city
  keeps the name it was saved with; switching the app language later does not
  rename it.
- Settings → Vinaya times: the 8 cities, then a "Search another city" field.
  Offline it says it needs internet. Strings in EN and SI (see the Sinhala UI
  terms).
- **Done when:** a user in London can search, pick London, and then see
  London's times offline.

### 3. Weather data

- Domain: `Weather` (temperature, mood, fetched at), `SkyMood { clear, gloomy,
  rain, snow }`, and `WeatherRepository.current(Place)` returning
  `Either<Failure, Weather>`.
- Data: one GET, a 5 s timeout. WMO weather codes to moods:

  | Codes | Meaning | Mood |
  |---|---|---|
  | 0, 1, 2 | clear to partly cloudy | clear |
  | 3, 45, 48 | overcast, fog | gloomy |
  | 51–67, 80–82, 95–99 | drizzle, rain, showers, thunder | rain |
  | 71–77, 85, 86 | snow | snow (drawn gloomy until the snow sky) |
  | anything else | | clear |

- Provider: fetch on start and every 30 minutes; keep the last good reading
  in memory only; drop it after 2 hours. Any failure → no reading.
- Web: check the offline worker never stores these replies.
- **Done when:** with Wi-Fi off the card is today's card, and no error shows.

### 4. Temperature on the card

- Rounded, e.g. `29°`, in both themes; a screen reader hears "29 degrees".
  Hidden when there is no reading.

### 5. Gloomy and rain skies

- Design first as local screenshots of the card: every keyframe in every mood.
- Gloomy: each keyframe moves part way to a grey veil, the sun's glow weaker,
  no stars, a few soft clouds.
- Rain: gloomy, plus a few thin slanted streaks.
- In `TodaySkyTheme`, light theme only, like the sky.
- Recheck the card's text contrast: 4.5:1 or better (see `_strength`).

### 6. Credits

- Anumodanā: Open-Meteo and GeoNames, behind the toggle.

### Later: snow

- A snow sky, once a city that sees snow can be picked.

## Handover

**2026-11-19 — planned, nothing built.** No tests yet; the test agent writes
them once steps are built.
