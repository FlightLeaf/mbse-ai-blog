@echo off
cd /d %~dp0
echo ========================================
echo   REBUILD: clean + generate
echo ========================================
echo.
echo [1/2] Cleaning cache ...
call npx hexo clean
if %errorlevel% neq 0 ( echo Clean FAILED. & pause & exit /b 1 )
echo.
echo [2/2] Generating static site ...
call npx hexo generate
if %errorlevel% neq 0 ( echo Build FAILED. & pause & exit /b 1 )
echo.
echo ========================================
echo   DONE. Output folder: public\
echo ========================================
pause
