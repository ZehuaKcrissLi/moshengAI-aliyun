#!/bin/bash

# 魔声AI服务日志快速查看脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志文件路径
TTS_LOG="/mnt/logs/tts-service-out.log"
BACKEND_LOG="/mnt/logs/backend-service-out.log"
FRONTEND_LOG="/mnt/logs/frontend-service-out.log"

# 函数：显示标题
show_header() {
    echo -e "${CYAN}=================================${NC}"
    echo -e "${CYAN}🎛️  魔声AI服务日志查看器${NC}"
    echo -e "${CYAN}📅 $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}=================================${NC}"
}

# 函数：显示服务状态
show_status() {
    echo -e "\n${GREEN}🚀 服务状态:${NC}"
    echo -e "${BLUE}--------------------------------${NC}"
    
    # 检查PM2状态
    if command -v pm2 &> /dev/null; then
        pm2 list | grep -E "(tts-service|backend-service|frontend-service)" | while read line; do
            if echo "$line" | grep -q "online"; then
                echo -e "${GREEN}✅ $line${NC}"
            elif echo "$line" | grep -q "stopped"; then
                echo -e "${RED}❌ $line${NC}"
            else
                echo -e "${YELLOW}⚠️  $line${NC}"
            fi
        done
    else
        echo -e "${RED}❌ PM2 未安装${NC}"
    fi
}

# 函数：显示彩色日志
show_colored_logs() {
    local log_file=$1
    local service_name=$2
    local lines=${3:-20}
    
    echo -e "\n${PURPLE}📝 $service_name 最近日志 (${lines}行):${NC}"
    echo -e "${BLUE}--------------------------------${NC}"
    
    if [ -f "$log_file" ]; then
        tail -n "$lines" "$log_file" | while IFS= read -r line; do
            if [[ $line == *"ERROR"* ]] || [[ $line == *"error"* ]]; then
                echo -e "${RED}🔴 $line${NC}"
            elif [[ $line == *"WARN"* ]] || [[ $line == *"warning"* ]]; then
                echo -e "${YELLOW}🟡 $line${NC}"
            elif [[ $line == *"INFO"* ]] || [[ $line == *"info"* ]]; then
                echo -e "${BLUE}🔵 $line${NC}"
            else
                echo -e "   $line"
            fi
        done
    else
        echo -e "${RED}❌ 日志文件不存在: $log_file${NC}"
    fi
}

# 函数：实时监控日志
monitor_logs() {
    local log_file=$1
    local service_name=$2
    
    echo -e "\n${GREEN}🔄 实时监控 $service_name 日志 (按Ctrl+C退出):${NC}"
    echo -e "${BLUE}================================${NC}"
    
    if [ -f "$log_file" ]; then
        tail -f "$log_file" | while IFS= read -r line; do
            timestamp=$(date '+%H:%M:%S')
            if [[ $line == *"ERROR"* ]] || [[ $line == *"error"* ]]; then
                echo -e "${RED}[$timestamp] 🔴 $line${NC}"
            elif [[ $line == *"WARN"* ]] || [[ $line == *"warning"* ]]; then
                echo -e "${YELLOW}[$timestamp] 🟡 $line${NC}"
            elif [[ $line == *"INFO"* ]] || [[ $line == *"info"* ]]; then
                echo -e "${BLUE}[$timestamp] 🔵 $line${NC}"
            else
                echo -e "[$timestamp]    $line"
            fi
        done
    else
        echo -e "${RED}❌ 日志文件不存在: $log_file${NC}"
    fi
}

