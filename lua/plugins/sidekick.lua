-- folke/sidekick.nvim: Claude Code terminal integration.
-- External file reloads are handled by config/autocmds.lua.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      cli = {
        watch = false,
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
        -- nvim 0.12+ ships native ':lsp restart'; nvim-lspconfig then skips
        -- defining its legacy :LspRestart, so pick whichever exists.
        if vim.fn.exists(":lsp") == 2 then
          vim.cmd("lsp restart")
        else
          vim.cmd("LspRestart")
        end
      end, { desc = "Reload buffers + restart LSP (recover from stale state)" })
      vim.keymap.set("n", "<leader>lR", "<cmd>LspResync<cr>", { desc = "LSP Resync" })

      -- Muscle-memory aliases: nvim 0.12 replaced nvim-lspconfig's commands
      -- with native ':lsp <subcommand>'; restore the old spellings.
      if vim.fn.exists(":lsp") == 2 then
        for alias, native in pairs({
          LspRestart = "restart",
          LspStart = "enable",
          LspStop = "stop",
        }) do
          vim.api.nvim_create_user_command(alias, function(info)
            local cmd = "lsp " .. native
            if #info.fargs > 0 then
              cmd = cmd .. " " .. table.concat(info.fargs, " ")
            end
            vim.cmd(cmd)
          end, {
            nargs = "*",
            desc = "Alias for :lsp " .. native,
            complete = function(arg)
              return vim.tbl_map(
                function(c)
                  return c.name
                end,
                vim.tbl_filter(function(c)
                  return c.name:sub(1, #arg) == arg
                end, vim.lsp.get_clients())
              )
            end,
          })
        end
      end
    end,
  },
}
