-- markdownlint-cli2 never reads config from parent directories, so a
-- workspace-level config is missed inside child repos. Use a personal rule
-- file instead; a repo's own config in the cwd still wins.
local config = vim.fn.expand("~/.config/markdownlint/.markdownlint-cli2.jsonc")

-- A missing file would silently break linting; keep the defaults then.
if not vim.uv.fs_stat(config) then
  return {}
end

return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", config, "-" },
      },
    },
  },
}
