#!/bin/bash

# Screenshot Capture Script for WorkOut Log
# Captures screenshots for App Store submission using UI tests
# Requires: Xcode 16+, iOS 18+ simulator

set -e  # Exit on error

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="workout_log"
DEVICE="iPhone 16 Pro Max"
OUTPUT_DIR="$PROJECT_DIR/AppStore/screenshots"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  WorkOut Log Screenshot Capture${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found${NC}"
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# Create output directories
echo "Creating output directories..."
mkdir -p "$OUTPUT_DIR/iPhone-6.7/light"
mkdir -p "$OUTPUT_DIR/iPhone-6.7/dark"

# Function to run UI tests with specific appearance
run_ui_tests() {
    local appearance=$1
    echo -e "${YELLOW}Capturing screenshots in ${appearance} mode...${NC}"

    # Set environment variable for appearance
    export SCREENSHOT_MODE="${appearance}"

    # Run UI tests (which will capture screenshots)
    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$DEVICE" \
        -testPlan "ScreenshotTests" \
        -resultBundlePath "$OUTPUT_DIR/TestResults-${appearance}.xcresult" \
        2>&1 | grep -E "(Test Suite|Test Case|passed|failed)" || true

    echo -e "${GREEN}✓ ${appearance} mode screenshots captured${NC}"
}

# Check if test plan exists, otherwise use all UI tests
if [ ! -f "$PROJECT_DIR/WorkOut Log.xcodeproj/ScreenshotTests.xctestplan" ]; then
    echo -e "${YELLOW}Warning: ScreenshotTests test plan not found${NC}"
    echo "Falling back to manual screenshot capture instructions..."
    echo ""
    echo "═══════════════════════════════════════"
    echo "  Manual Screenshot Capture Guide"
    echo "═══════════════════════════════════════"
    echo ""
    echo "1. Launch WorkOut Log on iPhone 16 Pro Max simulator"
    echo "2. Navigate to each screen and capture with ⌘⇧4:"
    echo ""
    echo "   LIGHT MODE:"
    echo "   • WorkLog tab (main list) → 01-worklog.png"
    echo "   • Tap a session → 02-session-detail.png"
    echo "   • Tap Add Set → Exercise Picker → 03-exercise-picker.png"
    echo "   • Trends tab → Weekly → 04-trends-weekly.png"
    echo "   • Trends tab → Daily → 05-trends-daily.png"
    echo "   • Restart app → Splash → 06-splash.png"
    echo ""
    echo "   DARK MODE:"
    echo "   • Settings → Developer → Dark Appearance → ON"
    echo "   • Repeat above 6 screenshots"
    echo ""
    echo "3. Save to:"
    echo "   $OUTPUT_DIR/iPhone-6.7/light/"
    echo "   $OUTPUT_DIR/iPhone-6.7/dark/"
    echo ""
    echo "═══════════════════════════════════════"
    exit 0
fi

# Automated capture (if test plan exists)
echo "Starting automated screenshot capture..."
echo ""

# Capture Light mode
run_ui_tests "light"
echo ""

# Capture Dark mode
run_ui_tests "dark"
echo ""

# Move screenshots from derived data to output directory
# (This assumes screenshots are saved via XCTAttachment in UI tests)
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
echo "Looking for screenshots in DerivedData..."

# Find most recent test results
RESULT_BUNDLE_LIGHT=$(find "$OUTPUT_DIR" -name "TestResults-light.xcresult" -print -quit)
RESULT_BUNDLE_DARK=$(find "$OUTPUT_DIR" -name "TestResults-dark.xcresult" -print -quit)

if [ -n "$RESULT_BUNDLE_LIGHT" ]; then
    echo "Extracting light mode screenshots..."
    # Extract screenshots from xcresult bundle
    xcrun xcresulttool get --path "$RESULT_BUNDLE_LIGHT" --attachment-types screenshot || true
fi

if [ -n "$RESULT_BUNDLE_DARK" ]; then
    echo "Extracting dark mode screenshots..."
    # Extract screenshots from xcresult bundle
    xcrun xcresulttool get --path "$RESULT_BUNDLE_DARK" --attachment-types screenshot || true
fi

# Verify screenshots were captured
LIGHT_COUNT=$(find "$OUTPUT_DIR/iPhone-6.7/light" -name "*.png" | wc -l | tr -d ' ')
DARK_COUNT=$(find "$OUTPUT_DIR/iPhone-6.7/dark" -name "*.png" | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Screenshot Capture Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Light mode: ${LIGHT_COUNT} screenshots"
echo "Dark mode: ${DARK_COUNT} screenshots"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""

if [ "$LIGHT_COUNT" -lt 6 ] || [ "$DARK_COUNT" -lt 6 ]; then
    echo -e "${YELLOW}Warning: Expected 6 screenshots per mode${NC}"
    echo "You may need to capture missing screenshots manually."
    echo "See Docs/README-AppStore.md for manual capture instructions."
    exit 1
fi

echo -e "${GREEN}✓ All screenshots captured successfully${NC}"
echo ""
echo "Next steps:"
echo "  1. Review screenshots in $OUTPUT_DIR"
echo "  2. Run: bash Scripts/export_appstore_zip.sh"
echo "  3. Upload screenshots to App Store Connect"
