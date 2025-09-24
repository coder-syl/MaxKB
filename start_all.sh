#!/bin/bash

echo "🚀 启动MaxKB项目..."

# 清理进程
sudo pkill -f "python.*main.py" 2>/dev/null
sudo pkill -f gunicorn 2>/dev/null
sudo pkill -f celery 2>/dev/null
sleep 2

# 启动前端
echo "📱 启动前端服务..."
cd /home/syl/MaxKB/ui
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 24
yarn dev > /tmp/frontend.log 2>&1 &
FRONTEND_PID=$!

# 启动后端
echo "⚙️ 启动后端服务..."
cd /home/syl/MaxKB
source venv/bin/activate

# 尝试官方启动方式
python main.py start > /tmp/backend.log 2>&1 &
BACKEND_PID=$!

sleep 5

# 检查启动状态
if curl -s http://localhost:3000/ > /dev/null; then
    echo "✅ 前端服务启动成功: http://localhost:3000/"
else
    echo "❌ 前端服务启动失败"
fi

if curl -s http://localhost:8080/api/ > /dev/null 2>&1; then
    echo "✅ 后端服务启动成功: http://localhost:8080/"
else
    echo "⚠️ 后端服务可能需要手动启动"
    echo "请运行: cd /home/syl/MaxKB/apps && source ../venv/bin/activate && python manage.py runserver 0.0.0.0:8080"
fi

echo ""
echo "🎉 MaxKB项目启动完成！"
echo "前端: http://localhost:3000/"
echo "后端: http://localhost:8080/"
echo "用户名: admin"
echo "密码: MaxKB@123.."
