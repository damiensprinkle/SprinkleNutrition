# Soleus — Product Roadmap

[< Back to README](../README.md)

This document outlines all planned features for Soleus, organized by priority tier and tagged as **Free** or **Pro**. The core workout experience will always remain free. Pro is intended as a low-cost upgrade (one-time purchase or annual subscription) for users who want advanced analytics, integrations, and platform extensions.

---

## Tier 1 — Near Term (High Impact, Low Effort)

These features build directly on existing infrastructure and can be shipped quickly.

---

### Enhanced Workout Overview `Free`

**Problem:** The workout completion screen feels repetitive when no achievements are unlocked — the user just sees stat cards and a Proceed button with nothing to make the session feel meaningful.

**Solution:**
- Always show elapsed time prominently at the top of the overview regardless of workout type
- Add a "Best Set" callout — highlight the single heaviest or highest-volume set from the session (e.g., "New best: Bench Press 185 lbs × 5")
- Add a motivational summary line that varies based on session data (e.g., "Great session — 12,400 lbs moved in 48 minutes")
- Surface Personal Records detected during this workout as a distinct banner, separate from the achievements section, so PRs appear even when no achievement milestone is crossed
- Ensure the screen never feels empty — if no stats, achievements, or PRs are present, show an encouraging message with workout duration

---

### Personal Records (PRs) `Free`

**Problem:** Users have no way to know when they hit a new max weight, rep count, or volume for a given exercise. This is one of the most motivating pieces of feedback in strength training.

**Solution:**
- After each workout completes, compare completed sets against the entire history for each exercise
- Detect three types of PR: max weight lifted (single set), max reps at a given weight, and highest total volume (sets × reps × weight) in a session
- Store PRs in CoreData alongside workout history so they persist and can be queried
- Display newly broken PRs on the Workout Overview screen with a distinct badge
- Show the current PR for each exercise in the exercise detail / history drill-down view
- PRs update automatically as history grows — no manual entry required

---

### Rest Timer Push Notifications `Free`

**Problem:** When a user locks their screen during rest, they have no way to know when the rest period ends without unlocking and checking the app.

**Solution:**
- Request `UNUserNotificationCenter` authorization on first app launch (or when rest timer is first used)
- When the rest timer starts, schedule a local `UNTimeIntervalNotificationTrigger` for the selected duration
- Notification content: title "Rest Complete", body "Time to get back to it — next set is ready"
- Cancel the scheduled notification immediately if the user manually dismisses the rest timer before it fires
- Respects the user's existing "Auto-start rest timer" setting — notifications only fire when that setting is enabled

---

### Enhanced Streak Tracking `Free`

**Problem:** Workout streaks already exist on the Dashboard (current streak, longest streak, flame icon) but there is no warning when a streak is about to break. Users may lose a streak simply because they forgot to work out, not because they chose to skip.

**Solution:**
- Add a "streak at risk" indicator on the Dashboard streak card when the user has an active streak but has not yet completed a workout today — the streak will break at midnight if no workout is logged
- Indicator should be visually distinct (e.g., amber/yellow warning tone) so it stands out from the normal "Keep it up!" state
- No changes to the underlying streak calculation — only surfacing the existing data in a more actionable way

---

## Tier 2 — Medium Term (High Impact, Moderate Effort)

These features require new screens or data models but no external dependencies.

---

### Weekly Workout Schedule `Free`

**Problem:** Users have workout templates but no way to plan which workouts happen on which days. There is no structure to guide their week.

**Solution:**
- Add a schedule screen (accessible from the Dashboard or Settings) where users can assign any workout template to one or more days of the week
- Days can have zero, one, or multiple workouts assigned
- The Dashboard shows "Today's Workout" — a card showing the scheduled workout for today with a quick-start button
- If no workout is scheduled for today, the dashboard shows a rest day message
- Schedule is stored locally in CoreData and does not require an account
- Integrates with streak tracking — a scheduled day counts toward the streak only if the scheduled workout (or any workout) is completed

---

### Apple Health Integration `Free`

**Problem:** Soleus workout data is siloed — it does not appear in the Health app or contribute to the user's activity rings, move goals, or fitness summaries.

**Solution:**
- Request HealthKit authorization for workout write access on first use
- On workout completion, write a `HKWorkout` record to HealthKit with:
  - Workout type (strength training, cardio, or mixed based on exercise types)
  - Start and end time (derived from the existing session timer)
  - Active energy burned (estimated from exercise type and duration using MET values)
  - Distance covered (for cardio workouts with distance tracking)
