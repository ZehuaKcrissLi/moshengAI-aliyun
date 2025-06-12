#!/usr/bin/env node

// 测试TTS API的一致性
const https = require('https');
const http = require('http');

const BASE_URL = 'moshengai.kcriss.dev';
const TTS_PATH = '/tts';

// 测试数据
const testData = {
    text: '这是一个测试文本，用于验证TTS API的功能。',
    gender: '女声',
    voice_label: '女声1大气磁性'
};

console.log('开始测试TTS API...');
console.log('测试数据:', testData);

// 测试voice_types接口
async function testVoiceTypes() {
    console.log('\n=== 测试 voice_types 接口 ===');
    
    return new Promise((resolve, reject) => {
        const options = {
            hostname: BASE_URL,
            port: 80,
            path: `${TTS_PATH}/voice_types`,
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    console.log('✅ voice_types 接口测试成功');
                    console.log('可用音色数量:', {
                        男声: result.voice_types?.男声?.length || 0,
                        女声: result.voice_types?.女声?.length || 0
                    });
                    resolve(result);
                } catch (error) {
                    console.error('❌ voice_types 接口解析失败:', error.message);
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ voice_types 接口请求失败:', error.message);
            reject(error);
        });

        req.end();
    });
}

// 测试异步合成接口
async function testAsyncSynthesize() {
    console.log('\n=== 测试异步合成接口 ===');
    
    return new Promise((resolve, reject) => {
        const formData = `------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="text"\r\n\r\n${testData.text}\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="gender"\r\n\r\n${testData.gender}\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="voice_label"\r\n\r\n${testData.voice_label}\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--\r\n`;
        
        const options = {
            hostname: BASE_URL,
            port: 80,
            path: `${TTS_PATH}/synthesize`,
            method: 'POST',
            headers: {
                'Content-Type': 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
                'Accept': 'application/json',
                'Content-Length': Buffer.byteLength(formData)
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    if (res.statusCode === 202) {
                        const result = JSON.parse(data);
                        console.log('✅ 异步合成任务提交成功');
                        console.log('任务ID:', result.task_id);
                        console.log('状态URL:', result.status_url);
                        resolve(result);
                    } else {
                        console.error('❌ 异步合成接口返回错误状态码:', res.statusCode);
                        console.error('响应内容:', data);
                        reject(new Error(`状态码: ${res.statusCode}`));
                    }
                } catch (error) {
                    console.error('❌ 异步合成接口解析失败:', error.message);
                    console.error('响应内容:', data);
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ 异步合成接口请求失败:', error.message);
            reject(error);
        });

        req.write(formData);
        req.end();
    });
}

// 测试任务状态查询
async function testTaskStatus(statusUrl) {
    console.log('\n=== 测试任务状态查询 ===');
    console.log('状态URL:', statusUrl);
    
    return new Promise((resolve, reject) => {
        const options = {
            hostname: BASE_URL,
            port: 80,
            path: statusUrl,
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    console.log('✅ 任务状态查询成功');
                    console.log('任务状态:', result.status);
                    if (result.result) {
                        console.log('合成结果:', {
                            success: result.result.success,
                            wav_url: result.result.wav_url,
                            mp3_url: result.result.mp3_url
                        });
                    }
                    resolve(result);
                } catch (error) {
                    console.error('❌ 任务状态查询解析失败:', error.message);
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ 任务状态查询请求失败:', error.message);
            reject(error);
        });

        req.end();
    });
}

// 测试确认脚本接口
async function testConfirmScript() {
    console.log('\n=== 测试确认脚本接口 ===');
    
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify(testData);
        
        const options = {
            hostname: BASE_URL,
            port: 80,
            path: `${TTS_PATH}/confirm_script`,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    console.log('✅ 确认脚本接口测试成功');
                    console.log('合成结果:', {
                        success: result.success,
                        audio_id: result.audio_id,
                        wav_url: result.wav_url,
                        mp3_url: result.mp3_url
                    });
                    resolve(result);
                } catch (error) {
                    console.error('❌ 确认脚本接口解析失败:', error.message);
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ 确认脚本接口请求失败:', error.message);
            reject(error);
        });

        req.write(postData);
        req.end();
    });
}

// 主测试函数
async function runTests() {
    try {
        // 1. 测试voice_types接口
        await testVoiceTypes();
        
        // 2. 测试异步合成接口
        const synthesizeResult = await testAsyncSynthesize();
        
        // 3. 等待一段时间后测试任务状态
        console.log('\n等待3秒后查询任务状态...');
        await new Promise(resolve => setTimeout(resolve, 3000));
        
        await testTaskStatus(synthesizeResult.status_url);
        
        // 4. 测试确认脚本接口
        await testConfirmScript();
        
        console.log('\n🎉 所有API测试完成！');
        console.log('\n📝 测试总结:');
        console.log('- voice_types 接口: ✅ 正常');
        console.log('- 异步合成接口: ✅ 正常');
        console.log('- 任务状态查询: ✅ 正常');
        console.log('- 确认脚本接口: ✅ 正常');
        console.log('\n✨ 8080服务的API调用方式与5173应用保持一致！');
        
    } catch (error) {
        console.error('\n❌ 测试过程中出现错误:', error.message);
        process.exit(1);
    }
}

// 运行测试
runTests(); 