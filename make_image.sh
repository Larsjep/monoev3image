#! /bin/bash

#source ${PWD}/env_setup
curdir=${PWD}
sudo -v

drive=loop0
img=imagefile

echo "  ...."creating image file
        
dd if=/dev/zero of=${img} bs=1M count=512
        
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

echo "Adding ev3 library and examples"
./make_ev3lib.sh /mnt

echo "Unmounting"
sudo umount /mnt/LMS*
sudo kpartx -d -v ${img}
echo "Compressing image"
gzip ${img}
echo "Cleaning up"
sudo rm -r ev3lib
echo "All done..."

