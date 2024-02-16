#!/bin/sh -xe

[ "$QT_PATH" ] || QT_PATH=/opt/Qt

[ "$ADDITIONAL_PACKAGES" ] || ADDITIONAL_PACKAGES='build-essential ninja-build locales sudo'

# Init package system
apt update

echo
echo '--> Locating the shared libs required for the installed tools'
echo

find "$QT_PATH" /usr/local -executable -type f -o -name '*.so' | xargs ldd 2>/dev/null | \
    grep -F '=> not found' | tr '\t' ' ' | cut -d' ' -f2 | sort -u | tee /tmp/not_found_libs.lst

echo
echo '--> Locating packages to provide the required shared libs'
echo

# Remove the version of libc that has broken the package manager ans revert so we can run apt again.
apt  --yes --fix-broken install --allow-downgrades  'libc6=2.27-3ubuntu1.6'

apt install -y apt-file software-properties-common
apt-file update

while read line ; do apt-file find $line | grep '^lib' | head -1; done < /tmp/not_found_libs.lst | tee /tmp/to_install_libs.lst

# TODO: Clean apt-file cache

apt autoremove -y --purge apt-file

echo
echo '--> Install the found libraries'
echo



cat /tmp/to_install_libs.lst | cut -d: -f 1 | xargs apt install -y --no-install-suggests --no-install-recommends $ADDITIONAL_PACKAGES

# Complete the cleaning

apt -qq clean
rm -rf /var/lib/apt/lists/*


# Reinstal the libc that is required.
dpkg   --force all -i  /libc6_2.28-0ubuntu1_amd64.deb

