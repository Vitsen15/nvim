return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- NOTE: didChangeWatchedFiles intentionally NOT disabled here.
          -- gopls has no filesystem watcher of its own — it relies on the
          -- client per LSP spec. Without it, changes to files not open in
          -- a buffer (AI agents editing in another tmux window) are never
          -- seen, leaving stale cross-file diagnostics that survive
          -- :lsp restart. Watching is enabled for all servers in
          -- lsp-external-changes.lua.
          settings = {
            gopls = {
              buildFlags = { "-tags=swagger,integration" },
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-vendor" },
            },
          },
        },
      },
      setup = {
        -- Skip LazyVim's semanticTokens workaround: it fakes the provider's
        -- legend with the client's token list, but tokens are indexed against
        -- the server's legend, so process_response crashes. Modern gopls
        -- advertises semanticTokensProvider natively, so the workaround is
        -- unnecessary.
        gopls = function() end,
      },
    },
  },
}
