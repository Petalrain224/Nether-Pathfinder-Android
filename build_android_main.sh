#!/data/data/com.termux/files/usr/bin/bash
echo "=== 编译静态链接版本 ==="

# 清理并创建构建目录
rm -rf build_android
mkdir build_android && cd build_android

echo "1. 配置CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DTESTING=OFF \
    -DUSE_ABSEIL=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=OFF

if [ $? -ne 0 ]; then
    echo "CMake配置失败!"
    exit 1
fi

echo -e "\n2. 开始编译..."
make -j2

echo -e "\n3. 验证生成的库文件..."
if [ -f "libnether_pathfinder-aarch64.so" ]; then
    echo "✅ 库文件生成成功"
    
    echo -e "\n4. 检查动态依赖（应该只有极少的Android系统库）:"
    # 使用 readelf 检查
    echo "=== readelf -d 输出 ==="
    readelf -d libnether_pathfinder-aarch64.so | grep -E "(NEEDED|SONAME)"
    
    echo -e "\n5. 检查 libz是否依赖:"
    readelf -d libnether_pathfinder-aarch64.so | grep -i libz
    
    echo -e "\n6. 库文件信息:"
    file libnether_pathfinder-aarch64.so
    
    echo -e "\n✅ 编译完成！"
    echo "库文件: $(pwd)/libnether_pathfinder-aarch64.so"
    echo "大小: $(du -h libnether_pathfinder-aarch64.so | cut -f1)"
else
    echo "❌ 库文件未生成!"
    exit 1
fi