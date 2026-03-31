-- Blade template support: treesitter parser + filetype detection
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "blade", "php" },
    },
  },
}
