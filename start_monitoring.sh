#!/bin/bash

# 魔声AI服务一键监控启动脚本

echo "🎛️ 魔声AI服务监控工具启动器"
echo "=================================="

# 检查依赖
check_dependencies() {
    echo "🔍 检查依赖..."
    
    # 检查Python3
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 未安装"
        exit 1
    fi
    
    # 检查PM2
    if ! command -v pm2 &> /dev/null; then
        echo "❌ PM2 未安装"
        exit 1
    fi
    
    # 检查Python依赖
    python3 -c "import psutil, requests" 2>/dev/null || {
        echo "📦 安装Python依赖..."
        pip3 install psutil requests
    }
    
    echo "✅ 依赖检查完成"
}

# 显示菜单
show_menu() {
    echo ""
    echo "📋 选择监控方式:"
    echo "=================================="
    echo "1. 🌐 启动Web监控面板 (推荐)"
    echo "2. 🐍 Python命令行监控"
    echo "3. 🔧 Bash快速日志查看"
    echo "4. 📊 查看当前服务状态"
    echo "5. 🚀 启动所有监控工具"
    echo "0. ❌ 退出"
    echo "=================================="
}

# 启动Web监控面板
start_web_monitor() {
    echo "🌐 启动Web监控面板..."
    
    # 检查是否已经运行
    if curl -s http://localhost:9999 >/dev/null 2>&1; then
        echo "✅ Web监控面板已在运行"
        echo "🔗 访问地址: http://localhost:9999"
        return
    fi
    
    # 启动监控面板
    if [ -d "monitor" ]; then
        cd monitor
        if [ ! -d "venv" ]; then
            echo "📦 创建虚拟环境..."
            python3 -m venv venv
        fi
        
        echo "🔧 激活虚拟环境并安装依赖..."
        source venv/bin/activate
        pip install -r requirements.txt >/dev/null 2>&1
        
        echo "🚀 启动监控服务..."
        nohup python3 app.py > /dev/null 2>&1 &
        
        # 等待服务启动
        sleep 3
        
        if curl -s http://localhost:9999 >/dev/null 2>&1; then
            echo "✅ Web监控面板启动成功!"
            echo "🔗 访问地址: http://localhost:9999"
        else
            echo "❌ Web监控面板启动失败"
        fi
        
        cd ..
    else
        echo "❌ monitor目录不存在"
    fi
}

# 启动Python监控
start_python_monitor() {
    echo "🐍 启动Python命令行监控..."
    python3 monitor_simple.py
}

# 启动Bash日志查看器
start_bash_monitor() {
    echo "🔧 启动Bash快速日志查看器..."
    ./quick_logs.sh
}

# 查看服务状态
show_status() {
    echo "📊 当前服务状态:"
    echo "=================================="
    
    # PM2状态
    echo "🚀 PM2服务状态:"
    pm2 list | grep -E "(tts-service|backend-service|frontend-service)"
    
    echo ""
    echo "🌐 服务健康检查:"
    
    # 检查各服务
    services=("8080:TTS服务" "8000:后端服务" "5173:前端服务" "9999:监控面板")
    
    for service in "${services[@]}"; do
        port=$(echo $service | cut -d: -f1)
        name=$(echo $service | cut -d: -f2)
        
        if curl -s http://localhost:$port >/dev/null 2>&1; then
            echo "✅ $name (端口$port) - 正常"
        else
            echo "❌ $name (端口$port) - 异常"
        fi
    done
    
    echo ""
    echo "💻 系统资源:"
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
    echo "内存: $(free -h | grep "Mem:" | awk '{print $3"/"$2}')"
    echo "磁盘: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
}

# 启动所有监控工具
start_all_monitors() {
    echo "🚀 启动所有监控工具..."
    
    # 启动Web监控面板
    start_web_monitor
    
    echo ""
    echo "🎉 监控工具启动完成!"
    echo "=================================="
    echo "🌐 Web监控面板: http://localhost:9999"
    echo "🐍 Python监控: python3 monitor_simple.py"
    echo "🔧 Bash日志查看: ./quick_logs.sh"
    echo "=================================="
    echo ""
    echo "💡 提示:"
    echo "- 在IDE中打开浏览器访问Web监控面板"
    echo "- 在终端中运行Python或Bash监控工具"
    echo "- 使用 ./quick_logs.sh [参数] 快速查看日志"
    echo ""
    
    read -p "按回车键继续..."
}

# 主函数
main() {
    # 检查依赖
    check_dependencies
    
    # 如果有参数，直接执行
    case "$1" in
        "web")
            start_web_monitor
            exit 0
            ;;
        "python")
            start_python_monitor
            exit 0
            ;;
        "bash")
            start_bash_monitor
            exit 0
            ;;
        "status")
            show_status
            exit 0
            ;;
        "all")
            start_all_monitors
            exit 0
            ;;
    esac
    
    # 交互式菜单
    while true; do
        show_menu
        echo -n "请选择 (0-5): "
        read choice
        
        case $choice in
            1)
                start_web_monitor
                echo ""
                read -p "按回车键返回菜单..."
                ;;
            2)
                start_python_monitor
                ;;
            3)
                start_bash_monitor
                ;;
            4)
                show_status
                echo ""
                read -p "按回车键返回菜单..."
                ;;
            5)
                start_all_monitors
                ;;
            0)
                echo "👋 再见!"
                exit 0
                ;;
            *)
                echo "❌ 无效选择，请重试"
                sleep 1
                ;;
        esac
    done
}

# 运行主函数
main "$@" 