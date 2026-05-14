return {
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
    },
    -- Load only inside Laravel/PHP projects (README-recommended triggers).
    -- Avoids watcher ENOENT in non-Laravel cwd and DB-connect spam at startup.
    ft = { "php", "blade" },
    event = { "BufEnter composer.json" },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
      { "<leader>la", ":Laravel artisan<cr>" },
      { "<leader>lr", ":Laravel routes<cr>" },
      { "<leader>lm", ":Laravel related<cr>" },
    },
    opts = {
      -- route_info registers a BufEnter autocmd on *Controller.php that
      -- runs `artisan route:list --json`, which boots Laravel and hits the DB.
      -- When docker/DB is down it spams QueryException popups. Disable; the
      -- `:Laravel routes` picker still works on demand.
      extensions = {
        route_info = { enable = false },
      },
    },
  },
}
