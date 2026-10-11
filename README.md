# nvim_Conf

我自用的一套 NeoVim 配置：智能补全、LSP、Tree-sitter 语法高亮、全局搜索、文件浏览、集成终端、Git 集成等，纯 Lua 配置，开箱即用。

本配置基于 [archibate/vimrc](https://github.com/archibate/vimrc)（“小彭老师自用 NeoVim 整合包”）修改而来。

> 截图占位：欢迎在真实终端截图后，替换成 `cover.png` 并在此处引用。

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
