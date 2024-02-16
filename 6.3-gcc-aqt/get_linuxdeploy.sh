#!/bin/sh -xe
# Script to install osxcross with SDK

[ "$LINUXDEPLOY_GIT" ] || LINUXDEPLOY_GIT="https://github.com/linuxdeploy/linuxdeploy.git"
[ "$LINUXDEPLOY_COMMIT" ] || LINUXDEPLOY_COMMIT="4c5b9c5dafd14412f80088a09437585aaf2edef4" # Jan 12, 2022
[ "$LINUXDEPLOY_QT_GIT" ] || LINUXDEPLOY_QT_GIT="https://github.com/linuxdeploy/linuxdeploy-plugin-qt.git"
[ "$LINUXDEPLOY_QT_COMMIT" ] || LINUXDEPLOY_QT_COMMIT="ecde8a04cc061f17fbd58883411710dc7605c701" # Jan 11, 2022

# Init the package system
apt update

echo
echo '--> Save the original installed packages list'
echo

dpkg --get-selections | cut -f 1 > /tmp/packages_orig.lst

echo
echo '--> Install the required packages to install linuxdeploy'
echo


# Remove the version of libc that has broken the package manager ans revert so we can run apt again.
apt  --yes --fix-broken install --allow-downgrades  'libc6=2.27-3ubuntu1.6'


apt install -y apt-file software-properties-common

#Not working on Cosmic
#   # Get a more recent g++ for bionic.
#   add-apt-repository ppa:ubuntu-toolchain-r/test

# Boost is too ol - we get an error about trying to call a non-constexpr function.
add-apt-repository ppa:savoury1/boost-defaults-1.71

apt-get update


#Not working on Cosmic
#   apt install --yes g++-13 libstdc++-10-dev
#   update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 110
#   update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 110


# NOt availanble in  bionic; trying anyway
apt install -y git libboost-filesystem1.71-dev libboost-regex1.71-dev cimg-dev wget patchelf nlohmann-json-dev build-essential
# apt install -y nlohmann-json3-dev

echo
echo '--> Download & install the linuxdeploy'
echo

git clone "$LINUXDEPLOY_GIT" /tmp/linuxdeploy
git -C /tmp/linuxdeploy checkout "$LINUXDEPLOY_COMMIT"
git -C /tmp/linuxdeploy submodule update --init --recursive
git clone "$LINUXDEPLOY_QT_GIT" /tmp/linuxdeploy-plugin-qt
git -C /tmp/linuxdeploy-plugin-qt checkout "$LINUXDEPLOY_QT_COMMIT"
git -C /tmp/linuxdeploy-plugin-qt submodule update --init --recursive

# Reinstal the libc that is required.
dpkg -i  /libc6_2.28-0ubuntu1_amd64.deb 

cmake /tmp/linuxdeploy -B /tmp/linuxdeploy-build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DUSE_CCACHE=OFF
cmake --build /tmp/linuxdeploy-build

cmake /tmp/linuxdeploy-plugin-qt -B /tmp/linuxdeploy-plugin-qt-build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DUSE_CCACHE=OFF
cmake --build /tmp/linuxdeploy-plugin-qt-build

mkdir -p /usr/local/bin
mv /tmp/linuxdeploy-build/bin/linuxdeploy /usr/local/bin
mv /tmp/linuxdeploy-plugin-qt-build/bin/linuxdeploy-plugin-qt /usr/local/bin

echo
echo '--> Restore the packages list to the original state'
echo


# This broke, not sure why. As it is just uninstalling, we will simply ignore it.
#dpkg --get-selections | cut -f 1 > /tmp/packages_curr.lst
#grep -Fxv -f /tmp/packages_orig.lst /tmp/packages_curr.lst | xargs apt remove -y --purge


# Complete the cleaning

apt -qq clean
rm -rf /var/lib/apt/lists/* /tmp/linuxdeploy*
