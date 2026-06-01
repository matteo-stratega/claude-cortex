# ============================================
#  CORTEX - ONE CLICK SETUP (Windows)
#  An operating system for Claude Code
# ============================================
#  Right click -> Run with PowerShell
#  Or: powershell -ExecutionPolicy Bypass -File setup-windows.ps1
#
#  This installer clones the repo and assembles a clean personal workspace
#  from its files -- it embeds no copies, so it can never drift from source.
# ============================================

$ErrorActionPreference = "Stop"

# Repo + workspace parent are overridable for testing.
$RepoUrl = if ($env:CORTEX_REPO) { $env:CORTEX_REPO } else { "https://github.com/matteo-stratega/claude-cortex.git" }
$WorkspaceParent = if ($env:CORTEX_HOME) { $env:CORTEX_HOME } else { "$env:USERPROFILE\Documents" }

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CORTEX SETUP" -ForegroundColor Cyan
Write-Host "   An operating system for Claude Code" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# STEP 1: Check prerequisites
# ============================================
Write-Host "[1/4] Checking prerequisites..." -ForegroundColor Yellow

function Require-Tool($names, $hint) {
    foreach ($n in $names) {
        if (Get-Command $n -ErrorAction SilentlyContinue) { return $true }
    }
    Write-Host "$($names[0]) not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  -> $hint"
    Write-Host ""
    Write-Host "Then run this script again."
    Write-Host "Press any key to close..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Require-Tool @("node") "Install Node.js (LTS): https://nodejs.org" | Out-Null
Require-Tool @("python3", "python") "Install Python 3: https://python.org (required for enforcement hooks)" | Out-Null
Require-Tool @("git") "Install Git: https://git-scm.com" | Out-Null
Write-Host "  + node, python, git found" -ForegroundColor Green

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  + Claude Code already installed" -ForegroundColor Green
} else {
    Write-Host "  Installing Claude Code..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
    Write-Host "  + Claude Code installed" -ForegroundColor Green
}

# ============================================
# STEP 2: Workspace name
# ============================================
Write-Host ""
Write-Host "[2/4] Naming workspace..." -ForegroundColor Yellow

$ProjectName = Read-Host "Workspace name (default: cortex)"
if ([string]::IsNullOrWhiteSpace($ProjectName)) { $ProjectName = "cortex" }
$ProjectName = $ProjectName -replace '\s+', '-'
$ProjectName = $ProjectName -replace '[^a-zA-Z0-9-]', ''
$ProjectPath = Join-Path $WorkspaceParent $ProjectName

if (Test-Path $ProjectPath) {
    Write-Host "  ! Folder already exists: $ProjectPath" -ForegroundColor Yellow
    $confirm = Read-Host "  Merge into it anyway? (y/n)"
    if ($confirm -ne "y") { Write-Host "Aborted."; exit 1 }
}
Write-Host "  + Workspace: $ProjectPath" -ForegroundColor Green

# ============================================
# STEP 3: Clone + assemble workspace
# ============================================
Write-Host ""
Write-Host "[3/4] Assembling workspace from source..." -ForegroundColor Yellow

$TmpSrc = Join-Path ([System.IO.Path]::GetTempPath()) ("cortex-src-" + [System.Guid]::NewGuid().ToString())
git clone --depth 1 --quiet $RepoUrl $TmpSrc

New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
# Copy everything (including dotfiles), then strip repo/plugin-only bits.
Copy-Item -Path (Join-Path $TmpSrc '*') -Destination $ProjectPath -Recurse -Force

Push-Location $ProjectPath
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue ".git"           # repo git
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue ".claude-plugin" # plugin manifest
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "skills"         # canonical plugin skills (workspace uses .claude/skills)
Remove-Item -Force -ErrorAction SilentlyContinue "hooks\hooks.json"        # plugin hook config (workspace uses .claude/settings.json)
Remove-Item -Force -ErrorAction SilentlyContinue "setup.sh"
Remove-Item -Force -ErrorAction SilentlyContinue "setup-windows.ps1"
Remove-Item -Force -ErrorAction SilentlyContinue "scripts\sync.sh"         # repo dev tool
Remove-Item -Force -ErrorAction SilentlyContinue "README.md"               # repo readme
Pop-Location

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $TmpSrc
Write-Host "  + Workspace assembled" -ForegroundColor Green

# ============================================
# STEP 4: Initialize git
# ============================================
Write-Host ""
Write-Host "[4/4] Initializing git..." -ForegroundColor Yellow

Push-Location $ProjectPath
if (-not (Test-Path ".git")) {
    git init --quiet
    git add -A
    git commit -m "Initial setup - Cortex" --quiet
}
Pop-Location
Write-Host "  + Git initialized" -ForegroundColor Green

# ============================================
# DONE!
# ============================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CORTEX SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your workspace is ready:"
Write-Host "  $ProjectPath" -ForegroundColor Blue
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd $ProjectPath"
Write-Host "  2. claude"
Write-Host "  3. /setup     (guided onboarding - fills in your context)"
Write-Host ""
Write-Host "Skills: /setup  /start  /close  /brief  /plan  /review  /weekly" -ForegroundColor Yellow
Write-Host "Agents: call cto, content-strategist, growth-hacker, war-council" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Repo:   github.com/matteo-stratega/claude-cortex" -ForegroundColor Blue
Write-Host "  Author: Matteo Lombardi" -ForegroundColor Blue
Write-Host ""
