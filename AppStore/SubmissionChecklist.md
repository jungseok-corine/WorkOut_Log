# App Store Submission Checklist

**App Name:** WorkOut Log
**Bundle ID:** com.ojung.workout-log
**Version:** 1.0.0
**Build:** 1
**Platform:** iOS 18.0+

---

## Pre-Submission

### 1. Code & Build
- [ ] All unit tests pass (`workout_logTests`)
- [ ] All UI tests pass (`workout_logUITests`)
- [ ] No compiler warnings
- [ ] Archive builds successfully
- [ ] App runs on physical device (iOS 18.0+)
- [ ] No crashes in common workflows

### 2. Assets
- [ ] App Icon (1024×1024) provided in Assets.xcassets
- [ ] Screenshots captured for required devices:
  - [ ] iPhone 6.7" (Pro Max) — Light & Dark
  - [ ] iPhone 6.5" (optional fallback)
- [ ] Launch Screen displays correctly
- [ ] Splash screen with quote appears on first launch

### 3. Metadata (EN + KO)
- [ ] App name: "WorkOut Log" (both languages)
- [ ] Subtitle (≤30 chars)
- [ ] Description (≤4000 chars)
- [ ] Keywords (≤100 chars, comma-separated)
- [ ] Promotional text (≤170 chars)
- [ ] Privacy Policy URL provided
- [ ] Support URL provided
- [ ] Marketing URL (optional)

### 4. Privacy & Compliance
- [ ] Privacy Policy.md reviewed and accurate
- [ ] Data Collection.yaml filled (Data Not Collected)
- [ ] No analytics/tracking SDKs
- [ ] No network requests (100% offline)
- [ ] Export Compliance: NO (app uses no encryption)

### 5. App Store Connect Configuration
- [ ] Primary category: **Health & Fitness**
- [ ] Secondary category: **Productivity** (optional)
- [ ] Age rating: **4+** (no sensitive content)
- [ ] Pricing: **Free**
- [ ] Availability: All territories
- [ ] Version release: Manual release after approval

### 6. Test Account (Not Required)
- ✅ App is fully offline — no login/account needed
- ✅ Reviewer can test all features without credentials

---

## Submission Workflow

### Step 1: Archive & Upload
```bash
# Archive in Xcode
Product → Archive

# Validate Archive
Organizer → Distribute App → App Store Connect → Validate

# Upload to App Store Connect
Organizer → Distribute App → App Store Connect → Upload
```

### Step 2: Complete App Store Connect Form
1. **App Information**
   - Name: WorkOut Log
   - Subtitle: (from Subtitle.en-US.txt)
   - Privacy Policy URL: https://github.com/ojung/workout-log/privacy
   - Categories: Health & Fitness, Productivity

2. **Version Information**
   - Version: 1.0.0
   - Copyright: © 2025 오정석
   - Release notes: (from ReleaseNotes.md)
   - Promotional text: (from PromoText.en-US.txt)
   - Description: (from Description.en-US.md)
   - Keywords: (from Keywords.en-US.txt)

3. **Screenshots**
   - Upload 6.7" screenshots (light + dark)
   - Optional: Add 6.5" screenshots

4. **App Review Information**
   - Contact: your-email@example.com
   - Phone: +82-10-XXXX-XXXX
   - Review notes: (from ReviewNotes.md)
   - Sign-in required: NO
   - Demo account: Not needed

5. **App Privacy**
   - Data types collected: **None**
   - Data collection: **Data Not Collected**

6. **Pricing and Availability**
   - Price: Free
   - Territories: All countries

### Step 3: Submit for Review
- [ ] Click "Submit for Review"
- [ ] Wait for "Waiting for Review" status
- [ ] Monitor App Store Connect for messages

---

## Post-Approval

### Release Checklist
- [ ] App approved (status: "Ready for Sale")
- [ ] Version 1.0.0 live on App Store
- [ ] Test download from App Store
- [ ] Verify all features work in production build
- [ ] Update README.md with App Store link
- [ ] Create release tag: `v1.0.0`

### Marketing
- [ ] Share App Store link on social media
- [ ] Update personal website/portfolio
- [ ] Post on ProductHunt (optional)
- [ ] Request reviews from beta testers

---

## Common Rejection Reasons (and How We Avoid Them)

| Reason | Prevention |
|--------|-----------|
| **2.1 App Completeness** | All features functional, no placeholders, no crashes |
| **4.2 Minimum Functionality** | Provides substantial value: session tracking, trends, PR highlights |
| **5.1.1 Privacy Policy** | Clear policy stating no data collection, no third-party SDKs |
| **2.3.3 Accurate Metadata** | Screenshots match actual app, description accurate |
| **2.3.10 Accurate Description** | No misleading claims, all features implemented |

---

## Support Contacts

**Developer:** 오정석
**Email:** your-email@example.com
**GitHub:** https://github.com/ojung/workout-log
**App Store Support:** your-email@example.com

---

**Last Updated:** 2025-10-16
**Next Review:** Before each submission
