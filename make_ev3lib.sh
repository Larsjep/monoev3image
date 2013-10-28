#! /bin/bash
echo
echo -------------------------------------------------------------------------------
echo Adding EV3 library and examples to SD card
echo -------------------------------------------------------------------------------
echo
git clone https://github.com/Larsjep/monoev3.git ev3lib
cd ev3lib
mdtool -v build "--configuration:Debug|x86" MonoBrick.sln
homedir=${1}/LMS2012_EXT/home/root
echo homedir = ${homedir}
sudo mkdir ${homedir}/apps
sudo find -iname *.exe -exec cp "{}" /mnt/LMS2012_EXT/home/root/apps/ \;
sudo find -iname *.dll -exec cp "{}" /mnt/LMS2012_EXT/home/root/apps/ \;
sudo rm /mnt/LMS2012_EXT/home/root/apps/StartupApp.exe
sudo find -iname StartupApp.exe -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname MonoBrickFirmware.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
