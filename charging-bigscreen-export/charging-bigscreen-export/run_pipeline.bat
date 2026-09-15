@echo off
chcp 65001 >nul
REM 本地（Windows）一键执行：Spark 清洗 -> 多维分析 -> 装载 MySQL
setlocal
set ROOT=%~dp0
set PY=%ROOT%.venv\Scripts\python.exe
if not exist "%PY%" set PY=python
cd /d "%ROOT%"
set PYTHONIOENCODING=utf-8
echo [1/2] Spark 清洗与多维分析
"%PY%" spark\jobs\run_all.py --raw data\raw
if errorlevel 1 goto :error
echo [2/2] 装载分析结果到 MySQL
"%PY%" spark\jobs\load_mysql.py
if errorlevel 1 goto :error
echo 完成。可执行 start_backend.bat 启动大屏服务。
goto :eof
:error
echo 执行失败，请检查上方日志。
endlocal
