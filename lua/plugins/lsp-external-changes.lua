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
  end,
}
