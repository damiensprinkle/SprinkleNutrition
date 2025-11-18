# FlexSprinkle

A comprehensive iOS fitness tracking application built with SwiftUI, focused on workout planning, tracking, and progress monitoring.

## Overview

FlexSprinkle is a native iOS app that helps users create custom workout plans, track active workout sessions in real-time, and monitor their fitness progress over time. Built with modern iOS technologies, it provides a smooth and intuitive user experience for fitness enthusiasts of all levels.

## Features

### 🏋️ Workout Management

- **Create Custom Workouts**: Build personalized workout plans with multiple exercises
  - Add unlimited exercises to each workout
  - Configure sets, reps, weight, time, and distance for each exercise
  - Support for both strength training (reps/weight) and cardio (time/distance)
  - Reorder exercises with up/down arrow controls
  - Rename exercises with modern dialog interface
  - Add notes to exercises for form cues, personal records, or reminders
  - Auto-populated sets (new sets copy values from previous set)

- **Workout Templates**:
  - Save workout plans as reusable templates
  - Duplicate existing workouts to create variations
  - Edit and update workout templates at any time
  - Color-coded workout cards for easy identification

- **Active Workout Tracking**:
  - Real-time workout timer with automatic time tracking
  - Track completion of individual sets with checkboxes
  - Auto-complete sets when both required fields are filled (e.g., reps AND weight)
  - **Edit Mode** for advanced modifications during workouts:
    - Add new exercises mid-workout
    - Add or remove sets (with set pre-population)
    - Rearrange exercises with up/down arrows
    - Edit exercise notes
    - Swipe-to-delete sets (only in edit mode)
  - **Workout Changes Preview**: Review all changes before updating your template
  - Resume workouts if you leave the app (persistent sessions)
  - Background time tracking when app is not active
  - Cancel or complete workouts with flexible template update options

### Progress Tracking

- **Workout History**:
  - View completed workouts by month and year
  - Detailed workout summaries showing:
    - Total workout duration
    - Total weight lifted
    - Total reps completed
    - Total cardio time
    - Total distance covered
  - Expandable exercise details for each workout session
  - Delete individual workout history entries

- **Workout Overview**:
  - Celebration screen upon workout completion with confetti animation
  - Instant display of workout statistics
  - Visual stat cards for key metrics

### Settings & Customization

- **Unit Preferences**:
  - Weight: lbs or kg
  - Distance: miles or km
  - Height: inches or cm

- **User Profile**:
  - Set and update user details
  - Personalized fitness data

### User Interface

- **Modern Design**:
  - Clean, intuitive SwiftUI interface
  - Dark mode support
  - Smooth animations and transitions
  - Custom tab navigation (Home, Workout, Settings)
  - Responsive layout adapting to different screen sizes

- **Visual Feedback**:
  - Animated card appearances
  - Smooth transitions between views
  - Active workout indicators
  - Progress animations

## Technical Details

### Technology Stack

- **Framework**: SwiftUI
- **Minimum iOS Version**: iOS 17.2+
- **Data Persistence**: CoreData
- **Architecture**: MVVM (Model-View-ViewModel)
- **Language**: Swift 5
- **Testing**: XCTest with unit tests

### Architecture Highlights

- **Protocol-Oriented Design**:
  - `WorkoutManaging` protocol for dependency injection and testability
  - Separation of concerns between managers, controllers, and view models

- **State Management**:
  - `@StateObject` and `@ObservableObject` for reactive UI updates
  - Environment objects for shared state across views
  - Combine framework for reactive data binding

- **Data Layer**:
  - CoreData for persistent storage
  - Background context operations for heavy data operations
  - Automatic merge of background changes to main context
  - Comprehensive error handling with custom `CoreDataError` types

- **Performance Optimizations**:
  - Background threading for database operations
  - Lazy loading for workout lists
  - Efficient CoreData fetch requests
  - Optimized animation rendering

### Project Structure

