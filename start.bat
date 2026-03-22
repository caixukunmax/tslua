@echo off
REM TS-Skynet Quick Start (Windows CMD)
REM Usage: start.bat [command] [config-file]
REM Examples:
REM   start.bat              - Show menu
REM   start.bat quick        - Quick start
REM   start.bat build:ts     - Build TS to Lua

cd /d "%~dp0"

REM Set default config file
set "TSLUA_CONFIG=tslua.config.yaml"

REM Get command argument
set "CMD=%~1"

REM Get config file argument
set "CONFIG_FILE=%~2"

if not "%CONFIG_FILE%"=="" (
    echo [Config] %CONFIG_FILE%
    set "TSLUA_CONFIG=%CONFIG_FILE%"
)

if "%CMD%"=="" (
    REM No command, show menu
    npm run cli
) else (
    REM Execute command
    npm run cli -- %CMD%
)
