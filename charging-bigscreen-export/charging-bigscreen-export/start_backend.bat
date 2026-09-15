@echo off
chcp 65001 >nul
REM 本地（Windows）启动 Flask 后端：默认数据源 MySQL，端口 5000
setlocal
set ROOT=%~dp0
set PY=%ROOT%.venv\Scripts\python.exe
if not exist "%PY%" set PY=python
cd /d "%ROOT%"
set PYTHONIOENCODING=utf-8
"%PY%" backend\app.py
endlocal
