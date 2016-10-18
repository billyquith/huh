#!/usr/bin/env bash

THISDIR="$(cd $(dirname $0); pwd -P)"
LUAJIT=$THISDIR/../../local/bin/luajit

# test we can compile moonscript and run it using LuaJIT
moonc -o test.lua test.moon
$LUAJIT test.lua