```
FlexSprinkle/
├── Models/               # Data models and Core Data entities
│   ├── CoreData/        # Core Data classes and properties
│   ├── AppViewModel.swift
│   ├── CoreDataError.swift
│   └── ErrorHandler.swift
├── Views/               # SwiftUI views
│   ├── Main/           # Home, tabs, and navigation
│   ├── WorkoutTracker/ # Workout-related views
│   ├── Cards/          # Reusable card components
│   └── SharedComponents/ # Common UI components
├── ViewModels/         # View models
├── Controllers/        # Business logic controllers
├── Manager/            # Data managers (WorkoutManager, UserManager)
└── Helpers/            # Utility classes and extensions
```

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.2+ device or simulator
- macOS with Apple Silicon or Intel processor

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/damiensprinkle/FlexSprinkle.git
   cd FlexSprinkle
   ```

2. Open the project in Xcode:
   ```bash
   open FlexSprinkle.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the project (⌘ + R)

### First Launch

On first launch, you'll be prompted to enter your user details. This is a one-time setup that personalizes your experience.

## Usage Guide

### Creating a Workout

1. Navigate to the Workout tab
2. Tap the "+" button in the navigation bar
3. Enter a workout title
4. Tap "Add Exercise" to add exercises
5. Configure sets, reps, weight, or cardio parameters
6. Tap "Save" to create your workout template

### Starting a Workout

1. From the Workout tab, tap on a workout card
2. Tap "Start Workout" to begin tracking
3. Check off sets as you complete them
4. Modify exercises or add sets as needed during your workout
5. Tap "Complete Workout" when finished

### Viewing History

1. Navigate to the Workout tab
2. Tap the clock icon in the navigation bar
3. Use the month/year picker to browse past workouts
4. Tap on any workout card to expand and view details

## Recent Updates & Improvements

### Performance Enhancements
- Migrated heavy CoreData operations to background threads
- Implemented async completion handlers for UI coordination
- Optimized database queries for faster loading

### Bug Fixes
- Fixed navigation title loading delays
- Resolved active workout session persistence issues
- Fixed duplicate workout UI update timing
- Corrected workout overview data display

### UI/UX Improvements
- Added smooth animations for workout history cards
- Improved background color consistency across views
- Enhanced visual feedback during workout operations
- Added staggered card animations for better user experience

### Code Quality
- Introduced comprehensive error handling
- Added unit tests for core functionality
- Implemented protocol-based architecture for better testability
- Fixed iOS 18 compatibility issues
- Removed force unwrapping for safer code execution

## Development Roadmap

### Planned Features
- Home dashboard with workout statistics widgets
- Advanced analytics and progress charts
- Workout sharing and import/export
- Rest timer between sets
- Exercise library with instructions
- Body measurement tracking
- Custom workout categories

### Technical Improvements
- Expanded test coverage
- Accessibility enhancements (VoiceOver, Dynamic Type)
- CloudKit integration for data sync across devices
- Widget support for quick workout access

## Testing

### Automated Tests

