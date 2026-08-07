@echo off
cd /d %~dp0
echo ========================================
echo   CREATE NEW POST
echo ========================================
echo.
if "%~1"=="" (
    echo Usage: newpost.bat "Post Title"
    echo.
    set /p "TITLE=Or enter title here: "
) else (
    set "TITLE=%*"
)
call npx hexo new "%TITLE%"
if %errorlevel% neq 0 ( echo Create FAILED. & pause & exit /b 1 )
echo.
echo ========================================
echo   Created in source\_posts\
echo   Tip: add "mathjax: true" in front-matter for math.
echo ========================================
pause
