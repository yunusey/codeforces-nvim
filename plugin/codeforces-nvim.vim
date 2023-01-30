	

" Title:        codeforces-nvim
" Description:  The neovim plugin for codeforces.
" Last Change:  01/26/2023
" Maintainer:   yunusey <https://github.com/yunusey>

if exists("g:loaded_codeforces_nvim")
    finish
endif
let g:loaded_codeforces_nvim = 1

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/cmake-nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"
exe "lua require('codeforces-nvim').user_commands()"
