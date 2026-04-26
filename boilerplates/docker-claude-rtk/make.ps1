<#
.SYNOPSIS
    PowerShell fallback for the Makefile. Mirrors `make` targets for Windows
    users running Docker Desktop without WSL2 / GNU make.

.EXAMPLE
    .\make.ps1 build
    .\make.ps1 shell
    .\make.ps1 claude
    .\make.ps1 gain
    .\make.ps1 doctor
    .\make.ps1 rebuild
    .\make.ps1 down
    .\make.ps1 clean
    .\make.ps1 help

.NOTES
    Run from `boilerplates\docker-claude-rtk\` in PowerShell or Windows Terminal.
    Requires Docker Desktop with the `docker compose` plugin.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'build', 'shell', 'claude', 'gain', 'doctor', 'rebuild', 'down', 'clean')]
    [string]$Target = 'help'
)

$ErrorActionPreference = 'Stop'

# Windows containers don't honor Linux UID/GID; the Dockerfile defaults (1000:1000)
# are fine because Docker Desktop bind-mounts handle ownership translation.
# We still pass them so the build args resolve consistently.
$env:USER_UID = '1000'
$env:USER_GID = '1000'

function Invoke-Compose {
    param([string[]]$Args)
    & docker compose @Args
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose $($Args -join ' ') failed (exit $LASTEXITCODE)"
    }
}

function Show-Help {
    @"
Targets:
  .\make.ps1 build     Build the image
  .\make.ps1 shell     Drop into the container (bash)
  .\make.ps1 claude    Run 'claude' inside the container
  .\make.ps1 gain      Show RTK token savings stats
  .\make.ps1 doctor    Run 'claude doctor'
  .\make.ps1 rebuild   Force rebuild without cache
  .\make.ps1 down      Stop and remove the container
  .\make.ps1 clean     Remove container + volumes (loses Claude login!)
"@ | Write-Host
}

switch ($Target) {
    'help'    { Show-Help }
    'build'   { Invoke-Compose @('build') }
    'shell'   { Invoke-Compose @('build'); Invoke-Compose @('run', '--rm', 'claude', 'bash') }
    'claude'  { Invoke-Compose @('build'); Invoke-Compose @('run', '--rm', 'claude', 'claude') }
    'gain'    { Invoke-Compose @('run', '--rm', 'claude', 'rtk', 'gain') }
    'doctor'  { Invoke-Compose @('run', '--rm', 'claude', 'claude', 'doctor') }
    'rebuild' { Invoke-Compose @('build', '--no-cache') }
    'down'    { Invoke-Compose @('down') }
    'clean'   { Invoke-Compose @('down', '-v') }
}
