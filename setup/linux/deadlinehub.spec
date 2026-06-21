Name:           deadlinehub
Version:        1.0.0
Release:        1%{?dist}
Summary:        Academic deadlines, calendar sync, and AI assistant
Group:          Applications/Productivity
License:        LGPLv3
URL:            https://github.com/yohanesokta/deadlinehub
Vendor:         Octa-OSS
Packager:       yohanesoktanio <https://github.com/yohanesokta>

%description
Academic deadlines, calendar sync, and AI assistant built with Flutter.

%install
mkdir -p %{buildroot}/usr/share/deadlinehub
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps

# Copy the precompiled bundle contents into /usr/share/deadlinehub
cp -r %{_builddir}/bundle/* %{buildroot}/usr/share/deadlinehub/

# Create symlink
ln -sf /usr/share/deadlinehub/deadlinehub %{buildroot}/usr/bin/deadlinehub

# Install Desktop Entry and Icons
cp %{_sourcedir}/deadlinehub.desktop %{buildroot}/usr/share/applications/
cp %{_sourcedir}/icons.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/deadlinehub.png

%files
/usr/share/deadlinehub/
/usr/bin/deadlinehub
/usr/share/applications/deadlinehub.desktop
/usr/share/icons/hicolor/256x256/apps/deadlinehub.png

%changelog
* Sun Jun 21 2026 yohanesoktanio <https://github.com/yohanesokta> - 1.0.0-1
- Initial Release
