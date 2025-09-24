#!/bin/bash
# MaxKB Docker构建脚本 - WSL2本地Docker版本
# 
# 使用方法:
#   ./build-docker.sh                    # 构建 latest 版本
#   ./build-docker.sh v1.0.0            # 构建 v1.0.0 版本
#   ./build-docker.sh 2024.09.24        # 构建日期版本
#   ./build-docker.sh dev                # 构建开发版本
#   ./build-docker.sh latest --no-cleanup # 跳过缓存清理

echo "🚀 开始构建MaxKB Docker镜像..."

# 设置构建变量
IMAGE_NAME="maxkb"
IMAGE_TAG="${1:-latest}"  # 支持命令行参数指定版本号，默认为latest
PROJECT_PATH="/home/syl/MaxKB"

# 检查是否跳过缓存清理
SKIP_CLEANUP=false
if [[ "$2" == "--no-cleanup" ]]; then
    SKIP_CLEANUP=true
fi

# 显示版本信息
echo "📦 镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"

echo "📁 项目路径: $PROJECT_PATH"

# 清理缓存函数
cleanup_cache() {
    echo "🧹 开始清理缓存..."
    
    # 显示清理前的磁盘使用情况
    echo "📊 清理前Docker磁盘使用情况:"
    docker system df
    
    echo ""
    echo "🔄 正在清理..."
    
    # 清理Docker构建缓存
    echo "  - 清理Docker构建缓存..."
    docker builder prune -f > /dev/null 2>&1
    
    # 清理未使用的镜像
    echo "  - 清理未使用的Docker镜像..."
    docker image prune -f > /dev/null 2>&1
    
    # 清理未使用的容器
    echo "  - 清理未使用的Docker容器..."
    docker container prune -f > /dev/null 2>&1
    
    # 清理未使用的网络
    echo "  - 清理未使用的Docker网络..."
    docker network prune -f > /dev/null 2>&1
    
    # 清理未使用的数据卷
    echo "  - 清理未使用的Docker数据卷..."
    docker volume prune -f > /dev/null 2>&1
    
    # 清理系统缓存
    echo "  - 清理Docker系统缓存..."
    docker system prune -f > /dev/null 2>&1
    
    echo ""
    echo "📊 清理后Docker磁盘使用情况:"
    docker system df
    
    echo ""
    echo "✅ 缓存清理完成"
    echo ""
}

# 执行缓存清理（除非跳过）
if [[ "$SKIP_CLEANUP" == "false" ]]; then
    cleanup_cache
else
    echo "⏭️ 跳过缓存清理"
    echo ""
fi

# 使用本地Docker（WSL2中安装的Docker）
DOCKER_CMD="docker"

# 检查Docker是否运行
echo "🔍 检查Docker状态..."
if ! $DOCKER_CMD version > /dev/null 2>&1; then
    echo "❌ Docker未运行，请启动Docker服务: sudo systemctl start docker"
    echo "   或者检查Docker是否已正确安装"
    exit 1
fi

echo "✅ Docker已运行"

# 切换到项目目录
cd "$PROJECT_PATH"

# 显示当前目录内容
echo "📋 当前目录结构:"
ls -la

# 检查必需文件
if [ ! -f "installer/Dockerfile" ]; then
    echo "❌ 找不到 installer/Dockerfile 文件"
    exit 1
fi

if [ ! -f "pyproject.toml" ]; then
    echo "❌ 找不到 pyproject.toml 文件"
    exit 1
fi

if [ ! -d "ui" ]; then
    echo "❌ 找不到 ui 目录"
    exit 1
fi

echo "✅ 所有必需文件检查通过"

# 构建Docker镜像
echo "🔨 开始构建镜像: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "使用Dockerfile: installer/Dockerfile"

$DOCKER_CMD build -f installer/Dockerfile -t "${IMAGE_NAME}:${IMAGE_TAG}" .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功！"
    echo "🐳 镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
    
    # 显示镜像信息
    echo ""
    echo "📊 镜像信息:"
    $DOCKER_CMD images "$IMAGE_NAME"
    
    echo ""
    echo "🚀 运行容器命令:"
    echo "  WSL2本地Docker:"
    echo "    $DOCKER_CMD run -d --name=maxkb --restart=always -p 8080:8080 -v ~/.maxkb:/opt/maxkb ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "  或者使用卷挂载:"
    echo "    $DOCKER_CMD run -d --name=maxkb --restart=always -p 8080:8080 -v maxkb-data:/opt/maxkb ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "💾 导出镜像命令:"
    echo "    $DOCKER_CMD save ${IMAGE_NAME}:${IMAGE_TAG} -o images/${IMAGE_NAME}-${IMAGE_TAG}.tar"
    echo ""
    echo "🌐 访问地址: http://localhost:8080"
    echo "👤 默认用户名: admin"
    echo "🔑 默认密码: MaxKB@123.."
else
    echo "❌ 镜像构建失败！"
    exit 1
fi