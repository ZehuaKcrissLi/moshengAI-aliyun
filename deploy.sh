#!/bin/bash

# 简单部署脚本
set -e

echo "开始部署魔声AI应用..."

# 更新代码
echo "拉取最新代码..."
git pull

# 更新前端依赖并构建
echo "更新前端依赖..."
cd ./moshengAI/frontend
npm install
npm run build

# 返回根目录
cd ../../

# 更新后端依赖
echo "更新后端依赖..."
source ~/miniforge3/bin/activate moshengai
pip install -r ./moshengAI/backend/requirements.txt

# 重启服务
echo "重启所有服务..."
pm2 restart ecosystem.config.js

echo "部署完成！" 