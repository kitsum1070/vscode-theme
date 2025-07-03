:: ============== Quick Git Push NORMAL ==============
:: This script cannot be named `git.bat` as it will conflict with the real git command.
:: Up-to-date version located at kitsum1070/Hello repository.
:: Last updated: 17/05/2025 : Updated title

@echo off
setlocal EnableDelayedExpansion

:: Allow printing Unicode characters
chcp 65001 >nul

:: clear terminal
cls

:: Starting message
set "batStartMsg=Git Tool starts"
powershell -Command "Write-Host '!batStartMsg!' -ForegroundColor Blue"
echo.

:: Pull changes
set "pullMsg=--- Pulling changes ---"
powershell -Command "Write-Host '!pullMsg!' -ForegroundColor Cyan"
echo.
git pull

:: Display Git Status
git status
echo.

:: Check status
:Main
set "GIT_STATUS="
for /f "delims=" %%i in ('git status --porcelain') do (
    set "GIT_STATUS=%%i"
    goto :HasChanges
)

:: ================== Functions ==================

:: No changes found
set "noChanges=No changes to commit."
powershell -Command "Write-Host '!noChanges!' -ForegroundColor Cyan"
goto :EndScript

:: Exit Script
:EndScript
echo.
set "leavingMsg=Script ends"
powershell -Command "Write-Host '!leavingMsg!' -ForegroundColor Blue"
timeout /t 30
exit

:: Commit/Push Failed
:Failed
set "failedMsg=ERROR: Something went wrong..."
powershell -Command "Write-Host '!failedMsg!' -ForegroundColor Red"
goto :EndScript

:: (Commit cancelled) Ask if unstaged or not
:Unstaged
set "unstagedMsg=Do you want to unstage the changes? ([Y] to unstage)"
powershell -Command "Write-Host '!unstagedMsg!' -ForegroundColor Cyan"
echo.
powershell -Command ^
    "$key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');" ^
    "if ($key.VirtualKeyCode -eq 89) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    set "notUnstageMsg=Staged changes remain."
    powershell -Command "Write-Host '!notUnstageMsg!' -ForegroundColor Cyan"
    echo.
    goto :EndScript
)
git reset
echo.
set "unstagedMsg=Changes unstaged."
powershell -Command "Write-Host '!unstagedMsg!' -ForegroundColor Cyan"
echo.
goto :EndScript

:: ====== Main Script ======
:HasChanges
echo.
set "proceedConfirmation=Continue? (Y/N)"
powershell -Command "Write-Host '!proceedConfirmation!' -ForegroundColor Cyan"
powershell -Command ^
    "$key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');" ^
    "if ($key.VirtualKeyCode -eq 89 -or $key.VirtualKeyCode -eq 13) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    goto :EndScript
)

:: Stage all files
echo.
git add .
set "stagedMsg=Changes staged."
powershell -Command "Write-Host '!stagedMsg!' -ForegroundColor Cyan"

:: Ask for commit type
set "defaultMsg=Back up works with small non-breaking changes"
echo.
@REM echo Select a commit tag:
powershell -Command "Write-Host 'Select a commit tag:' -ForegroundColor Cyan"
powershell -Command "Write-Host '[0] No tag' -ForegroundColor Green"
set "tagList=[1] [GIT]   [2] [FEAT]   [3] [FIX]   [4] [DOC]   [5] [STYLE]"
powershell -Command "Write-Host '!tagList!' -ForegroundColor Green"
powershell -Command "Write-Host 'Press the number key (0-5):' -ForegroundColor Cyan"

set "commitTag="
powershell -Command ^
    "$key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');" ^
    "if ($key.VirtualKeyCode -ge 48 -and $key.VirtualKeyCode -le 53) { Write-Output $key.Character } else { Write-Output '0' }" > tag_choice.tmp
set /p commitTag=<tag_choice.tmp
if exist tag_choice.tmp del tag_choice.tmp

:: Map numeric choice to tag
set "tag0="
set "tag1=[GIT] "
set "tag2=[FEAT] "
set "tag3=[FIX] "
set "tag4=[DOC] "
set "tag5=[STYLE] "

set "prefix=!tag%commitTag%!"
powershell -Command "Write-Host 'Selected tag: !prefix!' -ForegroundColor Green"

:: Ask for commit message
echo.
powershell -Command "Write-Host 'Commit message: ' -ForegroundColor Cyan -NoNewline"
set /p "commitMsg="
if "%commitMsg%"=="" (
    set "commitMsg=%defaultMsg%"
)
if "%commitMsg%"=="!q" (
    set "notCommitMsg=Commit cancelled."
    powershell -Command "Write-Host '!notCommitMsg!' -ForegroundColor Cyan"
    echo.
    goto :Unstaged
)

:: Final commit string
git commit -m "!prefix!!commitMsg!"

if errorlevel 1 (
    goto :Failed
)
echo.
set "committed=Changes committed."
powershell -Command "Write-Host '!committed!' -ForegroundColor Cyan"
echo.

:: Push changes
git push
if errorlevel 1 (
    goto :Failed
)
echo.
set "pushSuccess=Job done."
powershell -Command "Write-Host '!pushSuccess!' -ForegroundColor Cyan"
echo.

goto :EndScript

:: ============================== End of the quick-git.bat ==============================