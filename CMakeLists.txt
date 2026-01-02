cmake_minimum_required(VERSION 3.16)
project(nether_pathfinder)

# ==================== Android 配置 ====================
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 21)
set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)

set(CMAKE_C_COMPILER /data/data/com.termux/files/usr/bin/clang)
set(CMAKE_CXX_COMPILER /data/data/com.termux/files/usr/bin/clang++)

set(ANDROID_FLAGS "--target=aarch64-linux-android21 -fPIC")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ANDROID_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ANDROID_FLAGS} -std=c++20 -Wall")

# ==================== 预编译 zlib-ng 配置 ====================
# 假设你已经将预编译的 zlib-ng 放在 zlib-ng/build 目录下
set(ZLIB_NG_PREBUILT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zlib-ng/build)

# 检查预编译文件是否存在
if(NOT EXISTS ${ZLIB_NG_PREBUILT_DIR}/libz.a)
    message(FATAL_ERROR "预编译的 zlib-ng 未找到。请先运行预编译脚本，或确保 libz.a 存在于 ${ZLIB_NG_PREBUILT_DIR}")
endif()

# 设置 zlib-ng 的头文件和库路径
set(ZLIB_NG_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zlib-ng)
set(ZLIB_NG_LIBRARY ${ZLIB_NG_PREBUILT_DIR}/libz.a)

message(STATUS "使用预编译 zlib-ng: ${ZLIB_NG_LIBRARY}")

# ==================== abseil 配置 ====================
set(ABSEIL_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/abseil-cpp)
set(ABSEIL_BUILD_DIR ${ABSEIL_ROOT}/build)

# 收集所有 abseil 静态库
file(GLOB_RECURSE ABSL_STATIC_LIBS ${ABSEIL_BUILD_DIR}/*.a)

# ==================== 包含目录 ====================
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${ABSEIL_ROOT}
    ${ZLIB_NG_INCLUDE_DIR}           # zlib-ng 头文件
    /data/data/com.termux/files/usr/include
)

# ==================== 源文件收集 ====================
file(GLOB_RECURSE SRC src/*.cpp src/*.cc src/*.c)
list(REMOVE_ITEM SRC 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/benchmark_main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/baritone_pather.cpp"
)

# ==================== 主库目标 ====================
add_library(nether_pathfinder SHARED ${SRC})

# ==================== 链接配置 ====================
# 链接预编译的 zlib-ng 静态库
target_link_libraries(nether_pathfinder PRIVATE ${ZLIB_NG_LIBRARY})

# 链接 abseil 静态库
if(ABSL_STATIC_LIBS)
    foreach(ABSL_LIB ${ABSL_STATIC_LIBS})
        get_filename_component(LIB_NAME ${ABSL_LIB} NAME_WE)
        message(STATUS "链接 abseil 库: ${LIB_NAME}")
        target_link_libraries(nether_pathfinder PRIVATE ${ABSL_LIB})
    endforeach()
endif()

# 静态链接 C++ 标准库
target_link_options(nether_pathfinder PRIVATE
    "-static-libstdc++"
    "-static-libgcc"
    "-Wl,--exclude-libs,ALL"
    "-Wl,--gc-sections"
    "-Wl,--as-needed"  # 只链接实际需要的库
)

# Android 必要的系统库（动态链接，系统自带）
target_link_libraries(nether_pathfinder PRIVATE
    -llog
    -ldl
    -lm
    -lc
)

# ==================== 编译后处理 ====================
add_custom_command(TARGET nether_pathfinder POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:nether_pathfinder>
        ${CMAKE_CURRENT_BINARY_DIR}/libnether_pathfinder-aarch64.so
    COMMENT "重命名为 Baritone 期望的文件名: libnether_pathfinder-aarch64.so"
)

# ==================== 验证目标 ====================
add_custom_target(verify_all ALL
    COMMAND sh -c "
        echo '=== 最终验证 ===';
        echo '1. 文件类型:';
        file libnether_pathfinder-aarch64.so;
        echo '';
        echo '2. 动态依赖:';
        readelf -d libnether_pathfinder-aarch64.so | grep NEEDED;
        echo '';
        echo '3. 检查 zlib-ng 符号:';
        nm libnether_pathfinder-aarch64.so 2>/dev/null | grep -i 'zng_' | head -3 || echo '✅ 无 zng_ 动态符号';
        echo '';
        echo '4. 库大小:';
        ls -lh libnether_pathfinder-aarch64.so;
        echo '✅ 验证完成'
    "
    DEPENDS nether_pathfinder
)

# ==================== 编译器检查 ====================
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    message(STATUS "使用 Clang 编译器: ${CMAKE_CXX_COMPILER_VERSION}")
else()
    message(WARNING "建议使用 Clang 编译器以获得最佳 Android 兼容性")
endif()

# 打印配置摘要
message(STATUS "构建类型: ${CMAKE_BUILD_TYPE}")
message(STATUS "目标系统: ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION}")
message(STATUS "zlib-ng 路径: ${ZLIB_NG_LIBRARY}")