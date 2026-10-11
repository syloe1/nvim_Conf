-- 基础设置
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.encoding = "utf-8"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"

-- Windows 剪贴板：需要 win32yank.exe 在 PATH 中
-- 下载: https://github.com/equalsraf/win32yank/releases
vim.opt.clipboard = "unnamedplus"

-- 缩进默认值
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true

-- 空格为 leader
vim.g.mapleader = " "

-- ============================================================
-- LSP 配置 (Windows 路径)
-- ============================================================

-- C/C++ LSP (确保 clangd 在 PATH 中)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd" },
      root_dir = vim.fs.root(0, {
        "compile_commands.json",
        ".clangd",
        ".git",
        "CMakeLists.txt",
      }),
    })
  end,
})

-- Go LSP (请改成你自己的 gopls 路径)
-- 安装: go install golang.org/x/tools/gopls@latest
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod" },
  callback = function()
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },  -- Windows: 确保 gopls.exe 在 PATH 中
      root_dir = vim.fs.root(0, { "go.mod", ".git" }),
    })
  end,
})

-- LSP 快捷键
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<A-,>", "<cmd>pop<CR>", opts)
    vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- 启用 Treesitter 高亮（新版 nvim-treesitter 不再自动开启）
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "go", "lua" },
  callback = function()
    vim.treesitter.start()
  end,
})

-- 禁用 netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================
-- 安装 lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- 插件列表
-- ============================================================
require("lazy").setup({
  -- 主题
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        styles = {
          functions = { italic = false },
          keywords = { italic = false },
        },
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- 文件图标
  { "nvim-tree/nvim-web-devicons" },

  -- 自动补全 nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Esc>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
        completion = {
          completeopt = "menu,menuone,noselect",
        },
      })
    end,
  },

  -- 自动配对括号
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,
        disable_filetype = {},
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
        },
      })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- 自动检测缩进
  {
    "nmac427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("guess-indent").setup({
        auto_cmd = true,
        override_editorconfig = false,
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- 新版 nvim-treesitter 不支持懒加载
    config = function()
      require("nvim-treesitter").setup()
      -- 安装常用 parser（已安装则为 no-op）
      require("nvim-treesitter").install({ "c", "cpp", "go", "lua" })
    end,
  },

  -- 目录树
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        view = {
          side = "left",
          width = 28,
        },
        filters = {
          dotfiles = false,
        },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
      })
    end,
  },

  -- Telescope 搜索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local tb = require("telescope.builtin")
      vim.keymap.set("n", "<leader>f", tb.find_files, { silent = true })
      vim.keymap.set("n", "<leader>g", tb.live_grep, { silent = true })
      vim.keymap.set("n", "<leader>s", tb.lsp_document_symbols, { silent = true })
      vim.keymap.set("n", "<leader>w", tb.lsp_workspace_symbols, { silent = true })
    end,
  },
})

-- 快捷键
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true, desc = "切换目录树" })
vim.keymap.set("n", "<leader>r", "<cmd>NvimTreeRefresh<CR>", { silent = true, desc = "刷新目录树" })
vim.keymap.set("n", "==", "==", { noremap = true, desc = "格式化当前行" })
vim.keymap.set("n", "<leader>=", "gg=G<C-o>", { silent = true, desc = "格式化整个文件" })

-- ============================================================
-- :Note —— 在 nvim 和 VS Code 之间来回切换当前文件
-- ------------------------------------------------------------
-- 仅 Windows 可用：整段依赖同目录的 note-toggle.ps1（PowerShell + Win32 窗口句柄），
-- 非 Windows 上跳过整段，不注册 :Note 命令。下面这个 if 就是那道开关。
if vim.fn.has("win32") == 1 then

-- 第一次 :Note  -> 用 VS Code 打开当前文件（跳到相同行列）
-- 第二次 :Note  -> 关掉那个 VS Code 窗口，焦点回到终端
-- 小写 :note 也能用：nvim 要求用户命令首字母大写，所以下面用 cnoreabbrev 兜底。
--
-- 依赖同目录下的 note-toggle.ps1（负责 Windows 的窗口定位/关闭/激活）。
-- 为什么需要它：VS Code 是「一个主进程托管所有窗口」，所有窗口共用一个 pid，
-- 只有窗口句柄(HWND)能区分；不校验句柄就关窗口有误关你其他 VS Code 窗口的风险。
-- ============================================================
local NOTE = {
  reuse_window = false, -- false: 每次新开 VS Code 窗口（能精确关掉）；true: 复用已有窗口
  autosave = true,      -- 切过去之前先保存 nvim 里的改动（否则 VS Code 读到旧内容）
  reload = true,        -- 切回来时若文件被外部改过则自动重新载入
  timeout_ms = 15000,   -- 等待 VS Code 窗口出现的上限
}

