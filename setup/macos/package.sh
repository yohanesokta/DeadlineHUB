#!/bin/bash
# macOS Packaging Script for DeadlineHUB
# Developer: yohanesoktanio
# Organization: Octa-OSS ( Octanio Open Source Software )
# GitHub: github.com/yohanesokta

set -e

# Colors for terminal output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}Building Flutter macOS Release...${NC}"
echo -e "${BLUE}=======================================================${NC}"
# Get the absolute path to the project root directory relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

flutter build macos --release

APP_NAME="deadlinehub"
APP_PATH="build/macos/Build/Products/Release/deadlinehub.app"
OUT_DIR="build/macos/packages"
DMG_NAME="deadlinehub-macos.dmg"

mkdir -p "$OUT_DIR"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}[ERROR] $APP_PATH does not exist. macOS build failed.${NC}"
    exit 1
fi

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${BLUE}Creating macOS DMG installer...${NC}"
echo -e "${BLUE}=======================================================${NC}"

TMP_DMG="${OUT_DIR}/tmp-${DMG_NAME}"
FINAL_DMG="${OUT_DIR}/${DMG_NAME}"

# Clean up any existing image files
rm -f "$TMP_DMG" "$FINAL_DMG"

# Create a temporary staging folder
DMG_STAGE="build/macos/dmg_stage"
rm -rf "$DMG_STAGE"
mkdir -p "$DMG_STAGE"

# Copy App Bundle to stage
cp -R "$APP_PATH" "$DMG_STAGE/"

# Create symlink to /Applications inside the DMG folder
ln -s /Applications "$DMG_STAGE/Applications"

# Create the raw writeable DMG disk image
hdiutil create -srcfolder "$DMG_STAGE" -volname "DeadlineHUB" -fs HFS+ -fsopt "-j" -format UDRW "$TMP_DMG"

# Convert writeable image to a read-only compressed final DMG
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG"

# Clean up staging files
rm -f "$TMP_DMG"
rm -rf "$DMG_STAGE"

echo -e "\n${GREEN}=======================================================${NC}"
echo -e "${GREEN}macOS packaging complete! DMG generated in:${NC}"
echo -e "${GREEN}$(pwd)/${FINAL_DMG}${NC}"
echo -e "${GREEN}=======================================================${NC}"
