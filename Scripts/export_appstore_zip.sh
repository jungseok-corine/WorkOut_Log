#!/bin/bash

# App Store Package Export Script
# Creates a zip file with all submission materials
# Output: AppStore/WorkoutLog_AppStorePack.zip

set -e  # Exit on error

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_ZIP="$PROJECT_DIR/AppStore/WorkoutLog_AppStorePack.zip"
TEMP_DIR="$PROJECT_DIR/AppStore/temp_export"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  App Store Package Export${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""

# Remove existing temp directory
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# Create temp directory
mkdir -p "$TEMP_DIR"

echo "Collecting files..."

# Copy metadata files
echo "  • Metadata files..."
cp -r "$PROJECT_DIR/AppStore"/*.md "$TEMP_DIR/" 2>/dev/null || true
cp -r "$PROJECT_DIR/AppStore"/*.txt "$TEMP_DIR/" 2>/dev/null || true
cp -r "$PROJECT_DIR/AppStore"/*.yaml "$TEMP_DIR/" 2>/dev/null || true

# Copy fastlane metadata
echo "  • Fastlane metadata (EN + KO)..."
mkdir -p "$TEMP_DIR/fastlane/metadata"
cp -r "$PROJECT_DIR/fastlane/metadata/en-US" "$TEMP_DIR/fastlane/metadata/" 2>/dev/null || true
cp -r "$PROJECT_DIR/fastlane/metadata/ko-KR" "$TEMP_DIR/fastlane/metadata/" 2>/dev/null || true

# Copy screenshots
echo "  • Screenshots..."
if [ -d "$PROJECT_DIR/AppStore/screenshots" ]; then
    cp -r "$PROJECT_DIR/AppStore/screenshots" "$TEMP_DIR/"
fi

# Copy README
echo "  • Documentation..."
cp "$PROJECT_DIR/Docs/README-AppStore.md" "$TEMP_DIR/" 2>/dev/null || true
cp "$PROJECT_DIR/README.md" "$TEMP_DIR/README-Project.md" 2>/dev/null || true

# Create a manifest file
echo "  • Creating manifest..."
cat > "$TEMP_DIR/MANIFEST.txt" << EOF
WorkOut Log — App Store Submission Package
==========================================

Generated: $(date "+%Y-%m-%d %H:%M:%S")

Contents:
---------

1. Metadata Files:
   • SubmissionChecklist.md    — Step-by-step submission guide
   • ReleaseNotes.md            — Version 1.0.0 release notes
   • PrivacyPolicy.md           — Privacy policy (zero data collection)
   • DataCollection.yaml        — App Store privacy nutrition label
   • ReviewNotes.md             — Notes for App Review team
   • MarketingCopy.md           — Marketing messages and social copy

2. App Store Connect Copy (EN):
   • Keywords.en-US.txt         — English keywords (≤100 chars)
   • PromoText.en-US.txt        — English promo text (≤170 chars)
   • Subtitle.en-US.txt         — English subtitle (≤30 chars)
   • Description.en-US.md       — English full description

3. App Store Connect Copy (KO):
   • Keywords.ko-KR.txt         — Korean keywords (≤100 chars)
   • PromoText.ko-KR.txt        — Korean promo text (≤170 chars)
   • Subtitle.ko-KR.txt         — Korean subtitle (≤30 chars)
   • Description.ko-KR.md       — Korean full description

4. Fastlane Metadata:
   • fastlane/metadata/en-US/   — Fastlane-compatible English metadata
   • fastlane/metadata/ko-KR/   — Fastlane-compatible Korean metadata

5. Screenshots:
   • screenshots/iPhone-6.7/light/  — Light mode (6 images)
   • screenshots/iPhone-6.7/dark/   — Dark mode (6 images)

6. Documentation:
   • README-AppStore.md         — Submission guide
   • README-Project.md          — Project README

How to Use:
-----------

1. Extract this zip file
2. Review all metadata for accuracy
3. Follow README-AppStore.md for submission workflow
4. Upload screenshots to App Store Connect
5. Copy/paste text from .txt/.md files to App Store Connect forms

Support:
--------
Developer: 오정석 (Oh Jeongseok)
Email: your-email@example.com
GitHub: https://github.com/ojung/workout-log

EOF

# Create zip file
echo ""
echo "Creating zip archive..."
cd "$PROJECT_DIR/AppStore"

# Remove existing zip
if [ -f "$OUTPUT_ZIP" ]; then
    rm "$OUTPUT_ZIP"
fi

# Create new zip
zip -r "$OUTPUT_ZIP" "temp_export" > /dev/null 2>&1

# Move contents up one level in zip (remove temp_export folder)
cd "$TEMP_DIR"
zip -r "$OUTPUT_ZIP" . > /dev/null 2>&1

# Clean up temp directory
cd "$PROJECT_DIR"
rm -rf "$TEMP_DIR"

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_ZIP" | cut -f1)

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Export Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Output: $OUTPUT_ZIP"
echo "Size: $FILE_SIZE"
echo ""
echo "Package contents:"
echo "  • Metadata files (EN + KO)"
echo "  • Fastlane metadata structure"
echo "  • Screenshots (light + dark)"
echo "  • Submission documentation"
echo ""
echo -e "${GREEN}✓ App Store submission package ready${NC}"
echo ""
echo "Next steps:"
echo "  1. Extract zip to review contents"
echo "  2. Follow README-AppStore.md for submission"
echo "  3. Upload to App Store Connect"
