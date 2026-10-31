# install-antigravity-agent.ps1
# Orca에서 Antigravity(agy) 에이전트를 쓸 수 있게 준비한다.
#   1) Orca 설치 여부 확인  2) agy 설치(Google 공식 스크립트)  3) PATH 확인(항상 전체/Machine) 4) 로그인 안내
# 항상 시스템 전체(Machine) PATH에 설치한다 — 관리자 권한이 필요해서, 아니면 자동으로 관리자 창을 다시 연다.
# -CheckOnly : 아무것도 설치/변경하지 않고 상태만 점검 (관리자 권한 불필요)
# -NoLogin   : 마지막에 로그인 창을 열지 않음
param(
  [switch]$CheckOnly,
  [switch]$NoLogin
)

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p = New-Object Security.Principal.WindowsPrincipal($id)
  return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $CheckOnly -and -not (Test-Admin)) {
  Write-Host '전체(모든 사용자) PATH에 설치하려면 관리자 권한이 필요합니다. 관리자 권한 창을 새로 엽니다... (UAC 창에서 "예"를 눌러주세요)' -ForegroundColor Yellow
  $argList = @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
  if ($NoLogin) { $argList += '-NoLogin' }
  Start-Process powershell -Verb RunAs -ArgumentList $argList
  exit 0
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$AgyInstallUrl = 'https://antigravity.google/cli/install.ps1'
$OrcaReleaseUrl = 'https://github.com/stablyai/orca/releases'

function Say($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color }
function Step($n, $text) { Write-Host ''; Write-Host "[$n] $text" -ForegroundColor Cyan }

function Sync-Path {
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = (@($machine, $user) | Where-Object { $_ }) -join ';'
}

function Find-Agy {
  $cmd = Get-Command agy -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $fallback = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
  if (Test-Path -LiteralPath $fallback) { return $fallback }
  return $null
}

function Find-Orca {
  $keys = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  Get-ItemProperty $keys -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq 'Orca' } | Select-Object -First 1
}

function Test-InUserPath($dir) {
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  foreach ($p in (@($user, $machine) -join ';') -split ';') {
    if ($p -and ($p.TrimEnd('\') -ieq $dir.TrimEnd('\'))) { return $true }
  }
  return $false
}

try {
  if ($CheckOnly) { Say '점검 모드: 아무것도 설치하거나 변경하지 않습니다.' 'Yellow' }

  # 1) Orca
  Step 1 'Orca 확인'
  $orca = Find-Orca
  if ($orca) {
    Say "OK  Orca $($orca.DisplayVersion) 설치됨" 'Green'
  } else {
    Say '!!  Orca가 설치되어 있지 않습니다.' 'Yellow'
    Say "    $OrcaReleaseUrl 에서 Windows(.exe)를 받아 설치한 뒤 이 스크립트를 다시 실행하세요."
    if (-not $CheckOnly) { Start-Process $OrcaReleaseUrl }
  }

  # 2) agy
  Step 2 'Antigravity CLI(agy) 확인'
  $agy = Find-Agy
  if ($agy) {
    Say "OK  agy 설치됨: $agy" 'Green'
  } elseif ($CheckOnly) {
    Say '!!  agy 미설치 (점검 모드라 설치하지 않음)' 'Yellow'
  } else {
    Say "    Google 공식 설치 스크립트를 실행합니다: $AgyInstallUrl"
    $script = Invoke-RestMethod -Uri $AgyInstallUrl
    Invoke-Expression $script
    Sync-Path
    $agy = Find-Agy
    if (-not $agy) { throw 'agy 설치 후에도 agy.exe를 찾지 못했습니다. 새 터미널을 열어 다시 시도하세요.' }
    Say "OK  agy 설치 완료: $agy" 'Green'
  }

  # 3) PATH (Orca는 PATH에서 agy를 찾는다)
  if ($agy) {
    Step 3 'PATH 확인'
    $dir = Split-Path -Parent $agy
    if (Test-InUserPath $dir) {
      Say "OK  PATH에 있음: $dir" 'Green'
    } elseif ($CheckOnly) {
      Say "!!  PATH에 없음: $dir (점검 모드라 추가하지 않음)" 'Yellow'
    } else {
      $current = [Environment]::GetEnvironmentVariable('Path', 'Machine')
      $new = if ($current) { "$current;$dir" } else { $dir }
      [Environment]::SetEnvironmentVariable('Path', $new, 'Machine')
      Sync-Path
      Say "OK  전체(모든 사용자, Machine) PATH에 추가했습니다: $dir" 'Green'
    }
    $ver = (Get-Item -LiteralPath $agy).VersionInfo.ProductVersion
    if ($ver) { Say "    파일 버전: $ver" }
    if (-not $CheckOnly) {
      Say '    참고: PATH를 전체로 등록해도 Orca가 여전히 못 잡을 수 있습니다(Orca 쪽 버그로 보고된 사례들이 있음, 미검증). 안 되면 Orca Settings > Agents에서 agy.exe 경로를 직접 붙여넣는 방법을 같이 시도하세요.' 'DarkYellow'
    }

    if (-not $CheckOnly) {
      try { Set-Clipboard -Value $agy; Say '    agy.exe 경로를 클립보드에 복사했습니다.' } catch {}
    }
  }

  # 4) 안내
  Step 4 'Orca에서 Antigravity 쓰기'
  Say '  1. 지금 열려 있는 Orca를 완전히 종료했다가 다시 실행합니다. (PATH를 새로 읽어야 함)'
  Say '  2. Orca 설정(Settings) > Agents 에서 Antigravity가 보이는지 확인하고 켭니다.'
  Say '  3. 목록에 안 잡히면 그 줄의 명령(command) 칸에 agy.exe 경로를 붙여넣습니다. (Ctrl+V)'
  Say '  4. 새 탭(New Tab)이나 워크스페이스 생성 화면에서 Antigravity를 선택합니다.'
  Say '  5. 그래도 안 되면 Orca에서 일반 터미널 탭을 열고 agy 를 입력합니다.'

  # 5) 로그인
  if ($agy -and -not $CheckOnly -and -not $NoLogin) {
    Step 5 'Google 로그인 (처음 한 번)'
    Say '  API 키는 필요 없습니다. 개인 Gmail 계정(무료)으로 로그인하면 됩니다.'
    Say '  agy를 처음 실행하면 로그인 방법을 묻습니다. "1. Google OAuth"를 고르고 Enter를 누르세요.'
    Say '  (2번 "Use a Google Cloud project"는 고르지 마세요.)'
    Say '  브라우저가 열리면 로그인하고, 코드가 나오면 복사해서 agy 창에 붙여넣고 Enter를 누릅니다.'
    Say '  약관 동의와 폴더 신뢰(trust) 질문이 나오면 허용합니다. 비밀번호는 이 스크립트가 받지 않습니다.'
    $ans = Read-Host '  지금 로그인 창을 열까요? (Y/N)'
    if ($ans -match '^[Yy]') {
      Start-Process -FilePath $agy -WorkingDirectory $env:USERPROFILE
      Say '  새 창에서 agy가 열렸습니다. 로그인을 마치면 그 창에서 /exit 또는 Ctrl+C로 닫아도 됩니다.'
    } else {
      Say '  나중에 터미널에서 agy 를 실행하면 같은 로그인 화면이 나옵니다.'
    }
  }

  Write-Host ''
  Say '끝났습니다.' 'Green'
  exit 0
}
catch {
  Write-Host ''
  Say "오류: $($_.Exception.Message)" 'Red'
  Say '위 내용을 캡처해서 팀장에게 보내주세요.' 'Red'
  exit 1
}
