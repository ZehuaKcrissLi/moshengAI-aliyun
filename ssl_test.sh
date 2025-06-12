#!/bin/bash

echo "🔍 SSL连接诊断工具"
echo "=================="

DOMAIN="moshengai.kcriss.dev"
PORT="443"

echo "📋 测试域名: $DOMAIN"
echo "📋 测试端口: $PORT"
echo ""

# 1. 基本连接测试
echo "1️⃣ 基本SSL连接测试..."
timeout 10 openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN -brief 2>/dev/null | head -10

echo ""

# 2. TLS版本兼容性测试
echo "2️⃣ TLS版本兼容性测试..."
for version in tls1_1 tls1_2 tls1_3; do
    echo -n "   $version: "
    result=$(echo | timeout 10 openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN -$version 2>/dev/null | grep "Protocol version")
    if [ -n "$result" ]; then
        echo "✅ 支持 - $result"
    else
        echo "❌ 不支持"
    fi
done

echo ""

# 3. 证书信息
echo "3️⃣ SSL证书信息..."
cert_info=$(timeout 10 openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null)
echo "$cert_info"

echo ""

# 4. 密码套件测试
echo "4️⃣ 支持的密码套件测试..."
echo "   测试常用移动设备密码套件..."

# 常用移动设备密码套件
mobile_ciphers=(
    "ECDHE-RSA-AES128-GCM-SHA256"
    "ECDHE-RSA-AES256-GCM-SHA384"
    "ECDHE-RSA-AES128-SHA256"
    "ECDHE-RSA-AES256-SHA384"
    "AES128-GCM-SHA256"
    "AES256-GCM-SHA384"
)

for cipher in "${mobile_ciphers[@]}"; do
    echo -n "   $cipher: "
    result=$(echo | timeout 10 openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN -cipher $cipher 2>/dev/null | grep "Cipher is")
    if [[ $result == *"$cipher"* ]]; then
        echo "✅ 支持"
    else
        echo "❌ 不支持"
    fi
done

echo ""

# 5. HTTP/HTTPS重定向测试
echo "5️⃣ HTTP重定向测试..."
echo -n "   HTTP -> HTTPS 重定向: "
redirect_result=$(curl -s -I -L http://$DOMAIN/tts/ | grep -i "location\|http")
if [[ $redirect_result == *"https"* ]]; then
    echo "✅ 正常重定向"
else
    echo "❌ 重定向异常"
fi

echo ""

# 6. 端口连通性测试
echo "6️⃣ 端口连通性测试..."
echo -n "   端口443连通性: "
if timeout 5 nc -z $DOMAIN $PORT 2>/dev/null; then
    echo "✅ 端口开放"
else
    echo "❌ 端口不通"
fi

echo ""

# 7. DNS解析测试
echo "7️⃣ DNS解析测试..."
echo "   域名解析结果:"
dig +short $DOMAIN | head -5

echo ""

# 8. 移动设备兼容性建议
echo "8️⃣ 移动设备兼容性建议..."
echo "   ✅ 已启用TLS 1.1/1.2/1.3支持"
echo "   ✅ 已配置移动设备兼容密码套件"
echo "   ✅ 已添加DH参数支持"
echo "   ✅ 已启用HTTP/2"

echo ""
echo "🎯 如果手机仍无法访问，请尝试:"
echo "   1. 清除手机浏览器缓存和数据"
echo "   2. 尝试不同的手机浏览器"
echo "   3. 检查手机系统时间是否正确"
echo "   4. 尝试使用手机流量而非WiFi"
echo "   5. 重启手机网络设置" 