cmake_minimum_required (VERSION 3.10)
project (ct2wrap_test)

# reference ct2wrap in ../ct2wrap
add_subdirectory(../ct2wrap ct2wrap)
include_directories(../ct2wrap)

# executable
add_executable(ct2wrap_test main.cpp)
target_link_libraries(ct2wrap_test ct2wrap ctranslate2 sentencepiece)