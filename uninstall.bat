@echo off
rem 注意：chcp 必须重定向自己的 stdin，否则会把脚本后续 set /p 要读的输入吞掉
chcp 65001 >nul 2>&1 <nul
setlocal EnableExtensions EnableDelayedExpansion
title Dust Front RTS Demo - 简体中文汉化补丁 - 卸载

rem ============================================================
rem  Dust Front RTS Demo  简体中文汉化补丁  还原程序
rem
rem  指定游戏目录的三种方式（任选其一）：
rem    1. 把游戏文件夹直接拖到本 .bat 图标上
rem    2. 命令行传参： uninstall.bat "D:\Games\Dust Front RTS Demo"
rem    3. 运行时手动输入（自动查找失败时会自动询问）
rem ============================================================

set "TARGET="

echo.
echo   ==========================================================
echo      Dust Front RTS Demo   简体中文汉化补丁   还原程序
echo   ==========================================================
echo.

rem ---- 方式 1：命令行参数 / 拖拽 ----
if not "%~1"=="" (
    echo   检测到传入路径：%~1
    call :validate "%~1"
    if defined TARGET goto :confirmed
    echo   该目录下没有找到 Dust Front RTS_Data\resources.assets
    echo.
)

rem ---- 方式 2：自动查找 ----
echo   正在自动查找游戏目录...
call :autodetect
if defined TARGET (
    echo   已找到：%TARGET%
    echo.
    choice /c YN /n /t 15 /d Y /m "  使用这个目录？  Y=是（15 秒后自动确认）  N=手动指定："
    if errorlevel 2 (
        set "TARGET="
        echo.
    ) else (
        goto :confirmed
    )
)

rem ---- 方式 3：手动输入 ----
echo   请手动指定游戏安装目录（包含 Dust Front RTS_Data 的那个文件夹）。
echo   小技巧：可以把文件夹直接拖拽到本窗口里，再按回车。
echo.
:askloop
set "IN="
set /p "IN=  游戏目录> "
if not defined IN (
    echo   未输入任何路径，已取消。
    echo.
    pause
    exit /b 1
)
set "IN=!IN:"=!"
call :validate "!IN!"
if defined TARGET goto :confirmed
echo   [错误] 该目录下没有 Dust Front RTS_Data\resources.assets
echo          !IN!
echo.
goto :askloop

:confirmed
echo.
echo   目标目录：%TARGET%
echo.
set "DST=%TARGET%\Dust Front RTS_Data\resources.assets"
set "BAK=%DST%.backup"

if exist "%BAK%" (
    echo   正在从备份还原...
    copy /y "%BAK%" "%DST%" >nul
    if errorlevel 1 (
        echo   [错误] 还原失败。
        echo         请确认游戏已关闭，且对游戏目录有写入权限。
        echo         可尝试以管理员身份重新运行。
        pause
        exit /b 1
    )
    del /f /q "%BAK%" >nul 2>&1
    echo.
    echo   ----------------------------------------------------------
    echo     [完成] 已还原为原始英文/俄文文件。
    echo   ----------------------------------------------------------
    echo.
    pause
    exit /b 0
)

echo   [警告] 没有找到备份文件：
echo          %BAK%
echo.
echo   无法用备份还原。可以改用 Steam 自校验：
echo     Steam 库 -^> Dust Front RTS Demo -^> 右键属性 -^> 已安装文件
echo     -^> 验证游戏文件的完整性
echo   Steam 会自动重新下载原始文件。
echo.
pause
exit /b 1

rem ================= 子过程 =================

:validate
set "TARGET="
if "%~1"=="" exit /b 0
if not exist "%~1\Dust Front RTS_Data\resources.assets" exit /b 0
set "TARGET=%~1"
exit /b 0

:autodetect
set "TARGET="
rem 先从注册表读取 Steam 安装路径
for %%K in (
    "HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
    "HKLM\SOFTWARE\Valve\Steam"
    "HKCU\SOFTWARE\Valve\Steam"
) do (
    for /f "tokens=2,*" %%A in ('reg query %%~K /v InstallPath 2^>nul') do (
        if exist "%%B\steamapps\common\Dust Front RTS Demo\Dust Front RTS_Data\resources.assets" (
            set "TARGET=%%B\steamapps\common\Dust Front RTS Demo"
            exit /b 0
        )
    )
)
rem 再扫描常见盘符下的常见位置
for %%D in (C D E F G H I) do (
    call :tryone "%%D:\SteamLibrary\steamapps\common\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Steam\steamapps\common\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Program Files\Steam\steamapps\common\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Program Files (x86)\Steam\steamapps\common\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Games\Steam\steamapps\common\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Games\Dust Front RTS Demo"
    if defined TARGET exit /b 0
    call :tryone "%%D:\Dust Front RTS Demo"
    if defined TARGET exit /b 0
)
exit /b 0

:tryone
if not "%~1"=="" if exist "%~1\Dust Front RTS_Data\resources.assets" set "TARGET=%~1"
exit /b 0
