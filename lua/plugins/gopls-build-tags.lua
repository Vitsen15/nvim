return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- Disable neovim's file watcher for gopls (it has its own via fsnotify).
          -- Prevents inotify errors on non-existent directories like vendor/.
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          },
          settings = {
            gopls = {
              buildFlags = { "-tags=swagger,integration" },
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-vendor" },
            },
          },
        },
      },
    },
  },
}
