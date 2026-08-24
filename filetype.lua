vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    mdx = "markdown.mdx",
  },
  filename = {
    ["go.work"] = "gowork",
    -- Dotenv files are read by godotenv, not sourced by bash. `.env` is an
    -- exact-name match, so it always wins as `env`. `.env.*` is handled by the
    -- pattern below (+ the FileType guard).
    [".env"] = "env",
  },
  pattern = {
    -- Nvim core maps `.env.*` to `env`, but only as a low-priority fallback:
    -- its content detection sees the KEY=value lines and picks `sh` first.
    -- A high priority is meant to win before content detection. It usually
    -- does, but under lazy.nvim the buffer-open detection path is racy, so the
    -- FileType guard below is the real guarantee.
    ["^%.env%.[%w_.-]+"] = { "env", { priority = 100 } },
  },
})

-- Guarantee dotenv files never end up as `sh`. When detection (core content
-- detection, or the vim-dotenv `setfiletype sh` autocmd pulled in by
-- laravel.nvim) lands a `.env`/`.env.*` buffer on `sh`, bash-language-server
-- attaches and shellcheck floods every KEY=value with SC2034 "appears unused".
-- This fires on FileType=sh and flips them back to `env`. It is registered from
-- filetype.lua (sourced at startup, before plugins call vim.lsp.enable), so it
-- runs before the LSP-enable handler in the same FileType dispatch — by the
-- time that handler reads the buffer's filetype it is already `env`, and no
-- shell LSP attaches. `.envrc`/`.envrc.*` (direnv, genuinely shell) are left
-- alone.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotenv_force_env", { clear = true }),
  pattern = "sh",
  callback = function(ev)
    local tail = vim.fs.basename(vim.api.nvim_buf_get_name(ev.buf))
    if tail == ".env" or tail:match("^%.env%.") then
      vim.bo[ev.buf].filetype = "env"
    end
  end,
})
