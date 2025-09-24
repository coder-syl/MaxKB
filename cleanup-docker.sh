#!/bin/bash
# Docker缓存清理脚本
# 
# 使用方法:
#   ./cleanup-docker.sh                    # 清理所有缓存
#   ./cleanup-docker.sh --aggressive       # 激进清理（包括所有未使用的镜像）
#   ./cleanup-docker.sh --help             # 显示帮助信息

echo "🧹 Docker缓存清理工具"
echo "====================="

# 显示帮助信息
show_help() {
    echo ""
    echo "使用方法:"
    echo "  $0                    # 标准清理（保留正在使用的镜像）"
    echo "  $0 --aggressive       # 激进清理（删除所有未使用的镜像）"
    echo "  $0 --help             # 显示此帮助信息"
    echo ""
    echo "清理内容:"
    echo "  - 构建缓存"
    echo "  - 未使用的容器"
    echo "  - 未使用的网络"
    echo "  - 未使用的数据卷"
    echo "  - 系统缓存"
    echo ""
}

# 检查参数
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

AGGRESSIVE=false
if [[ "$1" == "--aggressive" ]]; then
    AGGRESSIVE=true
fi

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请启动Docker服务"
    exit 1
fi

echo "✅ Docker正在运行"
echo ""

# 显示清理前的状态
echo "📊 清理前Docker磁盘使用情况:"
docker system df
echo ""

# 显示当前镜像列表
echo "📋 当前Docker镜像:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo ""

# 显示当前容器列表
echo "📋 当前Docker容器:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""

# 确认清理
if [[ "$AGGRESSIVE" == "true" ]]; then
    echo "⚠️ 警告: 激进清理模式将删除所有未使用的镜像！"
    echo "这可能会删除一些您想要保留的镜像。"
    echo ""
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 清理已取消"
        exit 0
    fi
fi

echo "🔄 开始清理..."
echo ""

# 清理构建缓存
echo "  - 清理Docker构建缓存..."
docker builder prune -f

# 清理未使用的容器
echo "  - 清理未使用的Docker容器..."
docker container prune -f

# 清理未使用的网络
echo "  - 清理未使用的Docker网络..."
docker network prune -f

# 清理未使用的数据卷
echo "  - 清理未使用的Docker数据卷..."
docker volume prune -f

# 清理系统缓存
echo "  - 清理Docker系统缓存..."
docker system prune -f

# 激进清理：删除所有未使用的镜像
if [[ "$AGGRESSIVE" == "true" ]]; then
    echo "  - 清理所有未使用的Docker镜像..."
    docker image prune -a -f
else
    echo "  - 清理悬空镜像..."
    docker image prune -f
fi

echo ""
echo "📊 清理后Docker磁盘使用情况:"
docker system df

echo ""
echo "✅ 缓存清理完成！"
echo ""

# 显示清理后的镜像列表
echo "📋 清理后Docker镜像:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo ""

# 显示清理后的容器列表
echo "📋 清理后Docker容器:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
