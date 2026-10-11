-- Required for `opts.events.reload`.
vim.o.autoread = true

-- Recommended/example keymaps.
vim.keymap.set({ "n", "x" }, "<C-]>a", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
vim.keymap.set({ "n", "x" }, "<C-]>s", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "t" }, "<C-]><C-]>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })
vim.keymap.set({ "n", "t" }, "<C-]>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

vim.keymap.set({ "n", "x" }, "z]",  function() return require("opencode").operator("@this ") end,        { expr = true, desc = "Add range to opencode" })
vim.keymap.set("n",          "z]]", function() return require("opencode").operator("@this ") .. "_" end, { expr = true, desc = "Add line to opencode" })

vim.keymap.set("n", "<C-]><C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "opencode half page up" })
vim.keymap.set("n", "<C-]><C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "opencode half page down" })



-- Handle `opencode` events
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "OpencodeEvent:*", -- Optionally filter event types
--   callback = function(args)
--     local event = args.data.event
--     local port = args.data.port
--
--     -- See the available event types and their properties
--     -- vim.notify(vim.inspect(event))
--     -- Do something useful
--     -- if event.type == "session.idle" then
--     --   vim.notify("OpenCode finished responding.")
--     -- end
--   end,
-- })

local enabled_provider = "terminal"
if os.getenv('TMUX') then
    enabled_provider = "tmux"
elseif os.getenv('KITTY_PID') then
    enabled_provider = "kitty"
elseif pcall(require, 'snacks') then
    enabled_provider = "snacks"
end

vim.g.opencode_opts = {
    provider = {
        enabled = enabled_provider,
    }
}
