# nvim_Conf

**English** | [中文](README.md)

My personal NeoVim config, **hand-written and single-file** — one `init.lua`, plugins managed
by lazy.nvim. Small enough to read in one sitting, easy to extend: adding a plugin means adding
one block, not digging through a module tree.

> This repo has two branches — don't take the wrong one:
>
> | Branch | Contents |
> | --- | --- |
> | **`com`** | 👈 **this one**, my own hand-written minimal config |
> | `main` | a derivative of [archibate/vimrc](https://github.com/archibate/vimrc) — featureful but heavy |
>
> Every install command below points at the `com` branch.

> Screenshot placeholder: replace with `cover.png` and reference it here.

## Features

- **LSP**: `clangd` (C/C++) and `gopls` (Go) wired up out of the box — goto definition/declaration/
  reference/implementation, hover, rename, code actions.
- **Completion**: `nvim-cmp` sourcing from LSP + current buffer + file paths, rounded borders,
  `<Tab>` to navigate and `<CR>` to confirm.
- **Syntax highlighting**: `nvim-treesitter` with parsers for `c` / `cpp` / `go` / `lua`.
- **File tree**: `nvim-tree`, synced with the working directory and focused on the current file.
- **Search**: `telescope` — files, live grep and symbols, all behind `<leader>`.
- **Editing**: `nvim-autopairs` (integrated with completion confirm), `guess-indent`.
- **Looks**: `tokyonight` (night) + `nvim-web-devicons`.
- **`:Note`**: bounce the current file between nvim and VS Code without losing the cursor.
  Windows only — see below.
- **Ctrl + wheel**: zoom the terminal font. Windows Terminal only — see below.

## Install

**Linux / macOS / WSL2** (backs up any existing `~/.config/nvim` first):

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.sh | bash
```

**Native Windows** (PowerShell, installs to `%LOCALAPPDATA%\nvim`):

```powershell
irm https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.ps1 | iex
```

The script backs up your old config, clones this one, installs NeoVim if it is missing, installs
system dependencies (best effort — a failure only warns), then installs plugins and builds
Tree-sitter parsers headlessly. When it is done, just run `nvim`.

Prefer to look before you leap:

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.sh -o install.sh
less install.sh        # read it
bash install.sh
```

### Options

| Script | Option | Effect |
| --- | --- | --- |
| `install.sh` | `--dir <path>` | install elsewhere (default `~/.config/nvim`) |
| | `--branch <name>` | use another branch (default `com`) |
| | `--no-deps` | skip system dependency installation |
| | `--yes` | non-interactive |
| | `--uninstall` | remove the config |
| `install.ps1` | `-Dir` / `-Branch` / `-NoDeps` / `-Yes` / `-Uninstall` | as above |

Environment variables work too: `NVIM_CONF_DIR`, `NVIM_CONF_BRANCH`, `NVIM_CONF_REPO`, `NVIM_CONF_MIRROR`.

### Behind a restrictive network (China)

If `raw.githubusercontent.com` / `github.com` is unreachable, fetch the script via jsDelivr:

```bash
curl -SLf https://cdn.jsdelivr.net/gh/syloe1/nvim_Conf@com/install.sh | bash
```

- If the direct clone of github.com fails, the script retries through the `gh-proxy.com` mirror.
  Point `NVIM_CONF_MIRROR` at another mirror, or set `NVIM_CONF_REPO` to bypass the fallback.
- **The plugins come from GitHub too.** If they will not download, route git through a mirror:

  ```bash
  git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"
  ```

  then run `:Lazy sync` inside nvim. Undo with
  `git config --global --unset url."https://gh-proxy.com/https://github.com/".insteadOf`.

## Keymaps

`<leader>` is **Space**.

| What | Keys |
| --- | --- |
| File tree | `<leader>e` toggle · `<leader>r` refresh |
| Search | `<leader>f` files · `<leader>g` live grep · `<leader>s` document symbols · `<leader>w` workspace symbols |
| LSP | `gd` / `<F12>` definition · `gD` declaration · `gr` references · `gi` implementation · `K` hover · `<leader>rn` rename · `<leader>ca` code action |
| Movement | `<A-,>` jump back · `Ctrl+LeftClick` goto definition |
| Format | `==` reindent line · `<leader>=` format whole file |
| Completion | `<Tab>` / `<S-Tab>` select · `<CR>` confirm · `<C-Space>` trigger · `<Esc>` cancel |
| Autopairs | typing `(` `{` `[` closes itself · `<M-e>` wrap existing text |

Everything lives in [`init.lua`](init.lua) — edit it directly.

## The two party tricks

### `:Note` — bounce between nvim and VS Code

`:Note` opens the current file in VS Code at the same line and column; running it again closes
that VS Code window and puts the terminal back in front. Lowercase `:note` works too.

- first `:Note` → open the current file in VS Code at the same position
- second `:Note` → close that VS Code window, focus the terminal; the file is reloaded if it
  changed over there

It relies on [`note-toggle.ps1`](note-toggle.ps1) sitting next to `init.lua`, which does the
window finding/closing/activating. **Why a script at all**: modern VS Code runs one main process
hosting every window, so all its windows share a pid — only the window handle (HWND) is unique.
Before closing, the script re-checks that the handle still belongs to `Code.exe` *and* that its
title names the file, so a stale handle can never close one of your other VS Code windows.

Tune it via the `NOTE` table at the top of `init.lua`: `reuse_window` (default off),
`autosave` (default on), `reload` (default on), `timeout_ms`.

> Windows only: the whole block is guarded by `vim.fn.has("win32")`, so other platforms never
> register the command.

### Ctrl + wheel to zoom

In Windows Terminal, `Ctrl + wheel` zooms the font.

Why it needs Lua at all: WT has this built in, but it has to *receive* the wheel event first —
with `mouse=a` set, nvim swallows it and WT never sees anything. And nvim cannot resize the
terminal font itself (there is no escape sequence for that). So the config translates the
`Ctrl+wheel` nvim receives into a synthetic `Ctrl+=` / `Ctrl+-` pair — WT's window-level
shortcuts, which nvim cannot intercept — using LuaJIT FFI to call `user32!keybd_event` directly,
so there is no process fork and no lag.

> Windows only: `ffi.load("user32")` fails elsewhere, so the whole block is skipped there.

## Dependencies

The installer tries to install all of these. A missing one only costs you that specific
capability — the editor still works.

| Dependency | For | Without it |
| --- | --- | --- |
| **NeoVim ≥ 0.10** (0.11+ recommended) | the editor itself | required |
| **git** | lazy.nvim cloning itself on first launch | required |
| **clangd** | C/C++ LSP | no C/C++ completion or navigation |
| **gopls** | Go LSP | no Go completion or navigation |
| **ripgrep** | `<leader>g` live grep | no content search |
| **Nerd Font** | file icons | icons render as boxes |
| **win32yank.exe** (Windows) | system clipboard | copy/paste stays inside nvim |
| **xclip / wl-clipboard** (Linux) | same | same |

Install a Nerd Font (JetBrainsMono Nerd Font recommended) and select it in your terminal — no
config change needed.

## Platform support

| Platform | Support | Notes |
| --- | --- | --- |
| Linux (Ubuntu / Debian / Arch / Fedora / openSUSE…) | ✅ full | `install.sh` uses your package manager for dependencies |
| macOS | ✅ full | dependencies via Homebrew; `clangd` ships in `brew install llvm` and needs a PATH tweak (the script prints it) |
| Windows + WSL2 | ✅ recommended | use it exactly like Linux |
| Native Windows | ✅ full | use `install.ps1`; `:Note` and Ctrl+wheel zoom only work here |
| Windows + Git Bash | ⚠️ best effort | the config gets placed, but you install dependencies yourself; native nvim reads `%LOCALAPPDATA%\nvim`, not `~/.config/nvim` |

## Layout

```
init.lua          the whole config
note-toggle.ps1   Windows helper for :Note
lazy-lock.json    pinned plugin revisions — same versions the author runs
install.sh        Linux / macOS / WSL installer
install.ps1       Windows installer
```

## Updating / uninstalling

The config is a git clone, so updating is a pull:

```bash
git -C ~/.config/nvim pull
```

or just re-run the installer. Run `:Lazy sync` to move plugins to the pinned revisions.

Uninstall:

```bash
bash ~/.config/nvim/install.sh --uninstall      # or install.ps1 -Uninstall
```

It removes the config directory and asks whether to remove plugins/cache as well. If your old
config was backed up during install, it sits at `~/.config/nvim.bak.<timestamp>` — restore it
with `mv`.

## FAQ

- **Icons are boxes?** Install a Nerd Font and select it in your terminal.
- **No LSP completion?** Check `clangd` / `gopls` are on `PATH` (`clangd --version` works).
  Inside nvim, `:LspInfo` shows the state.
- **`:Note` cannot find the script?** Make sure `note-toggle.ps1` sits next to `init.lua`
  (a normal install keeps them together) and that `powershell` is on `PATH`.
- **`:Note` says it found no window handle?** Usually VS Code started slower than `timeout_ms`;
  raise the timeout.
- **Adding a plugin?** Add an entry to `require("lazy").setup({...})` in `init.lua`, then reopen
  nvim or `:Lazy sync`.
- **Plugins missing?** `:Lazy sync`.

## Credits & license

A personal config — **all rights reserved** by default, but feel free to read it and borrow
snippets. No open-source license is attached; ask the author before redistributing.

(The archibate/vimrc derivative on `main` is the upstream author's — unrelated to this branch.)
