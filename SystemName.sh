#!/bin/bash
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
echo "Enter the new System Definition you want to show up in About this Mac:"
read NEWNAME
echo "Backing up SystemProfiler.plist"
cp ~/Library/Preferences/com.apple.SystemProfiler.plist ~/Library/Preferences/com.apple.SystemProfiler.plist.backup
echo "Creating temp folder"
mkdir /tmp/CustomName
cp ~/Library/Preferences/com.apple.SystemProfiler.plist /tmp/CustomName
echo "Converting plist to XML"
plutil -convert xml1 /tmp/CustomName/com.apple.SystemProfiler.plist
echo "Changing System Name"
sed -i'.original' -e "s/iMac/Mac/g" /tmp/CustomName/com.apple.SystemProfiler.plist
sed -i'.switched' -e "s/Mac\(.*\))/$NEWNAME/g" /tmp/CustomName/com.apple.SystemProfiler.plist
echo "Converting back to binary"
plutil -convert binary1 /tmp/CustomName/com.apple.SystemProfiler.plist
echo "Replacing SystemProfiler.plist"
rm -rf ~/Library/Preferences/com.apple.SystemProfiler.plist
mv /tmp/CustomName/com.apple.SystemProfiler.plist ~/Library/Preferences/
echo "Fixing permissions"
sudo chown ${SUDO_USER:-${USER}} ~/Library/Preferences/com.apple.SystemProfiler.plist
sudo chgrp staff ~/Library/Preferences/com.apple.SystemProfiler.plist
echo "Cleaning Up"
rm -rf /tmp/CustomName
echo "Your system must restart for changes to take effect"
while true; do
    read -p "Restart now? (Remeber to save any open work)" yn
    case $yn in
        [Yy]* ) shutdown -r now;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

