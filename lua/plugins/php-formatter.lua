-- Override the LazyVim PHP extra's default formatter (php-cs-fixer) with Pint.
-- All our Laravel projects use Pint; per-project .nvim.lua files may further
-- override the command path (e.g. Docker or a different vendor dir).
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = { "pint" },
      },
      formatters = {
        pint = {
          command = "vendor/bin/pint",
          args = { "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
}
