-- LazyVim's PHP extra wires phpcs as a linter (nvim-lint + none-ls) and adds
-- it to mason ensure_installed. This project uses Pint exclusively and has no
-- phpcs.xml, so phpcs runs with default PSR12/Squiz rules and produces noise
-- ("Closing brace must be on a line by itself", etc.). Kill it everywhere.
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.php = {}
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(s)
        return not (s.name == "phpcs" or s.name == "phpcsfixer")
      end, opts.sources or {})
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(p)
        return p ~= "phpcs" and p ~= "php-cs-fixer"
      end, opts.ensure_installed or {})
    end,
  },
}
