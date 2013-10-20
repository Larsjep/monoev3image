#! /bin/bash
echo
echo -------------------------------------------------------------------------------
echo UPDATE SDCARD WITH NEWEST KERNEL, FILESYSTEM AND APPLICATION          TCP120709
echo -------------------------------------------------------------------------------
echo
sudo -v
mount=${1:-/media/`id -u -r -n`}
echo "Mount point is $mount"
echo
echo "  ...."checking.sdcard
sleep 10
current=${PWD}

if [ -d $mount/LMS2012 ]
then

    if [ -d $mount/LMS2012_EXT ]
    then

        echo "  ...."erasing.sdcard
        sudo rm -r $mount/LMS2012/*
        sudo rm -r $mount/LMS2012_EXT/*
        sync

        echo "  ...."copying.kernel.to.sdcard
        sudo cp uImage $mount/LMS2012/uImage
        sync

        echo "  ...."copying.filesystem.to.sdcard
	sudo cp lmsfs.tar.bz2 $mount/LMS2012_EXT
	cd $mount/LMS2012_EXT
	sudo tar -jxf lmsfs.tar.bz2 
	sudo rm lmsfs.tar.bz2
	cd ${current}
        sync

        echo "  ...."copying.application.to.sdcard
        sudo cp -r Linux_AM1808/* $mount/LMS2012_EXT/home/root/lms2012

        echo "  ...."copying.extra.modules.to.sdcard
        sudo cp -r netmods/* $mount/LMS2012_EXT/lib/modules/*/kernel/drivers/net/wireless/
        echo "  ...."force.depmod.on.first.boot
	sudo rm $mount/LMS2012_EXT/lib/modules/*/modules.dep

        echo "  ...."copying.lejos.to.sdcard
        sudo cp -r lejosfs/* $mount/LMS2012_EXT
	sudo cp wpa_supplicant.conf "$mount/LMS2012"
#	sudo cp ev3classes.jar $mount/LMS2012_EXT/lejos/lib

        echo "  ...."copying.mono.and.glibc.to.sdcard
        sudo cp -r monobin/* "$mount/LMS2012_EXT"
	sudo mkdir "$mount/LMS2012_EXT"/mnt/bootpar
        sudo cp fstab "$mount/LMS2012_EXT"/etc
	sudo rm "$mount/LMS2012_EXT"/sbin/sln
        sudo cp -r glibc-install/* "$mount/LMS2012_EXT"

	
        echo "  ...."writing.to.sdcard
        sync

        echo
        echo REMOVE sdcard

    else

        echo
        echo SDCARD NOT PROPERLY FORMATTED !!!

    fi

else

    echo
    echo SDCARD NOT PROPERLY FORMATTED !!!

fi
echo
echo -------------------------------------------------------------------------------
echo

