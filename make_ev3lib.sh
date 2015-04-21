#! /bin/bash
. copyapps.sh
echo
echo -------------------------------------------------------------------------------
echo Adding EV3 library and examples to SD card
echo -------------------------------------------------------------------------------
echo
currentDir=${PWD}
ev3LibDir=$currentDir"/ev3lib"
outputDir=$currentDir"/output"
doxygenOutput=$outputDir"/html"
dllName="MonoBrickFirmware.dll"
dllZipName=$outputDir/"MonoBrick.zip"
mdtoolExe="/Applications/Xamarin Studio.app/Contents/MacOS/mdtool"
solutionFile=$ev3LibDir"/MonoBrick.sln"
ev3Git=https://github.com/Larsjep/monoev3
branchName=$3

#-------------------------------------------
# If we using Linux change the path to mdtool
#-------------------------------------------
if [ ! -f "$mdtoolExe" ]; then
    mdtoolExe="mdtool"
fi

#--------------------------------------------------------------
# Make sure that the input argument is either master or release
#-------------------------------------------------------------- 
if [ $branchName == "master" ];
  then
   echo "Building master"
  else
   if [ $branchName == "release" ];
   then
    echo "Building release"	
   else
    echo "Input argument is invalid must be release or master"
    exit 1
   fi
fi

#-----------------------------------------------------
# Delte the output and fetch the MonoBrick EV3 library
#---------------------------------------------------- 
rm -fr $outputDir
cd $currentDir
echo "check dir"
if [ -d "$ev3LibDir" ]; then
  cd $ev3LibDir
  git pull
else
  git clone $ev3Git $ev3LibDir
fi

#------------------------------------------------------------------------
#Make sure that repository is using the correct branch (master or release)
#-------------------------------------------------------------------------
cd $ev3LibDir
git checkout $branchName

#------------------------------------------------------------
# Create the output folder and generate doxygen documentation
#------------------------------------------------------------
mkdir $outputDir
mkdir $doxygenOutput
cd $ev3LibDir/Doxygen
sh createHTML.sh $outputDir

#-------------------------------------------------
# Update the nuget packages and build the solution
#-------------------------------------------------
cd $ev3LibDir
nuget restore  $solutionFile
"$mdtoolExe" -v build "--configuration:Release" $solutionFile

#-------------------------------
# Copy the firmware DLL and mpack (Xamarin addin) to the output folder.
# Compress the DLL firmware file to a zip file
#---------------------------------------------
find . -name "$dllName" -type f -exec cp {} "$outputDir" \;
find . -name "*mpack" -type f -exec cp {} "$outputDir" \;
cd $outputDir
zip $dllZipName $dllName

#---------------------------------------------------------------------
# Create the StarupApp install package and copy it to the output folder
#----------------------------------------------------------------------
mv $ev3LibDir/InstallCreator/bin/Release/InstallCreator.exe $ev3LibDir/StartupApp/bin/Release/InstallCreator.exe  
cd $ev3LibDir/StartupApp/bin/Release
mono InstallCreator.exe test
rm InstallCreator.exe
mkdir $outputDir/StartupApp
cp -r . $outputDir/StartupApp


#---------------------------------------------------------------------
# Copy start up app and programs to SD card
#----------------------------------------------------------------------
cd $ev3LibDir

homedir=${1}/LMS2012_EXT/home/root
echo homedir = ${homedir}
sudo mkdir ${homedir}/apps
sudo find -iname StartupApp.exe -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname MonoBrickFirmware.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname StartupApp.XmlSerializers.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname version.txt -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;


cd ..
copyEv3Apps $ev3LibDir ${homedir}/apps
