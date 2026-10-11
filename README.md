# nvim_Conf

[English](README.en.md) | **中文**

我自己在用的 NeoVim 配置，**手写单文件**，就一个 `init.lua`，插件交给 lazy.nvim 管。
够用、好读、好改 —— 想加什么就往下写一行，不用先翻一堆模块文件。

> 本仓库有两个分支，别走错了：
>
> | 分支 | 内容 |
> | --- | --- |
> | **`com`** | 👈 **本页描述的这套**，我自己手写的精简配置 |
> | `main` | 基于 [archibate/vimrc](https://github.com/archibate/vimrc)（小彭老师整合包）的衍生版，功能多但很重 |
>
> 下面所有安装命令都指向 `com` 分支。

> 截图占位：欢迎替换成 `cover.png` 并在此处引用。

## 功能一览

- **LSP**：`clangd`（C/C++）和 `gopls`（Go）开箱接入，跳转定义/声明/引用/实现、悬停、重命名、代码操作。
- **智能补全**：`nvim-cmp`，数据源取 LSP + 当前缓冲区 + 文件路径，圆角边框，`<Tab>` 选择、`<CR>` 确认。
- **语法高亮**：`nvim-treesitter`，预置 `c` / `cpp` / `go` / `lua` 四个 parser。
- **文件树**：`nvim-tree`，跟随工作目录，打开文件时自动定位。
- **全局搜索**：`telescope` —— 找文件、搜内容、找符号，都在 `<leader>` 下。
- **编辑增强**：`nvim-autopairs` 自动配对（配合补全确认）、`guess-indent` 自动识别缩进。
- **主题**：`tokyonight`（night 风格）+ `nvim-web-devicons` 文件图标。
- **`:Note`**：在 nvim 和 VS Code 之间来回切换当前文件，光标位置不丢（仅 Windows，见下文）。
- **Ctrl + 滚轮**：缩放终端字号（仅 Windows Terminal，见下文）。

## 一键安装

**Linux / macOS / WSL2**（会先备份你已有的 `~/.config/nvim`）：

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.sh | bash
```

**Windows 原生**（PowerShell，装到 `%LOCALAPPDATA%\nvim`）：

```powershell
irm https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.ps1 | iex
```

脚本会：备份旧配置 → 克隆本配置 → 缺失时尝试装 NeoVim → 装系统依赖（best effort，
失败只 warning 不中断）→ 用 headless 模式把插件和 Tree-sitter parser 装好。装完直接敲 `nvim`。

更稳妥的做法是先下载、看一眼、再执行：

```bash
curl -SLf https://raw.githubusercontent.com/syloe1/nvim_Conf/com/install.sh -o install.sh
less install.sh        # 审阅脚本内容
bash install.sh
```

### 常用参数

| 脚本 | 参数 | 作用 |
| --- | --- | --- |
| `install.sh` | `--dir <路径>` | 装到指定目录（默认 `~/.config/nvim`） |
| | `--branch <名字>` | 换分支（默认 `com`） |
| | `--no-deps` | 跳过系统依赖安装 |
| | `--yes` | 全自动，不询问 |
| | `--uninstall` | 卸载 |
| `install.ps1` | `-Dir` / `-Branch` / `-NoDeps` / `-Yes` / `-Uninstall` | 同上 |

环境变量同样可用：`NVIM_CONF_DIR`、`NVIM_CONF_BRANCH`、`NVIM_CONF_REPO`、`NVIM_CONF_MIRROR`。

### 国内网络

如果 `raw.githubusercontent.com` / `github.com` 不通，用 jsDelivr 镜像取脚本：

```bash
curl -SLf https://cdn.jsdelivr.net/gh/syloe1/nvim_Conf@com/install.sh | bash
```

- 克隆仓库时若直连 github.com 失败，脚本会自动改用 `gh-proxy.com` 镜像重试
  （想换别的镜像就设 `NVIM_CONF_MIRROR`，或直接 `NVIM_CONF_REPO=<你的地址>`）。
- **插件本身也来自 GitHub**。插件下载不动的话，让 git 全局走镜像再装：

  ```bash
  git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"
  ```

  之后在 nvim 里执行 `:Lazy sync`。不需要时用
  `git config --global --unset url."https://gh-proxy.com/https://github.com/".insteadOf` 取消。

## 快捷键

`<leader>` 是**空格**。

| 场景 | 按键 |
| --- | --- |
| 文件树 | `<leader>e` 开关 · `<leader>r` 刷新 |
| 搜索 | `<leader>f` 找文件 · `<leader>g` 全文搜索 · `<leader>s` 当前文件符号 · `<leader>w` 全工程符号 |
| LSP | `gd` / `<F12>` 定义 · `gD` 声明 · `gr` 引用 · `gi` 实现 · `K` 悬停 · `<leader>rn` 重命名 · `<leader>ca` 代码操作 |
| 跳转 | `<A-,>` 跳回上一个位置 · `Ctrl+左键` 跳定义 |
| 格式化 | `==` 重新缩进当前行 · `<leader>=` 格式化整个文件 |
| 补全 | `<Tab>` / `<S-Tab>` 上下选择 · `<CR>` 确认 · `<C-Space>` 手动触发 · `<Esc>` 取消 |
| 自动配对 | 输入 `(` `{` `[` 等自动补右半 · `<M-e>` 快速给已有内容加括号 |

键位都在 [`init.lua`](init.lua) 里，直接改即可。

## 两个特色功能

### `:Note` —— 在 nvim 和 VS Code 之间往返

`:Note` 会把当前文件（连同行列位置）用 VS Code 打开；再执行一次 `:Note`，就关掉那个
VS Code 窗口、焦点回到终端。小写 `:note` 也能用。

- 第一次 `:Note` → 用 VS Code 打开当前文件，跳到相同行列
- 第二次 `:Note` → 关掉那个 VS Code 窗口，焦点回终端；文件若在 VS Code 里改过会自动重载

依赖同目录的 [`note-toggle.ps1`](note-toggle.ps1)（负责 Windows 的窗口定位/关闭/激活）。
**为什么需要它**：现代 VS Code 是「一个主进程托管所有窗口」，所有窗口共用一个 pid，
只有窗口句柄（HWND）能区分。脚本关窗口前会二次校验句柄确实属于 `Code.exe`、
且标题里含目标文件名 —— 不校验的话有误关你其它 VS Code 窗口的风险。

行为可在 `init.lua` 顶部的 `NOTE` 表里调：`reuse_window`（复用窗口，默认关）、
`autosave`（切过去前先存盘，默认开）、`reload`（切回来自动重载，默认开）、`timeout_ms`。

> 仅 Windows：整段由 `vim.fn.has("win32")` 包着，其它平台不会注册这条命令。

### Ctrl + 滚轮缩放字号

在 Windows Terminal 里按 `Ctrl + 滚轮` 缩放字号。

背景：WT 自带这个功能，但它得先收到滚轮事件 —— 你 `mouse=a` 一开，事件被 nvim 截走了，
WT 压根看不到。而 nvim 又改不了终端字号（终端里没有这种转义序列）。所以这里把 nvim 收到的
`Ctrl+滚轮` 翻译成一对合成的 `Ctrl+=` / `Ctrl+-`（WT 的窗口级快捷键，不会被 nvim 截走），
用 LuaJIT 的 FFI 直接调 `user32!keybd_event`，不 fork 进程，所以没有卡顿。

> 仅 Windows：`ffi.load("user32")` 在别的平台会失败，整段自动跳过。

## 依赖

一键脚本已尽量自动装好；即使某个缺失，也只是对应能力受限，不影响编辑器整体可用。

| 依赖 | 用途 | 缺了会怎样 |
| --- | --- | --- |
| **NeoVim ≥ 0.10**（推荐 0.11+） | 本体 | 必需 |
| **git** | lazy.nvim 首次启动时克隆自己 | 必需 |
| **clangd** | C/C++ LSP | 没有 C/C++ 补全与跳转 |
| **gopls** | Go LSP | 没有 Go 补全与跳转 |
| **ripgrep** | `<leader>g` 全文搜索 | 搜不了内容 |
| **Nerd Font** | 文件图标 | 图标显示成方块/乱码 |
| **win32yank.exe**（Windows） | 与系统剪贴板互通 | 复制粘贴只在 nvim 内部有效 |
| **xclip / wl-clipboard**（Linux） | 同上 | 同上 |

装好 Nerd Font 后（推荐 JetBrainsMono Nerd Font）在终端里选它即可，无需改配置。

## 平台支持

| 平台 | 支持 | 说明 |
| --- | --- | --- |
| Linux（Ubuntu / Debian / Arch / Fedora / openSUSE…） | ✅ 完整 | `install.sh` 自动用系统包管理器装依赖 |
| macOS | ✅ 完整 | 依赖走 Homebrew；`clangd` 在 `brew install llvm` 里，需自行加 PATH（脚本会提示） |
| Windows + WSL2 | ✅ 推荐 | 在 WSL 里当 Linux 用，体验最好 |
| Windows 原生 | ✅ 完整 | 用 `install.ps1`；`:Note` 和 Ctrl+滚轮缩放在这个平台才生效 |
| Windows + Git Bash | ⚠️ 尽力而为 | 能摆放配置，但系统依赖要自己装；原生 nvim 读 `%LOCALAPPDATA%\nvim`，不是 `~/.config/nvim` |

## 目录结构

```
init.lua          配置本体（全部逻辑都在这）
note-toggle.ps1   :Note 的 Windows 辅助脚本
lazy-lock.json    插件版本锁定 —— 保证你和作者装到完全一样的版本
install.sh        Linux / macOS / WSL 安装脚本
install.ps1       Windows 安装脚本
```

## 更新 / 卸载

更新（配置本身是 git 仓库，直接 pull）：

```bash
git -C ~/.config/nvim pull
```

或重跑一次安装脚本。想同步插件版本就顺便 `:Lazy sync`。

卸载：

```bash
bash ~/.config/nvim/install.sh --uninstall      # 或 install.ps1 -Uninstall
```

它会删掉配置目录，并询问是否连插件/缓存一起删。安装时若备份过旧配置，位于
`~/.config/nvim.bak.<时间戳>`，用 `mv` 还原即可。

## 常见问题

- **图标是方块？** 装个 Nerd Font 并在终端里选中它。
- **没有 LSP 补全？** 确认 `clangd` / `gopls` 在 `PATH` 里（`clangd --version` 能跑）。
  加载 LSP 后 `:LspInfo` 看状态。
- **`:Note` 报错找不到脚本？** 确认 `note-toggle.ps1` 和 `init.lua` 在同一目录
  （正常安装不会丢），且 `powershell` 在 `PATH` 里。
- **`:Note` 说没定位到窗口句柄？** 通常是因为 `reuse_window = false` 时 VS Code 启动太慢
  超过了 `timeout_ms`，把超时调大即可。
- **想加插件？** 在 `init.lua` 的 `require("lazy").setup({...})` 里加一项，
  重开 nvim 或 `:Lazy sync`。
- **插件没装全？** `:Lazy sync`。

## 致谢与许可

这是个人自用配置，默认**保留所有权利**，欢迎参考和自取片段。
未附加开源许可证；如需再分发请先联系作者。

（`main` 分支上的 archibate/vimrc 衍生版版权归其原作者所有，与本分支无关。）
