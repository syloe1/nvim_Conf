# install.ps1 -- one-command installer for syloe1/nvim_Conf (com branch),
# a small hand-written NeoVim config, plugins managed by lazy.nvim.
#
#   irm https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.ps1 | iex
#
# NOTE: this file is deliberately pure ASCII. PowerShell 5.1 reads a BOM-less
# file using the ANSI code page, which mangles UTF-8 and can silently swallow a
# closing brace. All user-facing text lives in README.md instead.
#
# Options (pass when you run it as a script, or via the env vars below):
#   -Dir <path>    install to <path>   (env NVIM_CONF_DIR;    default %LOCALAPPDATA%\nvim)
#   -Branch <name> git branch          (env NVIM_CONF_BRANCH; default com)
#   -NoDeps        skip the optional winget dependency install
#   -Yes           non-interactive
#   -Uninstall     remove the config
#   -Help          show help
#
#   env NVIM_CONF_REPO    override the clone URL entirely
#   env NVIM_CONF_MIRROR  GitHub mirror prefix used if the direct clone fails

[CmdletBinding()]
param(
  [string]$Dir    = $(if ($env:NVIM_CONF_DIR)    { $env:NVIM_CONF_DIR }    else { Join-Path $env:LOCALAPPDATA 'nvim' }),
  [string]$Branch = $(if ($env:NVIM_CONF_BRANCH) { $env:NVIM_CONF_BRANCH } else { 'com' }),
  [switch]$NoDeps,
  [switch]$Yes,
  [switch]$Uninstall,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

$RepoUrl      = if ($env:NVIM_CONF_REPO)   { $env:NVIM_CONF_REPO }   else { 'https://github.com/syloe1/nvim_Conf.git' }
$MirrorPrefix = if ($env:NVIM_CONF_MIRROR) { $env:NVIM_CONF_MIRROR } else { 'https://gh-proxy.com/' }

function Write-Log  ($m) { Write-Host "==> $m" -ForegroundColor Blue }
function Write-Warn ($m) { Write-Host "[warn] $m" -ForegroundColor Yellow }
function Write-Err  ($m) { Write-Host "[error] $m" -ForegroundColor Red }
function Have ($exe) { $null -ne (Get-Command $exe -ErrorAction SilentlyContinue) }

if ($Help) {
  Write-Host @'
One-command installer for syloe1/nvim_Conf.

Usage: install.ps1 [-Dir <path>] [-Branch <name>] [-NoDeps] [-Yes] [-Uninstall]

  -Dir <path>    install to <path> (default %LOCALAPPDATA%\nvim)
  -Branch <name> git branch to install (default com)
  -NoDeps        skip the optional winget dependency install
  -Yes           non-interactive
  -Uninstall     remove the config
'@
  exit 0
}

# --- uninstall -------------------------------------------------------------

if ($Uninstall) {
  Write-Log 'Uninstalling.'
  if (Test-Path $Dir) {
    Remove-Item -Recurse -Force $Dir
    Write-Log "Removed $Dir"
  }
  $dataDir  = Join-Path $env:LOCALAPPDATA 'nvim-data'
  $cacheDir = Join-Path $env:LOCALAPPDATA 'nvim-cache'
  $doMore = $Yes
  if (-not $Yes -and $Host.UI.RawUI) {
    $a = Read-Host "Also remove plugins/cache at $dataDir and $cacheDir? (y/N)"
    $doMore = ($a -match '^(y|yes)$')
  }
  if ($doMore) {
    foreach ($d in @($dataDir, $cacheDir)) {
      if (Test-Path $d) { Remove-Item -Recurse -Force $d; Write-Log "Removed $d" }
    }
  } else {
    Write-Warn "Kept the plugin/cache directories."
  }
  Write-Host "`nUninstalled.`n" -ForegroundColor Green
  exit 0
}

# --- preflight -------------------------------------------------------------

if (-not (Have git)) {
  Write-Err 'git is required but was not found. Install Git for Windows first.'
  exit 1
}

# --- place the configuration ----------------------------------------------

$Backup = $null
$isRepo = (Test-Path (Join-Path $Dir '.git')) -and
          ((git -C $Dir remote get-url origin 2>$null) -match 'nvim_Conf')

if ($isRepo) {
  Write-Log "Existing install detected at $Dir - updating."
  git -C $Dir pull --ff-only
  if ($LASTEXITCODE -ne 0) { Write-Warn 'Could not fast-forward; keeping the current checkout.' }
} elseif (Test-Path $Dir) {
  $Backup = "$Dir.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  Write-Log "Found an existing $Dir - backing it up to $Backup"
  Move-Item $Dir $Backup
}

if (-not (Test-Path (Join-Path $Dir '.git'))) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dir) | Out-Null
  Write-Log "Cloning configuration into $Dir (branch: $Branch)"
  if ($env:NVIM_CONF_REPO -or $env:NVIM_CONF_MIRROR) {
    git clone --branch $Branch $RepoUrl $Dir
  } else {
    git clone --branch $Branch $RepoUrl $Dir
    if ($LASTEXITCODE -ne 0) {
      Write-Warn "Direct GitHub clone failed - retrying via mirror ${MirrorPrefix} (third-party)."
      if (Test-Path $Dir) { Remove-Item -Recurse -Force $Dir }
      git clone --branch $Branch "$MirrorPrefix$RepoUrl" $Dir
    }
  }
  if ($LASTEXITCODE -ne 0) { Write-Err 'Clone failed. Check your network or set NVIM_CONF_MIRROR.'; exit 1 }
}

