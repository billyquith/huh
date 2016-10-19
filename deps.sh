#!/usr/bin/env bash

if [ "$1" == "-u" ]; then
    UPDATE=1
fi

THISDIR="$(cd $(dirname $0); pwd -P)"

if [ ! -z $UPDATE ]; then
    # get latest LuaJIT and force rebuild
    git-subrepo pull ext/luajit
    rm local/bin/luajit
fi

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

