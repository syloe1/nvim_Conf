if require'archvim.options'.enable_kitty then
    require'image'.setup {
        backend = 'kitty',
    }

    vim.api.nvim_create_autocmd({"FocusGained", "FocusLost"}, {
        group = vim.api.nvim_create_augroup("FocusEventsGroup", { clear = true }),
        callback = function(args)
            if args.event == "FocusGained" then
                -- Code to run when Neovim gains focus
                require'image'.enable()
            elseif args.event == "FocusLost" then
                -- Code to run when Neovim loses focus
                require'image'.disable()
            end
        end
    })
else
    -- require'image'.setup {
    --     backend = 'sixel',
    -- }
    -- require'image'.disable()
end
