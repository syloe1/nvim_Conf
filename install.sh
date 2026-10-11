#!/usr/bin/env bash
#
# One-command installer for syloe1/nvim_Conf (com branch):
# a small hand-written NeoVim config, plugins managed by lazy.nvim.
#
#   curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.sh | bash
#
# Options:
#   --dir <path>      install to <path> (default: ${XDG_CONFIG_HOME:-$HOME/.config}/nvim)
#   --branch <name>   git branch to install (default: com)
#   --no-deps         skip system dependency installation
#   --yes, -y         non-interactive; assume yes for every prompt
#   --uninstall       remove the config (and, when confirmed, its data/cache)
#   -h, --help        show this help

set -euo pipefail

REPO_URL="${NVIM_CONF_REPO:-https://github.com/syloe1/nvim_Conf.git}"
BRANCH="${NVIM_CONF_BRANCH:-com}"
DEST="${NVIM_CONF_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/nvim}"
# Third-party GitHub mirror used only when github.com itself is unreachable.
MIRROR_PREFIX="${NVIM_CONF_MIRROR:-https://gh-proxy.com/}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
RUN_DEPS=1
ASSUME_YES=0
DO_UNINSTALL=0

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<'USAGE'
One-command installer for syloe1/nvim_Conf.

Usage: install.sh [options]

Options:
  --dir <path>      install to <path> (default: ${XDG_CONFIG_HOME:-$HOME/.config}/nvim)
  --branch <name>   git branch to install (default: com)
  --no-deps         skip system dependency installation
  --yes, -y         non-interactive; assume yes for every prompt
  --uninstall       remove the config (and, when confirmed, its data/cache)
  -h, --help        show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)       DEST="$2"; shift 2 ;;
    --branch)    BRANCH="$2"; shift 2 ;;
    --no-deps)   RUN_DEPS=0; shift ;;
    --yes|-y)    ASSUME_YES=1; shift ;;
    --uninstall) DO_UNINSTALL=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           die "unknown option: $1 (try --help)" ;;
  esac
done

confirm() {
  [ "$ASSUME_YES" = 1 ] && return 0
  [ -t 0 ] || return 0
  printf '\033[1;33m?\033[0m %s [y/N] ' "$1"
  read -r reply
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# --- preflight -------------------------------------------------------------

[ "$(id -u)" -eq 0 ] && die "Do not run as root — plugins would be installed for root, not for you."

case "$(uname -s)" in
  Linux)   PLATFORM=linux ;;
  Darwin)  PLATFORM=macos ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM=gitbash ;;
  *)       PLATFORM=unknown ;;
esac

if [ "$PLATFORM" = gitbash ]; then
  warn "Git Bash is only best-effort: native Windows NeoVim reads %LOCALAPPDATA%\\nvim,"
  warn "not $DEST. Use install.ps1 for native Windows, or WSL2 for the best experience."
fi

# --- uninstall -------------------------------------------------------------

if [ "$DO_UNINSTALL" = 1 ]; then
  log "Uninstalling."
  [ -e "$DEST" ] && rm -rf "$DEST" && log "Removed $DEST"
  if [ -d "$DATA_DIR" ] || [ -d "$CACHE_DIR" ]; then
    if confirm "Also remove plugins/cache at $DATA_DIR and $CACHE_DIR? (affects every NeoVim config on this machine)"; then
      rm -rf "$DATA_DIR" "$CACHE_DIR"
      log "Removed $DATA_DIR and $CACHE_DIR"
    else
      warn "Kept $DATA_DIR and $CACHE_DIR — remove them yourself if you want a clean slate."
    fi
  fi
  printf '\n\033[1;32m✓ Uninstalled.\033[0m\n\n'
  exit 0
fi

have git || die "git is required but not found. Install git first."
have curl || warn "curl not found; some steps may fail."

# Cap runaway downloads (plugin sync on a slow link) without depending on GNU timeout.
run_timeout() {
  if have timeout;  then timeout 1800 "$@"
  elif have gtimeout; then gtimeout 1800 "$@"
  else "$@"; fi
}

# --- place the configuration ----------------------------------------------

BACKUP=""
if [ -d "$DEST/.git" ] && git -C "$DEST" remote get-url origin 2>/dev/null | grep -q 'nvim_Conf'; then
  log "Existing install detected at $DEST — updating."
  git -C "$DEST" pull --ff-only || warn "Could not fast-forward; keeping the current checkout."
