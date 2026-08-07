@echo off
cd /d %~dp0
echo ========================================
echo   DEPLOY: clean + generate + deploy
echo ========================================
echo.
echo [1/3] Cleaning cache ...
call npx hexo clean
if %errorlevel% neq 0 ( echo Clean FAILED. & pause & exit /b 1 )
echo.
echo [2/3] Generating static site ...
call npx hexo generate
if %errorlevel% neq 0 ( echo Build FAILED, deploy aborted. & pause & exit /b 1 )
echo.
echo [3/3] Deploying to GitHub Pages ...
set ATTEMPT=0
:deploy_retry
set /a ATTEMPT+=1
call npx hexo deploy
if %errorlevel% neq 0 (
  if %ATTEMPT% lss 3 (
    echo.
    echo Deploy attempt %ATTEMPT% failed, likely a transient network/DNS issue.
    echo Retrying in 5 seconds ...
    timeout /t 5 /nobreak >nul
    goto deploy_retry
  )
  echo Deploy FAILED after 3 attempts. Check network/SSH: ssh -T git@github.com
  pause
  exit /b 1
)
echo.
echo ========================================
echo   DEPLOYED to branch: main
echo   Site: https://flightleaf.github.io/
echo ========================================
echo.
echo   If the site does NOT update within ~2 min:
echo   GitHub repo -^> Settings -^> Pages -^> Source:
echo     "Deploy from a branch"  (NOT "GitHub Actions")
echo   Branch: main   Folder: / (root)   then Save.
echo ========================================
pause
