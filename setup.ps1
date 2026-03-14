#Requires -Version 5.1
$ErrorActionPreference = "Stop"

<#
.SYNOPSIS
    Setup script for Odoo Skills Ecosystem on Windows.
    Automates the integration of AI skills with coding assistants.

    Copyright (c) 2026 Geraldow - MIT License

.PARAMETER All
    Install all integrations (Claude Code, Cursor, VS Code).

.PARAMETER Claude
    Install Claude Code integration only.

.PARAMETER Cursor
    Install Cursor integration only.

.PARAMETER VSCode
    Install VS Code / Copilot integration only.

.EXAMPLE
    .\setup.ps1 -All
    .\setup.ps1 -Claude
    .\setup.ps1 -Cursor
#>

param(
    [switch]$All,
    [switch]$Claude,
    [switch]$Cursor,
    [switch]$VSCode
)

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# --- Initialization ---
$RepoRoot = $PSScriptRoot
$ParentDir = Split-Path -Path $RepoRoot -Parent
$AgentsFile = Join-Path $RepoRoot "AGENTS.md"

Write-Host "`n"
Write-Host "   ██████  ██████   ██████   ██████      ███████ ██   ██ ██ ██      ██      ███████" -ForegroundColor Magenta
Write-Host "  ██    ██ ██   ██ ██    ██ ██    ██     ██      ██  ██  ██ ██      ██      ██     " -ForegroundColor Magenta
Write-Host "  ██    ██ ██   ██ ██    ██ ██    ██     ███████ █████   ██ ██      ██      ███████" -ForegroundColor Magenta
Write-Host "  ██    ██ ██   ██ ██    ██ ██    ██          ██ ██  ██  ██ ██      ██           ██" -ForegroundColor Magenta
Write-Host "   ██████  ██████   ██████   ██████      ███████ ██   ██ ██ ███████ ███████ ███████" -ForegroundColor Magenta
Write-Host "`n--- Odoo Skills Installer for Windows ---`n" -ForegroundColor Gray

# --- Check Repo Integrity ---
if (-not (Test-Path $AgentsFile)) {
    Write-Error-Custom "Could not find AGENTS.md in $RepoRoot. Please run from the repo root."
    exit 1
}

# --- Detect Target Odoo Project ---
$OdooManifest = Join-Path $ParentDir "__manifest__.py"
$IsInsideOdoo = Test-Path $OdooManifest

if ($IsInsideOdoo) {
    Write-Info "Detected Odoo project at: $ParentDir"
} else {
    Write-Warn "Not running inside an Odoo project (no __manifest__.py found in $ParentDir)."
    $Proceed = Read-Host "Do you want to proceed with a standalone installation? (y/n)"
    if ($Proceed -ne "y") { exit 0 }
}

# --- Resolve tasks from flags or interactive menu ---
$tasks = @()

if ($All) {
    $tasks = @(1, 2, 3)
} elseif ($Claude) {
    $tasks = @(1)
} elseif ($Cursor) {
    $tasks = @(2)
} elseif ($VSCode) {
    $tasks = @(3)
} else {
    # Interactive menu (no flags provided)
    Write-Host "`nSelect integration targets:"
    Write-Host "1. Claude Code (AGENTS.md)"
    Write-Host "2. Cursor (.cursorrules)"
    Write-Host "3. VS Code / Copilot (.vscode/settings.json)"
    Write-Host "4. All of the above"
    Write-Host "q. Quit"

    $Choice = Read-Host "`nChoice"

    switch ($Choice) {
        "1" { $tasks = @(1) }
        "2" { $tasks = @(2) }
        "3" { $tasks = @(3) }
        "4" { $tasks = @(1, 2, 3) }
        "q" { exit 0 }
        default { Write-Error-Custom "Invalid choice"; exit 1 }
    }
}

# --- Task Execution ---

# Task 1: Claude Code / Generic AI Master Router
if ($tasks -contains 1) {
    $TargetAgents = Join-Path $ParentDir "AGENTS.md"
    Write-Info "Linking AGENTS.md to Odoo project root..."
    try {
        if (Test-Path $TargetAgents) {
            Write-Warn "AGENTS.md already exists in target. Backing up..."
            Move-Item $TargetAgents "$TargetAgents.bak" -Force
        }
        New-Item -ItemType SymbolicLink -Path $TargetAgents -Target $AgentsFile -Force | Out-Null
        Write-Success "Linked: $TargetAgents -> $AgentsFile"
    } catch {
        Write-Warn "Could not create symbolic link (Permissions?). Copying file instead..."
        Copy-Item $AgentsFile $TargetAgents -Force
        Write-Success "Copied: $TargetAgents"
    }
}

# Task 2: Cursor Integration
if ($tasks -contains 2) {
    $CursorRules = Join-Path $ParentDir ".cursorrules"
    Write-Info "Creating/Updating .cursorrules..."
    $RuleContent = "`n# Odoo Skills Ecosystem Integration`n# Use the master router for Odoo-specific logic`n@AGENTS.md`n"
    if (Test-Path $CursorRules) {
        $RuleContent | Add-Content -Path $CursorRules
    } else {
        $RuleContent | Set-Content -Path $CursorRules
    }
    Write-Success "Updated .cursorrules at $CursorRules"
}

# Task 3: VS Code
if ($tasks -contains 3) {
    $VSCodeDir = Join-Path $ParentDir ".vscode"
    if (-not (Test-Path $VSCodeDir)) { New-Item -ItemType Directory -Path $VSCodeDir | Out-Null }
    Write-Info "Configuring VS Code workspace..."
    Write-Warn "VS Code logic pending implementation (Tier 2). AGENTS.md link is usually enough."
}

Write-Host "`nIntegration complete! Happy Odoo Coding.`n" -ForegroundColor Green
