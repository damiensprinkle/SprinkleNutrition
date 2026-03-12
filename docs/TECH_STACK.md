# Tech Stack

[< Back to README](../README.md)

## Technology Stack

- **Framework**: SwiftUI
- **Minimum iOS Version**: iOS 17.2+
- **Data Persistence**: CoreData
- **Architecture**: MVVM (Model-View-ViewModel)
- **Language**: Swift 5
- **Testing**: XCTest with unit tests

## Architecture Highlights

### Protocol-Oriented Design

- `WorkoutManaging` protocol for dependency injection and testability
- Separation of concerns between managers, controllers, and view models

### State Management

- `@StateObject` and `@ObservableObject` for reactive UI updates
- Environment objects for shared state across views
- Combine framework for reactive data binding

### Data Layer

- CoreData for persistent storage
- Background context operations for heavy data operations
- Automatic merge of background changes to main context
- Comprehensive error handling with custom `CoreDataError` types

### Performance Optimizations

- Background threading for database operations
- Lazy loading for workout lists
- Efficient CoreData fetch requests
- Optimized animation rendering

## Project Structure

```
Soleus/
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
