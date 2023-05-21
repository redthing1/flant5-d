
# ct2wrap_Test

for testing ct2wrap

to build:
```sh
mkdir build && cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DCUDA_DYNAMIC_LOADING=ON -DOPENMP_RUNTIME=COMP -DCMAKE_BUILD_TYPE=RelWithDebInfo && make -j
```
