#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import subprocess
import psutil
import time
from datetime import datetime
from flask import Flask, render_template, jsonify, request
from flask_socketio import SocketIO, emit
import threading
import requests

app = Flask(__name__)
app.config['SECRET_KEY'] = 'monitor_secret_key'
socketio = SocketIO(app, cors_allowed_origins="*")

# 服务配置
SERVICES = {
    'tts-service': {
        'name': 'TTS语音合成服务',
        'port': 8080,
        'health_url': 'http://localhost:8080/health',
        'log_file': '/mnt/logs/tts-service-out.log',
        'error_log': '/mnt/logs/tts-service-error.log'
    },
    'backend-service': {
        'name': '后端API服务',
        'port': 8000,
        'health_url': 'http://localhost:8000/health',
        'log_file': '/mnt/logs/backend-service-out.log',
        'error_log': '/mnt/logs/backend-service-error.log'
    },
    'frontend-service': {
        'name': '前端Web服务',
        'port': 5173,
        'health_url': 'http://localhost:5173',
        'log_file': '/mnt/logs/frontend-service-out.log',
        'error_log': '/mnt/logs/frontend-service-error.log'
    }
}

def get_pm2_status():
    """获取PM2服务状态"""
    try:
        result = subprocess.run(['pm2', 'jlist'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if result.returncode == 0:
            return json.loads(result.stdout)
        return []
    except Exception as e:
        print(f"获取PM2状态失败: {e}")
        return []

def get_system_info():
    """获取系统信息"""
    try:
        # CPU使用率
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # 内存使用情况
        memory = psutil.virtual_memory()
        
        # 磁盘使用情况
        disk_usage = {}
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint)
                disk_usage[partition.mountpoint] = {
                    'total': usage.total,
                    'used': usage.used,
                    'free': usage.free,
                    'percent': (usage.used / usage.total) * 100
                }
            except:
                continue
        
        # 网络统计
        network = psutil.net_io_counters()
        
        return {
            'cpu_percent': cpu_percent,
            'memory': {
                'total': memory.total,
                'available': memory.available,
                'used': memory.used,
                'percent': memory.percent
            },
            'disk_usage': disk_usage,
            'network': {
                'bytes_sent': network.bytes_sent,
                'bytes_recv': network.bytes_recv,
                'packets_sent': network.packets_sent,
                'packets_recv': network.packets_recv
            },
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        print(f"获取系统信息失败: {e}")
        return {}

def check_service_health(service_config):
    """检查服务健康状态"""
    try:
        response = requests.get(service_config['health_url'], timeout=5)
        return {
            'status': 'healthy' if response.status_code == 200 else 'unhealthy',
            'status_code': response.status_code,
            'response_time': response.elapsed.total_seconds()
        }
    except requests.exceptions.ConnectionError:
        return {'status': 'down', 'error': 'Connection refused'}
    except requests.exceptions.Timeout:
        return {'status': 'timeout', 'error': 'Request timeout'}
    except Exception as e:
        return {'status': 'error', 'error': str(e)}

def get_log_tail(log_file, lines=50):
    """获取日志文件的最后几行"""
    try:
        if os.path.exists(log_file):
            result = subprocess.run(['tail', '-n', str(lines), log_file], 
                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            return result.stdout.split('\n')
        return ['日志文件不存在']
    except Exception as e:
        return [f'读取日志失败: {str(e)}']

@app.route('/')
def index():
    """主监控页面"""
    return render_template('monitor.html')

@app.route('/api/services')
def api_services():
    """获取所有服务状态"""
    pm2_services = get_pm2_status()
    pm2_dict = {service['name']: service for service in pm2_services}
    
    services_status = {}
    for service_id, config in SERVICES.items():
        pm2_info = pm2_dict.get(service_id, {})
        health_info = check_service_health(config)
        
        services_status[service_id] = {
            'name': config['name'],
            'port': config['port'],
            'pm2_status': pm2_info.get('pm2_env', {}).get('status', 'unknown'),
            'pid': pm2_info.get('pid'),
            'cpu': pm2_info.get('monit', {}).get('cpu', 0),
            'memory': pm2_info.get('monit', {}).get('memory', 0),
            'restarts': pm2_info.get('pm2_env', {}).get('restart_time', 0),
            'uptime': pm2_info.get('pm2_env', {}).get('pm_uptime'),
            'health': health_info
        }
    
    return jsonify(services_status)

@app.route('/api/system')
def api_system():
    """获取系统信息"""
    return jsonify(get_system_info())

@app.route('/api/logs/<service_id>')
def api_logs(service_id):
    """获取指定服务的日志"""
    if service_id not in SERVICES:
        return jsonify({'error': 'Service not found'}), 404
    
    lines = request.args.get('lines', 100, type=int)
    log_type = request.args.get('type', 'output')  # output or error
    
    config = SERVICES[service_id]
    log_file = config['error_log'] if log_type == 'error' else config['log_file']
    
    logs = get_log_tail(log_file, lines)
    
    return jsonify({
        'service': service_id,
        'log_type': log_type,
        'logs': logs,
        'timestamp': datetime.now().isoformat()
    })

@socketio.on('connect')
def handle_connect():
    """WebSocket连接处理"""
    print('客户端已连接')
    emit('connected', {'data': '连接成功'})

@socketio.on('subscribe_updates')
def handle_subscribe():
    """订阅实时更新"""
    def send_updates():
        while True:
            try:
                # 发送服务状态更新
                pm2_services = get_pm2_status()
                pm2_dict = {service['name']: service for service in pm2_services}
                
                services_status = {}
                for service_id, config in SERVICES.items():
                    pm2_info = pm2_dict.get(service_id, {})
                    health_info = check_service_health(config)
                    
                    services_status[service_id] = {
                        'name': config['name'],
                        'port': config['port'],
                        'pm2_status': pm2_info.get('pm2_env', {}).get('status', 'unknown'),
                        'pid': pm2_info.get('pid'),
                        'cpu': pm2_info.get('monit', {}).get('cpu', 0),
                        'memory': pm2_info.get('monit', {}).get('memory', 0),
                        'restarts': pm2_info.get('pm2_env', {}).get('restart_time', 0),
                        'uptime': pm2_info.get('pm2_env', {}).get('pm_uptime'),
                        'health': health_info
                    }
                
                socketio.emit('services_update', services_status)
                
                # 发送系统信息更新
                system_info = get_system_info()
                socketio.emit('system_update', system_info)
                
                time.sleep(5)  # 每5秒更新一次
            except Exception as e:
                print(f"发送更新失败: {e}")
                time.sleep(5)
    
    # 在后台线程中发送更新
    update_thread = threading.Thread(target=send_updates)
    update_thread.daemon = True
    update_thread.start()

if __name__ == '__main__':
    # 确保日志目录存在
    os.makedirs('/mnt/logs', exist_ok=True)
    
    print("启动监控服务...")
    print("访问地址: http://localhost:9999")
    socketio.run(app, host='0.0.0.0', port=9999, debug=False) 