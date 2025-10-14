# WorkOut Log

A modern workout tracking app built with SwiftUI, SwiftData, and Clean Architecture for iOS 18+.

## Features

### Week 1 (CRUD Essentials) ✅
- [x] Session management (create, view, list)
- [x] Set tracking with live updates
- [x] Real-time volume calculation
- [x] SwiftData persistence with proper relationships
- [x] Clean Architecture (Presentation → Domain ← Data)
- [x] Comprehensive unit and UI tests
- [x] Dependency injection via AppContainer

### Week 2 (Analytics & Features) 🚧
- [x] Exercise categories (7 muscle groups)
- [x] BodyMetric entity for body composition tracking
- [x] Personal Records (PR) computation with Epley 1RM formula
- [x] Volume aggregation by category with ISO week support
- [x] Advanced use cases (ComputePR, ComputeVolumesByCategory)
- [ ] Weekly & monthly volume charts (using Charts framework)
- [ ] Exercise search and auto-complete UI
- [ ] Recent exercises functionality
- [ ] Body metrics tracking UI

### Week 3 (Documentation & Polish) ✅
- [x] Complete documentation with architecture diagrams
- [x] Architecture Decision Records (4 ADRs)
- [x] GitHub Actions CI/CD pipeline
- [x] Export documentation scripts (PDF/HTML)
- [x] Developer guide with Mermaid diagrams
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)
- [ ] Snapshot tests for key screens

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
- **SetRecord**: Weight, reps, exercise ID, order, and calculated volume
- **Exercise**: Name, category (7 muscle groups), and unique identifier
- **BodyMetric**: Body weight, body fat %, muscle mass with timestamps

### Relationships

```
WorkoutSession (1) ─── (many) SetRecord ─── (ref) Exercise
                                                      ↓
                                                 ExerciseCategory
BodyMetric ─── (independent) ─── Date timeline
```

## Contributing

1. Follow Clean Architecture boundaries
2. Use Conventional Commits (`feat:`, `fix:`, `test:`, etc.)
3. Add unit tests for new use cases
4. Update documentation for architectural changes

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Documentation

📚 **Complete technical documentation available:**

- **[Developer Guide](Docs/workout_log_guide.md)**: Comprehensive architecture guide with Mermaid diagrams
- **[ADR-001](ADR/ADR-001-storage-swiftdata.md)**: SwiftData adoption rationale
- **[ADR-002](ADR/ADR-002-architecture-clean.md)**: Clean Architecture principles
- **[ADR-003](ADR/ADR-003-iso-week-aggregation.md)**: ISO week calendar for analytics
- **[ADR-004](ADR/ADR-004-pr-definition.md)**: Personal Record definition with Epley formula

### Generate PDF Documentation

```bash
# Export all documentation to PDF and HTML
cd Docs && ./export.sh

# Output: Docs/exports/ with PDF and HTML files
```

---

**Current Status**: Week 1 foundations complete + Week 2 domain layer + comprehensive documentation. Ready for UI implementation and analytics features.