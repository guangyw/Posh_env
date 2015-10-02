@echo off

set EnlistmentRoot=e:\office

call %EnlistmentRoot%\oStart.bat

powershell %~dp0ohomedaily.ps1
