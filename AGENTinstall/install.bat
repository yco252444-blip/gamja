@echo off
rem Double-click to run. Use "install.bat check" to only inspect (no changes).
rem 기본 설치는 항상 시스템 전체(Machine) PATH에 등록한다 — 관리자 권한 창(UAC)이 자동으로 뜬다. 거기서 "예"를 누르면 된다.
cd /d "%~dp0"
if /i "%~1"=="check" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-antigravity-agent.ps1" -CheckOnly
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-antigravity-agent.ps1"
)
echo.
pause
