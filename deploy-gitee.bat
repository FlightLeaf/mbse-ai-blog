@echo off
cd /d %~dp0
echo ========================================
echo   DEPLOY-GITEE: clean + generate + push to Gitee (branch: pages)
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
echo [3/3] Pushing public/ to Gitee (branch: pages) ...
cd public
if not exist .git (
  git init -b main
  git remote add origin git@gitee.com:flight-leaf/mbse-ai-blog.git
)
git add -A
git commit -m "Site updated: %date% %time%"
git push -f origin main:pages
if %errorlevel% neq 0 ( echo Push FAILED. Check network/SSH: ssh -T git@gitee.com & pause & exit /b 1 )
echo.
echo ========================================
echo   DEPLOYED to Gitee: https://flight-leaf.gitee.io/mbse-ai-blog/
echo   REMEMBER: Gitee Pages needs manual "Update" after each deploy!
echo   (Gitee -^> repo -^> Services -^> Gitee Pages -^> Branch: pages -^> Update)
echo ========================================
pause
