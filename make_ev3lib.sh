#! /bin/bash
. copyapps.sh
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
sudo find -iname StartupApp.exe -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname MonoBrickFirmware.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname StartupApp.XmlSerializers.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;

cd ..
copyEv3Apps ev3lib ${homedir}/apps
