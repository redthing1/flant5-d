cmake_minimum_required (VERSION 3.10)
project (ct2wrap)

# reference CTranslate2 in ../../lib/CTranslate2
add_subdirectory(../../lib/CTranslate2 ctranslate2)

# reference sentencepiece in ../../lib/sentencepiece
add_subdirectory(../../lib/sentencepiece sentencepiece)

# make us able to include headers from CTranslate2
include_directories(../../lib/CTranslate2/include)

# make us able to include headers from sentencepiece
include_directories(../../lib/sentencepiece/src)

# static library
add_library(ct2wrap STATIC ct2wrap.cpp)
target_link_libraries(ct2wrap ctranslate2 sentencepiece)
