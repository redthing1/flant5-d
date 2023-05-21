cmake_minimum_required (VERSION 3.10)
project (ct2wrap)

# reference CTranslate2 in ../../lib/CTranslate2
add_subdirectory(../../lib/CTranslate2 CTranslate2)

# reference sentencepiece in ../../lib/sentencepiece
add_subdirectory(../../lib/sentencepiece sentencepiece)

# static library
add_library(ct2wrap STATIC ct2wrap.cpp)
target_link_libraries(ct2wrap CTranslate2 sentencepiece)
