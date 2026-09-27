# Changelog

## 2.0.0 — unreleased

Two ways to read the Quran, a fix for missing verses, and a working dark mode.

### Fixed
- **112 surahs were missing their first ayah.** The `quran-uthmani` text puts
  the Basmala in front of ayah 1 of every surah except Al-Fatiha and
  At-Tawbah, and the parser deleted that whole ayah instead of the prefix.
  Al-Baqarah opened at ayah 2. Every surah now has all its verses, with the
  Basmala shown as its own line. No cache migration is needed: the cache
  holds the raw text and is re-parsed.
- Dark mode is actually dark. The app's dark theme was a light theme, so
  sheets, dialogs and default text stayed light at night, and several reader
  pages painted white under light-grey night text.
- Surah headings and the Basmala never appeared in the Translation, Urdu and
  English-and-Arabic readers.
- The Surah Playlist reciter picker built a broken audio URL.
- Recitation 404'd for six reciters that are not published at 128 kbps.
- Adhan alarms are scheduled a week ahead on per-mode notification channels,
  and release builds keep the rules they need to fire.
- A crash when leaving any screen that used the animated entry without a
  delay.
- Network calls that could spin forever now time out with a message.

### Added
- **Mushaf:** the printed 604-page Madinah Mushaf, line for line and fully
  offline. Listen along, and long-press an ayah for its translation, copy,
  share or "listen from here".
- **Easy Read:** the same 604 pages as flowing text at any size, with an
  optional translation under each ayah. Tap an ayah to hear it, read its
  translation, copy, share or bookmark it. Listening moves on to the next
  ayah and turns the page.
- The surah index has search, "Continue reading", and opens either reader
  on the same page.
- The home screen names the two readers "Easy Read" and "Mushaf".

### Changed
- Android toolchain modernised; the app targets SDK 35 and compiles against
  36.
- Plugins upgraded: geolocator 14, geocoding 5, share_plus 13,
  shared_preferences 2.5, flutter_timezone 5, audioplayers 6.8.
  flutter_local_notifications stays on 18, because 19 changed the
  `zonedSchedule` API the adhan scheduling uses.
- Removed the unused Syncfusion PDF viewer.
