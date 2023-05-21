#!/usr/bin/env bash

###
### DEPENDENCY LIBRARY BUILDER SCRIPT
### redthing1
###

set -e

HOST="flant5-d"
LIB_FILE_1="libctranslate2.so"
LIB_FILE_2="libsentencepiece.a"

PACKAGE_DIR=$(dirname "$0")
cd "$PACKAGE_DIR"
pushd .
if [ ! -f $LIB_FILE_1 ] || [ ! -f $LIB_FILE_2 ] || [ "$1" == "-f" ]; then
    echo "[$HOST] building CTranslate2 library..."

    pushd lib/CTranslate2
    git submodule update --init --recursive

    echo "[$HOST] starting build of CTranslate2" 
    #
    # START BUILD
    #
    # build the library
    pushd .
    mkdir -p build && cd build
    cmake .. -DBUILD_SHARED_LIBS=ON -DCUDA_DYNAMIC_LOADING=ON -DOPENMP_RUNTIME=COMP -DCMAKE_BUILD_TYPE=Release
    make -j
    popd
    #
    # END BUILD
    #

    echo "[$HOST] finished build of CTranslate2"

    echo "[$HOST] copying CTranslate2 binary ($LIB_FILE_1) to $PACKAGE_DIR"
    cp -v $(pwd)/build/$LIB_FILE_1 $PACKAGE_DIR/$LIB_FILE_1
    popd

    echo "[$HOST] building SentencePiece library..."

    pushd lib/sentencepiece
    git submodule update --init --recursive

    echo "[$HOST] starting build of SentencePiece" 
    #
    # START BUILD
    #
    # build the library
    pushd .
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j
    popd
    #
    # END BUILD
    #

    echo "[$HOST] finished build of SentencePiece"

    echo "[$HOST] copying SentencePiece binary ($LIB_FILE_2) to $PACKAGE_DIR"
    cp -v $(pwd)/build/src/$LIB_FILE_2 $PACKAGE_DIR/$LIB_FILE_2
    popd
else
    # delete $LIB_FILE_1 to force rebuild
    echo "[$HOST] library $LIB_NAME already built."
fi
popd
