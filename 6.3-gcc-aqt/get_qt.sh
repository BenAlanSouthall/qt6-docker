#!/bin/sh -xe
# Script to install Qt 6 in docker container

[ "$AQT_VERSION" ] || AQT_VERSION=aqtinstall
[ "$QT_VERSION" ] || exit 1

[ "$QT_PATH" ] || QT_PATH=/opt/Qt

root_dir=$PWD
[ "$root_dir" != '/' ] || root_dir=""

# Init the package system
apt update

echo
echo '--> Save the original installed packages list'
echo

dpkg --get-selections | cut -f 1 > /tmp/packages_orig.lst

echo
echo '--> Install the required packages to install Qt'
echo

apt install -y git python3-pip libglib2.0-0

# For bionic, we need to pin this package to an older version, as the system python is missing some setuptools stuff.
pip3 install pybcj==0.6.0

pip3 install --no-cache-dir "$AQT_VERSION"

echo
echo '--> Download & install the Qt library using aqt'
echo

aqt install-qt -O "$QT_PATH" linux desktop "$QT_VERSION" gcc_64

# For 6.3 this happens, but not there in 5.13.2
#if ! ${QT_PATH}/${QT_VERSION}/gcc_64/./libexec/moc --help  ; then

if ! ${QT_PATH}/${QT_VERSION}/gcc_64/bin/moc --help  ; then
    echo "WAS NOT ABLE TO RUN AN INSTALLED TOOL"
    echo "DO WE STILL HAVE PROBLEMS WITH LIBC VERSIONING?"
fi

aqt install-tool -O "$QT_PATH" linux desktop tools_cmake
aqt install-tool -O "$QT_PATH" linux desktop tools_ninja

pip3 freeze | xargs pip3 uninstall -y

echo
echo '--> Restore the packages list to the original state'
echo

dpkg --get-selections | cut -f 1 > /tmp/packages_curr.lst

# Do not do this
# grep -Fxv -f /tmp/packages_orig.lst /tmp/packages_curr.lst | xargs apt remove -y --purge

# Complete the cleaning

apt -qq clean
#rm -rf /var/lib/apt/lists/*
