-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.o.exrc = true -- Enable reading .nvim.lua, .nvimrc, .exrc files
vim.o.secure = true -- Restrict usage of some commands in non-default .nvimrc files
