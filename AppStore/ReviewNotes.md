# App Review Notes — WorkOut Log

**Submitted By:** 오정석 (Oh Jeongseok)
**Submission Date:** 2025-10-16
**Version:** 1.0.0 (Build 1)
**Platform:** iOS 18.0+

---

## 📱 App Overview

**WorkOut Log** is a 100% offline workout tracker with zero data collection. All data is stored locally on the user's device using Apple's SwiftData framework.

**Key Highlights:**
- No login/account system required
- No internet connectivity required
- No third-party SDKs or analytics
- No in-app purchases or subscriptions
- Fully accessible with VoiceOver support

---

## 🧪 Testing Instructions

### No Test Account Needed
✅ **The app is fully offline and requires no authentication.**

Reviewers can test all features immediately after installation without:
- Creating an account
- Providing an email
- Connecting to the internet

---

## 🚀 Recommended Test Flow

### 1. **First Launch Experience (Splash Screen)**
On app launch, you'll see a **splash screen with a random motivational quote**:

- Displays for **2.5 seconds**, then auto-dismisses
- Can be skipped instantly by **tapping anywhere**
- VoiceOver users get an extended **5-second** delay for quote narration
- This is intentional design, not a loading delay

**Note:** This is a one-time experience per app launch (not per session).

---

### 2. **Create a Workout Session**

**Path:** WorkLog tab → "+" button (top-right)

1. Tap "+" to create a new session
2. Select a date (defaults to today)
3. Tap "Add Set"
4. Choose an exercise from the picker:
   - Use search bar to find exercises
   - Or tap "Create New" to add a custom exercise
5. Enter weight (kg) and reps
6. Tap "Save" — set appears in the session

**Expected Behavior:**
- Selected exercise persists (sticky selection) for rapid entry
- Sets are grouped by exercise with section headers
- Subtotal volume shown per exercise

---

### 3. **View Workout Log**

**Path:** WorkLog tab (main screen)

- Sessions displayed chronologically (newest first)
- Each session shows:
  - Date
  - Total volume (kg)
  - Category badges (Lower/Upper/Cardio/Full)
- Swipe left on a session to delete
- Tap a session to view details

---

### 4. **Explore Trends**

**Path:** Trends tab (bottom navigation)

1. **Scope Selector:**
   - Tap "Daily" / "Weekly" / "Monthly" to switch views
   - **Daily:** Shows latest ≤10 days
   - **Weekly:** Shows last 8 weeks
   - **Monthly:** Shows last 6 months

2. **Daily Mode Features:**
   - Toggle "Show All Days" to include/exclude zero-volume days
   - Chart updates dynamically

3. **Category Filters:**
   - Tap "Lower Body" / "Upper Body" / "Cardio" / "Full Body" chips
   - Chart filters to show only that category's volume
   - Tap "All" to reset filter

**Expected Behavior:**
- Line chart renders smoothly
- Axis labels adjust to scope
- No network requests (works offline)

---

### 5. **Exercise Management**

**Path:** WorkLog → Session Detail → "Add Set" → Exercise Picker

1. **Search:** Type exercise name (e.g., "squat")
2. **Create New:**
   - Tap "+ Create New Exercise"
   - Enter name (e.g., "Bulgarian Split Squat")
   - Select category (Lower/Upper/Cardio/Full)
   - Tap "Create"
3. **Delete:**
   - Swipe left on an exercise in the picker
   - Tap "Delete"
   - If exercise has existing sets, deletion is blocked with error message

**Expected Behavior:**
- Search debounces with 300ms delay (smooth typing)
- Exercises grouped by category in sections
- Safe deletion prevents orphaned sets

---

### 6. **VoiceOver Testing (Optional)**

**Path:** iOS Settings → Accessibility → VoiceOver → ON

1. Launch app — splash quote is announced with 5s duration
2. Navigate to WorkLog tab — sessions are semantically labeled
3. Add a set — form fields have clear labels
4. View Trends — chart and filters are accessible

**Expected Behavior:**
- All buttons have accessibility labels
- Chart data announced correctly
- No silent/unlabeled elements

---

## 🔒 Privacy & Permissions

### No Permissions Required
✅ WorkOut Log requests **ZERO iOS permissions**:
- ❌ No location
- ❌ No camera
- ❌ No photos
- ❌ No contacts
- ❌ No notifications (yet)
- ❌ No network access

### Data Storage
- All data stored via **SwiftData** (Apple's native framework)
- No third-party databases or cloud services
- Data encrypted by iOS (if device passcode enabled)
- Data deleted when app is uninstalled

---

## 🛠️ Technical Details

### Build Info
- **Xcode:** 16
- **Swift:** 6
- **Frameworks:** SwiftUI, SwiftData, Swift Charts, Observation
- **Minimum iOS:** 18.0
- **Architecture:** Clean Architecture (Domain → Presentation/Data)

### No External Dependencies
- ✅ Zero CocoaPods
- ✅ Zero Swift Package Manager dependencies
- ✅ Zero third-party SDKs
- ✅ 100% native Apple frameworks

---

## ⚠️ Known Behaviors (Not Bugs)

### 1. Splash Screen on Every Launch
The motivational quote splash screen appears **every time** the app launches (not just first launch). This is intentional to provide daily motivation.

### 2. Daily Trends Cap at 10 Points
Daily scope intentionally shows only the **latest ≤10 days** to provide an at-a-glance view. For longer historical data, use Weekly or Monthly scopes.

### 3. No Cloud Sync
Data is stored **only on the device**. If the app is deleted, data is permanently lost (unless user has iCloud Backup enabled in iOS Settings, which backs up app data automatically).

### 4. No "Clone Latest" Button
This feature was removed to simplify the UI. Users can manually add sets to new sessions.

---

## 📋 Crash-Free Scenarios

We have tested the following workflows extensively with **zero crashes**:

1. ✅ Adding 100+ workout sessions
2. ✅ Adding 500+ sets
3. ✅ Creating 50+ custom exercises
4. ✅ Rapid typing in search field (debouncing prevents crash)
5. ✅ Switching between all trend scopes
6. ✅ Toggling category filters rapidly
7. ✅ Deleting sessions with 20+ sets
8. ✅ Running in Airplane Mode
9. ✅ VoiceOver enabled throughout all flows
10. ✅ Dark Mode + Light Mode

---

## 🐛 Bug Reporting (Post-Approval)

If reviewers encounter any issues:

**Contact Developer:**
- Email: your-email@example.com
- GitHub: https://github.com/ojung/workout-log/issues

**Expected Response Time:** Within 24 hours

---

## 📦 App Store Assets

All required assets are included:
- ✅ App Icon (1024×1024)
- ✅ Screenshots (6.7" Light + Dark)
- ✅ Privacy Policy
- ✅ Support URL
- ✅ Keywords & Description (EN + KO)

---

## 🙏 Thank You

Thank you for reviewing WorkOut Log! We've built this app with:
- **Privacy-first** design (zero data collection)
- **Accessibility** in mind (VoiceOver support)
- **Offline-first** architecture (no network dependency)

We believe this app provides substantial value for users who want a simple, private workout tracker without cloud sync, accounts, or subscriptions.

If you have any questions during review, please don't hesitate to reach out.

---

**Submitted with ❤️ by 오정석**
