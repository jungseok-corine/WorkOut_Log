# WorkOut Log

A modern workout tracking app built with SwiftUI, SwiftData, and Clean Architecture for iOS 18+.

## Features

### Week 1 (CRUD Essentials) ✅
- [x] Session management (create, view, list)
- [x] Set tracking with live updates
- [x] Real-time volume calculation
- [x] SwiftData persistence with proper relationships
- [x] Clean Architecture (Presentation → Domain ← Data)

### Week 2 (Insights & Polish) 🚧
- [ ] Weekly & monthly volume charts (using Charts framework)
- [ ] Personal Records (PR) tracking with optional Epley 1RM
- [ ] Exercise search and auto-complete
- [ ] Quick-pick recent exercises
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)
- [ ] Snapshot tests for key screens

### Week 3 (DX & Release) 🚧
- [ ] Complete documentation with architecture diagrams
- [ ] Architecture Decision Records (ADRs)
- [ ] GitHub Actions CI/CD
- [ ] Export documentation scripts

## Architecture

This app follows **Global Clean Architecture** principles:

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Presentation  │───▶│    Domain    │◀───│      Data       │
│                 │    │              │    │                 │
│ • Views         │    │ • Entities   │    │ • Repositories  │
│ • ViewModels    │    │ • Use Cases  │    │ • SwiftData     │
│ • @Observable   │    │ • Protocols  │    │ • Mappers       │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

### Key Principles
- **Domain** is pure Swift (no SwiftUI/SwiftData imports)
- **Presentation** only knows Domain entities and use cases
- **Data** implements Domain protocols and handles persistence

## Tech Stack

- **iOS 18.6+** / **Swift 6**
- **SwiftUI** with **Observation** framework (`@Observable`)
- **SwiftData** for local persistence
- **Charts** framework for data visualization
- **XCTest** for unit and UI testing

## Module Structure

```
WorkOut Log/
├── App/
│   ├── DI/AppContainer.swift        # Dependency injection
│   └── WorkOut_LogApp.swift         # App entry point
├── Presentation/
│   └── Scenes/
│       ├── SessionList/             # Session overview
│       └── SessionDetail/           # Set management
├── Domain/
│   ├── Entities/                    # Core models
│   ├── UseCases/                    # Business logic
│   └── Repositories/                # Abstract protocols
├── Data/
│   ├── SwiftDataModels/             # SwiftData @Model classes
│   ├── Repositories/                # Repository implementations
│   ├── Mappers/                     # Domain ↔ Data conversion
│   └── Persistence/                 # SwiftData setup
└── Tests/
    ├── DomainTests/                 # Unit tests
    └── UITests/                     # Integration tests
```

## Getting Started

### Prerequisites
- Xcode 16+
- iOS 18.6+ Simulator or Device

### Build & Run

```bash
# Clone the repository
git clone https://github.com/jungseok-corine/WorkOut_Log.git
cd WorkOut_Log

# Open in Xcode
open "WorkOut Log.xcodeproj"

# Or build from command line
xcodebuild -scheme workout_log -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Run Tests

```bash
# Unit tests
xcodebuild -scheme workout_log -destination 'platform=iOS Simulator,name=iPhone 16' test

# UI tests (optional)
xcodebuild -scheme workout_logUITests -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Usage

1. **Create Session**: Tap "오늘 생성" to create a workout session for today
2. **Add Sets**: In session detail, enter weight and reps, then tap "Add Set"
3. **View Progress**: Session list shows total volume for each workout
4. **Clone Workouts**: Use "최근 복제" to repeat your last workout

## Data Model

### Core Entities

- **WorkoutSession**: Date, note, and collection of sets
- **SetRecord**: Weight, reps, exercise ID, and order within session
- **Exercise**: Name, body part, and unique identifier

### Relationships

```
WorkoutSession (1) ─── (many) SetRecord
                              ↓
                         Exercise (reference)
```

## Contributing

1. Follow Clean Architecture boundaries
2. Use Conventional Commits (`feat:`, `fix:`, `test:`, etc.)
3. Add unit tests for new use cases
4. Update documentation for architectural changes

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Current Status**: Week 1 implementation complete with full CRUD operations and live volume updates.