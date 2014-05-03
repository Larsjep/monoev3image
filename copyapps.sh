function copyEv3Apps ()
{
for arg in $(ls $1) 
do
  if [ -d $1/$arg -a $arg != StartupApp ]
  then
    local dest=$2/$arg
    local src=$1/$arg/bin/Debug
    if [ -f $src/*.exe ]
    then
      echo Copying program $arg to $dest
      sudo mkdir $dest
      sudo cp $src/*.exe $dest
      sudo cp $src/*.dll $dest
    fi
  fi
done
}

