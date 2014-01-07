cat dllfiles | while read f
do
  target=$(readlink -f "$f")
  echo "processing $f at $target"
  targetso="$target.so"
#  echo "SO file = $targetso"
  if [ ! -f $targetso ]; then
    echo "Compiling $f"
    mono --aot=full "$f"
  fi
done
