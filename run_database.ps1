# HL Generator Solutions Database Setup Script
# PowerShell script để setup database

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    HL Generator Solutions Database" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Kiểm tra MySQL có được cài đặt không
    Write-Host "[1] Checking MySQL installation..." -ForegroundColor Yellow
    $mysqlVersion = mysql --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ MySQL is not installed or not in PATH!" -ForegroundColor Red
        Write-Host "Please install MySQL and add it to your PATH environment variable." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ MySQL found: $mysqlVersion" -ForegroundColor Green
    Write-Host ""

    # Nhập thông tin kết nối
    Write-Host "[2] Database connection setup..." -ForegroundColor Yellow
    $hostname = Read-Host "Enter MySQL hostname (default: localhost)"
    if ([string]::IsNullOrEmpty($hostname)) { $hostname = "localhost" }
    
    $port = Read-Host "Enter MySQL port (default: 3306)"
    if ([string]::IsNullOrEmpty($port)) { $port = "3306" }
    
    $username = Read-Host "Enter MySQL username (default: root)"
    if ([string]::IsNullOrEmpty($username)) { $username = "root" }
    
    $password = Read-Host "Enter MySQL password" -AsSecureString
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    Write-Host ""

    # Test connection
    Write-Host "[3] Testing MySQL connection..." -ForegroundColor Yellow
    $testConnection = "mysql -h $hostname -P $port -u $username -p$plainPassword -e 'SELECT 1;'" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Cannot connect to MySQL!" -ForegroundColor Red
        Write-Host "Please check your connection details and try again." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ MySQL connection successful!" -ForegroundColor Green
    Write-Host ""

    # Chạy script database
    Write-Host "[4] Setting up database..." -ForegroundColor Yellow
    $databaseScript = "mysql -h $hostname -P $port -u $username -p$plainPassword < database.sql"
    Invoke-Expression $databaseScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database setup completed successfully!" -ForegroundColor Green
        Write-Host ""
        
        # Test database
        Write-Host "[5] Testing database..." -ForegroundColor Yellow
        $testQuery = "mysql -h $hostname -P $port -u $username -p$plainPassword -e 'USE hl_electric; SELECT COUNT(*) as user_count FROM users;'"
        Invoke-Expression $testQuery
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Database setup completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Database Information:" -ForegroundColor Cyan
        Write-Host "- Database: hl_electric" -ForegroundColor White
        Write-Host "- Host: $hostname" -ForegroundColor White
        Write-Host "- Port: $port" -ForegroundColor White
        Write-Host "- Username: $username" -ForegroundColor White
        Write-Host ""
        Write-Host "Default Admin User:" -ForegroundColor Cyan
        Write-Host "- Username: admin" -ForegroundColor White
        Write-Host "- Password: admin123" -ForegroundColor White
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Update database.properties with your connection details" -ForegroundColor White
        Write-Host "2. Run the web application: mvn tomcat7:run" -ForegroundColor White
        Write-Host "3. Access admin panel: http://localhost:8080/admin/login.jsp" -ForegroundColor White
        
    } else {
        Write-Host "❌ Database setup failed!" -ForegroundColor Red
        Write-Host "Please check the error messages above and try again." -ForegroundColor Red
    }

} catch {
    Write-Host "❌ An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
