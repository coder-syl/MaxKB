# 切换到MaxKB目录
cd /home/syl/MaxKB

# 1. 更新包索引并安装必要的依赖
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 2. 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 3. 添加Docker APT仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. 更新包索引并安装Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. 启动并启用Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 6. 验证Docker安装
sudo docker --version
sudo docker run hello-world

# 7. 配置用户权限（将当前用户添加到docker组）
sudo usermod -aG docker $USER

# 8. 重新加载用户组权限
newgrp docker

# 9. 验证无需sudo的Docker命令
docker --version
docker run hello-world