@echo off
echo ========================================
echo    HL Generator Solutions Database
echo ========================================
echo.

echo [1] Starting MySQL service...
net start mysql
if %errorlevel% neq 0 (
    echo Warning: Could not start MySQL service. Please start manually.
    echo.
)

echo [2] Connecting to MySQL...
echo Please enter your MySQL root password:
mysql -u root -p < database.sql

if %errorlevel% equ 0 (
    echo.
    echo ✅ Database setup completed successfully!
    echo.
    echo Database: hl_electric
    echo Default admin user: admin
    echo Default admin password: admin123
    echo.
) else (
    echo.
    echo ❌ Database setup failed!
    echo Please check your MySQL connection and try again.
    echo.
)

echo [3] Testing database connection...
mysql -u root -p -e "USE hl_electric; SELECT COUNT(*) as user_count FROM users;"

echo.
echo ========================================
echo Database setup completed!
echo ========================================
pause
