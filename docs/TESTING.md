# Testing

[< Back to README](../README.md)

## Automated Tests

Run the test suite:
```bash
xcodebuild test -scheme FlexSprinkle -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or use Xcode's test runner (Cmd + U)

## Manual Testing Checklist

### 1. Workout Creation & Management

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

### 2. Active Workout Flow

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

### 3. Workout History

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

### 4. Achievements & Dashboard

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

### 5. Settings & Customization

**Unit Preferences**
- [ ] Change weight units (lbs / kg)
- [ ] Verify unit change reflects in all views
- [ ] Change distance units (miles / km)
- [ ] Verify conversions are correct
- [ ] Change height units (inches / cm)

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

### 6. Sharing & Export

**Workout Export**
- [ ] Long-press a workout card
- [ ] Select "Share"
- [ ] Verify workout data exports correctly
- [ ] Share via AirDrop or save to Files
- [ ] Import the workout on another device (if available)
- [ ] Verify imported workout has all exercises, sets, and notes

### 7. Edge Cases & Error Handling

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

### 8. Regression Tests

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

## Testing Notes

- **Testing Device**: Document which device/iOS version you tested on
- **Test Date**: Record the date of testing
- **Issues Found**: Document any bugs or unexpected behavior
- **Screenshots**: Consider taking screenshots of any issues
- **Performance**: Note any slowdowns or lag

## Regression Testing Schedule

It's recommended to run through this checklist:
- Before each release
- After major feature additions
- After bug fixes that touch core functionality
- Quarterly for general health check
