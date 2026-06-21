#!/bin/bash
# Linux Packaging Script for DeadlineHUB
# Developer: yohanesoktanio
# Organization: Octa-OSS ( Octanio Open Source Software )
# GitHub: github.com/yohanesokta

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}Building Flutter Linux Release...${NC}"
echo -e "${BLUE}=======================================================${NC}"
cd ../..
flutter build linux --release

# Variables
VERSION="1.0.0"
APP_NAME="deadlinehub"
BUILD_DIR="build/linux/x64/release/bundle"
OUT_DIR="build/linux/packages"

mkdir -p "$OUT_DIR"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}[ERROR] Build directory $BUILD_DIR does not exist. Build failed.${NC}"
    exit 1
fi

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${BLUE}1. Packaging as tar.gz...${NC}"
echo -e "${BLUE}=======================================================${NC}"
TAR_NAME="${APP_NAME}-${VERSION}-linux-x64.tar.gz"
tar -czf "${OUT_DIR}/${TAR_NAME}" -C build/linux/x64/release bundle
echo -e "${GREEN}[SUCCESS] Tarball created: ${OUT_DIR}/${TAR_NAME}${NC}"

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${BLUE}2. Packaging as .deb...${NC}"
echo -e "${BLUE}=======================================================${NC}"
DEB_STAGE="build/linux/deb_stage"
rm -rf "$DEB_STAGE"
mkdir -p "$DEB_STAGE/DEBIAN"
mkdir -p "$DEB_STAGE/usr/bin"
mkdir -p "$DEB_STAGE/usr/share/${APP_NAME}"
mkdir -p "$DEB_STAGE/usr/share/applications"
mkdir -p "$DEB_STAGE/usr/share/icons/hicolor/256x256/apps"

# Copy binary bundle
cp -r "${BUILD_DIR}/"* "$DEB_STAGE/usr/share/${APP_NAME}/"

# Create symlink in /usr/bin
ln -sf "/usr/share/${APP_NAME}/${APP_NAME}" "$DEB_STAGE/usr/bin/${APP_NAME}"

# Copy desktop config & icon
cp setup/linux/deadlinehub.desktop "$DEB_STAGE/usr/share/applications/"
cp setup/linux/icons.png "$DEB_STAGE/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"

# Create DEBIAN/control file
cat <<EOT > "$DEB_STAGE/DEBIAN/control"
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: yohanesoktanio <https://github.com/yohanesokta>
Depends: libgtk-3-0, libblkid1, liblzma5
Description: Academic deadlines, calendar sync, and AI assistant
 DeadlineHUB integrates Google Classroom, Google Calendar, Google Drive,
 and Gmail with a local AI assistant to monitor and schedule tasks.
EOT

dpkg-deb --build "$DEB_STAGE" "${OUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb"
rm -rf "$DEB_STAGE"
echo -e "${GREEN}[SUCCESS] Debian package created: ${OUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb${NC}"

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${BLUE}3. Packaging as .rpm...${NC}"
echo -e "${BLUE}=======================================================${NC}"

if command -v rpmbuild &> /dev/null; then
    RPM_TOP_DIR="$(pwd)/build/linux/rpmbuild"
    rm -rf "$RPM_TOP_DIR"
    mkdir -p "$RPM_TOP_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    
    # Place resources in SOURCES
    cp setup/linux/deadlinehub.desktop "$RPM_TOP_DIR/SOURCES/"
    cp setup/linux/icons.png "$RPM_TOP_DIR/SOURCES/"
    
    # Place compiled bundle in BUILD
    mkdir -p "$RPM_TOP_DIR/BUILD/bundle"
    cp -r "${BUILD_DIR}/"* "$RPM_TOP_DIR/BUILD/bundle/"
    
    # Copy and configure SPEC
    cp setup/linux/deadlinehub.spec "$RPM_TOP_DIR/SPECS/"
    
    rpmbuild --define "_topdir $RPM_TOP_DIR" -bb "$RPM_TOP_DIR/SPECS/deadlinehub.spec"
    
    # Copy output RPM
    cp "$RPM_TOP_DIR"/RPMS/x86_64/*.rpm "$OUT_DIR/"
    rm -rf "$RPM_TOP_DIR"
    echo -e "${GREEN}[SUCCESS] RPM package created inside ${OUT_DIR}/${NC}"
else
    echo -e "${RED}[WARNING] rpmbuild not found. Skipping RPM package creation.${NC}"
    echo -e "To package as RPM, install rpmbuild (e.g., 'sudo apt install rpm' or 'dnf install rpm-build') and run:"
    echo -e "rpmbuild --define \"_topdir \$(pwd)/build/linux/rpmbuild\" -bb setup/linux/deadlinehub.spec"
fi

echo -e "\n${GREEN}=======================================================${NC}"
echo -e "${GREEN}Linux packaging complete! Outputs generated in:${NC}"
echo -e "${GREEN}$(pwd)/${OUT_DIR}/${NC}"
echo -e "${GREEN}=======================================================${NC}"
