#!/bin/bash
# Plex Media Server Installation Script for Fedora

# Exit on error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Set environment variables
PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new"
PLEX_ARCH="x86_64"  # Fedora uses x86_64 naming convention

echo "**** install runtime packages ****"
dnf check-update || true  # The || true prevents script exit if no updates
dnf install -y udev wget jq

echo "**** install plex ****"
if [ -z ${PLEX_RELEASE+x} ]; then
    PLEX_RELEASE=$(curl -sX GET 'https://plex.tv/api/downloads/5.json' | jq -r '.computer.Linux.version')
fi

echo "Installing Plex version: ${PLEX_RELEASE}"
# For Fedora, download the RPM package instead of DEB
curl -o /tmp/plexmediaserver.rpm -L "${PLEX_DOWNLOAD}/${PLEX_RELEASE}/redhat/plexmediaserver-${PLEX_RELEASE}.${PLEX_ARCH}.rpm"
dnf install -y /tmp/plexmediaserver.rpm

# Store version info
VERSION=${VERSION:-"custom"}
BUILD_DATE=$(date -u +"%Y-%m-%d")
mkdir -p /plex
printf "Version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /plex/build_version

echo "**** cleanup ****"
dnf clean all
rm -rf /tmp/plexmediaserver.rpm

echo "Plex Media Server installation complete!"
echo "You can access it at http://localhost:32400/web"