set -e

echo "-- Testing on Erlang VM:"
rm -rf ./build/test
mkdir -p ./build/test
gleam test

echo -e "\n-- Testing on NodeJs:"
rm -rf ./build/test
mkdir -p ./build/test
gleam test -t javascript --runtime nodejs