log()
{
  echo $1 >> /tmp/logfile
  echo $1 >> /tmp/debug
  echo $1
  sleep 2
}

startLog()
{
  setterm -clear > /dev/tty1
  # make sure terminal is enabled
  echo 1 > /sys/class/vtconsole/vtcon1/bind
  # configure terminal
  setterm -cursor off > /dev/tty1
  setterm -blank 0 > /dev/tty1
  setterm -linewrap off > /dev/tty1
  setterm -clear > /dev/tty1
  # load the logo
  cp ${LEJOS_HOME}/images/lejoslogo.ev3i /dev/fb0
  echo "" > /tmp/logfile
  ${LEJOS_HOME}/bin/spinner.sh > /dev/tty1 &
}

stopLog()
{
  # stop spinner
  rm /tmp/logfile 2> /dev/null
  # disable console
  echo 0 > /sys/class/vtconsole/vtcon1/bind
}


error()
{
  # some sort of error, log it
  log "Install error"
  echo $1 >> /tmp/logfile
  echo $1 >> /tmp/debug
  # try and save the error info.
  mount /dev/mmcblk0p1 /media/bootfs
  cp /tmp/debug /media/bootfs
  cp /tmp/logfile /media/bootfs
  umount /media/bootfs
  rm /tmp/logfile
  sleep 2
  setterm -clear > /dev/tty1
  echo "Install error:" > /dev/tty1
  echo $1 > /dev/tty1
  echo
  sleep 20
  echo "Power off..." > /dev/tty1
  sleep 10
  poweroff -f
  exit 1
}


