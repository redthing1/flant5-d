#!/usr/bin/env bash

###
### DEPENDENCY LIBRARY BUILDER SCRIPT
### redthing1
###

set -e
set -x

HOST="flant5-d"
LIB_FILE_0="libct2wrap.a"
LIB_FILE_1="libctranslate2.so"
# LIB_FILE_1="libctranslate2.a"
LIB_FILE_2="libsentencepiece.a"
# LIB_FILE_3="libcpu_features.a"

PARALLEL=${PARALLEL:-$(nproc)}

PACKAGE_DIR=$(dirname "$0")
cd "$PACKAGE_DIR"
pushd .
if [ ! -f $LIB_FILE_0 ] || [ ! -f $LIB_FILE_1 ] || [ ! -f $LIB_FILE_2 ] || [ "$1" == "-f" ]; then
# if [ ! -f $LIB_FILE_0 ] || [ ! -f $LIB_FILE_1 ] || [ ! -f $LIB_FILE_2 ] || [ ! -f $LIB_FILE_3 ] || [ "$1" == "-f" ]; then
    echo "[$HOST] building ct2wrap library..."
    
    # git submodule update --init --recursive
    # check if .git exists (to see if we can use submodule)
    if [ ! -d ".git" ]; then
        # git does not exist, so we need to clone the submodules directly
        echo "[$HOST] cloning submodules..."
        git clone https://github.com/google/sentencepiece lib/sentencepiece
        pushd lib/sentencepiece && git checkout v0.1.99 && popd
        git clone https://github.com/OpenNMT/CTranslate2 lib/CTranslate2
        pushd lib/CTranslate2 && git checkout cb228834390ad6f29864d0c205be49d144fa1dae && popd
    else
        # git exists, so we can use submodule
        echo "[$HOST] updating submodules..."
        git submodule update --init --recursive
    fi

    pushd cpp/ct2wrap

    echo "[$HOST] starting build of ct2wrap"
    #
    # START BUILD
    #
    # build the library
    pushd .
    mkdir -p build && cd build
    cmake .. -DBUILD_SHARED_LIBS=ON -DWITH_MKL=OFF -DWITH_OPENBLAS=ON -DOPENMP_RUNTIME=COMP -DBUILD_CLI=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
    # cmake .. -DBUILD_SHARED_LIBS=OFF -DWITH_MKL=OFF -DWITH_OPENBLAS=ON -DWITH_RUY=OFF -DOPENMP_RUNTIME=COMP -DBUILD_CLI=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make -j${PARALLEL}
    popd
    #
    # END BUILD
    #

    echo "[$HOST] finished build of ct2wrap"
    
    echo "[$HOST] copying ct2wrap binary ($LIB_FILE_0) to $PACKAGE_DIR"
    cp -v $(pwd)/build/$LIB_FILE_0 $PACKAGE_DIR/$LIB_FILE_0
    echo "[$HOST] copying CTranslate2 binary ($LIB_FILE_1) to $PACKAGE_DIR"
    cp -v $(pwd)/build/ctranslate2/$LIB_FILE_1 $PACKAGE_DIR/$LIB_FILE_1
    echo "[$HOST] copying sentencepiece binary ($LIB_FILE_2) to $PACKAGE_DIR"
    cp -v $(pwd)/build/sentencepiece/src/$LIB_FILE_2 $PACKAGE_DIR/$LIB_FILE_2
    # echo "[$HOST] copying cpu_features binary ($LIB_FILE_3) to $PACKAGE_DIR"
    # cp -v $(pwd)/build/ctranslate2/third_party/cpu_features/$LIB_FILE_3 $PACKAGE_DIR/$LIB_FILE_3
    popd
else
    # delete $LIB_FILE_1 to force rebuild
    echo "[$HOST] library $LIB_NAME already built."
fi
popd
