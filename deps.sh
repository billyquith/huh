#!/usr/bin/env bash

THISDIR="$(cd $(dirname $0); pwd -P)"

# LuaJIT
if [ ! -e local/bin/luajit ]; then
    pushd ext/luajit
    make install PREFIX="$THISDIR/local"
    make clean
    popd
fi
./local/bin/luajit -v

# Moonscript
if [ -z `luarocks list moonscript | grep moonscript` ]; then
    luarocks install moonscript
fi 
luarocks list moonscript

