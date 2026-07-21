set -xe
rm -rf ./build/test
mkdir -p ./build/test

echo "Testing on Erlang VM"
gleam test