# 🎛️ 魔声AI服务监控工具套件

## 🎯 概述

为了让你能够在IDE中优雅地监控魔声AI服务的运行状态和日志，我创建了一套完整的监控解决方案。

## 🚀 监控工具一览

### 1. **一键启动脚本** ⭐ 推荐
```bash
./start_monitoring.sh
```
- 🎯 **功能**: 统一入口，一键启动所有监控工具
- 🔧 **特点**: 自动检查依赖，智能启动服务
- 📋 **菜单**: 交互式选择监控方式

### 2. **Web监控面板** 🌐 最佳体验
```bash
./start_monitoring.sh web
# 或直接访问: http://localhost:9999
```
- 📊 **实时图表**: CPU/内存使用率趋势
- 🚀 **服务状态**: PM2进程监控，健康检查
- 📝 **日志查看**: 实时日志流，错误高亮
- 💻 **系统监控**: 资源使用情况
- 🎨 **现代界面**: 深色主题，响应式设计

### 3. **Python命令行监控** 🐍 IDE友好
```bash
python3 monitor_simple.py
# 或实时监控模式
python3 monitor_simple.py --monitor
```
- 🎛️ **交互菜单**: 7种监控功能
- 🔄 **实时刷新**: 每5秒自动更新
- 🎨 **彩色输出**: 状态指示器，进度条
- 📊 **详细信息**: 服务状态，系统资源

### 4. **Bash快速日志查看** 🔧 轻量快速
```bash
./quick_logs.sh
# 或快速命令
./quick_logs.sh tts        # 查看TTS日志
./quick_logs.sh status     # 查看服务状态
./quick_logs.sh monitor-tts # 实时监控TTS
```
- ⚡ **快速启动**: 秒级响应
- 🎨 **彩色日志**: 错误红色，警告黄色，信息蓝色
- 🔄 **实时监控**: tail -f 实时日志流
- 📋 **快捷命令**: 支持参数直接执行

## 📖 快速开始

### 🎯 一键启动所有监控
```bash
# 启动所有监控工具
./start_monitoring.sh all

# 或交互式选择
./start_monitoring.sh
```

### 🌐 在IDE中使用Web监控面板
1. 启动监控面板：`./start_monitoring.sh web`
2. 在IDE中打开浏览器
3. 访问：http://localhost:9999
4. 享受现代化监控体验！

### 🐍 在IDE终端中使用Python监控
```bash
# 在IDE终端中运行
python3 monitor_simple.py

# 选择功能：
# 1. 实时监控 (自动刷新)
# 2. 查看服务状态
# 3. 查看系统资源
# 4-6. 查看各服务日志
# 7. 启动Web监控面板
```

### 🔧 快速查看日志
```bash
# 快速查看TTS服务日志
./quick_logs.sh tts

# 实时监控后端服务
./quick_logs.sh monitor-backend

# 查看所有服务状态
./quick_logs.sh status
```

## 📊 监控内容

### 🚀 服务监控
- **TTS语音合成服务** (8080端口)
- **后端API服务** (8000端口)
- **前端Web服务** (5173端口)
- **监控面板服务** (9999端口)

### 📈 监控指标
- ✅ PM2进程状态 (online/stopped)
- 🏥 服务健康检查 (HTTP响应)
- ⚡ 响应时间监控
- 🔄 重启次数统计
- ⏱️ 运行时间统计
- 💾 CPU和内存使用率
- 📊 实时性能图表

### 📝 日志监控
- 🔴 错误日志高亮显示
- 🟡 警告信息标记
- 🔵 普通信息分类
- 🔄 实时日志流
- 📜 历史日志查看

### 💻 系统资源
- 📊 CPU使用率 (实时图表)
- 🧠 内存使用情况
- 💾 磁盘空间监控
- 🌐 网络连接状态

## 🎨 界面预览

### Web监控面板
```
🎛️ 魔声AI服务监控面板
┌─────────────────────────────────────────┐
│ 🚀 服务状态                              │
│ ┌─────────────────────────────────────┐ │
│ │ 🟢 TTS语音合成服务    :8080         │ │
│ │    健康状态: 🟢 健康   响应: 0.05s  │ │
│ │    CPU: 0% | 内存: 3MB | 运行: 14m  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│ 💻 系统资源                              │
│ CPU:  🟢 [████░░░░░░░░░░░░░░░░] 20.1%   │
│ 内存: 🟢 [██░░░░░░░░░░░░░░░░░░] 10.5%   │
└─────────────────────────────────────────┘
```