elif [ -e "$DEST" ]; then
  BACKUP="$DEST.bak.$(date +%Y%m%d-%H%M%S)"
  log "Found an existing $DEST — backing it up to $BACKUP"
  mv "$DEST" "$BACKUP"
fi

# Clone the repo, falling back to a GitHub mirror when github.com is unreachable
# (common on some networks in China). A custom NVIM_CONF_REPO/MIRROR disables the fallback.
if [ ! -d "$DEST/.git" ]; then
  mkdir -p "$(dirname "$DEST")"
  log "Cloning configuration into $DEST (branch: $BRANCH)"
  if [ -n "${NVIM_CONF_REPO:-}" ] || [ -n "${NVIM_CONF_MIRROR:-}" ]; then
    git clone --branch "$BRANCH" "$REPO_URL" "$DEST"
  elif ! git clone --branch "$BRANCH" "$REPO_URL" "$DEST"; then
    warn "Direct GitHub clone failed — retrying via mirror ${MIRROR_PREFIX} (third-party)."
    rm -rf "$DEST"
    git clone --branch "$BRANCH" "${MIRROR_PREFIX}${REPO_URL}" "$DEST"
  fi
fi

# --- ensure NeoVim ---------------------------------------------------------

if ! have nvim; then
  log "NeoVim not found — attempting to install it."
  if [ "$PLATFORM" = macos ] && have brew; then
    brew install neovim
  elif [ "$PLATFORM" = linux ] && have apt-get; then
    sudo apt-get update -qq && sudo apt-get install -y neovim
  elif [ "$PLATFORM" = linux ] && have pacman; then
    sudo pacman -S --noconfirm neovim
  elif [ "$PLATFORM" = linux ] && have dnf; then
    sudo dnf install -y neovim
  else
    die "Please install NeoVim >= 0.10 manually: https://github.com/neovim/neovim/wiki/Installing-Neovim"
  fi
fi

# --- system dependencies ---------------------------------------------------

# Everything here is optional: a missing tool only costs you LSP or formatting
# for one language, so failures are warnings, never fatal.
pkg_install() {
  # $@ = candidate package names; installs the first one the package manager knows.
  local pm="$1"; shift
  local p
  for p in "$@"; do
    case "$pm" in
      apt)
        if apt-cache show "$p" >/dev/null 2>&1; then
          sudo apt-get install -y "$p" && return 0
        fi ;;
      pacman) sudo pacman -S --noconfirm "$p" && return 0 ;;
      dnf)    sudo dnf install -y "$p" && return 0 ;;
      zypper) sudo zypper --non-interactive install "$p" && return 0 ;;
      brew)   brew install "$p" && return 0 ;;
    esac
  done
  return 1
}

