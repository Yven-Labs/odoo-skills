#Requires -Version 5.1

<#
.SYNOPSIS
    Odoo Skills full setup for Windows.
    Detects installed AI tools, installs skills, and injects the Odoo Skills
    block into each tool's global instructions file. Safe to re-run.

    Copyright (c) 2026 Geraldow - MIT License

.PARAMETER Agent
    Set up a specific agent only.
    Valid values: claude-code, opencode, gemini-cli, codex, vscode, cursor
.PARAMETER All
    Auto-detect and set up all found agents.
.PARAMETER NonInteractive
    Skip confirmation prompts (for use by external installers).
.PARAMETER Help
    Show help.
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -All
.EXAMPLE
    irm https://raw.githubusercontent.com/Geraldow/odoo-skills/main/scripts/install.ps1 | iex
#>

[CmdletBinding()]
param(
    [ValidateSet('claude-code', 'opencode', 'gemini-cli', 'codex', 'vscode', 'cursor')]
    [string]$Agent,
    [switch]$All,
    [switch]$NonInteractive,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# Remote Execution Support
# ============================================================================
# When invoked via `irm ... | iex`, $PSScriptRoot is empty.
# Clone repo to temp dir and re-execute from there.

if (-not $MyInvocation.MyCommand.Definition -or
    $MyInvocation.MyCommand.Definition -match '^$') {
    $TempDir = Join-Path $env:TEMP "odoo-skills-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host '[INFO] Remote execution detected. Cloning odoo-skills...' -ForegroundColor Cyan
    git clone --depth 1 https://github.com/Geraldow/odoo-skills.git $TempDir 2>&1 | Out-Null
    & (Join-Path $TempDir 'scripts\install.ps1') @PSBoundParameters
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    exit $LASTEXITCODE
}

# ============================================================================
# Paths
# ============================================================================

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoDir = Split-Path -Parent $ScriptRoot
$SkillsSrc = Join-Path $RepoDir 'skills'
$ExamplesDir = Join-Path $RepoDir 'examples'

$MarkerBegin = '<!-- BEGIN:odoo-skills -->'
$MarkerEnd = '<!-- END:odoo-skills -->'

$SkillsPaths = @{
    'claude-code' = Join-Path $env:USERPROFILE '.claude\skills'
    'opencode'    = Join-Path $env:USERPROFILE '.config\opencode\skills'
    'gemini-cli'  = Join-Path $env:USERPROFILE '.gemini\skills'
    'codex'       = Join-Path $env:USERPROFILE '.codex\skills'
    'vscode'      = Join-Path $env:USERPROFILE '.copilot\skills'
    'cursor'      = Join-Path $env:USERPROFILE '.cursor\skills'
}

$PromptPaths = @{
    'claude-code' = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
    'opencode'    = Join-Path $env:USERPROFILE '.config\opencode\AGENTS.md'
    'gemini-cli'  = Join-Path $env:USERPROFILE '.gemini\GEMINI.md'
    'codex'       = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
    'vscode'      = Join-Path $env:APPDATA 'Code\User\prompts\odoo-skills.instructions.md'
    'cursor'      = Join-Path $env:USERPROFILE '.cursor\rules\odoo-skills.mdc'
}

$ExampleFiles = @{
    'claude-code' = Join-Path $ExamplesDir 'claude-code\CLAUDE.md'
    'opencode'    = Join-Path $ExamplesDir 'opencode\AGENTS.md'
    'gemini-cli'  = Join-Path $ExamplesDir 'gemini-cli\GEMINI.md'
    'codex'       = Join-Path $ExamplesDir 'codex\agents.md'
    'vscode'      = Join-Path $ExamplesDir 'vscode\copilot-instructions.md'
    'cursor'      = Join-Path $ExamplesDir 'cursor\.cursorrules'
}

$AgentBinaries = @{
    'claude-code' = 'claude'
    'opencode'    = 'opencode'
    'gemini-cli'  = 'gemini'
    'codex'       = 'codex'
    'vscode'      = 'code'
    'cursor'      = 'cursor'
}

# ============================================================================
# Display Helpers
# ============================================================================

function Write-Header {
    Write-Host ''
    Write-Host '   ___       _                ____  _    _ _ _     ' -ForegroundColor Cyan
    Write-Host '  / _ \   __| | ___   ___    / ___|| | _(_) | |___ ' -ForegroundColor Cyan
    Write-Host ' | | | | / _` |/ _ \ / _ \   \___ \| |/ / | | / __|' -ForegroundColor Cyan
    Write-Host ' | |_| || (_| | (_) | (_) |   ___) |   <| | | \__ \' -ForegroundColor Cyan
    Write-Host '  \___/  \__,_|\___/ \___/  |____/|_|\_\_|_|_|___/ ' -ForegroundColor Cyan
    Write-Host ''
    Write-Host "  Odoo Skills - configure any AI agent, any OS" -ForegroundColor DarkGray
    Write-Host ''
}

function Write-Ok   { param([string]$Msg) Write-Host '  ' -NoNewline; Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline; Write-Host " $Msg" }
function Write-Warn { param([string]$Msg) Write-Host '  ! ' -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Fail { param([string]$Msg) Write-Host '  ' -NoNewline; Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline; Write-Host " $Msg" }
function Write-Info { param([string]$Msg) Write-Host '  ' -NoNewline; Write-Host ([char]0x2192) -ForegroundColor Blue -NoNewline; Write-Host " $Msg" }
function Write-Head { param([string]$Msg) Write-Host ''; Write-Host $Msg -ForegroundColor Cyan }

# ============================================================================
# Prerequisites
# ============================================================================

function Test-Prerequisites {
    if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Fail 'git is required but not found in PATH.'
        Write-Host '  Please install git and try again.' -ForegroundColor DarkGray
        exit 1
    }
}

# ============================================================================
# Agent Detection
# ============================================================================

function Find-Agents {
    Write-Head 'Detecting installed AI tools...'

    $found = @()
    foreach ($agent in ($AgentBinaries.Keys | Sort-Object)) {
        $binary = $AgentBinaries[$agent]
        $cmd = Get-Command $binary -ErrorAction SilentlyContinue
        if ($cmd) {
            Write-Ok "$agent  ($binary found in PATH)"
            $found += $agent
        } else {
            Write-Warn "$agent  ($binary not found in PATH - skipping)"
        }
    }

    Write-Host ''
    if ($found.Count -eq 0) {
        Write-Warn 'No agents detected. Use .\install.ps1 for manual installation.'
    } else {
        Write-Host "  $($found.Count) agent(s) detected" -ForegroundColor Green
    }

    return $found
}

# ============================================================================
# Install Skills
# ============================================================================

function Install-Skills {
    param([string]$TargetDir, [string]$AgentName)

    Write-Info "Installing skills -> $TargetDir"
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    $count = 0
    $skillDirs = Get-ChildItem -Path $SkillsSrc -Directory -Filter 'odoo-*'

    foreach ($skillDir in $skillDirs) {
        $skillFile = Join-Path $skillDir.FullName 'SKILL.md'
        if (-not (Test-Path $skillFile)) { continue }

        $targetSkillDir = Join-Path $TargetDir $skillDir.Name
        New-Item -ItemType Directory -Path $targetSkillDir -Force | Out-Null
        Copy-Item -Path $skillFile -Destination (Join-Path $targetSkillDir 'SKILL.md') -Force

        # Copy assets/ and references/ if present
        foreach ($subDir in @('assets', 'references')) {
            $src = Join-Path $skillDir.FullName $subDir
            if (Test-Path $src) {
                $dst = Join-Path $targetSkillDir $subDir
                Copy-Item -Path $src -Destination $dst -Recurse -Force
            }
        }
        $count++
    }

    Write-Ok "$count Odoo skills installed"
}

# ============================================================================
# Inject Odoo Skills Block (idempotent)
# ============================================================================

function Set-OdooBlock {
    param([string]$PromptPath, [string]$ExampleFile, [string]$AgentName)

    if (-not $ExampleFile -or -not (Test-Path $ExampleFile)) {
        Write-Warn "No example file for $AgentName - skipping prompt configuration"
        return
    }

    # Extract content between markers in example file
    $rawContent = Get-Content -Path $ExampleFile -Raw
    $content = ''
    if ($rawContent -match "(?s)$([regex]::Escape($MarkerBegin))(.*?)$([regex]::Escape($MarkerEnd))") {
        $content = $Matches[1].Trim()
    } else {
        $content = $rawContent.Trim()
    }

    $promptDir = Split-Path -Parent $PromptPath
    if ($promptDir) { New-Item -ItemType Directory -Path $promptDir -Force | Out-Null }

    if (Test-Path $PromptPath) {
        $existing = Get-Content -Path $PromptPath -Raw

        if ($existing -match [regex]::Escape($MarkerBegin)) {
            # Replace existing block
            $pattern = "(?s)$([regex]::Escape($MarkerBegin)).*?$([regex]::Escape($MarkerEnd))"
            $replacement = "$MarkerBegin`n$content`n$MarkerEnd"
            $updated = [regex]::Replace($existing, $pattern, $replacement)
            Set-Content -Path $PromptPath -Value $updated -NoNewline
            Write-Ok "Odoo Skills block updated in $PromptPath"
        } else {
            # Check if already present without markers
            if ($existing -match '## Odoo Skills Ecosystem') {
                Write-Warn "Odoo Skills block already present in $PromptPath (no markers)"
                Write-Info "To enable auto-updates, wrap the block with: $MarkerBegin / $MarkerEnd"
            } else {
                # Append
                $appendContent = "`n`n$MarkerBegin`n$content`n$MarkerEnd"
                Add-Content -Path $PromptPath -Value $appendContent
                Write-Ok "Odoo Skills block appended to $PromptPath"
            }
        }
    } else {
        # Create new file
        Set-Content -Path $PromptPath -Value "$MarkerBegin`n$content`n$MarkerEnd"
        Write-Ok "Odoo Skills block created at $PromptPath"
    }
}

# ============================================================================
# Full Setup for One Agent
# ============================================================================

function Set-Agent {
    param([string]$AgentName)

    Write-Head "Setting up $AgentName"

    Install-Skills -TargetDir $SkillsPaths[$AgentName] -AgentName $AgentName
    Set-OdooBlock -PromptPath $PromptPaths[$AgentName] -ExampleFile $ExampleFiles[$AgentName] -AgentName $AgentName
}

# ============================================================================
# Next Steps
# ============================================================================

function Show-NextSteps {
    param([string[]]$Agents)
    Write-Host ''
    Write-Host 'Setup complete!' -ForegroundColor Green
    Write-Host ''
    foreach ($a in $Agents) {
        Write-Host '  ' -NoNewline
        Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
        Write-Host " $a" -ForegroundColor White
        Write-Host "    Skills : $($SkillsPaths[$a])"
        Write-Host "    Prompt : $($PromptPaths[$a])"
    }
    Write-Host ''
    Write-Host 'Open any Odoo project and your AI tool will use the skills automatically.'
    Write-Host ''
}

# ============================================================================
# Main
# ============================================================================

function Main {
    if ($Help) {
        Write-Host 'Usage: .\install.ps1 [OPTIONS]'
        Write-Host ''
        Write-Host 'Options:'
        Write-Host '  -All               Auto-detect and set up all found agents'
        Write-Host '  -Agent NAME        Set up a specific agent'
        Write-Host '  -NonInteractive    No prompts (for external installers)'
        Write-Host '  -Help              Show this help'
        Write-Host ''
        Write-Host 'Agents: claude-code, opencode, gemini-cli, codex, vscode, cursor'
        Write-Host ''
        Write-Host 'Remote install (Windows):'
        Write-Host '  irm https://raw.githubusercontent.com/Geraldow/odoo-skills/main/scripts/install.ps1 | iex'
        exit 0
    }

    Write-Header
    Test-Prerequisites

    $installedAgents = @()

    if ($Agent) {
        Set-Agent -AgentName $Agent
        $installedAgents += $Agent
    }
    elseif ($All -or $NonInteractive) {
        $detected = Find-Agents
        foreach ($a in $detected) {
            Set-Agent -AgentName $a
            $installedAgents += $a
        }
    }
    else {
        $detected = Find-Agents
        if ($detected.Count -eq 0) {
            Write-Host ''
            Write-Warn 'No agents detected. Use .\install.ps1 for manual installation.'
            exit 0
        }

        Write-Host ''
        $answer = if ($NonInteractive) { 'y' } else { Read-Host 'Set up all detected agents? [Y/n]' }

        if (-not $answer -or $answer -match '^[Yy]') {
            foreach ($a in $detected) {
                Set-Agent -AgentName $a
                $installedAgents += $a
            }
        } else {
            Write-Host ''
            Write-Host 'Select agents to set up (space-separated numbers):' -ForegroundColor White
            Write-Host ''
            $i = 1
            foreach ($a in $detected) {
                Write-Host "  $i) $a"
                $i++
            }
            Write-Host ''
            $choices = (Read-Host 'Choice') -split '\s+'
            foreach ($c in $choices) {
                $idx = [int]$c - 1
                if ($idx -ge 0 -and $idx -lt $detected.Count) {
                    Set-Agent -AgentName $detected[$idx]
                    $installedAgents += $detected[$idx]
                }
            }
        }
    }

    if ($installedAgents.Count -gt 0) {
        Show-NextSteps -Agents $installedAgents
    } else {
        Write-Host ''
        Write-Warn 'No agents were set up.'
    }
}

try {
    Main
}
catch {
    Write-Host ''
    Write-Fail "Setup failed: $_"
    Write-Host ''
    exit 1
}
