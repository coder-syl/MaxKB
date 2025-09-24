#!/bin/bash
# MaxKB Docker镜像导出脚本
# 
# 使用方法:
#   ./export-image.sh                    # 导出 latest 版本
#   ./export-image.sh v1.0.0            # 导出 v1.0.0 版本
#   ./export-image.sh 2024.09.24        # 导出日期版本

echo "📦 导出MaxKB Docker镜像..."

# 设置变量
IMAGE_NAME="maxkb"
IMAGE_TAG="${1:-latest}"
PROJECT_PATH="/home/syl/MaxKB"
EXPORT_DIR="$PROJECT_PATH/images"

# 创建导出目录
mkdir -p "$EXPORT_DIR"

echo "📦 镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "📁 导出目录: $EXPORT_DIR"

# 检查镜像是否存在
if ! docker images "${IMAGE_NAME}:${IMAGE_TAG}" | grep -q "${IMAGE_NAME}"; then
    echo "❌ 镜像 ${IMAGE_NAME}:${IMAGE_TAG} 不存在！"
    echo "请先构建镜像: ./build-docker.sh ${IMAGE_TAG}"
    exit 1
fi

# 导出镜像
echo "🔄 正在导出镜像..."
docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "${EXPORT_DIR}/${IMAGE_NAME}-${IMAGE_TAG}.tar"

if [ $? -eq 0 ]; then
    echo "✅ 镜像导出成功！"
    echo "📁 文件位置: ${EXPORT_DIR}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
    
    # 显示文件信息
    echo ""
    echo "📊 文件信息:"
    ls -lh "${EXPORT_DIR}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
    
    echo ""
    echo "🔄 导入镜像命令:"
    echo "    docker load -i ${EXPORT_DIR}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
else
    echo "❌ 镜像导出失败！"
    exit 1
fi
