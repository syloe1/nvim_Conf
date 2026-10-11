# nvim_Conf

**English** | [中文](README.md)

My personal NeoVim configuration: smart completion, LSP, Tree-sitter highlighting, fuzzy search, file explorer, integrated terminal, Git integration — all pure Lua, ready to use out of the box.

Derived from [archibate/vimrc](https://github.com/archibate/vimrc).

> Screenshot placeholder — capture your own terminal, save it as `cover.png`, and reference it here.

## Features

- **Completion**: `nvim-cmp` + `LuaSnip` snippets, combining LSP / buffer / path / Git sources; supports Chinese input methods (rime / pinyin), emoji, calculator, and spell checking.
- **LSP**: servers managed by `mason` (`clangd` / `pyright` / `lua_ls` / `typescript` / `cmake` / `rust` …) for go-to definition/declaration/references/implementation, rename, code actions, signature help, and live diagnostics.
- **Syntax highlighting & text objects**: `nvim-treesitter` highlighting, indentation, rainbow brackets, context; `textobjects` for selecting / jumping / swapping by syntax node.
- **Fuzzy search**: `telescope` — files, recent files, cross-file grep, Git commits and branches, command history, help docs; everything is fuzzy-findable.
- **File tree & outline**: `nvim-tree` explorer, `aerial` symbol outline.
- **Git**: `neogit` panel, `gitsigns` inline markers, `diffview`, `fugitive`.
- **Debugging**: `nvim-dap` + `dap-ui` for breakpoints and stepping.
- **Terminal & one-key run**: `toggleterm` built-in terminal; `<F5>` to build/run.
- **C/C++ friendly**: `cmake-tools` integration (`cm c/b/r`), `clangd` header/source switching, `QuickFix` build errors.
- **Editing**: `surround`, auto-pairing/closing, multi-cursor (`vim-visual-multi`), quick comments, `hop` jumps, marks.
- **UI**: `catppuccin` / `tokyonight` themes, `lualine` statusline, `bufferline` tabs, `noice` / `notify` messages, `which-key` hints, `scrollbar`.
- **Markdown / typesetting**: render enhancements, `markdown-preview`, `mathjax`, image paste.
- **Sessions & persistence**: `auto-session` restore, `undotree`, autosave.
- **AI assistants (optional, bring your own API key)**: `genius` / `gpt` / `avante` / `codeium` / `opencode`, e.g. with DeepSeek.

> The full keybinding reference is in [`scripts/key_details.md`](scripts/key_details.md) (written in Chinese).

## Keybindings cheat sheet

| Context | Keys |
| --- | --- |
| Basics | `jk` / `kj` back to normal · `q` save & close window · `Q` record macro · `gh` / `gl` line start/end · `gm` line middle · `<F4>` save all · `<C-Insert>` / `<S-Insert>` copy/paste |
| Panels | `<F12>` outline · `<F10>` Git panel · `<F9>` diagnostics · `<F8>` terminal · `<F7>` file tree · `<F6>` build errors · `<F5>` run |
| Tabs | `<F3>` / `gt` next · `<F2>` / `gb` previous · `<F1>` / `g<Tab>` pin · `<S-F1>` close |
| Windows | `<C-h/j/k/l>` switch · `<M-s>` / `<M-v>` split · `<M-h/j/k/l>` resize |
| LSP | `gd` definition · `gD` declaration · `gr` references · `gY` implementation · `gy` type definition · `gss` diagnostics · `go` switch header/source |
| Search (all start with `,`) | `,l` files · `,o` recent files · `,b` buffers · `,k` global grep · `,c` Git history · `,v` branches · `,m` marks · `,a` diagnostics |
| Build | `cmc` configure · `cmb` build · `cmr` / `<F5>` run · `cms` / `<S-F5>` stop |

Keymaps can be changed in [`lua/archvim/mappings.lua`](lua/archvim/mappings.lua).

## Install (one command)

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/main/install.sh | bash
```

The script will: back up your existing `~/.config/nvim` (if any) → clone this configuration → install system dependencies → bootstrap packer and download plugins. Then just run `nvim`.

Safer alternative (download, read, then run):

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/main/install.sh -o install.sh
less install.sh        # review the script
bash install.sh
```

Useful flags: `--dir <path>` install location, `--no-deps` skip system dependencies, `--yes` fully non-interactive, `--help` for help.

### Restricted networks (e.g. mainland China)

If `raw.githubusercontent.com` / `github.com` are unreachable, fetch the script via the jsDelivr mirror:

```bash
curl -SLf https://cdn.jsdelivr.net/gh/syloe1/nvim_Conf@main/install.sh | bash
```

- If cloning over github.com fails, the script automatically retries via the `gh-proxy.com` mirror (set `NVIM_CONF_MIRROR` for a different mirror, or `NVIM_CONF_REPO=<your URL>` directly).
- **Plugins themselves also come from GitHub.** If plugin downloads stall, route git through a mirror before installing:

  ```bash
  git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"
  ```

  Then run `:PackerSync` inside nvim. To undo: `git config --global --unset url."https://gh-proxy.com/https://github.com/".insteadOf`.

## Platform support

| Platform | Support | Notes |
| --- | --- | --- |
| Linux (Ubuntu / Debian / Arch / Manjaro / Fedora / openSUSE / CentOS, …) | ✅ Full | One command; dependencies installed via the system package manager |
| macOS | ✅ Full | Dependencies installed via Homebrew (no sudo) |
| Windows + WSL2 | ✅ Recommended | Use it like Linux inside WSL — the best experience |
| Windows + Git Bash | ⚠️ Best-effort | The script can place the config, but you must install system dependencies yourself; native Windows NeoVim reads `%LOCALAPPDATA%\nvim` by default, so `XDG_CONFIG_HOME` must be set |
| Native Windows (cmd / PowerShell) | ❌ Not supported | Toolchain and path differences are too large; use WSL2 instead |

## Dependencies

The installer tries to install these automatically (`clangd`, `ripgrep`, `fzf`, `cmake`, `make`, `gcc`, `python3`, `nodejs/npm`, …). If some fail, the editor still works — only completion/formatting for the affected languages is limited. You can re-run it anytime:

```bash
~/.config/nvim/scripts/install_deps.sh
```

## Icons & fonts

If file icons show up as boxes/garbage, you're missing a Nerd Font. Install one (JetBrainsMono Nerd Font recommended), enable it in your terminal, then:

```vim
:lua require'archvim.options'.nerd_fonts = true
```

## Customization

```bash
~/.config/nvim/scripts/customize_settings.sh
```

It interactively asks a few preferences (transparency, inlay hints, clipboard sharing, Kitty image support, …) and writes them to `~/.local/share/nvim/archvim/opts.json`. Re-run anytime to change them.

## Update

Re-run the one-command installer; or:

```bash
git -C ~/.config/nvim pull
nvim                                          # then run :PackerSync inside
```

## Uninstall / rollback

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
```

If a backup was made during install, it's at `~/.config/nvim.bak.<timestamp>` — restore it with `mv`.

## Attribution & license

This configuration is a derivative of [archibate/vimrc](https://github.com/archibate/vimrc). The upstream repository **declares no license**, so this repository ships none either; it is shared for personal and educational use only, and the copyright of upstream code belongs to its original author. If you intend to redistribute or use it commercially, please contact the upstream author first.

## FAQ

- **Plugins missing?** Open nvim and run `:PackerSync`.
- **No LSP / syntax highlighting?** Run `scripts/install_deps.sh`, then `:TSUpdateSync` inside nvim.
- **Don't want some plugins, or want to add one?** Edit the `plugins` list in `lua/archvim/plugins.lua`, then `:PackerSync`.