local note_script = vim.fs.joinpath(vim.fn.stdpath("config"), "note-toggle.ps1")
local note_state_path = vim.fs.joinpath(vim.fn.stdpath("state"), "note_toggle.json")

local function note_notify(msg, level)
  vim.notify("[Note] " .. msg, level or vim.log.levels.INFO)
end

-- 只记录「当前开着的那个 VS Code 窗口」，切换时用完即清
local function note_state_get()
  local f = io.open(note_state_path, "r")
  if not f then return {} end
  local body = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, body)
  if ok and type(data) == "table" then return data end
  return {}
end

local function note_state_set(t)
  vim.fn.mkdir(vim.fn.fnamemodify(note_state_path, ":h"), "p")
  local f = io.open(note_state_path, "w")
  if not f then return end
  f:write(vim.json.encode(t))
  f:close()
end

-- 调用 note-toggle.ps1，把 stdout 交给回调
local function note_run(args, on_done)
  if vim.fn.filereadable(note_script) == 0 then
    note_notify("找不到 " .. note_script .. "，:Note 无法工作", vim.log.levels.ERROR)
    return
  end
  local cmd = {
    "powershell", "-NoProfile", "-NonInteractive",
    "-ExecutionPolicy", "Bypass", "-File", note_script,
  }
  vim.list_extend(cmd, args)

  local lines = {}
  local ok, job = pcall(vim.fn.jobstart, cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data) if data then lines = data end end,
    on_exit = function(_, _)
      local out = table.concat(lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
      if on_done then on_done(out) end
    end,
  })
  if not ok or job <= 0 then
    note_notify("启动 powershell 失败，:Note 无法工作", vim.log.levels.ERROR)
  end
end