# --- ensure NeoVim ---------------------------------------------------------

if (-not (Have nvim)) {
  Write-Log 'NeoVim not found - attempting to install it via winget.'
  if (Have winget) {
    winget install --id Neovim.Neovim -e --accept-source-agreements --accept-package-agreements
    if (-not (Have nvim)) {
      Write-Warn 'NeoVim is not on PATH yet - open a NEW terminal after this finishes.'
    }
  } else {
    Write-Err 'Install NeoVim >= 0.10 manually: https://github.com/neovim/neovim/releases'
    exit 1
  }
}

# --- system dependencies (all optional) -----------------------------------

if (-not $NoDeps -and (Have winget)) {
  Write-Log 'Installing optional dependencies via winget (best effort).'
  $pkgs = @(
    @{ Id = 'LLVM.LLVM';            What = 'clangd (C/C++ LSP)' },
    @{ Id = 'GoLang.Go';            What = 'Go toolchain' },
    @{ Id = 'BurntSushi.ripgrep.MSVC'; What = 'ripgrep' },
    @{ Id = 'junegunn.fzf';         What = 'fzf' }
  )
  foreach ($p in $pkgs) {
    Write-Log "  $($p.What)"
    winget install --id $p.Id -e --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { Write-Warn "  $($p.Id) did not install - $($p.What) will be unavailable." }
  }
  if (Have go) {
    Write-Log 'Installing gopls.'
    go install golang.org/x/tools/gopls@latest
    if ($LASTEXITCODE -ne 0) { Write-Warn 'gopls install failed.' }
  }
  Write-Warn 'Clipboard sharing needs win32yank.exe on your PATH:'
  Write-Warn '  https://github.com/equalsraf/win32yank/releases'
} elseif (-not $NoDeps) {
  Write-Warn 'winget not found - skipping dependency install. Install clangd/ripgrep/node yourself.'
}

# --- install plugins -------------------------------------------------------

if (Have nvim) {
  Write-Log 'Installing plugins with lazy.nvim (first run can take a few minutes)...'
  & nvim --headless '+Lazy! sync' '+qa'
  if ($LASTEXITCODE -ne 0) {
    Write-Warn 'Plugin sync did not finish. Open nvim and run :Lazy sync - lazy.nvim also'
    Write-Warn 'installs anything missing on your first normal launch.'
  }

  Write-Log 'Building Tree-sitter parsers (c, cpp, go, lua)...'
  # Single-quoted Lua strings keep this argument free of double quotes, which
  # PowerShell 5.1 would otherwise mangle on the way to nvim.exe.
  & nvim --headless -c 'lua pcall(function() require(''nvim-treesitter'').install({''c'',''cpp'',''go'',''lua''}):wait(600000) end)' -c 'qa!'
  if ($LASTEXITCODE -ne 0) { Write-Warn 'Parser build skipped; run :TSUpdate inside nvim later.' }
} else {
  Write-Warn 'nvim is not on PATH in this session - open a new terminal, then run: nvim --headless "+Lazy! sync" +qa'
}

# --- summary ---------------------------------------------------------------

Write-Host ''
Write-Host 'Installed.' -ForegroundColor Green
Write-Host ''
Write-Host "  configuration : $Dir"
if ($Backup) { Write-Host "  backup        : $Backup" }
Write-Host @'

Next steps:
  * Run:  nvim
  * Install a Nerd Font (https://www.nerdfonts.com/) and select it in Windows
    Terminal for the file-type icons.
  * :Note (jump the current file between nvim and VS Code) and Ctrl+wheel zoom
    need Windows + VS Code; see README.md.
  * To update later, re-run this installer, or:  git -C <dir> pull
  * To uninstall:  install.ps1 -Uninstall
'@
if ($Backup) { Write-Host "  (or restore your previous config: Move-Item '$Backup' '$Dir')" }
Write-Host ''
