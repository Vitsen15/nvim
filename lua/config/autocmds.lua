-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reload buffers when files change on disk (AI agents editing in another
-- tmux window). Two pieces:
--   1. reload_all(): bare :checktime only reloads buffers visible in a
--      window; hidden buffers (background tabs) keep stale content, which
--      poisons LSP overlays with phantom diagnostics ("redeclared in this
--      block") that survive :lsp restart. ':checktime {bufnr}' forces the
--      check for hidden buffers too, so iterate every loaded file buffer.
--   2. fs_event watchers on every buffer's directory: reload fires the
--      moment the agent writes, without waiting for focus/cursor events.

local external_file_changes = vim.api.nvim_create_augroup("external_file_changes", { clear = true })

local function reload_all()
  if vim.fn.mode() == "c" or vim.fn.getcmdwintype() ~= "" then
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      pcall(vim.cmd, ("silent! checktime %d"):format(buf))
    end
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
  callback = reload_all,
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

-- fs_event watchers: one per directory containing a loaded file buffer.
local watches = {} ---@type table<string, uv.uv_fs_event_t>
local reload_timer = assert(vim.uv.new_timer())

local function on_fs_event()
  -- debounce: agents often write several files back-to-back
  reload_timer:start(100, 0, vim.schedule_wrap(reload_all))
end

local function sync_watches()
  local dirs = {} ---@type table<string, boolean>
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and name ~= "" then
      local dir = vim.fs.dirname(name)
      -- Check the directory, not the file: a brand-new file (agent-created,
      -- or user `:e newfile` before first `:w`) shouldn't block watching its
      -- already-existing parent dir.
      if dir and dir ~= "" and vim.uv.fs_stat(dir) then
        dirs[dir] = true
      end
    end
  end
  for dir in pairs(dirs) do
    if not watches[dir] then
      local w = vim.uv.new_fs_event()
      if w then
        local ok = w:start(dir, {}, on_fs_event)
        if ok then
          watches[dir] = w
        else
          w:close()
        end
      end
    end
  end
  for dir, w in pairs(watches) do
    if not dirs[dir] then
      watches[dir] = nil
      if not w:is_closing() then
        w:close()
      end
    end
  end
end

local sync_timer = assert(vim.uv.new_timer())

local function schedule_sync_watches()
  sync_timer:start(50, 0, vim.schedule_wrap(sync_watches))
end

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufReadPost" }, {
  group = external_file_changes,
  callback = schedule_sync_watches,
})
schedule_sync_watches()
