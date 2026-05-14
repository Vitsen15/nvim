-- LSP choice (intelephense vs phpactor) is set via vim.g.lazyvim_php_lsp in init.lua.
-- Project-specific settings (phpVersion, stubs, excludes) belong in .neoconf.json.
-- License auto-loads from ~/intelephense/licence.txt.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              format = { enable = false }, -- Pint owns formatting
              telemetry = { enabled = false },
            },
          },
        },
      },
    },
  },
}
