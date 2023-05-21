cmake_minimum_required (VERSION 3.10)
project (ct2wrap_test)

# reference ct2wrap in ../ct2wrap
add_subdirectory(../ct2wrap ct2wrap)
include_directories(../ct2wrap)

# turn on basically all the useful warnings
add_compile_options(-Wall -Wextra)
# # turn on sanitizers
# add_compile_options(-fsanitize=address -fsanitize=undefined)

# executable
add_executable(ct2wrap_test main.cpp)
target_link_libraries(ct2wrap_test ct2wrap ctranslate2 sentencepiece)