-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local external_file_changes = vim.api.nvim_create_augroup("external_file_changes", { clear = true })

local function checktime_if_safe()
  if vim.fn.mode() ~= "c" then
    pcall(vim.cmd, "silent! checktime")
  end
end

vim.api.nvim_create_autocmd({
  "FocusGained",
  "BufEnter",
  "CursorHold",
  "CursorHoldI",
  "TermClose",
  "TermLeave",
}, {
  group = external_file_changes,
  callback = function()
    checktime_if_safe()
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = external_file_changes,
  callback = function(ev)
    local file = ev.file ~= "" and ev.file or ev.match
    if file ~= "" then
      vim.notify("Reloaded: " .. vim.fn.fnamemodify(file, ":."))
    end
  end,
})
