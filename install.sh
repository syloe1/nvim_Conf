#!/usr/bin/env bash
#
# One-command installer for syloe1/nvim_Conf,
# a NeoVim configuration derived from archibate/vimrc.
#
#   curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/main/install.sh | bash
#
# Options:
#   --dir <path>     install to <path> (default: ~/.config/nvim)
#   --branch <name>  git branch to install (default: main)
#   --no-deps        skip system dependency installation
#   --yes            non-interactive; skip the optional customization prompts
#   -h, --help       show this help

set -euo pipefail

REPO_URL="${NVIM_CONF_REPO:-https://github.com/syloe1/nvim_Conf.git}"
BRANCH="${NVIM_CONF_BRANCH:-main}"
DEST="${NVIM_CONF_DIR:-$HOME/.config/nvim}"
RUN_DEPS=1
ASSUME_YES=0

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
One-command installer for syloe1/nvim_Conf.

Usage: install.sh [options]

Options:
  --dir <path>     install to <path> (default: ~/.config/nvim)
  --branch <name>  git branch to install (default: main)
  --no-deps        skip system dependency installation
  --yes, -y        non-interactive; skip the optional customization prompts
  -h, --help       show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)     DEST="$2"; shift 2 ;;
    --branch)  BRANCH="$2"; shift 2 ;;
    --no-deps) RUN_DEPS=0; shift ;;
    --yes|-y)  ASSUME_YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

# --- preflight -------------------------------------------------------------

[ "$(id -u)" -eq 0 ] && die "Do not run as root — plugins would be installed for root, not for you."

command -v git >/dev/null 2>&1 || die "git is required but not found. Please install git first."
command -v curl >/dev/null 2>&1 || warn "curl not found; some dependency steps may fail."

case "$(uname -s)" in
  Linux)   PLATFORM=linux ;;
  Darwin)  PLATFORM=macos ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM=gitbash ;;
  *)       PLATFORM=unknown ;;
esac

if [ "$PLATFORM" = gitbash ]; then
  warn "Windows via Git Bash is only best-effort."
  warn "Native Windows NeoVim reads %LOCALAPPDATA%\\nvim, not $DEST."
  warn "For the best experience use WSL2 and run this installer inside it."
fi

run_timeout() {
  if command -v timeout  >/dev/null 2>&1; then timeout 1800 "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout 1800 "$@"
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
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$DEST"
else
  log "Cloning configuration into $DEST"
  mkdir -p "$(dirname "$DEST")"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$DEST"
fi

# --- ensure NeoVim ---------------------------------------------------------

if ! command -v nvim >/dev/null 2>&1; then
  log "NeoVim not found — attempting to install it."
  if [ "$PLATFORM" = macos ] && command -v brew >/dev/null 2>&1; then
    brew install neovim
  elif [ "$PLATFORM" = linux ] && [ -f "$DEST/scripts/install_nvim.sh" ]; then
    bash "$DEST/scripts/install_nvim.sh" || warn "Automatic NeoVim install failed; see https://github.com/neovim/neovim/wiki/Installing-Neovim"
  else
    die "Please install NeoVim >= 0.9 manually: https://github.com/neovim/neovim/wiki/Installing-Neovim"
  fi
fi

# --- system dependencies ---------------------------------------------------

if [ "$RUN_DEPS" = 1 ] && [ -f "$DEST/scripts/install_deps.sh" ] && [ "$PLATFORM" != gitbash ]; then
  log "Installing system dependencies (clangd, ripgrep, fzf, ...). This needs sudo."
  ( cd "$DEST" && bash scripts/install_deps.sh ) || warn "Some dependencies failed to install; the editor still works, but LSP/formatting for some languages may be limited."
elif [ "$PLATFORM" = gitbash ]; then
  warn "Skipping automatic dependency install on Git Bash — install clangd/ripgrep/fzf/nodejs yourself, or use WSL2."
fi

# --- install plugins -------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
  log "Bootstrapping packer and installing plugins (this can take a few minutes)..."
  if ! run_timeout nvim --headless \
        -c 'autocmd User PackerComplete ++once quitall' \
        -c 'PackerSync'; then
    warn "Automatic plugin install did not finish. Plugins will also be installed on your first normal launch;"
    warn "or open nvim and run :PackerSync."
  fi

  log "Compiling plugin loader and building treesitter parsers..."
  run_timeout nvim --headless \
    -c 'PackerCompile' \
    -c 'lua pcall(vim.cmd, "TSUpdateSync")' \
    -c 'qa!' || warn "Treesitter parser build was skipped; run :TSUpdateSync inside nvim later."
fi

# --- optional customization ------------------------------------------------

if [ "$ASSUME_YES" = 0 ] && [ -t 0 ] && [ -f "$DEST/scripts/customize_settings.sh" ]; then
  log "Starting optional customization (press Ctrl-C to skip)..."
  ( cd "$DEST" && bash scripts/customize_settings.sh ) || warn "Customization skipped; defaults will be used."
fi

# --- summary ---------------------------------------------------------------

printf '\n\033[1;32m✓ Installed.\033[0m\n\n'
printf '  configuration : %s\n' "$DEST"
if [ -n "$BACKUP" ]; then
  printf '  backup        : %s\n' "$BACKUP"
fi
cat <<EOF

Next steps:
  * Run:  nvim
  * For file-type icons, install a Nerd Font (https://www.nerdfonts.com/)
    and set it in your terminal.
  * To update later, re-run this installer, or:  git -C "$DEST" pull
  * To uninstall:  rm -rf "$DEST" ~/.local/share/nvim ~/.cache/nvim
EOF
if [ -n "$BACKUP" ]; then
  printf '    (or restore your previous config: mv "%s" "%s")\n' "$BACKUP" "$DEST"
fi
printf '\n'
