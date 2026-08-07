@echo off
cd /d %~dp0
echo ========================================
echo   LOCAL PREVIEW SERVER
echo ========================================
echo.
echo Open in browser: http://localhost:4000
echo Press Ctrl+C to stop the server.
echo.
call npx hexo server