-- 用 VS Code 打开文件，并记下「终端窗口 + VS Code 窗口」两个句柄
local function note_open(name)
  -- VS Code 的 --goto 要的是「字符列」，而 col(".") 是字节列。
  -- 中文一个字占 3 字节，直接传字节列光标会跳偏，所以这里按字符数算。
  local row = vim.fn.line(".")
  local prefix = vim.fn.getline("."):sub(1, vim.fn.col(".") - 1)
  local col = vim.fn.strchars(prefix) + 1

  local args = {
    "-Mode", "launch",
    "-File", name,
    "-Line", tostring(row),
    "-Column", tostring(col),
    "-TimeoutMs", tostring(NOTE.timeout_ms),
  }
  if NOTE.reuse_window then args[#args + 1] = "-Reuse" end

  note_run(args, function(out)
    local term, win, confirmed = out:match("^OK (%d+) (%d+) (%d+)$")
    if not term then
      note_notify("切换失败: " .. (out:gsub("^ERR ", "")), vim.log.levels.ERROR)
      return
    end
    if win == "0" then
      -- 没拿到句柄就没法可靠地关它，宁可不记状态也不要留个可能误关的句柄
      note_notify("VS Code 已打开，但没定位到窗口句柄，这次切换不作为一次「往返」",
        vim.log.levels.WARN)
      return
    end
    note_state_set({
      term_hwnd = tonumber(term),
      win_hwnd = tonumber(win),
      file = name,
      -- 标题已确认过文件名，关窗口时才能用 -Expect 做二次校验
      expect = (confirmed == "1") and vim.fn.fnamemodify(name, ":t") or "",
    })
  end)
end

-- 关掉 VS Code 窗口、把终端切回前台；then_open 不为空时接着为它开一个新窗口
local function note_close(st, then_open)
  local args = {
    "-Mode", "close",
    "-Hwnd", tostring(st.term_hwnd or 0),
    "-Window", tostring(st.win_hwnd or 0),
  }
  if st.expect and st.expect ~= "" then
    vim.list_extend(args, { "-Expect", st.expect })
  end

  -- 立刻清状态：句柄可能被系统回收，留着它下次就可能关错窗口
  note_state_set({})

  note_run(args, function(out)
    if out == "OK" then
      note_notify("已切回 nvim")
    elseif out:match("^GONE") then
      note_notify("VS Code 窗口已经不在了")
    elseif out:match("^SKIP") then
      note_notify("没关那个窗口（标题对不上，可能句柄被回收了）: " .. out, vim.log.levels.WARN)
    else
      note_notify("关闭失败: " .. out, vim.log.levels.ERROR)
    end

    if NOTE.reload and st.file then
      local buf = vim.fn.bufnr(st.file)
      if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
        if vim.bo[buf].modified then
          note_notify("文件在 nvim 里有未保存改动，没有自动重载", vim.log.levels.WARN)
        else
          vim.api.nvim_buf_call(buf, function() vim.cmd("silent! edit!") end)
        end
      end
    end

    if then_open then
      vim.schedule(function() note_open(then_open) end)
    end
  end)
end

local function note_toggle()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" then
    note_notify("当前缓冲区不是普通文件", vim.log.levels.WARN)
    return
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    note_notify("当前缓冲区还没有文件名，先 :w 存一下", vim.log.levels.WARN)
    return
  end

  if NOTE.autosave and vim.bo[buf].modified then
    vim.cmd("silent! write")
    if vim.bo[buf].modified then
      note_notify("保存失败，已取消切换（否则 VS Code 会读到旧内容）", vim.log.levels.ERROR)
      return
    end
  end

  local st = note_state_get()
  if st.win_hwnd and st.win_hwnd ~= 0 then
    if st.file == name then
      note_close(st)          -- 同一个文件：切回去
    else
      note_close(st, name)    -- 换了文件：先关掉旧的，再为当前文件开一个
    end
  else
    note_open(name)
  end
end

vim.api.nvim_create_user_command("Note", note_toggle, {
  desc = "在 nvim 和 VS Code 之间切换当前文件",
})

-- 让字面输入 :note 也能用（用户命令必须大写开头，这里做个小写别名）
vim.cmd([[
  cnoreabbrev <expr> note getcmdtype() ==# ':' && getcmdline() ==# 'note' ? 'Note' : 'note'
]])

end -- if vim.fn.has("win32")

-- ============================================================
-- Ctrl + 滚轮 缩放字号（在 Windows Terminal 里用）
-- ------------------------------------------------------------
-- 背景：Windows Terminal 自带 Ctrl+滚轮 缩放字号，但它得先收到这个滚轮事件。
-- 你 nvim 开了 mouse=a，鼠标事件被 nvim 截走了，WT 压根看不到 Ctrl+滚轮，
-- 所以按了没反应。而 nvim 自己又改不了终端字号（终端里没有这种转义序列）。
--
-- 办法：WT 的 Ctrl+= / Ctrl+- 是窗口级快捷键，不会被 nvim 截走。
-- 这里把 nvim 收到的 Ctrl+滚轮 翻译成一对合成的 Ctrl+= / Ctrl+-，
-- 交给 WT 去缩放。用 LuaJIT 的 FFI 直接调 user32!keybd_event，
-- 不 fork 进程，所以没有卡顿。
--
-- 如果哪天 WT 自己在滚轮事件到达 nvim 之前就处理掉了（比如它认了
-- experimental.scrollToZoom），事件根本到不了 nvim，下面就是死代码，留着无害。
-- 不想要了整段删掉即可。
-- ============================================================
do
  local ok, ffi = pcall(require, "ffi")
  local ok2, user32 = false, nil
  if ok then
    pcall(ffi.cdef, [[
      void keybd_event(unsigned char bVk, unsigned char bScan,
                       unsigned long dwFlags, void *dwExtraInfo);
    ]])
    ok2, user32 = pcall(ffi.load, "user32")
  end

  if ok and ok2 then
    local VK_CONTROL, VK_OEM_PLUS, VK_OEM_MINUS = 0x11, 0xBB, 0xBD
    local KEYUP = 0x0002

    -- 合成一次 Ctrl+<vk>：按下再抬起，别把 Ctrl 留在按下状态
    local function tap_ctrl(vk)
      user32.keybd_event(VK_CONTROL, 0, 0, nil)
      user32.keybd_event(vk, 0, 0, nil)
      user32.keybd_event(vk, 0, KEYUP, nil)
      user32.keybd_event(VK_CONTROL, 0, KEYUP, nil)
    end

    vim.keymap.set({ "n", "v", "i" }, "<C-ScrollWheelUp>",
      function() tap_ctrl(VK_OEM_PLUS) end,
      { silent = true, desc = "放大字号 (转发 Ctrl+= 给终端)" })
    vim.keymap.set({ "n", "v", "i" }, "<C-ScrollWheelDown>",
      function() tap_ctrl(VK_OEM_MINUS) end,
      { silent = true, desc = "缩小字号 (转发 Ctrl+- 给终端)" })
  end
end