- Writes are one-way (Soleus → Health) — no reading from Health in this version
- Users can disable Health sync from Settings at any time
- Requires `NSHealthUpdateUsageDescription` in Info.plist

---

### Progress Charts (Exercise History Graphs) `Pro`

**Problem:** The existing Progress view shows trend arrows and a text table of recent sessions but no actual visual chart. Users cannot see the shape of their progress over time at a glance.

**Solution:**
- Add a line chart to `ExerciseProgressDetail` using Swift Charts (iOS 16+, no external dependency)
- Chart plots max weight per session on the Y axis and session date on the X axis
- Toggle between three metrics: Max Weight, Total Reps, Total Volume — chart updates instantly
- Tapping a data point shows a tooltip with the exact date and value
- Chart spans all available history for that exercise regardless of the time period filter selected in the list view
- Fix the existing bug where cardio exercises display weight-based volume (0) — cardio exercises show total distance and total time instead
- Fix the avg duration calculation bug (currently shows first session's time instead of average)
- Remove the hard cap of 5 recent sessions in the text table — show all sessions with a scroll view
- Decouple the Progress view from the Monthly filter — progress always shows all-time data

---

### Progressive Overload Suggestions `Pro`

**Problem:** Users must manually remember what they lifted last session and decide whether to increase weight or reps. There is no guidance for progression.

**Solution:**
- When the user opens an active workout, compare the current template weights and reps against the most recent completed session for each exercise
- If the previous session's sets were all completed and form looked strong (all sets checked off), suggest a small increase — typically +5 lbs for upper body, +10 lbs for lower body, or +1-2 reps
- Suggestions appear as a subtle banner above each exercise card during the active workout ("Last time: 135 × 8 — try 140 today?")
- User can dismiss individual suggestions or disable the feature entirely in Settings
- Suggestions are conservative — only trigger after a fully completed session, never after a partial one
- Requires the PRs feature (Tier 1) to be built first as it shares the same history query infrastructure

---

### Customizable Dashboard `Pro`

**Problem:** The Dashboard currently shows a fixed set of cards in a fixed order — Achievements, Workout Streaks, Lifetime Stats, and Personal Records. Users who care more about streaks than lifetime stats have no way to rearrange or hide cards they find less useful, and there is no way to add new data widgets as the app grows.

**Solution:**
- Allow users to add, remove, and reorder Dashboard widgets via an "Edit Dashboard" mode (similar to the iOS home screen or Health app summary)
- Initial widget library includes the four existing cards plus new widgets to be built:
  - **This Week** — workouts completed this week vs. a configurable weekly goal
  - **Recent Activity** — a compact list of the last 3–5 completed workouts with date and duration
  - **Workout Frequency** — a heatmap or bar chart showing workout days over the past 30/90 days
  - **Cardio Summary** — total distance and cardio time for the current month
- Widget visibility and order persisted in UserDefaults or CoreData per user
- Default layout matches the current fixed layout so existing users see no change until they opt in to customization
- Edit mode entered via an "Edit Dashboard" button; widgets can be toggled on/off and long-press dragged to reorder
- New widgets can be added to the library over time without requiring a layout migration

---

## Tier 3 — Longer Term (Significant Effort or External Dependencies)

---

### iCloud Sync `Pro`

**Problem:** Workout data lives only on the user's current device. Switching phones, getting a new iPhone, or using an iPad means starting from scratch unless a full device backup is restored.

**Solution:**
- Migrate the CoreData stack from `NSPersistentContainer` to `NSPersistentCloudKitContainer`
- Apple's CloudKit integration handles sync automatically across all devices signed into the same Apple ID
- Workouts, history, templates, and settings all sync
- Conflict resolution uses `NSMergeByPropertyObjectTrumpMergePolicy` (already in place) — most recent write wins
- Sync is transparent to the user — no login required beyond their existing Apple ID
- Requires CloudKit entitlement and iCloud capability in the Xcode project
- Full regression testing required against the existing CoreData model to ensure no data loss during migration
- Note: this is the most technically complex item in Tier 3 — the migration path is well-documented by Apple but must be tested thoroughly

---

### Universal Links / Server-Backed Workout Sharing `Pro`

**Problem:** The current `.soleus` file sharing works but requires the recipient to manually open a file. There is no way to share a workout as a link that opens directly in the app.

**Solution:**
- Set up a lightweight serverless backend (e.g., AWS Lambda + S3, or Cloudflare Workers + R2) to host workout JSON payloads
- When a user shares a workout, the app uploads the serialized `ShareableWorkout` JSON to the backend and receives a short URL (e.g., `https://soleus.app/w/abc123`)
- The URL is copied to clipboard or passed to the share sheet alongside the existing `.soleus` file option
- Implement Associated Domains in the app so that tapping the link on any iOS device opens Soleus directly and triggers the existing import flow
- Links expire after 30 days to limit storage costs
- Free users retain the existing `.soleus` file sharing — Pro users get the shareable link
- Requires: a registered domain, SSL certificate, Associated Domains entitlement, and a minimal backend

---

### Workout Recap Shareable Card `Pro`

**Problem:** Users have no way to share their workout accomplishments to social media in a polished format. A plain screenshot of the overview is unpolished.

**Solution:**
- On the Workout Overview screen, add a "Share" button that generates a styled image card
- Card includes: workout name, date, key stats (weight lifted, reps, duration, distance), any PRs broken, and the Soleus logo/branding
- Generated using SwiftUI's `ImageRenderer` (iOS 16+) — renders a SwiftUI view to a `UIImage` with no third-party dependencies
- User can customize card color (tied to the workout card's existing color)
- Image is passed to `UIActivityViewController` for sharing to any app (Instagram, Messages, Twitter, etc.)

---

## Tier 4 — Platform Expansion

These are independent platform targets and should be built after the core app is feature-complete and stable.

---

### Home Screen Widget `Pro`

**Problem:** Users must open the app to see today's scheduled workout or their recent stats. A widget would surface this information passively.

**Solution:**
- Implement a WidgetKit extension with two widget sizes:
  - **Small**: today's streak count and scheduled workout name
  - **Medium**: today's scheduled workout with a summary of last session's stats
- Widget reads from a shared App Group container (CoreData store must be migrated to an App Group to be accessible from the extension)
- Tapping the widget deep-links to the relevant workout in the app
- Requires the Weekly Workout Schedule (Tier 2) to be completed first — without a schedule there is nothing meaningful to show
- Widget timeline refreshes after each completed workout and at midnight (new day)

---

### Apple Watch Companion App `Pro`

**Problem:** Tracking sets during a workout requires the user to keep their phone accessible at all times. A Watch app would let users log sets, view the rest timer, and control the workout from their wrist.

**Solution:**
- Create a separate WatchKit App target within the Xcode project
- Use `WatchConnectivity` (`WCSession`) to pass the active workout's exercise list and set state between iPhone and Watch in real time
- Watch UI shows:
  - Current exercise name and set number
  - A checkmark button to mark the current set complete
  - Rest timer countdown with haptic feedback when complete
  - A "Next Exercise" button
  - Workout elapsed time in a complication
- Set completions on the Watch sync immediately to the iPhone via `WCSession.transferUserInfo`
- If the phone is out of range, the Watch queues changes and syncs when reconnected
- Watch-only sessions (without the phone) are out of scope for the initial version
- Requires: WatchKit target, WatchConnectivity implementation, a simplified Watch-optimized data model, and separate UI design for the small screen
- This is the most development-intensive item on the roadmap

---

## Summary

| Feature | Tier | Free / Pro |
|---|---|---|
| Enhanced Workout Overview | 1 | Free |
| Personal Records | 1 | Free |
| Rest Timer Push Notifications | 1 | Free |
| Enhanced Streak Tracking | 1 | Free |
| Weekly Workout Schedule | 2 | Free |
| Apple Health Integration | 2 | Free |
| Progress Charts (Exercise History Graphs) | 2 | Pro |
| Progressive Overload Suggestions | 2 | Pro |
| Customizable Dashboard | 2 | Pro |
| iCloud Sync | 3 | Pro |
| Universal Links / Server Sharing | 3 | Pro |
| Workout Recap Shareable Card | 3 | Pro |
| Home Screen Widget | 4 | Pro |
| Apple Watch Companion App | 4 | Pro |

---

## Notes on Monetization

The free tier covers the complete core workout loop — creating workouts, tracking sessions, viewing history, scheduling, notifications, and Health integration. A user who never pays gets a fully functional fitness tracker.

Pro is positioned as an analytics and convenience upgrade:
- **Analytics**: Progress Charts, Progressive Overload Suggestions, PRs (free, but Pro builds on them)
- **Convenience**: iCloud Sync, Widget, Watch app
- **Social**: Shareable Card, Universal Links

Recommended pricing: **$2.99/year** or **$4.99 one-time**. Given the utility nature of the app, a low-friction one-time purchase may convert better than a subscription for an early-stage user base.
