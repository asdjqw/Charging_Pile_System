@echo off
chcp 65001 >nul
REM 本地（Windows）启动 Flask 后端：默认数据源 MySQL，端口 5000
REM 依赖：Python 3.11/3.12 + backend\requirements.txt，MySQL 连接见 config\database.env
setlocal
set ROOT=%~dp0
set PY=%ROOT%.venv\Scripts\python.exe
if not exist "%PY%" set PY=python
cd /d "%ROOT%"
set PYTHONIOENCODING=utf-8
if not defined PORT set PORT=5000
echo [INFO] 依赖检查（首次运行请先执行： .venv\Scripts\pip install -r backend\requirements.txt ）
"%PY%" -c "import flask, pymysql" 2>nul || echo [WARN] 缺少 Flask / PyMySQL 依赖
echo [INFO] 启动后访问  http://127.0.0.1:%PORT%/
"%PY%" backend\app.py
endlocal
