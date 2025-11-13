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
  - Reorder exercises with drag-and-drop functionality
  - Rename exercises on the fly

- **Workout Templates**:
  - Save workout plans as reusable templates
  - Duplicate existing workouts to create variations
  - Edit and update workout templates at any time
  - Color-coded workout cards for easy identification

- **Active Workout Tracking**:
  - Real-time workout timer with automatic time tracking
  - Track completion of individual sets with checkboxes
  - Modify exercises and sets during active workouts
  - Resume workouts if you leave the app (persistent sessions)
  - Background time tracking when app is not active
  - Cancel or complete workouts with optional template updates

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

Run the test suite:
```bash
xcodebuild test -scheme FlexSprinkle -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or use Xcode's test runner (⌘ + U)

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is private and proprietary.

## Project Status

Active development - The app is functional and continually being improved with new features and optimizations.

## Contact

- Developer: Damien Sprinkle
- Project Board: [Trello Board](https://trello.com/b/cKlOY11d/workout)
