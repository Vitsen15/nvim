return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters.golangcilint = {
        cmd = "go",
        condition = function(ctx)
          return vim.fs.find({
            ".golangci.yml",
            ".golangci.yaml",
            ".golangci.toml",
            ".golangci.json",
          }, { upward = true, path = ctx.dirname })[1] ~= nil
        end,
        args = {
          "tool",
          "golangci-lint",
          "run",
          "--output.json.path=stdout",
          "--output.text.path=",
          "--output.tab.path=",
          "--output.html.path=",
          "--output.checkstyle.path=",
          "--output.code-climate.path=",
          "--output.junit-xml.path=",
          "--output.teamcity.path=",
          "--output.sarif.path=",
          "--issues-exit-code=0",
          "--show-stats=false",
          "--path-mode=abs",
          function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
          end,
        },
      }
    end,
  },
  {
    -- The linter above runs `go tool golangci-lint`, i.e. the version pinned in
    -- the project's go.mod, which is what CI and `.golangci.yml` are written
    -- against. Mason's own golangci-lint is therefore never invoked, so keep it
    -- out of ensure_installed instead of downloading 40M that nothing runs.
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(p)
        return p ~= "golangci-lint"
      end, opts.ensure_installed or {})
    end,
  },
}
