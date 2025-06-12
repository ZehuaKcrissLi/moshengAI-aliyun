#!/bin/bash

# 魔声AI服务监控面板启动脚本

echo "🎛️ 启动魔声AI服务监控面板..."

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，请先安装Python3"
    exit 1
fi

# 进入监控目录
cd "$(dirname "$0")"

# 检查并安装依赖
if [ ! -d "venv" ]; then
    echo "📦 创建虚拟环境..."
    python3 -m venv venv
fi

echo "🔧 激活虚拟环境..."
source venv/bin/activate

echo "📥 安装依赖包..."
pip install -r requirements.txt

# 确保日志目录存在
mkdir -p /mnt/logs

echo "🚀 启动监控服务..."
echo "📊 监控面板地址: http://localhost:9999"
echo "🔗 或者访问: http://$(hostname -I | awk '{print $1}'):9999"
echo ""
echo "按 Ctrl+C 停止服务"
echo "=========================="

# 启动监控应用
python3 app.py 