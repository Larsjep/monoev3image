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
rootfs=$mount/LMS2012_EXT
ipaddress=10.0.1.1
LJHOME=home/root/lejos

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

        #echo "  ...."copying.application.to.sdcard
        
        #sudo cp -r Linux_AM1808/* $mount/LMS2012_EXT/home/root/lms2012

        echo "  ...."copying.extra.modules.to.sdcard
        sudo cp -r modules/* $rootfs
        sudo cp -r netmods/* "$rootfs/"/lib/modules/*/kernel/drivers/net/wireless/
        sudo cp -r firmware/* "$rootfs"/
        rm "$rootfs"/lib/modules/*/modules.dep

        
        #sudo cp -r netmods/* $mount/LMS2012_EXT/lib/modules/*/kernel/drivers/net/wireless/
        #echo "  ...."force.depmod.on.first.boot
	#sudo rm $mount/LMS2012_EXT/lib/modules/*/modules.dep

        echo "  ...."copying.lejos.to.sdcard
        sudo cp -r lejosfs/* "$rootfs"
        
        #sudo cp -r lejosfs/* $mount/LMS2012_EXT
	sudo cp wpa_supplicant.conf "$mount/LMS2012"
	sudo mkdir "$rootfs"/$LJHOME/mod
	sudo cp mod/*.ko "$rootfs"/$LJHOME/mod
	sudo sh -c "echo $ipaddress > '$rootfs'/$LJHOME/bin/netaddress"

	echo "  ...."installing.links
        cd $rootfs/bin
        ln -s ../$LJHOME/bin/jrun jrun
        cd ../etc/rc0.d
        ln -s ../init.d/lejos K09lejos
        ln -s ../init.d/lejosunload S89lejosunload
        cd ../rc5.d
        ln -s ../init.d/dropbear S81dropbear
        ln -s ../init.d/lejos S98lejos
        cd $current
        rm "$rootfs"/var/lib/bluetooth
        mkdir "$rootfs"/var/lib/bluetooth
	
#	sudo cp ev3classes.jar $mount/LMS2012_EXT/lejos/lib

        echo "  ...."copying.mono.and.glibc.to.sdcard
        sudo cp -r monobin/* "$mount/LMS2012_EXT"
	sudo mkdir "$mount/LMS2012_EXT"/mnt/bootpar
        sudo cp fstab "$mount/LMS2012_EXT"/etc
	sudo rm "$mount/LMS2012_EXT"/sbin/sln
        sudo cp -r glibc-install/* "$mount/LMS2012_EXT"

        echo "  ...."copying.startup.script
        sudo cp startup "$mount/LMS2012_EXT/home/root/lejos/bin"

	
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

