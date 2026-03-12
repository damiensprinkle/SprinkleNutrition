# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Soleus is an iOS workout tracking application built with SwiftUI and CoreData. Development is active as of March 2026.

## Build and Development Commands

```bash
# Build the project
xcodebuild -scheme Soleus -configuration Debug build

# Run tests
xcodebuild -scheme Soleus -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' test

# Clean build folder
xcodebuild clean -scheme Soleus
```

## Architecture Overview

### MVVM Pattern with Manager Layer

The app follows MVVM architecture with an additional Manager layer:
- **Views**: Pure SwiftUI views, no UIKit (except UIViewControllerRepresentable wrappers)
- **Controllers**: `WorkoutTrackerController` bridges Managers and Views, manages UI state
- **Managers**: `WorkoutManager` (600+ lines of business logic), `ColorManager`, `FocusManager`, `RestTimerManager`, `AchievementManager`
- **Models**: CoreData entities + lightweight transfer objects

### CoreData Persistence Architecture

**Dual-State Pattern** - Key architectural decision:
- `Workouts` → `WorkoutDetail` → `WorkoutSet` = Templates/Plans (persistent)
- `TemporaryWorkoutDetail` → `WorkoutSet` = Active workout state (ephemeral)

When a workout is started, the template is copied to temporary entities. Users can modify sets during the workout without affecting the template. On completion, they're prompted to update the template if changes were made.

**Session Persistence**:
- `WorkoutSession` entity tracks active workouts with `startTime` and `isActive`
- Enables workout timer recovery after app backgrounding
- Only one active workout allowed at a time

**History Snapshots**:
- `WorkoutHistory` stores complete workout snapshots on completion
- Includes all exercise details, sets, and aggregated metrics
- Retrieved monthly for history view

**CoreData Stack**:
- Managed by `PersistenceController` singleton
- Container name: "Model"
- `NSManagedObjectModel` is a shared static instance to prevent duplicate model registration errors in tests
- Context injected into Managers via property observers
- Manual save calls (no auto-save)
- Merge policy: `NSMergeByPropertyObjectTrumpMergePolicy`

### Custom Navigation System

Navigation is **state-based** (not NavigationStack), managed by `AppViewModel`:

```swift
@Published var currentView: ContentViewType = .main

enum ContentViewType {
    case main
    case workoutOverview(UUID)
    case workoutActiveView(UUID)
    case workoutHistoryView
    case customizeCardView(UUID)
}
```

All navigation happens through `appViewModel.navigateTo()`. The `WorkoutContentMainView` switches views based on `currentView` state. Back buttons manually call `appViewModel.resetToWorkoutMainView()`.

### Key View Hierarchy

```
HomeView (root)
└── CustomTabView
    ├── HomeContentView (placeholder)
    ├── WorkoutContentMainView
    │   └── NavigationView wraps switch statement:
    │       ├── WorkoutTrackerMainView (grid of workout cards)
    │       ├── ActiveWorkoutView (workout in progress)
    │       ├── WorkoutOverviewView (completion summary)
    │       ├── WorkoutHistoryView (past workouts)
    │       └── CustomizeCardView (color picker)
    └── SettingsView
        ├── FAQView (sheet)
        ├── PrivacyPolicyView (sheet)
        └── ContactUsView (sheet)
```

**Critical Navigation Rule**: Only `WorkoutContentMainView` should have a `NavigationView`. Child views must not wrap themselves in `NavigationView` or navigation will break (white screen bug when returning from empty views).

### Dependency Injection Pattern

Environment objects injected from `SoleusApp`:
```swift
@StateObject private var persistenceController = PersistenceController.shared
@StateObject private var appViewModel = AppViewModel()
@StateObject private var workoutManager = WorkoutManager()
@StateObject private var controller = WorkoutTrackerController(workoutManager: workoutManager)

// Views receive these via .environmentObject()
```

CoreData context is injected separately:
```swift
.environment(\.managedObjectContext, persistenceController.container.viewContext)
```

## Core Workflows

### Active Workout Flow (Critical Path)

1. User taps play button → `ActiveWorkoutView` loads
2. User confirms "Start Workout" → `WorkoutManager.setSessionStatus(isActive: true)`
3. `WorkoutSession` created with `startTime` for timer persistence
4. Template data copied to `TemporaryWorkoutDetail` entities
5. User edits sets → `saveOrUpdateSetsDuringActiveWorkout()` updates temporary entities
6. User taps "End Workout" (double confirmation required)
7. If modified → Prompt "Update Workout?"
8. `saveWorkoutHistory()` creates snapshot with aggregated metrics:
   - Total weight lifted
   - Reps completed
   - Cardio time and distance
9. `deleteAllTemporaryWorkoutDetails()` cleans up temporary state
10. `setSessionStatus(isActive: false)` clears session
11. Navigate to `WorkoutOverviewView` with confetti animation

**State Management During Workouts**:
- `workoutController.hasActiveSession` indicates if any workout is active
- `workoutController.activeWorkoutId` stores the active workout UUID
- Active workouts show animated green icon on card
- Active workouts cannot be edited or deleted
- Resume banner appears on main view if session exists

### Workout Template Management

**WorkoutTrackerController State**:
- `workoutDetails`: Editable in-memory state (array of `WorkoutDetailInput`)
- `originalWorkoutDetails`: Immutable copy for change detection
- Dirty checking on save determines if confirmation dialog needed