install_deps() {
  local pm=""
  if   have apt-get; then pm=apt;    sudo apt-get update -qq || true
  elif have pacman;  then pm=pacman
  elif have dnf;     then pm=dnf
  elif have zypper;  then pm=zypper
  elif [ "$PLATFORM" = macos ] && have brew; then pm=brew
  else warn "No supported package manager found — install clangd/ripgrep/fd/node/gopls yourself."; return 0
  fi

  log "Installing dependencies with $pm (best effort, needs sudo)."

  case "$pm" in
    apt)
      pkg_install "$pm" clangd clang            || warn "clangd not installed — C/C++ LSP will be off."
      pkg_install "$pm" ripgrep                 || warn "ripgrep not installed — Telescope live_grep will be off."
      pkg_install "$pm" fd-find fd              || warn "fd not installed."
      pkg_install "$pm" nodejs                  || warn "nodejs not installed."
      pkg_install "$pm" npm                     || warn "npm not installed."
      pkg_install "$pm" golang-go               || warn "go not installed."
      pkg_install "$pm" gopls                   || warn "gopls not installed — run: go install golang.org/x/tools/gopls@latest"
      pkg_install "$pm" xclip wl-clipboard      || warn "no clipboard tool — install xclip (X11) or wl-clipboard (Wayland)."
      ;;
    pacman)
      pkg_install "$pm" clang                   || warn "clang not installed — C/C++ LSP will be off."
      pkg_install "$pm" ripgrep                 || warn "ripgrep not installed."
      pkg_install "$pm" fd                      || warn "fd not installed."
      pkg_install "$pm" nodejs                  || warn "nodejs not installed."
      pkg_install "$pm" npm                     || warn "npm not installed."
      pkg_install "$pm" gopls                   || warn "gopls not installed."
      pkg_install "$pm" xclip wl-clipboard      || warn "no clipboard tool installed."
      ;;
    dnf)
      pkg_install "$pm" clang-tools-extra clang || warn "clangd not installed — C/C++ LSP will be off."
      pkg_install "$pm" ripgrep                 || warn "ripgrep not installed."
      pkg_install "$pm" fd-find fd              || warn "fd not installed."
      pkg_install "$pm" nodejs                  || warn "nodejs not installed."
      pkg_install "$pm" npm                     || warn "npm not installed."
      pkg_install "$pm" golang-x-tools-gopls gopls || warn "gopls not installed."
      pkg_install "$pm" xclip wl-clipboard      || warn "no clipboard tool installed."
      ;;
    zypper)
      pkg_install "$pm" clang                   || warn "clang not installed — C/C++ LSP will be off."
      pkg_install "$pm" ripgrep                 || warn "ripgrep not installed."
      pkg_install "$pm" fd                      || warn "fd not installed."
      pkg_install "$pm" nodejs                  || warn "nodejs not installed."
      pkg_install "$pm" npm                     || warn "npm not installed."
      pkg_install "$pm" gopls                   || warn "gopls not installed."
      pkg_install "$pm" xclip wl-clipboard      || warn "no clipboard tool installed."
      ;;
    brew)
      pkg_install "$pm" llvm                    || warn "llvm not installed — clangd lives in it."
      pkg_install "$pm" ripgrep                 || warn "ripgrep not installed."
      pkg_install "$pm" fd                      || warn "fd not installed."
      pkg_install "$pm" node                    || warn "node not installed."
      if pkg_install "$pm" go; then
        go install golang.org/x/tools/gopls@latest || warn "gopls install failed."
      else
        warn "go not installed — skipping gopls."
      fi
      warn "macOS: add Homebrew's llvm to PATH so 'clangd' is found:"
      warn "  echo 'export PATH=\"\$(brew --prefix llvm)/bin:\$PATH\"' >> ~/.zshrc"
      ;;
  esac
}

if [ "$RUN_DEPS" = 1 ] && [ "$PLATFORM" != gitbash ]; then
  install_deps
elif [ "$PLATFORM" = gitbash ]; then
  warn "Skipping dependency install on Git Bash — install clangd/ripgrep/node yourself, or use WSL2."
fi

# --- install plugins -------------------------------------------------------

if have nvim; then
  log "Installing plugins with lazy.nvim (first run can take a few minutes)..."
  if ! run_timeout nvim --headless "+Lazy! sync" +qa; then
    warn "Plugin sync did not finish. Open nvim and run :Lazy sync, or just start nvim —"
    warn "lazy.nvim also installs anything missing on your first normal launch."
  fi

  log "Building Tree-sitter parsers (c, cpp, go, lua)..."
  # The modern nvim-treesitter API returns a promise; :wait blocks until done.
  # pcall keeps this harmless on an older/newer API — parsers then install on first launch.
  run_timeout nvim --headless \
    -c 'lua pcall(function() require("nvim-treesitter").install({"c","cpp","go","lua"}):wait(600000) end)' \
    -c 'qa!' || warn "Parser build skipped; run :TSUpdate inside nvim later."
fi

# --- summary ---------------------------------------------------------------

printf '\n\033[1;32m✓ Installed.\033[0m\n\n'
printf '  configuration : %s\n' "$DEST"
[ -n "$BACKUP" ] && printf '  backup        : %s\n' "$BACKUP"
cat <<EOF

Next steps:
  * Run:  nvim
  * For the file-type icons, install a Nerd Font (https://www.nerdfonts.com/)
    and select it in your terminal.
  * :Note (jump the current file between nvim and VS Code) is Windows-only.
  * To update later, re-run this installer, or:  git -C "$DEST" pull
  * To uninstall:  bash "$DEST/install.sh" --uninstall
EOF
if [ -n "$BACKUP" ]; then
  printf '    (or restore your previous config: mv "%s" "%s")\n' "$BACKUP" "$DEST"
fi
printf '\n'
