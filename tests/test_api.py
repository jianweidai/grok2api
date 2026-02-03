#!/usr/bin/env python3
import httpx
import json

url = "http://127.0.0.1:8999/v1/chat/completions"
headers = {
    "Authorization": "Bearer daijianwei",
    "Content-Type": "application/json"
}

# 测试非流式
payload = {
    "model": "grok-4",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": False
}

print("=== 测试非流式响应 ===")
response = httpx.post(url, json=payload, headers=headers, timeout=30)
print(f"Status: {response.status_code}")
print(f"Content-Type: {response.headers.get('content-type')}")
print(f"\nResponse:")
if response.status_code == 200:
    print(json.dumps(response.json(), indent=2, ensure_ascii=False))
else:
    print(response.text)

print("\n" + "="*50 + "\n")

# 测试流式
payload["stream"] = True
print("=== 测试流式响应 ===")
with httpx.stream("POST", url, json=payload, headers=headers, timeout=30) as response:
    print(f"Status: {response.status_code}")
    print(f"Content-Type: {response.headers.get('content-type')}")
    print(f"\nResponse (前500字符):")
    content = ""
    for line in response.iter_lines():
        if line:
            content += line + "\n"
            if len(content) > 500:
                break
    print(content)
