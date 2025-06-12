# 魔声AI TTS服务部署总结

## 🎉 部署完成状态

✅ **8080 TTS服务已成功部署到 `moshengai.kcriss.dev/tts`**

## 📋 服务信息

- **访问地址**: https://moshengai.kcriss.dev/tts/
- **API基础路径**: https://moshengai.kcriss.dev/tts/
- **前端界面**: 简洁的HTML界面，支持语音合成和试听
- **后端服务**: 基于FastAPI的TTS服务，运行在8080端口

## 🔧 API接口一致性

8080服务的API调用方式已与5173应用保持完全一致：

### 1. 获取音色类型
```bash
GET /tts/voice_types
```
**响应示例**:
```json
{
  "success": true,
  "voice_types": {
    "男声": ["男声1大气磁性", "男声2浑厚大气", ...],
    "女声": ["女声1大气磁性", "女声2知性温柔", ...]
  }
}
```

### 2. 异步语音合成（试听）
```bash
POST /tts/synthesize
Content-Type: multipart/form-data

text=测试文本&gender=女声&voice_label=女声1大气磁性
```
**响应**: 202 状态码 + 任务信息
```json
{
  "task_id": "uuid",
  "status": "pending",
  "status_url": "/synthesis_tasks/{task_id}/status"
}
```

### 3. 任务状态查询
```bash
GET /tts/synthesis_tasks/{task_id}/status
```
**响应示例**:
```json
{
  "status": "completed",
  "result": {
    "success": true,
    "wav_url": "/output/xxx.wav",
    "mp3_url": "/output/xxx.mp3",
    "text": "测试文本"
  }
}
```

### 4. 确认脚本（同步合成）
```bash
POST /tts/confirm_script
Content-Type: application/json

{
  "text": "测试文本",
  "gender": "女声", 
  "voice_label": "女声1大气磁性"
}
```
**响应示例**:
```json
{
  "success": true,
  "audio_id": "uuid",
  "wav_url": "/client_output/xxx.wav",
  "mp3_url": "/client_output/xxx.mp3",
  "timestamp": "2025-05-27 02:32:21"
}
```

## 🌐 前端界面特性

- **响应式设计**: 适配移动端和桌面端
- **实时状态反馈**: 显示合成进度和状态信息
- **异步轮询**: 与5173应用相同的轮询机制
- **音频播放**: 内置音频播放器，支持试听和下载
- **错误处理**: 完善的错误提示和状态管理

## 🔄 与5173应用的一致性

### API调用方式
- ✅ 相同的接口路径和参数
- ✅ 相同的请求/响应格式
- ✅ 相同的异步轮询机制
- ✅ 相同的错误处理逻辑

### 前端交互
- ✅ 试听按钮使用异步轮询
- ✅ 确认按钮使用同步接口
- ✅ 相同的状态管理和用户反馈
- ✅ 相同的音频URL处理逻辑

## 🚀 部署架构

```
用户请求 → Nginx → TTS服务(8080端口)
                ↓
            静态文件服务
            音频文件服务
            API接口服务
```

### Nginx配置
- **路径代理**: `/tts/` → `localhost:8080/`
- **静态文件**: 音频文件、前端资源
- **HTTPS支持**: 自动SSL证书
- **CORS配置**: 支持跨域请求

## 📊 测试结果

所有API接口测试通过：
- ✅ voice_types 接口: 正常 (181个音色)
- ✅ 异步合成接口: 正常 (202状态码)
- ✅ 任务状态查询: 正常 (轮询机制)
- ✅ 确认脚本接口: 正常 (同步合成)

## 🎯 使用方法

### 直接访问
1. 打开 https://moshengai.kcriss.dev/tts/
2. 输入要合成的文本
3. 选择性别和音色
4. 点击"试听"进行预览或"确认使用"生成最终音频

### API集成
```javascript
// 获取音色类型
const voiceTypes = await fetch('/tts/voice_types').then(r => r.json());

// 异步合成（试听）
const formData = new FormData();
formData.append('text', '测试文本');
formData.append('gender', '女声');
formData.append('voice_label', '女声1大气磁性');

const response = await fetch('/tts/synthesize', {
    method: 'POST',
    body: formData
});

// 轮询状态
const taskInfo = await response.json();
// ... 轮询逻辑

// 确认脚本（同步）
const result = await fetch('/tts/confirm_script', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        text: '测试文本',
        gender: '女声',
        voice_label: '女声1大气磁性'
    })
});
```

## 🔧 维护说明

### 服务管理
```bash
# 查看服务状态
pm2 status

# 重启TTS服务
pm2 restart tts-service

# 查看日志
pm2 logs tts-service
```

### 文件路径
- **前端文件**: `/mnt/moshengAI/static/index.html`
- **音频输出**: `/mnt/moshengAI/output/` (试听)
- **最终音频**: `/mnt/moshengAI/client_output/` (确认)
- **配置文件**: `/etc/nginx/conf.d/moshengai.conf`

---

**🎊 部署成功！8080服务现在可以通过 `moshengai.kcriss.dev/tts` 访问，API调用方式与5173应用完全一致。** 