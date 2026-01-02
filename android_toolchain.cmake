# android_toolchain.cmake - zlib-ng 专用工具链
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 21)
set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)

# 使用绝对路径的编译器
set(CMAKE_C_COMPILER /data/data/com.termux/files/usr/bin/clang)
set(CMAKE_CXX_COMPILER /data/data/com.termux/files/usr/bin/clang++)

# 设置编译器目标
set(CMAKE_C_FLAGS "--target=aarch64-linux-android21 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "--target=aarch64-linux-android21 ${CMAKE_CXX_FLAGS}")

# 设置交叉编译标志
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_FIND_ROOT_PATH /data/data/com.termux/files/usr)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)