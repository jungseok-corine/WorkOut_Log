# App Store Submission Guide — WorkOut Log

**Quick Start:** Follow this guide to prepare and submit WorkOut Log to the App Store.

---

## 📁 Directory Structure

```
WorkOut Log/
├── AppStore/                    # Submission metadata
│   ├── SubmissionChecklist.md   # Step-by-step checklist
│   ├── ReleaseNotes.md          # Version 1.0.0 release notes
│   ├── PrivacyPolicy.md         # Privacy policy (zero data collection)
│   ├── DataCollection.yaml      # App Store privacy nutrition label spec
│   ├── ReviewNotes.md           # Notes for App Review team
│   ├── MarketingCopy.md         # Marketing messages and social media copy
│   ├── Keywords.en-US.txt       # English keywords (≤100 chars)
│   ├── Keywords.ko-KR.txt       # Korean keywords (≤100 chars)
│   ├── PromoText.en-US.txt      # English promo text (≤170 chars)
│   ├── PromoText.ko-KR.txt      # Korean promo text (≤170 chars)
│   ├── Subtitle.en-US.txt       # English subtitle (≤30 chars)
│   ├── Subtitle.ko-KR.txt       # Korean subtitle (≤30 chars)
│   ├── Description.en-US.md     # English full description
│   └── Description.ko-KR.md     # Korean full description
│
├── fastlane/metadata/           # Fastlane-compatible metadata
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── keywords.txt
│   │   ├── description.txt
│   │   ├── promotional_text.txt
│   │   └── release_notes.txt
│   └── ko-KR/
│       ├── name.txt
│       ├── subtitle.txt
│       ├── keywords.txt
│       ├── description.txt
│       ├── promotional_text.txt
│       └── release_notes.txt
│
├── Scripts/                     # Automation scripts
│   ├── capture_screenshots.sh   # Screenshot capture script
│   └── export_appstore_zip.sh  # Package all assets for submission
│
└── Docs/
    └── README-AppStore.md       # This file
```

---

## 🚀 Submission Workflow

### Step 1: Build & Test

