@echo off
chcp 65001 >nul
REM 本地（Windows）一键执行：Spark 清洗 -> 多维分析 -> 装载 MySQL
REM 依赖：Python 3.11/3.12、Java（见下方 JAVA_HOME 自动探测）、MySQL（config\database.env）
setlocal
set ROOT=%~dp0
set PY=%ROOT%.venv\Scripts\python.exe
if not exist "%PY%" set PY=python
cd /d "%ROOT%"
set PYTHONIOENCODING=utf-8

REM 自动探测 JAVA_HOME（Spark 需要 Java 11，或 8u371+ / 17）
if not defined JAVA_HOME (
  for %%J in (
    "C:\Program Files\Java\jdk-11"
    "C:\Program Files\Java\jdk-17"
    "C:\Program Files\Java\jdk1.8.0_481"
    "C:\Program Files\Java\jre1.8.0_481"
    "C:\Program Files (x86)\Common Files\Oracle\Java\java8path"
  ) do (
    if not defined JAVA_HOME if exist "%%~fJ\bin\java.exe" set "JAVA_HOME=%%~fJ"
  )
)
if defined JAVA_HOME echo [INFO] JAVA_HOME=%JAVA_HOME%

echo [1/2] Spark 清洗与多维分析
"%PY%" spark\jobs\run_all.py --raw data\raw_expanded
if errorlevel 1 goto :error
echo [2/2] 装载分析结果到 MySQL
"%PY%" spark\jobs\load_mysql.py
if errorlevel 1 goto :error
echo 完成。可执行 start_backend.bat 启动大屏服务。
goto :eof
:error
echo 执行失败，请检查上方日志。
endlocal
