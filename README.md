# WorkOut Log

**A privacy-first workout tracking app for iOS — No accounts, no tracking, completely offline**

[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-16+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🏋️ Overview

**WorkOut Log** is a modern iOS workout tracking application built with SwiftUI, SwiftData, and Clean Architecture. Track your exercises, sets, and training volume with complete privacy — all data stays on your device, no internet required.

### Core Philosophy

- **🔒 Privacy First**: Zero data collection, no analytics, no third-party SDKs
- **📴 Fully Offline**: Works without internet connection
- **🎨 Native iOS**: Built with latest SwiftUI, Swift 6, and iOS 18 APIs
- **🏗️ Clean Code**: Follows Clean Architecture principles with comprehensive tests

---

## ✨ Features

### Session & Set Tracking
- **Create Sessions**: Quick session creation with date selection
- **Add Sets**: Record exercise name, weight (kg), and reps
- **Auto-Calculated Volume**: Automatic volume calculation (weight × reps)
- **Clone Workouts**: Duplicate recent sessions to save time

### Exercise Library
- **7 Categories**: Lower Body, Upper Body, Cardio, Core, Full Body, Arms, Shoulders
- **Custom Exercises**: Add your own exercises with custom names
- **Search & Filter**: Fast search with category filtering
- **Delete Management**: Remove unused exercises

### Trends & Analytics
- **Daily Trends**: View last 10 days of training volume with two-line axis labels (month/day)
- **Weekly Trends**: Sunday-Saturday weekly buckets (last 8 weeks) with day-range labels
- **Monthly Trends**: Monthly volume aggregation (last 6 months)
- **Category Filtering**: Filter trends by muscle group
- **Interactive Charts**: Built with Swift Charts for smooth, native performance

### Personal Records
- **PR Tracking**: Automatic personal record detection
- **Epley 1RM Formula**: Estimated one-rep max calculation
- **Recent PR Highlights**: See your latest achievements

### Accessibility
- **VoiceOver Support**: Full screen reader accessibility with custom labels
- **Dynamic Type**: Respects user text size preferences
- **High Contrast**: Readable in all lighting conditions
- **Accessibility Identifiers**: Complete UI testing coverage

---

## 📸 Screenshots

<table>
<tr>
<td align="center">
<strong>Session List</strong><br/>
<em>View all your workouts</em>
</td>
<td align="center">
<strong>Session Detail</strong><br/>
<em>Track sets and exercises</em>
</td>
<td align="center">
<strong>Trends (Weekly)</strong><br/>
<em>Sunday-Saturday aggregation</em>
</td>
</tr>
<tr>
<td align="center">
<strong>Trends (Daily)</strong><br/>
<em>Last 10 days with Show All Days option</em>
</td>
<td align="center">
<strong>Exercise Search</strong><br/>
<em>Find exercises by name or category</em>
</td>
<td align="center">
<strong>Splash Screen</strong><br/>
<em>App branding and logo</em>
</td>
</tr>
</table>

_Note: Screenshots are available in AppStore metadata for submission. See `/AppStore/` directory._

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Presentation  │───▶│    Domain    │◀───│      Data       │
│                 │    │              │    │                 │
│ • Views         │    │ • Entities   │    │ • Repositories  │
│ • ViewModels    │    │ • Use Cases  │    │ • SwiftData     │
│ • @Observable   │    │ • Protocols  │    │ • Mappers       │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

### Layer Responsibilities

**Presentation Layer**
- SwiftUI views and navigation
- `@Observable` ViewModels (Observation framework)
- User interaction handling
- UI state management

**Domain Layer** _(Pure Swift — NO SwiftUI/SwiftData imports)_
- Business entities (Exercise, Session, SetRecord)
- Use cases (UpsertExercise, CreateSession, ComputeVolumeTrend)
- Repository protocols
- Business logic and validation

**Data Layer**
- SwiftData `@Model` classes
- Repository implementations
- Domain ↔ Data mappers
- Persistence layer (SwiftData ModelContext)

### Key Design Decisions

📄 **Architecture Decision Records (ADRs):**
- [ADR-001: SwiftData Adoption](ADR/ADR-001-storage-swiftdata.md)
- [ADR-002: Clean Architecture](ADR/ADR-002-architecture-clean.md)
- [ADR-003: Sunday-Saturday Week Buckets](ADR/ADR-003-iso-week-aggregation.md) _(updated from ISO to Sunday-start)_
- [ADR-004: Personal Record Definition](ADR/ADR-004-pr-definition.md)

---

## 📦 Data Model

### Core Entities

**WorkoutSession**
```swift
struct WorkoutSession {
    let id: String
    let date: Date
    let note: String?
}
```

**SetRecord**
```swift
struct SetRecord {
    let id: String
    let sessionID: String
    let exerciseID: String
    let weight: Double
    let reps: Int
    let order: Int
    // Computed: volume = weight × reps
}
```

**Exercise**
```swift
struct Exercise {
    let id: String
    let name: String
    let main: ExerciseCategoryMain
    // Categories: lowerBody, upperBody, cardio, core, fullBody, arms, shoulders
}
```

### Relationships

```
Session (1) ─────────── (N) SetRecord
                           │
                           │ exerciseID
                           ▼
                        Exercise (1)
```

### SwiftData Constraints

⚠️ **Important Limitations:**
- No KeyPath chaining to value-type members (e.g., `\.name.localizedLowercase`)
- `FetchDescriptor.fetchLimit` is a **property**, not a constructor parameter
- `#Predicate<Model>` requires generic type annotation
- Use `SortDescriptor(\Model.property, order: .forward)` for sorting

---

## 🚀 Development Setup

### Prerequisites

- **Xcode 16+** (with full Xcode.app, not just Command Line Tools)
- **iOS 18.0+ Simulator** or physical device
- **macOS 15+** (Sequoia)
- **Swift 6** language mode enabled

### Clone & Build

```bash
# Clone repository
git clone https://github.com/jungseok-corine/WorkOut_Log.git
cd "WorkOut Log"

# Open in Xcode
open "WorkOut Log.xcodeproj"

# Or build from command line
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build
```

### Run Tests

```bash
# Run all unit and domain tests
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test

# Run specific test class
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test -only-testing:workout_logTests/WeeklyBucketTests

# Enable code coverage
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test -enableCodeCoverage YES
```

### Project Structure

```
WorkOut Log/
├── App/
│   ├── DI/AppContainer.swift          # Dependency injection
│   └── WorkOut_LogApp.swift           # App entry point
│
├── Presentation/
│   └── Scenes/
│       ├── SessionList/               # Session overview & list
│       ├── SessionDetail/             # Set management & editing
│       ├── Exercise/                  # Exercise search & picker
│       ├── Trends/                    # Volume trend charts
│       └── Splash/                    # App splash screen
│
├── Domain/                            # ⚠️ NO SwiftUI/SwiftData imports
│   ├── Entities/                      # Pure Swift structs
│   ├── UseCases/                      # Business logic
│   └── Repositories/                  # Protocol definitions only
│
├── Data/
│   ├── SwiftDataModels/               # @Model classes
│   ├── Repositories/                  # Repository implementations
│   └── Mappers/                       # Domain ↔ Data conversion
│
└── Tests/
    ├── DomainTests/                   # Unit tests (Domain layer)
    ├── DataTests/                     # Integration tests (Data layer)
    └── UITests/                       # UI automation tests
```

---

## 🧪 Testing

### Test Coverage

- **Domain Layer**: 85%+ coverage (use cases, entities, business logic)
- **Data Layer**: 75%+ coverage (repositories, SwiftData queries)
- **Presentation Layer**: UI tests for critical workflows

### Key Test Files

- `WeeklyBucketTests.swift`: Verifies Sunday-Saturday week aggregation
- `DailyTrendAxisTests.swift`: Validates ≤10 points cap and ordering
- `ExerciseRepositorySearchTests.swift`: Tests client-side filtering
- `SessionListViewModelTests.swift`: ViewModel state management

### Running Specific Tests

```bash
# Test weekly bucket aggregation
xcodebuild test -only-testing:workout_logTests/WeeklyBucketTests

# Test daily trend axis
xcodebuild test -only-testing:workout_logTests/DailyTrendAxisTests

# Test exercise search
xcodebuild test -only-testing:workout_logTests/ExerciseRepositorySearchTests
```

---

## ♿ Accessibility

### VoiceOver Support

- **Custom Labels**: All charts and controls have descriptive accessibility labels
- **Trends Chart**: "Daily training volume trend" / "Weekly training volume trend"
- **Axis Labels**: Combined labels for two-line axis marks (e.g., "October 9th" instead of separate "Oct" and "9")
- **Category Chips**: Identified as `categoryChip_all`, `categoryChip_lowerBody`, etc.

### Dynamic Type

- All text scales with user's preferred reading size
- Minimum touch target sizes (44×44pt) maintained
- Readable at all Dynamic Type sizes (XS to XXXL)

### High Contrast

- Sufficient color contrast ratios (WCAG AA compliant)
- Dark mode support with semantic colors
- Focus indicators for keyboard navigation

### Testing Accessibility

```bash
# Run accessibility audit in Xcode
# 1. Product → Analyze
# 2. Check "Accessibility" warnings

# Test VoiceOver manually
# 1. Simulator → Accessibility Inspector
# 2. Enable VoiceOver (Cmd+F5)
# 3. Navigate with Tab/Shift+Tab
```

---

## 🔒 Privacy & Data

### Zero Data Collection

- ✅ **No Analytics**: No Firebase, Mixpanel, or tracking SDKs
- ✅ **No Crash Reporting**: No Sentry, Crashlytics, or remote logging
- ✅ **No Network Requests**: 100% offline functionality
- ✅ **No Third-Party SDKs**: Pure Apple frameworks only

### Data Storage

- **Local Only**: All data stored on-device via SwiftData
- **iCloud Backup**: Optional (user-controlled via iOS Settings)
- **No Cloud Sync**: No custom cloud synchronization

### Privacy Policy

Full privacy policy available at:
- **File**: [AppStore/PrivacyPolicy.md](AppStore/PrivacyPolicy.md)
- **Web**: https://github.com/jungseok-corine/WorkOut_Log/blob/main/AppStore/PrivacyPolicy.md

**Summary**: We collect zero data. Your workouts stay on your device.

---

## 📱 App Store Submission

### Status

✅ **Ready for submission** — All metadata, screenshots, and documentation prepared.

### Submission Checklist

See [AppStore/SubmissionChecklist.md](AppStore/SubmissionChecklist.md) for complete guide.

**Quick submission:**
```bash
# 1. Build and test
xcodebuild -scheme workout_log -destination 'platform=iOS Simulator,name=iPhone 16' clean build test

# 2. Archive for distribution (in Xcode)
# Product → Archive → Distribute App → App Store Connect

# 3. Submit via App Store Connect
# https://appstoreconnect.apple.com
```

### Metadata

All App Store metadata ready in `/AppStore/` directory:
- English (`Description.en-US.md`, `Keywords.en-US.txt`, etc.)
- Korean (`Description.ko-KR.md`, `Keywords.ko-KR.txt`, etc.)
- Privacy policy (`PrivacyPolicy.md`)
- Review notes (`ReviewNotes.md`)

---

## 📚 Documentation

### For Developers

- **[Developer Guide](Docs/workout_log_guide.md)**: Comprehensive architecture guide
- **[Tutorial (HTML)](Docs/WorkoutLog_Tutorial.html)**: Printable beginner tutorial (A4-ready PDF export)
- **ADRs**: Architecture decision records in `/ADR/` directory

### For Users

- **Privacy Policy**: [AppStore/PrivacyPolicy.md](AppStore/PrivacyPolicy.md)
- **Release Notes**: [AppStore/ReleaseNotes.md](AppStore/ReleaseNotes.md)

### Generating Documentation

```bash
# Export documentation to PDF/HTML (if export script exists)
cd Docs && ./export.sh

# Output: Docs/exports/ with timestamped HTML and PDF files
```

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Swift 6 (strict concurrency) |
| **UI Framework** | SwiftUI |
| **State Management** | Observation framework (`@Observable`) |
| **Persistence** | SwiftData (iOS 17+) |
| **Charts** | Swift Charts |
| **Testing** | XCTest (unit + UI tests) |
| **Architecture** | Clean Architecture (3-layer) |
| **Deployment** | iOS 18.0+ |
| **IDE** | Xcode 16+ |

---

## 🚀 Continuous Integration & Deployment

### Fastlane Setup

This project uses [Fastlane](https://fastlane.tools) for automated building, testing, and deployment to TestFlight.

**Prerequisites:**
```bash
# Install Ruby dependencies
bundle install
```

**Available Lanes:**

```bash
# Run unit tests
bundle exec fastlane tests

# Increment build number and commit
bundle exec fastlane bump_build

# Build archive (automatic signing)
bundle exec fastlane build

# Upload to TestFlight (requires App Store Connect API key)
bundle exec fastlane beta

# Submit to App Store (manual review)
bundle exec fastlane release
```

### GitHub Actions CI

**Automated workflows:**
- **Pull Requests** → Runs `bundle exec fastlane tests` on every PR
- **Tag Pushes (`v*`)** → Builds and uploads to TestFlight automatically

**To trigger TestFlight upload:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Required GitHub Secrets** (Settings → Secrets and variables → Actions):
- `ASC_KEY_ID` — App Store Connect API Key ID
- `ASC_ISSUER_ID` — Issuer ID
- `ASC_KEY_CONTENT` — Base64-encoded .p8 file content

**Get App Store Connect API Key:**
1. Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. Create a new API key with "App Manager" role
3. Download the `.p8` file
4. Convert to Base64: `base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy`
5. Add to GitHub Secrets as `ASC_KEY_CONTENT`

---

## 🤝 Contributing

### Development Workflow

1. **Fork & Clone**: Fork this repo and clone locally
2. **Create Branch**: `git checkout -b feat/your-feature-name`
3. **Follow Architecture**: Respect Clean Architecture boundaries
4. **Add Tests**: Write unit tests for new use cases
5. **Commit Convention**: Use [Conventional Commits](https://www.conventionalcommits.org/)
   - `feat:` New feature
   - `fix:` Bug fix
   - `test:` Test updates
   - `docs:` Documentation changes
   - `refactor:` Code refactoring
6. **Submit PR**: Open pull request to `main` branch

### Code Standards

- **Swift 6** strict concurrency mode
- **No force unwraps** (`!`) in production code (use `guard let` or `if let`)
- **SwiftLint** rules enforced (if configured)
- **Domain layer purity**: NO `import SwiftUI` or `import SwiftData` in `/Domain/`

---

## 📧 Support

### Contact

- **Developer**: Ben (오정석 / Oh Jungseok)
- **Email**: fiverights99@gmail.com
- **GitHub Issues**: https://github.com/jungseok-corine/WorkOut_Log/issues

### Support URLs

- **App Support**: https://github.com/jungseok-corine/WorkOut_Log
- **Privacy Policy**: https://github.com/jungseok-corine/WorkOut_Log/blob/main/AppStore/PrivacyPolicy.md

### Reporting Bugs

Please open a GitHub issue with:
- iOS version
- Xcode version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)

---

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) file for details.

### MIT License Summary

```
Copyright (c) 2025 Oh Jungseok (Ben)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

**You are free to:**
- ✅ Use commercially
- ✅ Modify
- ✅ Distribute
- ✅ Sublicense

**Conditions:**
- Include original license and copyright notice
- Provided "as is" without warranty

---

## 🙏 Credits

**Developed by**: Ben (오정석 / Oh Jungseok)
**Architecture Guidance**: Claude (Anthropic AI Assistant)
**Design Philosophy**: Privacy-first, offline-first, user-first
**Built with**: ❤️ and Swift

---

## 📊 Project Status

**Version**: 1.0.0
**Status**: ✅ Ready for App Store submission
**Last Updated**: 2025-10-19

### Recent Updates

- ✅ Implemented Sunday-Saturday weekly trend buckets
- ✅ Added two-line axis labels for Daily and Weekly trends
- ✅ Fixed AxisValueLabel overload ambiguity with explicit `content:` parameter
- ✅ Comprehensive unit tests for trend calculations
- ✅ Full VoiceOver accessibility support

---

**⭐ Star this repo if you find it useful!**
**🐛 Found a bug? [Open an issue](https://github.com/jungseok-corine/WorkOut_Log/issues/new)**
**💬 Have questions? [Start a discussion](https://github.com/jungseok-corine/WorkOut_Log/discussions)**