```bash
# Build the project
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build

# Run all tests
xcodebuild -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

**Expected Result:** All tests pass, no compiler warnings.

---

### Step 2: Capture Screenshots

```bash
# Capture screenshots for App Store
bash Scripts/capture_screenshots.sh
```

**Output:** Screenshots saved to `AppStore/screenshots/`

**Devices covered:**
- iPhone 6.7" (Pro Max) — Light & Dark modes
- 6 required scenes: WorkLog list, Session detail, Exercise picker, Trends weekly, Trends daily, Splash

**Manual verification:**
- Open `AppStore/screenshots/` directory
- Review each screenshot for correct content
- Ensure text is readable and UI is polished

---

### Step 3: Archive & Upload

**In Xcode:**

1. **Select Generic iOS Device** (or a physical device)
2. **Product → Archive**
3. **Wait for archive to complete**
4. **Organizer opens automatically**
5. **Select archive → Distribute App**
6. **Select "App Store Connect"**
7. **Select "Upload"**
8. **Follow wizard** (automatic signing recommended)
9. **Wait for upload** (may take 5-10 minutes)

**Expected Result:** "Upload Successful" message in Organizer.

---

### Step 4: Complete App Store Connect

**URL:** https://appstoreconnect.apple.com

#### 4.1 App Information
Navigate to: **My Apps → WorkOut Log → App Information**

- **Name:** WorkOut Log
- **Subtitle:** (copy from `AppStore/Subtitle.en-US.txt`)
- **Primary Category:** Health & Fitness
- **Secondary Category:** Productivity (optional)
- **Privacy Policy URL:** https://github.com/ojung/workout-log/blob/main/AppStore/PrivacyPolicy.md
- **Support URL:** https://github.com/ojung/workout-log

#### 4.2 Pricing and Availability
Navigate to: **Pricing and Availability**

- **Price:** Free
- **Territories:** All countries

#### 4.3 App Privacy
Navigate to: **App Privacy**

- **Question:** "Does this app collect data from its users?"
- **Answer:** **No**

(See `AppStore/DataCollection.yaml` for full specification)

#### 4.4 Version Information
Navigate to: **Prepare for Submission → 1.0.0**

**What's New in This Version:**
- Copy from `fastlane/metadata/en-US/release_notes.txt`

**Promotional Text (EN):**
- Copy from `AppStore/PromoText.en-US.txt`

**Description (EN):**
- Copy from `AppStore/Description.en-US.md`

**Keywords (EN):**
- Copy from `AppStore/Keywords.en-US.txt`

**Screenshots:**
- Upload from `AppStore/screenshots/iPhone-6.7/light/` (6 images)
- Upload from `AppStore/screenshots/iPhone-6.7/dark/` (6 images)

**Repeat for Korean (ko-KR)** if targeting Korea.

#### 4.5 App Review Information
Navigate to: **App Review Information**

- **Contact Information:**
  - First Name: 정석
  - Last Name: 오
  - Phone: +82-10-XXXX-XXXX
  - Email: your-email@example.com

- **Sign-In Required:** NO
- **Demo Account:** Not needed (app is fully offline)

- **Notes:**
  - Paste content from `AppStore/ReviewNotes.md`

#### 4.6 Version Release
- **Automatically release** this version after review: ☑️
- OR: **Manually release** this version (your choice)

---

### Step 5: Submit for Review

1. **Review all sections** for completeness (green checkmarks)
2. **Click "Submit for Review"**
3. **Wait for confirmation email**

**Expected Timeline:**
- Waiting for Review: 1-3 days
- In Review: 12-48 hours
- Ready for Sale: After approval

---

## 📸 Screenshot Capture (Detailed)

### Automated Capture

```bash
# Capture screenshots with UI tests
bash Scripts/capture_screenshots.sh
```

**What it does:**
1. Launches simulator (iPhone 16 Pro Max)
2. Runs UI tests in Light mode
3. Captures screenshots at key moments
4. Repeats in Dark mode
5. Saves to `AppStore/screenshots/`

**Requirements:**
- Xcode 16+
- iOS 18+ simulator
- UI tests passing

---

### Manual Capture (if automated fails)

**Light Mode:**
1. **Launch app** on iPhone 16 Pro Max simulator
2. **Navigate to WorkLog tab** → Screenshot (⌘⇧4)
3. **Tap a session** → Screenshot
4. **Tap Add Set → Exercise Picker** → Screenshot
5. **Navigate to Trends tab** → Select Weekly → Screenshot
6. **Select Daily scope** → Toggle "Show All Days" → Screenshot
7. **Restart app** (to trigger splash) → Screenshot immediately

**Dark Mode:**
1. **Settings → Developer → Dark Appearance** → ON
2. Repeat steps 1-7

**Save screenshots to:**
```
AppStore/screenshots/
├── iPhone-6.7/
│   ├── light/
│   │   ├── 01-worklog.png
│   │   ├── 02-session-detail.png
│   │   ├── 03-exercise-picker.png
│   │   ├── 04-trends-weekly.png
│   │   ├── 05-trends-daily.png
│   │   └── 06-splash.png
│   └── dark/
│       └── (same 6 files)
```

**File naming:** Must match convention for upload script to work.

---

## 📦 Export Package

```bash
# Create submission package (zip)
bash Scripts/export_appstore_zip.sh
```

**Output:** `AppStore/WorkoutLog_AppStorePack.zip`

**Contents:**
- All metadata files (EN + KO)
- Screenshots (Light + Dark)
- Privacy policy
- Review notes
- README

**Use case:** Share with team or backup before submission.

---

## ✅ Pre-Submission Checklist

Use `AppStore/SubmissionChecklist.md` for detailed checklist.

**Quick Check:**
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Archive builds successfully
- [ ] Screenshots captured (12 images minimum)
- [ ] Metadata complete (EN + KO)
- [ ] Privacy policy reviewed
- [ ] App Store Connect form filled
- [ ] Review notes provided

---

## 🐛 Troubleshooting

### Build Fails
**Error:** "No such module 'XCTest'"
**Fix:** Verify test files are in `workout_logTests` target, not app target.

### Archive Fails
**Error:** "No provisioning profile"
**Fix:** Select "Automatically manage signing" in Xcode project settings.

### Screenshot Script Fails
**Error:** "UI tests timeout"
**Fix:** Run manual capture instead (see Manual Capture section above).

### Upload Fails
**Error:** "Invalid binary"
**Fix:** Ensure iOS Deployment Target is set to 18.0 in project settings.

---

## 📧 Support

**Developer:** 오정석 (Oh Jeongseok)
**Email:** your-email@example.com
**GitHub:** https://github.com/ojung/workout-log

---

## 📜 License

See [LICENSE](../LICENSE) for details.

---

**Last Updated:** 2025-10-16
**Next Review:** Before each App Store submission
