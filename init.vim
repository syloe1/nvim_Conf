if has('nvim')
" Use the vendored predownload/ plugins when present (offline installs);
" otherwise fall back to cloning plugins from GitHub on first launch.
let g:archvim_predownload = isdirectory(stdpath('config') . '/predownload') ? 1 : 0
let g:archvim_autoinstall = 1
lua require('archvim')
else
echoerr "You are using Vim, not NeoVim"
endif

if filereadable('.vim_localrc')
    source .vim_localrc
endif
