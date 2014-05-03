function copyEv3Apps ()
{
for arg in $(ls $1) 
do
  if [ -d $1/$arg -a $arg != StartupApp ]
  then
    local dest=$2/$arg
    local src=$1/$arg/bin/Debug
    echo Copying program $arg to $dest
    mkdir $dest
    cp $src/*.exe $dest
    cp $src/*.dll $dest
  fi
done
}

