<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Encoding UTF-8</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
        .success { color: green; }
        .error { color: red; }
        input[type="text"] { width: 300px; padding: 5px; }
        button { padding: 5px 10px; margin: 5px; }
    </style>
</head>
<body>
    <h1>Test Encoding UTF-8</h1>
    
    <div class="test-section">
        <h2>1. Test hiển thị tiếng Việt</h2>
        <p>Tiếng Việt có dấu: á, à, ả, ã, ạ, ă, ắ, ằ, ẳ, ẵ, ặ, â, ấ, ầ, ẩ, ẫ, ậ</p>
        <p>Đặc biệt: đ, Đ</p>
        <p>Ký tự đặc biệt: ư, ơ, ô, ê, ế, ề, ể, ễ, ệ</p>
        <p>Test sản phẩm: Máy phát điện Perkins công suất 50KVA</p>
        <p>Test hợp đồng: Hợp đồng 123 - HĐ #1</p>
        <p>Test mô tả: Máy bị hỏng mô tơ</p>
    </div>
    
    <div class="test-section">
        <h2>2. Test gửi dữ liệu tiếng Việt</h2>
        <form id="testForm">
            <input type="text" id="testInput" placeholder="Nhập text tiếng Việt có dấu..." />
            <button type="button" onclick="testSubmit()">Test Submit</button>
        </form>
        <div id="result"></div>
    </div>
    
    <div class="test-section">
        <h2>3. Test với dữ liệu thực tế</h2>
        <button onclick="testRealData()">Test với dữ liệu sản phẩm</button>
        <div id="realDataResult"></div>
    </div>

    <script>
        function testSubmit() {
            const input = document.getElementById('testInput').value;
            const resultDiv = document.getElementById('result');
            
            if (!input.trim()) {
                resultDiv.innerHTML = '<p class="error">Vui lòng nhập text để test</p>';
                return;
            }
            
            fetch('/encoding-test', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: 'text=' + encodeURIComponent(input)
            })
            .then(response => response.json())
            .then(data => {
                resultDiv.innerHTML = '<p class="success">Dữ liệu nhận được: ' + data.received + '</p>';
            })
            .catch(error => {
                resultDiv.innerHTML = '<p class="error">Lỗi: ' + error.message + '</p>';
            });
        }
        
        function testRealData() {
            const testData = [
                "Máy phát điện Perkins công suất 50KVA, động cơ Perkins 4 xi-lanh, phù hợp cho công nghiệp và thương mại",
                "Hợp đồng 123 - HĐ #1",
                "Máy bị hỏng mô tơ"
            ];
            
            const resultDiv = document.getElementById('realDataResult');
            resultDiv.innerHTML = '<p>Đang test...</p>';
            
            let testIndex = 0;
            const runTest = () => {
                if (testIndex >= testData.length) {
                    resultDiv.innerHTML += '<p class="success">Hoàn thành test!</p>';
                    return;
                }
                
                const data = testData[testIndex];
                fetch('/encoding-test', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: 'text=' + encodeURIComponent(data)
                })
                .then(response => response.json())
                .then(result => {
                    resultDiv.innerHTML += '<p>Test ' + (testIndex + 1) + ': ' + result.received + '</p>';
                    testIndex++;
                    setTimeout(runTest, 500);
                })
                .catch(error => {
                    resultDiv.innerHTML += '<p class="error">Lỗi test ' + (testIndex + 1) + ': ' + error.message + '</p>';
                    testIndex++;
                    setTimeout(runTest, 500);
                });
            };
            
            runTest();
        }
    </script>
</body>
</html>