Run the test suite:
```bash
xcodebuild test -scheme FlexSprinkle -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or use Xcode's test runner (⌘ + U)

### Manual Testing Checklist

#### 1. Workout Creation & Management

**Basic Workout Creation**
- [ ] Create a new workout with a unique title
- [ ] Add exercises of different types (Reps, Weight & Reps, Time, Distance)
- [ ] Add multiple sets to an exercise
- [ ] Verify "Add Set" pre-populates values from previous set
- [ ] Remove sets using swipe-to-delete
- [ ] Reorder exercises using up/down arrows
- [ ] Delete exercises using trash icon
- [ ] Save the workout successfully
- [ ] Verify workout appears on main screen

**Exercise Notes**
- [ ] Tap notebook icon on an exercise (should show gray icon)
- [ ] Add notes to an exercise
- [ ] Verify notebook icon changes to orange with badge
- [ ] Verify notes appear below exercise title
- [ ] Edit existing notes
- [ ] Clear notes (delete all text and save)
- [ ] Verify notebook icon returns to gray

**Workout Template Management**
- [ ] Edit an existing workout template
- [ ] Rename exercises using pencil icon
- [ ] Duplicate a workout (verify all exercises and sets copied)
- [ ] Customize workout card color
- [ ] Delete a workout template
- [ ] Rearrange workouts on main screen using swipe gestures

**Validation**
- [ ] Try to save workout with empty title (should show error)
- [ ] Try to save workout with no exercises (should show error)
- [ ] Try to create workout with duplicate title (should show error)
- [ ] Cancel workout creation with unsaved changes (should show warning)

#### 2. Active Workout Flow

**Starting a Workout**
- [ ] Tap play button on workout card
- [ ] Verify exercises and sets load correctly
- [ ] Tap "Start Workout" button (requires double confirmation)
- [ ] Verify timer starts and displays correctly
- [ ] Verify timer continues when app is backgrounded
- [ ] Verify active workout indicator appears on card (green animated icon)

**Completing Sets - Manual**
- [ ] Check off a set using the slider/toggle
- [ ] Verify set marks as complete
- [ ] Uncheck a completed set
- [ ] Check multiple sets in sequence

**Completing Sets - Auto-completion**
- [ ] For Weight & Reps exercise: Enter weight only (should NOT auto-complete)
- [ ] Enter reps only (should NOT auto-complete)
- [ ] Enter BOTH weight and reps (should auto-complete)
- [ ] Verify auto-completion only triggers when values are modified, not just pre-populated
- [ ] Test auto-completion for Time exercises
- [ ] Test auto-completion for Distance exercises

**Edit Mode - During Active Workout**
- [ ] Tap pencil icon to enter edit mode
- [ ] Verify pencil icon changes to green checkmark
- [ ] Verify up/down arrows appear for exercises (when applicable)
- [ ] Verify "Add Set" button appears
- [ ] Add a new set (verify it pre-populates from last set)
- [ ] Delete a set using swipe-to-delete (only works in edit mode)
- [ ] Try to swipe-delete when NOT in edit mode (should not work)
- [ ] Rearrange exercises using up/down arrows
- [ ] Tap plus icon to add a new exercise during workout
- [ ] Add notes to an exercise during workout
- [ ] Exit edit mode (tap checkmark)

**Completing a Workout - No Changes**
- [ ] Complete a workout without making changes
- [ ] Tap "End Workout" (requires double-tap)
- [ ] Verify redirects to workout overview screen
- [ ] Verify confetti animation plays
- [ ] Verify workout stats are correct (weight, reps, time, distance)

**Completing a Workout - With Changes**
- [ ] Modify a workout during session (add/remove sets, add exercises, change values)
- [ ] Tap "End Workout"
- [ ] Verify workout changes preview appears
- [ ] Review the changes shown (added/removed exercises, modified sets)
- [ ] Choose "Update Workout" option
- [ ] Verify template is updated with changes
- [ ] Start the workout again and verify changes were saved

**Completing a Workout - Keep Original**
- [ ] Modify a workout during session
- [ ] Tap "End Workout"
- [ ] In preview, choose "Keep Original Values"
- [ ] Verify workout history is saved but template unchanged
- [ ] Start the workout again and verify original template intact

**Canceling a Workout**
- [ ] Start a workout
- [ ] Tap "Back" button
- [ ] Verify session is saved (can resume)
- [ ] Close and reopen app
- [ ] Verify workout resume banner appears
- [ ] Cancel the workout session

#### 3. Workout History

**Viewing History**
- [ ] Tap clock icon to view history
- [ ] Change month/year picker
- [ ] Verify workouts for selected month appear
- [ ] Tap to expand workout details
- [ ] Verify all stats are correct
- [ ] Verify exercise details show correctly
- [ ] Collapse workout details

**Empty States**
- [ ] View a month with no workouts (should show empty state message)
- [ ] Verify no crashes or errors

**History Persistence**
- [ ] Delete a workout template
- [ ] Verify history for that workout is still preserved
- [ ] Verify stats/achievements remain accurate

#### 4. Achievements & Dashboard

**Achievement Tracking**
- [ ] Complete workouts to unlock achievements
- [ ] Verify achievement notifications appear
- [ ] Check Dashboard for unlocked achievements
- [ ] Verify achievement progress updates correctly

**Workout Streaks**
- [ ] Complete a workout today
- [ ] Verify current streak increments
- [ ] Skip a day and verify streak resets
- [ ] Verify longest streak is preserved

**Personal Records**
- [ ] Check PR for heaviest single workout
- [ ] Check PR for most reps in one workout
- [ ] Check PR for longest workout duration
- [ ] Check PR for furthest distance
- [ ] Complete a workout that beats a PR and verify it updates

#### 5. Settings & Customization

**Unit Preferences**
- [ ] Change weight units (lbs ↔ kg)
- [ ] Verify unit change reflects in all views
- [ ] Change distance units (miles ↔ km)
- [ ] Verify conversions are correct
- [ ] Change height units (inches ↔ cm)

**Color Customization**
- [ ] Long-press a workout card
- [ ] Select "Customize Card"
- [ ] Change workout card color
- [ ] Verify color persists after app restart

**Dark Mode**
- [ ] Toggle device dark mode
- [ ] Verify all screens render correctly in dark mode
- [ ] Check that StaticWhite color remains white in dark mode
- [ ] Verify text contrast is sufficient

#### 6. Sharing & Export

**Workout Export**
- [ ] Long-press a workout card
- [ ] Select "Share"
- [ ] Verify workout data exports correctly
- [ ] Share via AirDrop or save to Files
- [ ] Import the workout on another device (if available)
- [ ] Verify imported workout has all exercises, sets, and notes

#### 7. Edge Cases & Error Handling

**Data Integrity**
- [ ] Create a workout with many exercises (15+)
- [ ] Create a workout with many sets per exercise (20+)
- [ ] Add very long exercise names
- [ ] Add very long notes (multiple paragraphs)
- [ ] Enter maximum weight values
- [ ] Enter maximum rep values
- [ ] Enter maximum time values (hours)

**App State Management**
- [ ] Start a workout and background the app for 1 minute
- [ ] Verify timer continues accurately
- [ ] Force quit app during active workout
- [ ] Reopen app and verify session can resume
- [ ] Test multiple workout sessions in same day

**UI Responsiveness**
- [ ] Test all interactions with keyboard open
- [ ] Verify keyboard dismisses when tapping outside text fields
- [ ] Test on different device sizes (iPhone SE, iPhone 15 Pro Max)
- [ ] Test in landscape orientation
- [ ] Verify all dialogs appear correctly
- [ ] Verify no UI elements are clipped or overlapping

#### 8. Regression Tests

**Core Functionality Preservation**
- [ ] Verify old workouts (created before updates) still load correctly
- [ ] Verify old workout history entries display correctly
- [ ] Verify achievements earned before updates still show
- [ ] Test that all previous features still work after new updates

**Performance**
- [ ] App launches in under 3 seconds
- [ ] Workout list loads quickly (< 1 second)
- [ ] History view loads smoothly
- [ ] No lag when checking off sets during workout
- [ ] No lag when adding exercises or sets
- [ ] Smooth animations throughout the app

**Data Persistence**
- [ ] Create workout, force quit app, verify workout saved
- [ ] Complete workout, force quit app, verify history saved
- [ ] Modify settings, force quit app, verify settings saved
- [ ] Start workout, force quit app, verify session can resume

### Testing Notes

- **Testing Device**: Document which device/iOS version you tested on
- **Test Date**: Record the date of testing
- **Issues Found**: Document any bugs or unexpected behavior
- **Screenshots**: Consider taking screenshots of any issues
- **Performance**: Note any slowdowns or lag

### Regression Testing Schedule

It's recommended to run through this checklist:
- Before each release
- After major feature additions
- After bug fixes that touch core functionality
- Quarterly for general health check

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is private and proprietary.

## Project Status

Active development - The app is functional and continually being improved with new features and optimizations.

## Contact

- Developer: Damien Sprinkle
- Project Board: [Trello Board](https://trello.com/b/cKlOY11d/workout)
