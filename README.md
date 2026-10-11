# nvim_Conf

[English](README.en.md) | **中文**

我自用的一套 NeoVim 配置：智能补全、LSP、Tree-sitter 语法高亮、全局搜索、文件浏览、集成终端、Git 集成等，纯 Lua 配置，开箱即用。

本配置基于 [archibate/vimrc](https://github.com/archibate/vimrc)（“小彭老师自用 NeoVim 整合包”）修改而来。

> 截图占位：欢迎在真实终端截图后，替换成 `cover.png` 并在此处引用。

## 功能亮点

- **智能补全**：`nvim-cmp` + `LuaSnip` 代码片段，整合 LSP / 缓冲区 / 路径 / Git 补全；支持中文输入法（rime / 拼音）、emoji、计算器、拼写。
- **LSP 语言服务**：`mason` 统一管理服务器（`clangd` / `pyright` / `lua_ls` / `typescript` / `cmake` / `rust` …），提供跳转定义/声明/引用/实现、重命名、代码操作、签名帮助、实时诊断。
- **语法高亮与文本对象**：`nvim-treesitter` 高亮、缩进、彩虹括号、上下文；`textobjects` 支持按语法块选择 / 跳转 / 换位。
- **全局搜索**：`telescope` —— 文件、最近文件、跨文件 grep、Git 提交与分支、命令历史、帮助文档等，一切皆可模糊查找。
- **文件树与大纲**：`nvim-tree` 文件树、`aerial` 符号大纲。
- **Git 集成**：`neogit` 面板、`gitsigns` 行内标记、`diffview`、`fugitive`。
- **调试**：`nvim-dap` + `dap-ui`，断点与单步。
- **终端与一键运行**：`toggleterm` 内置终端；`<F5>` 一键构建/运行。
- **C/C++ 友好**：`cmake-tools` 集成（`cmc/b/r`），`clangd` 切换头/源文件，`QuickFix` 编译错误列表。
- **编辑增强**：`surround` 括号环绕、自动配对/闭合、多光标（`vim-visual-multi`）、快速注释、`hop` 跳转、标记。
- **界面**：`catppuccin` / `tokyonight` 主题、`lualine` 状态栏、`bufferline` 标签页、`noice` / `notify` 消息、`which-key` 键位提示、`scrollbar` 滚动条。
- **Markdown / 排版**：渲染增强、`markdown-preview` 预览、`mathjax`、图片粘贴。
- **会话与持久化**：`auto-session` 自动恢复、`undotree`、自动保存。
- **AI 辅助（可选，需自备 API key）**：`genius` / `gpt` / `avante` / `codeium` / `opencode`，可接 DeepSeek 等。

> 完整键位说明见 [`scripts/key_details.md`](scripts/key_details.md)。

## 常用快捷键速查

| 场景 | 按键 |
| --- | --- |
| 基础 | `jk` / `kj` 回普通模式 · `q` 保存并关窗 · `Q` 录宏 · `gh` / `gl` 行首/行尾 · `gm` 行中 · `<F4>` 保存全部 · `<C-Insert>` / `<S-Insert>` 复制/粘贴 |
| 功能窗口 | `<F12>` 大纲 · `<F10>` Git 面板 · `<F9>` 诊断 · `<F8>` 终端 · `<F7>` 文件树 · `<F6>` 编译错误 · `<F5>` 运行 |
| 标签页 | `<F3>` / `gt` 下一个 · `<F2>` / `gb` 上一个 · `<F1>` / `g<Tab>` 固定 · `<S-F1>` 关闭 |
| 窗口 | `<C-h/j/k/l>` 切换 · `<M-s>` / `<M-v>` 分屏 · `<M-h/j/k/l>` 调整大小 |
| LSP | `gd` 定义 · `gD` 声明 · `gr` 引用 · `gY` 实现 · `gy` 类型定义 · `gss` 诊断 · `go` 切换头/源文件 |
| 搜索（均以 `,` 开头） | `,l` 文件 · `,o` 最近文件 · `,b` 缓冲区 · `,k` 全局 grep · `,c` Git 历史 · `,v` 分支 · `,m` 标记 · `,a` 诊断 |
| 构建 | `cmc` 配置 · `cmb` 构建 · `cmr` / `<F5>` 运行 · `cms` / `<S-F5>` 停止 |

键位都可在 [`lua/archvim/mappings.lua`](lua/archvim/mappings.lua) 中修改。

## 一键安装

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/main/install.sh | bash
```

脚本会自动：备份你已有的 `~/.config/nvim`（如果有）→ 克隆本配置 → 安装系统依赖 → 引导 packer 并下载插件。装完直接输入 `nvim` 即可。

更稳妥的做法（先下载、看一眼、再执行）：

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/main/install.sh -o install.sh
less install.sh        # 审阅脚本内容
bash install.sh
```

常用参数：`--dir <路径>` 指定安装目录、`--no-deps` 跳过系统依赖、`--yes` 全自动不询问、`--help` 查看帮助。

### 国内网络

如果 `raw.githubusercontent.com` / `github.com` 访问不了，用 jsDelivr 镜像获取脚本：

```bash
curl -SLf https://cdn.jsdelivr.net/gh/syloe1/nvim_Conf@main/install.sh | bash
```

- 克隆仓库时若直连 github.com 失败，脚本会自动改用 `gh-proxy.com` 镜像重试（想指定别的镜像可设环境变量 `NVIM_CONF_MIRROR` 或直接 `NVIM_CONF_REPO=<你的地址>`）。
- **插件本身也来自 GitHub**。若插件下载不动，可让 git 全局走镜像再安装：

  ```bash
  git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"
  ```

  之后在 nvim 里执行 `:PackerSync` 即可。不需要时用 `git config --global --unset url."https://gh-proxy.com/https://github.com/".insteadOf` 取消。

## 平台支持

| 平台 | 支持 | 说明 |
| --- | --- | --- |
| Linux（Ubuntu / Debian / Arch / Manjaro / Fedora / openSUSE / CentOS 等） | ✅ 完整 | 一条命令搞定，自动用系统包管理器装依赖 |
| macOS | ✅ 完整 | 依赖通过 Homebrew 安装（无需 sudo） |
| Windows + WSL2 | ✅ 推荐 | 在 WSL 里当作 Linux 使用，体验最好 |
| Windows + Git Bash | ⚠️ 尽力而为 | 脚本可摆放配置，但系统依赖需自行安装；原生 Windows NeoVim 默认读 `%LOCALAPPDATA%\nvim`，需额外设置 `XDG_CONFIG_HOME` |
| Windows 原生（cmd / PowerShell） | ❌ 不支持 | 依赖工具链与路径差异太大，请改用 WSL2 |

## 依赖

安装脚本会尽量自动安装（`clangd`、`ripgrep`、`fzf`、`cmake`、`make`、`gcc`、`python3`、`nodejs/npm` 等）。即使其中某个失败，也不影响编辑器整体使用，只是对应语言的补全/格式化会受限。之后可以随时手动重跑：

```bash
~/.config/nvim/scripts/install_deps.sh
```

## 图标与字体

如果文件图标显示为方块/乱码，是缺少 Nerd Font。请安装一款 Nerd Font（推荐 JetBrainsMono Nerd Font）并在终端里启用，然后：

```vim
:lua require'archvim.options'.nerd_fonts = true
```

## 个性化定制

```bash
~/.config/nvim/scripts/customize_settings.sh
```

会交互式询问若干偏好（透明度、inlay hint、剪贴板共享、Kitty 图片支持等），写入 `~/.local/share/nvim/archvim/opts.json`，可随时重跑修改。

## 更新

重新执行一次一键安装命令即可；或：

```bash
git -C ~/.config/nvim pull
nvim                                          # 打开后执行 :PackerSync
```

## 卸载 / 回滚

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
```

安装时若备份过旧配置，它位于 `~/.config/nvim.bak.<时间戳>`，可用 `mv` 还原。

## 署名与许可

本配置是基于 [archibate/vimrc](https://github.com/archibate/vimrc) 的衍生作品。上游仓库**未声明开源许可证**，因此本仓库也不附加许可证，仅供个人学习与使用；上游代码版权归其原作者所有。如需再分发或商用，请先联系上游作者。

## 常见问题

- **插件没装全？** 打开 nvim 执行 `:PackerSync`。
- **没有 LSP / 语法高亮？** 先跑 `scripts/install_deps.sh`，再在 nvim 内执行 `:TSUpdateSync`。
- **不要某些插件 / 想加插件？** 编辑 `lua/archvim/plugins.lua` 的 `plugins` 列表，然后 `:PackerSync`。