### Python命令行监控
```
================================================================================
🎛️  魔声AI服务监控面板
📅 2025-05-27 23:32:00
================================================================================

🚀 服务状态:
--------------------------------------------------------------------------------
🟢 TTS语音合成服务        | 端口:8080  | PM2:online   | PID:549852  
   健康状态: 🟢 健康      | 响应时间: 0.050s   
   CPU: 0% | 内存: 3MB | 重启: 3次 | 运行: 14h 25m

💻 系统资源:
--------------------------------------------------------------------------------
CPU使用率:  🟢 [████░░░░░░░░░░░░░░░░] 20.1%
内存使用率: 🟢 [██░░░░░░░░░░░░░░░░░░] 10.5% (10GB/181GB)
磁盘使用率: 🟡 [█████████████████░░░] 89.0% (剩余 7GB)
```

## 🔧 高级用法

### 🎯 IDE集成建议

#### VS Code / Cursor
1. **多终端布局**:
   - 终端1: `python3 monitor_simple.py --monitor`
   - 终端2: `./quick_logs.sh monitor-tts`
   - 浏览器: http://localhost:9999

2. **任务配置** (tasks.json):
```json
{
    "label": "启动监控面板",
    "type": "shell",
    "command": "./start_monitoring.sh web",
    "group": "build"
}
```

#### JetBrains IDEs
1. **运行配置**: 添加Shell脚本运行配置
2. **工具窗口**: 在终端工具窗口中运行监控
3. **浏览器**: 使用内置浏览器访问监控面板

### 🚀 自动化启动

#### 开机自启动监控面板
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
alias monitor='cd /mnt && ./start_monitoring.sh web'

# 或创建systemd服务
sudo tee /etc/systemd/system/mosheng-monitor.service << EOF
[Unit]
Description=MoshengAI Monitor Panel
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/mnt/monitor
ExecStart=/mnt/monitor/venv/bin/python /mnt/monitor/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable mosheng-monitor
sudo systemctl start mosheng-monitor
```

### 📱 移动端访问
Web监控面板支持响应式设计，可以在手机/平板上访问：
```
http://你的服务器IP:9999
```

## 🛠️ 故障排除

### 常见问题

#### 1. Web监控面板无法访问
```bash
# 检查服务状态
./start_monitoring.sh status

# 重启监控面板
cd monitor
source venv/bin/activate
python3 app.py
```

#### 2. Python依赖缺失
```bash
# 安装依赖
pip3 install psutil requests flask flask-socketio

# 或使用虚拟环境
cd monitor
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 3. 日志文件不存在
```bash
# 创建日志目录
mkdir -p /mnt/logs

# 检查PM2配置
pm2 show tts-service
```

#### 4. 端口冲突
```bash
# 检查端口占用
netstat -tlnp | grep -E ":8080|:8000|:5173|:9999"

# 修改监控面板端口 (monitor/app.py 最后一行)
socketio.run(app, host='0.0.0.0', port=9998, debug=False)
```

## 📚 命令参考

### 一键启动脚本
```bash
./start_monitoring.sh          # 交互式菜单
./start_monitoring.sh web      # 启动Web监控面板
./start_monitoring.sh python   # 启动Python监控
./start_monitoring.sh bash     # 启动Bash日志查看
./start_monitoring.sh status   # 查看服务状态
./start_monitoring.sh all      # 启动所有监控工具
```

### Python监控
```bash
python3 monitor_simple.py              # 交互式菜单
python3 monitor_simple.py --monitor    # 实时监控模式
```

### Bash日志查看
```bash
./quick_logs.sh                    # 交互式菜单
./quick_logs.sh tts                # TTS服务日志
./quick_logs.sh backend            # 后端服务日志
./quick_logs.sh frontend           # 前端服务日志
./quick_logs.sh status             # 服务状态
./quick_logs.sh system             # 系统资源
./quick_logs.sh monitor-tts        # 实时监控TTS
./quick_logs.sh monitor-backend    # 实时监控后端
./quick_logs.sh monitor-frontend   # 实时监控前端
```

### PM2管理
```bash
pm2 list                           # 查看所有服务
pm2 restart tts-service           # 重启TTS服务
pm2 logs tts-service              # 查看TTS日志
pm2 monit                         # PM2内置监控
```

## 🎉 总结

现在你拥有了一套完整的服务监控解决方案：

✅ **Web监控面板**: 现代化界面，实时图表，完整功能
✅ **Python命令行**: IDE友好，交互式菜单，彩色输出  
✅ **Bash快速工具**: 轻量级，快速响应，实时日志
✅ **一键启动**: 统一入口，自动化部署，智能检测

**推荐使用方式**:
1. 🌐 在IDE浏览器中打开Web监控面板作为主要监控界面
2. 🐍 在IDE终端中运行Python监控进行详细检查
3. 🔧 使用Bash工具进行快速日志查看和问题排查

享受优雅的服务监控体验！🎛️✨ 