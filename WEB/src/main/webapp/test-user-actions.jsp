<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test User Actions</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
        .warning { color: orange; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .btn { padding: 8px 15px; margin: 5px; cursor: pointer; border: none; border-radius: 3px; }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-success { background-color: #28a745; color: white; }
        .btn-danger { background-color: #dc3545; color: white; }
        .btn-warning { background-color: #ffc107; color: black; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .action-demo { background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>🧪 Test User Actions - Delete Functions</h1>
    
    <div class="section">
        <h2>📋 Current Users</h2>
        <button class="btn btn-primary" onclick="loadUsers()">Load Users</button>
        <div id="usersList"></div>
    </div>
    
    <div class="section">
        <h2>🗑️ Delete Actions Test</h2>
        <div class="action-demo">
            <h4>Available Delete Actions:</h4>
            <ul>
                <li><strong>Soft Delete (Tạm khóa):</strong> Sets is_active = false, data preserved</li>
                <li><strong>Hard Delete (Xóa vĩnh viễn):</strong> Permanently removes from database</li>
                <li><strong>Deactivate:</strong> Same as soft delete but different UI flow</li>
                <li><strong>Activate:</strong> Reactivates a deactivated user</li>
            </ul>
        </div>
        
        <button class="btn btn-warning" onclick="testSoftDelete()">Test Soft Delete</button>
        <button class="btn btn-danger" onclick="testHardDelete()">Test Hard Delete</button>
        <button class="btn btn-success" onclick="testActivate()">Test Activate</button>
        <button class="btn btn-primary" onclick="testDeactivate()">Test Deactivate</button>
    </div>
    
    <div class="section">
        <h2>📊 Test Results</h2>
        <div id="testResults"></div>
    </div>
    
    <div class="section">
        <h2>🎯 Action Buttons Demo</h2>
        <p>In the actual users.jsp page, you'll see these action buttons:</p>
        <div class="action-demo">
            <div style="display: inline-block; margin: 5px;">
                <button class="btn btn-info btn-xs">👁️</button>
                <button class="btn btn-warning btn-xs">✏️</button>
                <div class="btn-group" style="display: inline-block;">
                    <button class="btn btn-primary btn-xs dropdown-toggle" data-toggle="dropdown">⚙️ ▼</button>
                    <ul class="dropdown-menu">
                        <li><a href="#">🔑 Đổi mật khẩu</a></li>
                        <li><a href="#">🔒 Tạm khóa</a></li>
                        <li class="divider"></li>
                        <li><a href="#" style="color: #f39c12;">🗑️ Xóa (Tạm khóa)</a></li>
                        <li><a href="#" style="color: #e74c3c;">💀 Xóa vĩnh viễn</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    
    <script>
    function loadUsers() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'api/users?action=list', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        displayUsers(data.data);
                    } catch (e) {
                        showResult('Load Users', 'error', 'Parse error: ' + e.message);
                    }
                } else {
                    showResult('Load Users', 'error', 'HTTP ' + xhr.status);
                }
            }
        };
        xhr.send();
    }
    
    function displayUsers(users) {
        var html = '<table><tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Actions</th></tr>';
        
        users.forEach(function(user) {
            html += '<tr>';
            html += '<td>' + user.id + '</td>';
            html += '<td>' + user.username + '</td>';
            html += '<td>' + user.email + '</td>';
            html += '<td>' + user.role + '</td>';
            html += '<td>' + (user.isActive ? 'Active' : 'Inactive') + '</td>';
            html += '<td>';
            html += '<button class="btn btn-warning btn-xs" onclick="testSoftDeleteUser(' + user.id + ')">Soft Delete</button> ';
            html += '<button class="btn btn-danger btn-xs" onclick="testHardDeleteUser(' + user.id + ')">Hard Delete</button>';
            html += '</td>';
            html += '</tr>';
        });
        
        html += '</table>';
        document.getElementById('usersList').innerHTML = html;
    }
    
    function testSoftDelete() {
        showResult('Soft Delete Test', 'info', 'Testing soft delete functionality...');
        
        // Create a test user first
        createTestUser(function(userId) {
            if (userId) {
                performSoftDelete(userId);
            }
        });
    }
    
    function testHardDelete() {
        showResult('Hard Delete Test', 'warning', 'Testing hard delete functionality...');
        
        // Create a test user first
        createTestUser(function(userId) {
            if (userId) {
                performHardDelete(userId);
            }
        });
    }
    
    function testActivate() {
        showResult('Activate Test', 'info', 'Testing activate functionality...');
        // Implementation would go here
    }
    
    function testDeactivate() {
        showResult('Deactivate Test', 'info', 'Testing deactivate functionality...');
        // Implementation would go here
    }
    
    function createTestUser(callback) {
        var testData = 'action=add&username=testuser' + Date.now() + '&email=test' + Date.now() + '@example.com&password=123456&fullName=Test User&role=customer&permissions=[]&isActive=true';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'api/users', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        showResult('Create Test User', 'success', 'Test user created successfully');
                        // Extract user ID from response or reload users
                        loadUsers();
                        callback(1); // Placeholder ID
                    } else {
                        showResult('Create Test User', 'error', data.message);
                        callback(null);
                    }
                } else {
                    showResult('Create Test User', 'error', 'HTTP ' + xhr.status);
                    callback(null);
                }
            }
        };
        xhr.send(testData);
    }
    
    function performSoftDelete(userId) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'api/users', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    showResult('Soft Delete', data.success ? 'success' : 'error', data.message);
                } else {
                    showResult('Soft Delete', 'error', 'HTTP ' + xhr.status);
                }
            }
        };
        xhr.send('action=delete&id=' + userId);
    }
    
    function performHardDelete(userId) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'api/users', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    showResult('Hard Delete', data.success ? 'success' : 'error', data.message);
                } else {
                    showResult('Hard Delete', 'error', 'HTTP ' + xhr.status);
                }
            }
        };
        xhr.send('action=hardDelete&id=' + userId);
    }
    
    function testSoftDeleteUser(id) {
        if (confirm('Test soft delete for user ' + id + '?')) {
            performSoftDelete(id);
        }
    }
    
    function testHardDeleteUser(id) {
        if (confirm('⚠️ WARNING: Test hard delete for user ' + id + '?\n\nThis will permanently delete the user!')) {
            performHardDelete(id);
        }
    }
    
    function showResult(title, type, message) {
        var result = document.createElement('div');
        result.className = 'section';
        result.innerHTML = '<h4>' + title + '</h4><p class="' + type + '">' + message + '</p>';
        document.getElementById('testResults').appendChild(result);
    }
    
    // Load users on page load
    window.onload = function() {
        loadUsers();
    };
    </script>
</body>
</html>
