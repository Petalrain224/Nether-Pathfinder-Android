#!/data/data/com.termux/files/usr/bin/bash
echo "=== 修复版 zlib-ng 编译 ==="

cd zlib-ng
rm -rf build && mkdir build && cd build

echo "配置 zlib-ng，禁用平台特定代码..."

# 关键：禁用所有平台特定优化，使用通用实现
cmake .. \
    -DCMAKE_C_COMPILER=/data/data/com.termux/files/usr/bin/clang \
    -DCMAKE_C_FLAGS="--target=aarch64-linux-android21 -fPIC" \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=21 \
    -DBUILD_SHARED_LIBS=OFF \
    -DZLIB_COMPAT=ON \
    -DWITH_GZFILEOP=ON \
    -DWITH_OPTIM=OFF \
    -DWITH_NATIVE_INSTRUCTIONS=OFF \
    -DWITH_X86=OFF \
    -DWITH_ACLE=OFF \
    -DWITH_S390=OFF \
    -DWITH_POWER=OFF \
    -DWITH_POWER8=OFF \
    -DWITH_RISCV=OFF \
    -DWITH_MIPS=OFF \
    -DWITH_NG=ON \
    -DWITH_LOONGARCH=OFF \
    -DCMAKE_BUILD_TYPE=Release

if [ $? -ne 0 ]; then
    echo "❌ CMake 配置失败"
    exit 1
fi

echo "编译 zlib-ng..."
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ zlib-ng 编译成功！"
    cp libz.a ../../
else
    echo "❌ 编译失败，尝试手动编译..."
fi

echo "检查符号："
nm libz.a 2>/dev/null | grep -E "zng_gzread|T gzread" | head -5