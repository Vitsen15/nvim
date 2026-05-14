-- Override the LazyVim PHP extra's default formatter (php-cs-fixer) with Pint.
-- conform.nvim's built-in pint formatter resolves vendor/bin/pint via upward
-- search from the buffer's directory, so no command override is needed.
-- For Docker-only projects, override `formatters.pint.command` in .nvim.lua.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = { "pint" },
      },
    },
  },
}
