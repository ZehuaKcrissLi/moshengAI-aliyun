#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
魔声AI服务监控脚本 - 命令行版本
适合在IDE终端中运行，提供实时服务状态和日志监控
"""

import os
import json
import subprocess
import psutil
import time
import requests
from datetime import datetime
import threading
import sys

# 服务配置
SERVICES = {
    'tts-service': {
        'name': 'TTS语音合成服务',
        'port': 8080,
        'health_url': 'http://localhost:8080/health',
        'log_file': '/mnt/logs/tts-service-out.log'
    },
    'backend-service': {
        'name': '后端API服务',
        'port': 8000,
        'health_url': 'http://localhost:8000/health',
        'log_file': '/mnt/logs/backend-service-out.log'
    },
    'frontend-service': {
        'name': '前端Web服务',
        'port': 5173,
        'health_url': 'http://localhost:5173',
        'log_file': '/mnt/logs/frontend-service-out.log'
    }
}

def clear_screen():
    """清屏"""
    os.system('clear' if os.name == 'posix' else 'cls')

def get_pm2_status():
    """获取PM2服务状态"""
    try:
        result = subprocess.run(['pm2', 'jlist'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if result.returncode == 0:
            return json.loads(result.stdout)
        return []
    except Exception:
        return []

def check_service_health(service_config):
    """检查服务健康状态"""
    try:
        response = requests.get(service_config['health_url'], timeout=3)
        return {
            'status': '🟢 健康' if response.status_code == 200 else '🟡 异常',
            'response_time': f"{response.elapsed.total_seconds():.3f}s"
        }
    except requests.exceptions.ConnectionError:
        return {'status': '🔴 离线', 'response_time': 'N/A'}
    except requests.exceptions.Timeout:
        return {'status': '🟡 超时', 'response_time': '>3s'}
    except Exception:
        return {'status': '❌ 错误', 'response_time': 'N/A'}

def get_system_info():
    """获取系统信息"""
    try:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return {
            'cpu_percent': cpu_percent,
            'memory_percent': memory.percent,
            'memory_used': memory.used // (1024**3),  # GB
            'memory_total': memory.total // (1024**3),  # GB
            'disk_percent': (disk.used / disk.total) * 100,
            'disk_free': disk.free // (1024**3),  # GB
        }
    except Exception:
        return {}

def format_uptime(uptime_ms):
    """格式化运行时间"""
    if not uptime_ms:
        return 'N/A'
    
    seconds = (time.time() * 1000 - uptime_ms) / 1000
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    return f"{hours}h {minutes}m"

def get_log_tail(log_file, lines=10):
    """获取日志文件的最后几行"""
    try:
        if os.path.exists(log_file):
            result = subprocess.run(['tail', '-n', str(lines), log_file], 
                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            return result.stdout.strip().split('\n')
        return ['日志文件不存在']
    except Exception:
        return ['读取日志失败']

def print_header():
    """打印标题"""
    print("=" * 80)
    print("🎛️  魔声AI服务监控面板".center(80))
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}".center(80))
    print("=" * 80)

def print_services_status():
    """打印服务状态"""
    print("\n🚀 服务状态:")
    print("-" * 80)
    
    pm2_services = get_pm2_status()
    pm2_dict = {service['name']: service for service in pm2_services}
    
    for service_id, config in SERVICES.items():
        pm2_info = pm2_dict.get(service_id, {})
        health_info = check_service_health(config)
        
        # 服务基本信息
        name = config['name']
        port = config['port']
        pm2_status = pm2_info.get('pm2_env', {}).get('status', '未知')
        pid = pm2_info.get('pid', 'N/A')
        cpu = pm2_info.get('monit', {}).get('cpu', 0)
        memory_mb = pm2_info.get('monit', {}).get('memory', 0) // (1024*1024)
        restarts = pm2_info.get('pm2_env', {}).get('restart_time', 0)
        uptime = format_uptime(pm2_info.get('pm2_env', {}).get('pm_uptime'))
        
        # 状态图标
        if pm2_status == 'online' and '🟢' in health_info['status']:
            status_icon = '🟢'
        elif pm2_status == 'online':
            status_icon = '🟡'
        else:
            status_icon = '🔴'
        
        print(f"{status_icon} {name:<20} | 端口:{port:<5} | PM2:{pm2_status:<8} | PID:{pid:<8}")
        print(f"   健康状态: {health_info['status']:<10} | 响应时间: {health_info['response_time']:<8}")
        print(f"   CPU: {cpu}% | 内存: {memory_mb}MB | 重启: {restarts}次 | 运行: {uptime}")
        print()

def print_system_status():
    """打印系统状态"""
    print("💻 系统资源:")
    print("-" * 80)
    
    system_info = get_system_info()
    if system_info:
        cpu = system_info['cpu_percent']
        mem_percent = system_info['memory_percent']
        mem_used = system_info['memory_used']
        mem_total = system_info['memory_total']
        disk_percent = system_info['disk_percent']
        disk_free = system_info['disk_free']
        
        # CPU状态
        cpu_bar = '█' * int(cpu/5) + '░' * (20 - int(cpu/5))
        cpu_color = '🔴' if cpu > 80 else '🟡' if cpu > 60 else '🟢'
        print(f"CPU使用率:  {cpu_color} [{cpu_bar}] {cpu:.1f}%")
        
        # 内存状态
        mem_bar = '█' * int(mem_percent/5) + '░' * (20 - int(mem_percent/5))
        mem_color = '🔴' if mem_percent > 80 else '🟡' if mem_percent > 60 else '🟢'
        print(f"内存使用率: {mem_color} [{mem_bar}] {mem_percent:.1f}% ({mem_used}GB/{mem_total}GB)")
        
        # 磁盘状态
        disk_bar = '█' * int(disk_percent/5) + '░' * (20 - int(disk_percent/5))
        disk_color = '🔴' if disk_percent > 80 else '🟡' if disk_percent > 60 else '🟢'
        print(f"磁盘使用率: {disk_color} [{disk_bar}] {disk_percent:.1f}% (剩余 {disk_free}GB)")

def print_recent_logs(service_id='tts-service', lines=5):
    """打印最近的日志"""
    print(f"\n📝 {SERVICES[service_id]['name']} 最近日志:")
    print("-" * 80)
    
    logs = get_log_tail(SERVICES[service_id]['log_file'], lines)
    for log in logs[-lines:]:
        if log.strip():
            # 简单的日志着色
            if 'ERROR' in log or 'error' in log:
                print(f"🔴 {log}")
            elif 'WARN' in log or 'warning' in log:
                print(f"🟡 {log}")
            elif 'INFO' in log or 'info' in log:
                print(f"🔵 {log}")
            else:
                print(f"   {log}")

def monitor_loop():
    """监控主循环"""
    try:
        while True:
            clear_screen()
            print_header()
            print_services_status()
            print_system_status()
            print_recent_logs()
            
            print("\n" + "=" * 80)
            print("💡 提示: 按 Ctrl+C 退出监控 | 每5秒自动刷新")
            print("🌐 Web监控面板: http://localhost:9999")
            print("=" * 80)
            
            time.sleep(5)
            
    except KeyboardInterrupt:
        print("\n\n👋 监控已停止")
        sys.exit(0)

def show_menu():
    """显示菜单"""
    print("\n🎛️ 魔声AI服务监控")
    print("=" * 40)
    print("1. 实时监控 (自动刷新)")
    print("2. 查看服务状态")
    print("3. 查看系统资源")
    print("4. 查看TTS服务日志")
    print("5. 查看后端服务日志")
    print("6. 查看前端服务日志")
    print("7. 启动Web监控面板")
    print("0. 退出")
    print("=" * 40)

def show_logs(service_id, lines=20):
    """显示指定服务的日志"""
    clear_screen()
    print(f"📝 {SERVICES[service_id]['name']} 日志 (最近{lines}行)")
    print("=" * 80)
    
    logs = get_log_tail(SERVICES[service_id]['log_file'], lines)
    for log in logs:
        if log.strip():
            if 'ERROR' in log or 'error' in log:
                print(f"🔴 {log}")
            elif 'WARN' in log or 'warning' in log:
                print(f"🟡 {log}")
            elif 'INFO' in log or 'info' in log:
                print(f"🔵 {log}")
            else:
                print(f"   {log}")
    
    input("\n按回车键返回菜单...")

def start_web_monitor():
    """启动Web监控面板"""
    print("🚀 启动Web监控面板...")
    try:
        # 检查是否已经在运行
        try:
            response = requests.get('http://localhost:9999', timeout=2)
            print("✅ Web监控面板已在运行: http://localhost:9999")
            return
        except:
            pass
        
        # 启动监控面板
        monitor_dir = os.path.join(os.path.dirname(__file__), 'monitor')
        if os.path.exists(monitor_dir):
            os.chdir(monitor_dir)
            subprocess.Popen(['bash', 'start_monitor.sh'], 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL)
            print("✅ Web监控面板启动中...")
            print("🌐 访问地址: http://localhost:9999")
            time.sleep(2)
        else:
            print("❌ 监控面板目录不存在")
    except Exception as e:
        print(f"❌ 启动失败: {e}")

def main():
    """主函数"""
    if len(sys.argv) > 1 and sys.argv[1] == '--monitor':
        # 直接进入监控模式
        monitor_loop()
        return
    
    while True:
        clear_screen()
        show_menu()
        
        try:
            choice = input("\n请选择操作 (0-7): ").strip()
            
            if choice == '0':
                print("👋 再见!")
                break
            elif choice == '1':
                monitor_loop()
            elif choice == '2':
                clear_screen()
                print_header()
                print_services_status()
                input("\n按回车键返回菜单...")
            elif choice == '3':
                clear_screen()
                print_header()
                print_system_status()
                input("\n按回车键返回菜单...")
            elif choice == '4':
                show_logs('tts-service')
            elif choice == '5':
                show_logs('backend-service')
            elif choice == '6':
                show_logs('frontend-service')
            elif choice == '7':
                start_web_monitor()
                input("\n按回车键返回菜单...")
            else:
                print("❌ 无效选择，请重试")
                time.sleep(1)
                
        except KeyboardInterrupt:
            print("\n\n👋 再见!")
            break
        except Exception as e:
            print(f"❌ 发生错误: {e}")
            time.sleep(2)

if __name__ == '__main__':
    main() 