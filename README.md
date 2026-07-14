# 型得你 — Flutter App

Cantonese personality self-discovery app. MBTI × Enneagram × Zodiac × Mental Health.

## Quick Start (macOS)

```bash
# 1. Install Flutter (if not already)
brew install --cask flutter

# 2. Get the code
cd ~/Documents
# Download from your Supabase or copy from project folder:
# (Or create fresh and copy files)

# 3. Install dependencies
cd @typingself-app
flutter pub get

# 4. Set up Supabase (optional — app works locally without it)
# - Create project at https://supabase.com
# - Replace values in lib/main.dart
# - Run supabase/schema.sql in SQL Editor

# 5. Run the app
flutter run
```

## Project Stats (July 2026)

- **Dart files:** 14 files, ~1,200+ lines
- **Features:** Daily quotes, mood check-in, MBTI×Enneagram naming, zodiac, consent/privacy, payment scaffold
- **Naming entries:** 16 MBTI×Enneagram combos (placeholder names — user can edit naming_engine.dart)
- **Dependencies:** Flutter 3.29+, Riverpod, Supabase, Firebase Messaging, RevenueCat, Google Fonts
- **Verification:** `flutter analyze` — 0 errors, 0 warnings

## Structure

```
lib/
├── main.dart                 # Entry point (no Supabase dependency by default)
├── app.dart                  # App shell + custom bottom nav
├── core/theme.dart           # Brand colors, typography
├── features/
│   ├── daily_quote/          # Quote screen, service, AI service, zodiac
│   ├── mood_checkin/         # Mood screen + local storage service
│   ├── personality_naming/   # Naming engine (16 entries), screen, share card
│   ├── payment/              # RevenueCat scaffold (unconfigured)
│   └── profile/              # Profile screen + consent screen
```

## To Do (User)

1. **Install Flutter** → `brew install --cask flutter` ✅ (your Mac)
2. **Download project** → get zip to your machine
3. **Run** → `cd ~/Documents/@typingself-app && flutter run`
4. **Set up Supabase** → copy schema.sql to Supabase SQL Editor
5. **Edit names** → open `naming_engine.dart`, change any placeholder names
6. **Register Apple/Google Developer** → needed for App Store launch
