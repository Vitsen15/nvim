return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          -- Intelephense automatically reads license from ~/intelephense/licence.txt
          -- No need to pass it explicitly
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000, -- Increase to handle large vendor files
              },
              telemetry = {
                enabled = false,
              },
            },
          },
        },
      },
    },
  },
}
