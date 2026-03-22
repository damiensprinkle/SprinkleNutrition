# Changelog

[< Back to README](../README.md)

All notable changes to Soleus will be documented in this file.


## v1.0.2
### Improvements
 - Added customizable push notifications
 - Moved Import workout to Settings View

## v1.0.1

### Bug Fixes
- Fixed sheet flash/dismiss-reopen when tapping input fields in the edit workout view — moved sheet ownership from CardView to WorkoutTrackerMainView to prevent re-render interference
- Fixed workout cards getting stuck invisible after a long-press in reorder mode
- Fixed bottom buttons (Add Exercise, Start from Template) inconsistently hiding/showing when switching between input fields

### Improvements
- Replaced swipe-based workout reordering with iOS home screen-style long-press drag — long press a card to lift it, then drag to reorder; other cards shift to fill the gap
- Added keyboard dismiss ("Done" button) to the Add Exercise dialog
- Added scroll-to-focused-field behavior in the Add/Edit workout view so fields are never hidden behind the keyboard
- Added swipe-down dismiss warning when the Add/Edit workout sheet has unsaved changes
- Added 30-character limit with live counter to workout title, exercise name, and rename exercise fields
- Notes icon in the active workout view is now disabled and dimmed until the workout has been started
- Set number column in exercise rows is now styled as a non-editable label (muted color)
- Segmented pickers in the Add Exercise dialog now highlight the selected option in the app's blue accent color
- Added `time`, `distance`, `exerciseQuantifier`, and `exerciseMeasurement` support to workout templates, enabling Warmup and Cardio template types

## v1.0.0
- App released for test flight
