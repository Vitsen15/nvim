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
    -- Plugin assumes cwd is Laravel root: hardcodes vendor/nvim-laravel/ and
    -- runs models_loader unconditionally at boot. In monorepos where Laravel
    -- lives in a subdir (e.g. forward-secrets-api/backend/), skip the plugin
    -- unless nvim's cwd contains artisan.
    cond = function()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/artisan") == 1
    end,
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
