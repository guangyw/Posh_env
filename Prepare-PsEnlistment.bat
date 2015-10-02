@echo off

set EnlistmentTitle=OMEX_PreCheckIn
set EnlistmentRoot=e:\OmexPC
set OpenEnlistmentScript=%EnlistmentRoot%\dev\otools\bin\OpenEnlistment.bat"

echo Call OpenEnlistment.bat
call %OpenEnlistmentScript%

echo
echo Current environment variables
env

echo
echo Call Prepare-Enlistment.ps1
call powershell -File Prepare-Enlistment.ps1

