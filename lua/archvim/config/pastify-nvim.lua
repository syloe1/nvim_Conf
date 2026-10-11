require('pastify').setup {
  opts = {
    absolute_path = false, -- use absolute or relative path to the working directory
    apikey = '', -- Api key, required for online saving
    local_path = '/images/', -- The path to put local files in, ex <cwd>/assets/images/<filename>.png
    save = 'local', -- Either 'local' or 'online' or 'local_file'
    filename = function() return vim.fn.expand("%:t:r") .. '_' .. os.date("%Y-%m-%d_%H-%M-%S") end,
    -- The file name to save the image as, if empty pastify will ask for a name
    -- Example function for the file name that I like to use:
    -- filename = function() return vim.fn.expand("%:t:r") .. '_' .. os.date("%Y-%m-%d_%H-%M-%S") end,
    -- Example result: 'file_2021-08-01_12-00-00'
    default_ft = 'markdown', -- Default filetype to use
  },
  ft = { -- Custom snippets for different filetypes, will replace $IMG$ with the image url
    html = '<img src="$IMG$" alt="">',
    markdown = '![]($IMG$)',
    tex = [[\includegraphics[width=\linewidth]{$IMG$}]],
    css = 'background-image: url("$IMG$");',
    js = 'const img = new Image(); img.src = "$IMG$";',
    xml = '<image src="$IMG$" />',
    php = '<?php echo "<img src=\"$IMG$\" alt=\"\">"; ?>',
    python = '# $IMG$',
    java = '// $IMG$',
    c = '// $IMG$',
    cpp = '// $IMG$',
    swift = '// $IMG$',
    kotlin = '// $IMG$',
    go = '// $IMG$',
    typescript = '// $IMG$',
    ruby = '# $IMG$',
    vhdl = '-- $IMG$',
    verilog = '// $IMG$',
    systemverilog = '// $IMG$',
    lua = '-- $IMG$',
  },
}

-- vim.keymap.set({'n', 'i'}, '<C-v><C-v>', '<Cmd>Pastify<CR>', { noremap = true, silent = true })
vim.keymap.set({'n', 'i'}, '<C-v><C-v>', '<Cmd>PastifyAfter<CR>', { noremap = true, silent = true })