**Adding Exercises**:
- `AddExerciseDialog` modal for exercise name input
- Exercise added with default 3 sets
- Sets configured with: reps, weight, time, or distance
- `exerciseQuantifier` enum determines which fields are active

**Saving Changes**:
- `WorkoutManager.addWorkoutDetail()` or `updateWorkoutDetail()`
- Validation in controller before persistence
- Result<Void, WorkoutSaveError> pattern for error handling

### Workout Import/Export

- `ShareableWorkout` is the codable transfer object for `.soleus` files
- `DocumentPicker` (UIViewControllerRepresentable) opens the system file picker
- `ImportWorkoutPreviewView` is presented as a sheet to confirm name and preview exercises before importing
- Duplicate workout names are auto-resolved with a `-copy` suffix

### Contact Us

- `ContactUsView` is a sheet accessible from Settings
- Bug reports open `MFMailComposeViewController` pre-filled with device/app info and optionally attach `soleus-logs.txt` from `LogCapture.shared`
- Feature requests open a pre-filled email template (no logs attached)
- On simulator `canSendMail()` returns false — a "Mail Not Available" alert is shown instead
- Support email: `SoleusApp@gmail.com` (defined as `ContactUsView.supportEmail`)

## Important Conventions

### File Organization
- CoreData entity files: Auto-generated pairs (Class + Properties extensions)
- Helpers in global scope: `TimeHelper`, `ExerciseInputHelper`
- Shared UI components: `Views/SharedComponents/`
- Settings subviews: `Views/Main/`

### Navigation Bar Items
**Always combine multiple trailing items in HStack**:
```swift
.navigationBarItems(trailing: HStack(spacing: 20) {
    Button(...) { }
    Button(...) { }
})
```
Never use multiple `.navigationBarItems(trailing:)` calls - only the last one will render.

### Color System
15 custom colors defined in Assets.xcassets:
- MyBlue, MyBabyBlue, MyLightBlue, MyGreyBlue
- MyPurple, MyOrchid
- MyBrown, MyLightBrown, MyTan
- MyGreen, MyRed
- MyBlack, MyWhite, MyGrey, StaticWhite

`ColorManager` randomly assigns colors to new workouts. Users can customize via `CustomizeCardView`.

### Logging
- Use `AppLogger` (not `print()`) throughout production code
- `LogCapture.shared` holds the last 500 in-memory log entries
- In-app log viewer accessible via 5-tap secret trigger in the About section of Settings
- Logs are categorized: workout, coreData, ui, navigation, validation, lifecycle

### Input Validation
- Regex patterns for form validation
- Max length constraints (typically 10 for numeric inputs)
- `FocusManager` handles keyboard state

### Accessibility Identifiers
- All interactive elements used in UI tests must have `.accessibilityIdentifier(AccessibilityID.someKey)`
- `AccessibilityID` (app target) and `TestID` (UI test target) must be kept in sync
- Both files live at `Soleus/Helpers/AccessibilityIdentifiers.swift` and `SoleusUITests/TestAccessibilityIDs.swift`

## Testing

### Test Targets
- `SoleusTests` — unit tests (~35 coverage on production code, ~98% self-coverage)
- `SoleusUITests` — UI tests using `SoleusUITestBase`

### CoreData in Unit Tests
- Use `PersistenceController.forUITesting` (static `let`, not computed var) to avoid duplicate `NSManagedObjectModel` registration errors
- Always delete test data in `tearDown` and save the context

### UI Test Patterns
- Base class: `SoleusUITestBase` — launches with `--uitesting` arg, provides `tapTab()`, `tapNavBarButton()`, `waitForElement()`
- Inject test data via `launchEnvironment`: `UI_TEST_IMPORT_WORKOUT` (JSON), `UI_TEST_PRE_CREATE_WORKOUT` (name)
- Toggles in Forms: use `coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()` to avoid hitting the cell row instead of the switch handle

## Dependencies

**ConfettiSwiftUI**: v1.1.0
- Only external dependency
- Used in `WorkoutOverviewView` for workout completion celebration
- Package: https://github.com/simibac/ConfettiSwiftUI.git

## Known Issues and Patterns

### Empty State Handling
Views must handle empty states explicitly:
- Empty workout list: Show grid anyway
- Empty history: Show placeholder message with icon
- Empty sets: Show "Add Set" button

### Timer Persistence
Timer is **calculated** not stored:
```swift
let elapsed = Date().timeIntervalSince(session.startTime)
```
This ensures timer remains accurate after app backgrounding.

## Data Model Relationships

```
Workouts (1) ←→ (many) WorkoutDetail
    ↓                       ↓
WorkoutSession (1:1)   WorkoutSet (many)

Workouts (1) ←→ (many) WorkoutHistory
                            ↓
                      WorkoutDetail snapshot
                            ↓
                      WorkoutSet snapshot
```

`TemporaryWorkoutDetail` mirrors `WorkoutDetail` structure but exists only during active workouts.

## Project Status

- Active development as of March 2026
- Targeting TestFlight release
- Nutrition tracking feature was removed (see commit 3e42e7b)
- Home tab is currently a placeholder
- CI pipeline: GitHub Actions on `macos-26`, scheme `Soleus`, posts coverage report to PRs
