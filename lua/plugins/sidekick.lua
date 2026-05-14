-- folke/sidekick.nvim: libuv fs_event watcher reloads buffers when AI tools
-- (Claude Code etc.) edit files externally. Pairs with lsp-external-changes.lua,
-- which enables didChangeWatchedFiles so LSP servers see those edits too.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        tools = { claude = {} },
      },
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
      },
    },
    init = function()
      -- Long-tail fallback: some servers (intelephense among them) stop
      -- republishing diagnostics even after a clean reload. :checktime first
      -- so the new server sees fresh buffer text on didOpen, then restart.
      vim.api.nvim_create_user_command("LspResync", function()
        vim.cmd("checktime")
        vim.cmd("LspRestart")
      end, { desc = "Reload buffers + restart LSP (recover from stale state)" })
      vim.keymap.set("n", "<leader>lR", "<cmd>LspResync<cr>", { desc = "LSP Resync" })
    end,
  },
}
