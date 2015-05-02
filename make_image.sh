#! /bin/bash

#source ${PWD}/env_setup
curdir=${PWD}
sudo -v

drive=loop0
img=$1
size=$2
branchName=$3
buildev3lib=$4
echo "  ...."creating image file
        
dd if=/dev/zero of=${img} bs=1M count=${size}
        
sudo losetup /dev/${drive} ${img}
echo "  ...."creating partitions
sudo fdisk /dev/${drive} < fdisk.cmd &>> sdcard.err
sudo losetup -d /dev/${drive}
echo "Listing devices"
sudo kpartx -l -v ${img}
sudo kpartx -a -v ${img}

echo
echo "  ...."making.kernel.partition
sudo mkfs.msdos -n LMS2012 /dev/mapper/${drive}p1 &>> sdcard.err

echo
echo "  ...."making.filesystem.partition
sudo mkfs.ext3 -L LMS2012_EXT /dev/mapper/${drive}p2 &>> sdcard.err

echo
echo "  ...."checking.partitions
sync

if [ -e /dev/mapper/${drive}p1 ]
then

    if [ -e /dev/mapper/${drive}p2 ]
    then

        echo
        echo SUCCESS

    else

        echo
echo "******************************************************************"
	cat sdcard.err
echo "******************************************************************"
        echo
        echo SDCARD NOT FORMATTED PROPERLY !!!

    fi

else

    echo
echo "******************************************************************"
    cat sdcard.err
echo "******************************************************************"
    echo
    echo SDCARD NOT FORMATTED PROPERLY !!!

fi

echo "Mounting partitions"
sudo mkdir /mnt/LMS2012
sudo mount /dev/mapper/loop0p1 /mnt/LMS2012
sudo mkdir /mnt/LMS2012_EXT
sudo mount /dev/mapper/loop0p2 /mnt/LMS2012_EXT

./update_sdcard.sh /mnt
if [ $buildev3lib == "false" ];
  then
   echo "Skipping building ev3 lib"
  else
   if [ $buildev3lib == "true" ];
   then
    echo "Building ev3 library"
    ./make_ev3lib.sh /mnt $branchName
   else
    echo "Input argument is invalid must be true or false"
    exit 1
   fi
fi

#---------------------------------------------------------------------
# Copy start up app and programs to SD card
#----------------------------------------------------------------------
ev3LibDir=$currentDir"/ev3lib"
cd $ev3LibDir

homedir=/mnt/LMS2012_EXT/home/root
echo homedir = ${homedir}
sudo mkdir ${homedir}/apps
sudo find -iname StartupApp.exe -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname MonoBrickFirmware.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname StartupApp.XmlSerializers.dll -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;
sudo find -iname version.txt -exec cp "{}" "/mnt/LMS2012_EXT/usr/local/bin" \;

cd ..
#copyEv3Apps $ev3LibDir ${homedir}/apps

echo "Unmounting"
sudo umount /mnt/LMS*
sudo kpartx -d -v ${img}
echo "Compressing image"
gzip ${img}
echo "Cleaning up"
#sudo rm -r ev3lib
echo "All done..."

