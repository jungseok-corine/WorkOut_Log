# Release Notes — Version 1.0.0

**Release Date:** 2025-10-16
**Build:** 1
**Platform:** iOS 18.0+

---

## 🎉 Initial Release

Welcome to **WorkOut Log** — your offline-first, privacy-focused workout tracker built for iOS 18.

---

## ✨ Key Features

### 📝 Session & Set Tracking
- Create workout sessions with date selection
- Add sets with exercise, weight, and reps
- Automatic volume calculation (weight × reps)
- Swipe-to-delete for sessions and sets
- Persistent exercise selection for rapid set entry

### 🏋️ Exercise Library
- **User-defined exercises** with custom names
- **Four main categories:**
  - Lower Body (하체)
  - Upper Body (상체)
  - Cardio (유산소)
  - Full Body (전신)
- Swipe-to-delete exercises (with safety validation)
- Create new exercises in-app
- Search with 300ms debouncing for smooth typing

### 📊 Workout Log
- Chronological session list
- **Category badges** showing exercise types per session
- Total volume display per session
- Sets grouped by exercise with:
  - Section headers (exercise name + category)
  - Per-exercise set numbering (#1, #2, #3...)
  - Subtotal volume per exercise

### 📈 Trends & Analytics
- **Three viewing scopes:**
  - **Daily:** Latest ≤10 days at-a-glance
  - **Weekly:** Last 8 weeks
  - **Monthly:** Last 6 months
- **"Show All Days" toggle** for Daily mode:
  - ON: Include zero-volume days
  - OFF: Show only workout days
- **Category filters:** View trends by Lower/Upper/Cardio/Full
- Interactive line chart with volume visualization

### 🏆 PR Highlights (Coming Soon)
- Personal records tracking
- Best weight × reps per exercise
- Historical PR timeline

### 💬 Motivational Splash
- Random workout quote on app launch
- 15 curated quotes from athletes and leaders
- 2.5s auto-dismiss (5s for VoiceOver users)
- Tap to skip instantly

---

## 🔒 Privacy & Offline

- **100% Offline:** No internet required, no cloud sync
- **No Data Collection:** Zero analytics, zero tracking
- **On-device storage only:** All data stays on your iPhone
- **No third-party SDKs:** Built with native SwiftUI + SwiftData
- **No ads, no subscriptions:** Free forever

---

## ♿️ Accessibility

- Full VoiceOver support with semantic labels
- Dynamic Type for text scaling
- High contrast color scheme
- Accessibility identifiers for UI testing
- Extended splash duration for screen reader users

---

## 🏗️ Technical Highlights

- **iOS 18.0+** (Swift 6, SwiftUI, SwiftData)
- **Clean Architecture:** Domain-driven design with separation of concerns
- **Observation Framework:** Modern @Observable + @MainActor ViewModels
- **Swift Charts:** Native chart visualizations
- **Offline-first:** No network dependencies, instant performance

---

## 🐛 Known Issues

- None reported in beta testing

---

## 📱 Requirements

- **Device:** iPhone (iOS 18.0 or later)
- **Storage:** ~10 MB
- **Connectivity:** None required (fully offline)

---

## 🛠️ Bug Reports & Feedback

Found a bug or have a feature request?
- **GitHub Issues:** https://github.com/ojung/workout-log/issues
- **Email:** your-email@example.com

---

## 🙏 Acknowledgments

Built with ❤️ by 오정석 using:
- SwiftUI for modern UI
- SwiftData for local persistence
- Swift Charts for trend visualizations
- Claude Code for development assistance

---

## 📜 License

WorkOut Log is free and open-source.
See [LICENSE](../LICENSE) for details.

---

**Next Version (1.1.0) Preview:**
- Body metrics tracking (weight, body fat %)
- Exercise history per movement
- Export workout data as CSV
- iCloud sync (optional)
- Dark mode improvements
