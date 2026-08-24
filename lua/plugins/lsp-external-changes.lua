-- Enable the built-in file watcher on Linux so LSP servers get
-- workspace/didChangeWatchedFiles notifications for external edits
-- (e.g. by AI agents). Disabled on Linux by default due to scaling concerns,
-- but works fine for normal-sized projects.
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].capabilities = vim.tbl_deep_extend("force", opts.servers["*"].capabilities or {}, {
      workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      },
    })

    -- Servers register watches for dirs that may not exist (gopls: vendor/).
    -- vim._watch spawns inotifywait on them, which fails and surfaces an
    -- ERROR notification. Skip nonexistent paths instead.
    local ok, watch = pcall(require, "vim._watch")
    if ok and watch.inotify then
      if not watch._skip_missing_patched then
        watch._skip_missing_patched = true
        local inotify = watch.inotify
        ---@diagnostic disable-next-line: duplicate-set-field
        watch.inotify = function(path, wopts, callback)
          if not vim.uv.fs_stat(path) then
            return function() end
          end
          return inotify(path, wopts, callback)
        end
      end
    else
      -- vim._watch.inotify moved/renamed upstream: the patch above no longer
      -- applies. Surface it instead of silently falling back to ERROR
      -- notifications for every nonexistent watched path (e.g. vendor/).
      vim.notify(
        "lsp-external-changes: vim._watch.inotify not found — missing-path patch "
          .. "not applied; expect ERROR notifications for watched dirs that don't exist",
        vim.log.levels.WARN
      )
    end
  end,
}
