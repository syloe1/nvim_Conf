require'nvim-mcp'.setup{}

local old_rpcnotify = vim.rpcnotify
vim.rpcnotify = function(channel, method, ...)
    if method:match("NVIM_MCP") then
        return
    end
    old_rpcnotify(channel, method, ...)
end
