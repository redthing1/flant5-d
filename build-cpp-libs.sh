#!/usr/bin/env bash

###
### DEPENDENCY LIBRARY BUILDER SCRIPT
### redthing1
###

set -e

HOST="flant5-d"
LIB_FILE_0="libct2wrap.a"
LIB_FILE_1="libctranslate2.so"
LIB_FILE_2="libsentencepiece.a"

PACKAGE_DIR=$(dirname "$0")
cd "$PACKAGE_DIR"
pushd .
if [ ! -f $LIB_FILE_0 ] || [ ! -f $LIB_FILE_1 ] || [ ! -f $LIB_FILE_2 ] || [ "$1" == "-f" ]; then
    echo "[$HOST] building ct2wrap library..."
    git submodule update --init --recursive

    pushd cpp/ct2wrap

    echo "[$HOST] starting build of ct2wrap"
    #
    # START BUILD
    #
    # build the library
    pushd .
    mkdir -p build && cd build
    cmake .. -DBUILD_SHARED_LIBS=ON -DCUDA_DYNAMIC_LOADING=ON -DOPENMP_RUNTIME=COMP -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make -j
    popd
    #
    # END BUILD
    #

    echo "[$HOST] finished build of ct2wrap"
    
    echo "[$HOST] copying ct2wrap binary ($LIB_FILE_0) to $PACKAGE_DIR"
    cp -v $(pwd)/build/$LIB_FILE_0 $PACKAGE_DIR/$LIB_FILE_0
    echo "[$HOST] copying CTranslate2 binary ($LIB_FILE_1) to $PACKAGE_DIR"
    cp -v $(pwd)/build/CTranslate2/$LIB_FILE_1 $PACKAGE_DIR/$LIB_FILE_1
    echo "[$HOST] copying sentencepiece binary ($LIB_FILE_2) to $PACKAGE_DIR"
    cp -v $(pwd)/build/sentencepiece/src/$LIB_FILE_2 $PACKAGE_DIR/$LIB_FILE_2
    popd
else
    # delete $LIB_FILE_1 to force rebuild
    echo "[$HOST] library $LIB_NAME already built."
fi
popd
