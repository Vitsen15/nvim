require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.autoread = true

-- Marksman reports the whole Laffer workspace as root (shared .marksman.toml
-- for cross-repo links). Ignore it for root detection so lazygit, find-files
-- and grep stay in the current file's repository.
vim.g.root_lsp_ignore = { "copilot", "marksman" }

-- Diff: highlight whole changed words and keep soft wrap (better for prose).
vim.opt.diffopt:remove("inline:char")
vim.opt.diffopt:append({ "inline:word", "followwrap" })
