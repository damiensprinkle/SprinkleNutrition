# Tech Stack

[< Back to README](../README.md)

## Technology Stack

- **Language**: Swift 5
- **Framework**: SwiftUI (no UIKit views except `UIViewControllerRepresentable` wrappers)
- **Minimum iOS Version**: iOS 17.2+
- **Data Persistence**: CoreData (`NSPersistentContainer`)
- **Architecture**: MVVM with a Manager layer
- **Testing**: XCTest (unit tests) + XCUITest (UI tests)
- **External Dependencies**: ConfettiSwiftUI v1.1.0

## Architecture

### Layer Responsibilities

| Layer | Role |
|---|---|
| **Views** | Pure SwiftUI. No business logic. |
| **Controllers** | Bridge between Managers and Views. Own UI state. |
| **Managers** | All business logic and CoreData operations. |
| **Models** | CoreData entities + lightweight transfer objects (`WorkoutDetailInput`, `SetInput`, etc.) |

### Key Classes

- **`WorkoutTrackerController`** — Central controller for the workout tab. Owns `workoutDetails`, `workouts`, and session state. Passed as `@EnvironmentObject` throughout the workout flow.
- **`WorkoutManager`** (~600 lines) — All CoreData reads/writes for workouts, history, sessions, and sets.
- **`AppViewModel`** — Manages custom state-based navigation. Owns `currentView: ContentViewType`.
- **`AchievementManager`** — Evaluates and persists milestone achievements after each workout.
- **`RestTimerManager`** — Countdown timer for between-set rest periods. Published as an environment object.
- **`FocusManager`** — Tracks keyboard/focus state across exercise row fields. Used to drive scroll-to-focused-field behavior and hide/show bottom buttons.
- **`ColorManager`** — Randomly assigns colors to new workouts from the 15-color palette.
- **`HapticManager`** — Centralized haptic feedback (set completion, reorder, etc.).
- **`PersistenceController`** — CoreData stack singleton. Shared static instance prevents duplicate `NSManagedObjectModel` registration in tests.
- **`LogCapture`** — Retains last 500 in-memory log entries for in-app diagnostics and bug report attachments.

### Navigation System

Navigation is **state-based**, not `NavigationStack`-based, managed by `AppViewModel`:

```swift
enum ContentViewType {
    case main
    case workoutOverview(UUID)
    case workoutActiveView(UUID)
    case workoutHistoryView
    case customizeCardView(UUID)
    case achievementsView
}
```

All navigation goes through `appViewModel.navigateTo()`. `WorkoutContentMainView` switches views based on `currentView`. Only `WorkoutContentMainView` wraps content in `NavigationView` — child views must not add their own or a white-screen bug occurs on back navigation.

### CoreData — Dual-State Pattern

| Entities | Purpose |
|---|---|
| `Workouts` → `WorkoutDetail` → `WorkoutSet` | Templates / plans (persistent) |
| `TemporaryWorkoutDetail` → `WorkoutSet` | Active workout state (ephemeral, deleted on completion) |
| `WorkoutSession` | Tracks the active session's start time for timer recovery |
| `WorkoutHistory` → `WorkoutDetail` → `WorkoutSet` | Completed workout snapshots (permanent record) |

When a workout starts, the template is copied to `TemporaryWorkoutDetail` entities. Users modify sets during the session without touching the template. On completion, the user is prompted to optionally update the template with any changes made.

### Logging

```swift
AppLogger.workout.debug("...")
AppLogger.coreData.error("...")
AppLogger.validation.warning("...")
// Categories: workout, coreData, ui, navigation, validation, lifecycle
```

Use `AppLogger` (not `print()`) throughout production code. `LogCapture.shared` taps into the OSLog stream and retains the last 500 entries in memory for the in-app log viewer and bug report attachments.

### Input Validation

- Max length constraints enforced with live counters in the UI (30 chars for titles and exercise names)
- `validateAndSetInputInt` / `validateAndSetInputFloat` helpers in `ExerciseInputHelper`
- `FocusableField` enum drives `@FocusState` across all exercise row text fields

### Accessibility

All interactive elements used in UI tests carry `.accessibilityIdentifier(AccessibilityID.someKey)`. The `AccessibilityID` struct (app target) and `TestID` struct (UI test target) must be kept in sync. Both live at:
- `Soleus/Helpers/AccessibilityIdentifiers.swift`
- `SoleusUITests/TestAccessibilityIDs.swift`

## External Dependencies

| Package | Version | Purpose |
|---|---|---|
| [ConfettiSwiftUI](https://github.com/simibac/ConfettiSwiftUI) | 1.1.0 | Confetti cannon animation on workout completion |

## Project Structure

```
Soleus/
├── Models/
│   ├── CoreData/             # Auto-generated CoreData entity classes
│   ├── AppViewModel.swift    # Navigation state
│   ├── WorkoutTemplates.swift # Built-in workout templates
│   └── Transfer objects      # WorkoutDetailInput, SetInput, ShareableWorkout, etc.
├── Views/
│   ├── Main/                 # HomeView, CustomTabView, SettingsView, ContactUsView, FAQView, etc.
│   ├── WorkoutTracker/
│   │   ├── ModifyWorkout/    # AddWorkoutView, AddExerciseDialog, RenameExerciseDialogView, etc.
│   │   ├── Shared/           # ExerciseRow, ExerciseRowActive, SetHeaders, etc.
│   │   └── ActiveWorkout     # ActiveWorkoutView, WorkoutOverviewView, WorkoutHistoryView, etc.
│   ├── Cards/                # CardView, WorkoutHistoryCardView, DataCardView, etc.
│   └── SharedComponents/     # Reusable UI components
├── Controllers/
│   ├── WorkoutTrackerController.swift
│   └── PersistenceController.swift
├── Manager/
│   ├── WorkoutManager.swift  # All CoreData workout operations (~600 lines)
│   ├── AchievementManager.swift
│   ├── RestTimerManager.swift
│   ├── FocusManager.swift
│   ├── ColorManager.swift
│   └── HapticManager.swift
├── Enums/                    # ModalType, FocusableField, ActiveAlert, etc.
├── Helpers/
│   ├── AccessibilityIdentifiers.swift
│   ├── TimeHelper.swift
│   ├── ExerciseInputHelper.swift
│   ├── AppLogger.swift
│   └── LogCapture.swift
└── Assets.xcassets/          # 15 custom colors + app icons
```

## Build Commands

```bash
# Build
xcodebuild -scheme Soleus -configuration Debug build

# Run all tests
xcodebuild -scheme Soleus -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' test

# Clean
xcodebuild clean -scheme Soleus
```

## Testing Architecture

- **`SoleusTests`** — Unit tests using `PersistenceController.forUITesting` (in-memory store). Always delete test data in `tearDown`.
- **`SoleusUITests`** — UI tests using `SoleusUITestBase`. Launches with `--uitesting` arg. Test data injected via `launchEnvironment` keys (`UI_TEST_IMPORT_WORKOUT`, `UI_TEST_PRE_CREATE_WORKOUT`).
- Coverage: ~35% on production code, ~98% self-coverage on test helpers.