# 函数：显示菜单
show_menu() {
    echo -e "\n${CYAN}📋 选择操作:${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}1.${NC} 查看TTS服务日志"
    echo -e "${GREEN}2.${NC} 查看后端服务日志"
    echo -e "${GREEN}3.${NC} 查看前端服务日志"
    echo -e "${GREEN}4.${NC} 查看所有服务状态"
    echo -e "${GREEN}5.${NC} 实时监控TTS服务"
    echo -e "${GREEN}6.${NC} 实时监控后端服务"
    echo -e "${GREEN}7.${NC} 实时监控前端服务"
    echo -e "${GREEN}8.${NC} 查看系统资源"
    echo -e "${GREEN}9.${NC} 启动Python监控面板"
    echo -e "${RED}0.${NC} 退出"
    echo -e "${BLUE}================================${NC}"
}

# 函数：显示系统资源
show_system_resources() {
    echo -e "\n${PURPLE}💻 系统资源:${NC}"
    echo -e "${BLUE}--------------------------------${NC}"
    
    # CPU使用率
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    echo -e "${GREEN}CPU使用率:${NC} ${cpu_usage}%"
    
    # 内存使用率
    memory_info=$(free -h | grep "Mem:")
    echo -e "${GREEN}内存信息:${NC} $memory_info"
    
    # 磁盘使用率
    echo -e "${GREEN}磁盘使用率:${NC}"
    df -h | grep -E "^/dev/" | head -3
    
    # 网络连接
    echo -e "\n${GREEN}服务端口监听:${NC}"
    netstat -tlnp 2>/dev/null | grep -E ":8080|:8000|:5173|:9999" | head -5
}

# 主函数
main() {
    # 检查参数
    case "$1" in
        "tts")
            show_colored_logs "$TTS_LOG" "TTS语音合成服务" 30
            exit 0
            ;;
        "backend")
            show_colored_logs "$BACKEND_LOG" "后端API服务" 30
            exit 0
            ;;
        "frontend")
            show_colored_logs "$FRONTEND_LOG" "前端Web服务" 30
            exit 0
            ;;
        "status")
            show_header
            show_status
            exit 0
            ;;
        "monitor-tts")
            monitor_logs "$TTS_LOG" "TTS语音合成服务"
            exit 0
            ;;
        "monitor-backend")
            monitor_logs "$BACKEND_LOG" "后端API服务"
            exit 0
            ;;
        "monitor-frontend")
            monitor_logs "$FRONTEND_LOG" "前端Web服务"
            exit 0
            ;;
        "system")
            show_system_resources
            exit 0
            ;;
    esac
    
    # 交互式菜单
    while true; do
        clear
        show_header
        show_status
        show_menu
        
        echo -ne "\n${CYAN}请选择操作 (0-9): ${NC}"
        read -r choice
        
        case $choice in
            1)
                clear
                show_header
                show_colored_logs "$TTS_LOG" "TTS语音合成服务" 30
                echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                read -r
                ;;
            2)
                clear
                show_header
                show_colored_logs "$BACKEND_LOG" "后端API服务" 30
                echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                read -r
                ;;
            3)
                clear
                show_header
                show_colored_logs "$FRONTEND_LOG" "前端Web服务" 30
                echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                read -r
                ;;
            4)
                clear
                show_header
                show_status
                show_system_resources
                echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                read -r
                ;;
            5)
                clear
                monitor_logs "$TTS_LOG" "TTS语音合成服务"
                ;;
            6)
                clear
                monitor_logs "$BACKEND_LOG" "后端API服务"
                ;;
            7)
                clear
                monitor_logs "$FRONTEND_LOG" "前端Web服务"
                ;;
            8)
                clear
                show_header
                show_system_resources
                echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                read -r
                ;;
            9)
                echo -e "\n${GREEN}🚀 启动Python监控面板...${NC}"
                if [ -f "monitor_simple.py" ]; then
                    python3 monitor_simple.py
                else
                    echo -e "${RED}❌ monitor_simple.py 文件不存在${NC}"
                    echo -e "\n${YELLOW}按回车键返回菜单...${NC}"
                    read -r
                fi
                ;;
            0)
                echo -e "\n${GREEN}👋 再见!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}❌ 无效选择，请重试${NC}"
                sleep 1
                ;;
        esac
    done
}

# 运行主函数
main "$@" 