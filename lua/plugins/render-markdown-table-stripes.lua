-- Stripe every second table body row. render-markdown.nvim gives all body rows
-- one highlight and has no row separators (declined upstream, #295), so
-- wrapped cells blur into neighbouring rows. The plugin has no setting for
-- this, so patch its table renderer.
local ALT = "RenderMarkdownTableRowAlt"
local RATIO = 0.07 -- how far to blend Normal bg towards Normal fg

---@param a integer rgb
---@param b integer rgb
---@param t number 0..1
---@return integer
local function blend(a, b, t)
  local function channel(shift)
    local x = bit.band(bit.rshift(a, shift), 0xff)
    local y = bit.band(bit.rshift(b, shift), 0xff)
    return math.floor(x + (y - x) * t + 0.5)
  end
  return bit.lshift(channel(16), 16) + bit.lshift(channel(8), 8) + channel(0)
end

-- Transparent themes have no Normal bg; start from CursorLine instead so the
-- stripe still differs from the cursor line.
local function define_highlight()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
  local base = normal.bg or cursorline.bg
  if base and normal.fg then
    vim.api.nvim_set_hl(0, ALT, { bg = blend(base, normal.fg, RATIO) })
  else
    vim.api.nvim_set_hl(0, ALT, { link = "CursorLine" })
  end
end

local function patch()
  local ok, Render, Parser, Line = pcall(function()
    return require("render-markdown.render.markdown.table"),
      require("render-markdown.parser.table"),
      require("render-markdown.lib.line")
  end)
  -- Private plugin internals: if upstream renames them, skip patching instead
  -- of erroring on every render.
  if
    not ok
    or type(Render.row) ~= "function"
    or type(Render.wrapped_row) ~= "function"
    or type(Parser.wrap) ~= "function"
    or type(Line.new) ~= "function"
  then
    vim.notify_once("render-markdown table stripes: plugin internals changed, stripes disabled", vim.log.levels.WARN)
    return
  end
  if Render.table_stripes_patched then
    return
  end
  Render.table_stripes_patched = true
  local neutral = { Normal = true, RenderMarkdownPadding = true }

  -- Row index per table, built once per render.
  local positions = setmetatable({}, { __mode = "k" })

  -- rows[1] is the header; stripe every second body row.
  local function striped(self, row)
    local index = positions[self.data]
    if not index then
      index = {}
      for i, candidate in ipairs(self.data.rows) do
        index[candidate] = i
      end
      positions[self.data] = index
    end
    local i = index[row]
    return i ~= nil and i > 1 and i % 2 == 1
  end

  local rendering_striped = false

  -- Alignment padding is inline virtual text, which the source-line stripe
  -- doesn't cover; give it the stripe colour too.
  local function alt_line()
    return Line.new(ALT)
  end

  local function with_row_highlight(self, fn)
    local saved = self.config.row
    self.config.row = ALT
    self.line = alt_line
    rendering_striped = true
    local ok_fn, result = pcall(fn)
    self.config.row = saved
    self.line = nil
    rendering_striped = false
    if not ok_fn then
      error(result, 0)
    end
    return result
  end

  ---@param hl string|string[]|nil
  ---@return string|string[]
  local function recolour(hl)
    if hl == nil or neutral[hl] then
      return ALT
    end
    if type(hl) == "table" then
      local out = {}
      for i, group in ipairs(hl) do
        out[i] = neutral[group] and ALT or group
      end
      return out
    end
    return hl
  end

  local orig_row = Render.row
  function Render:row(row)
    if not striped(self, row) then
      return orig_row(self, row)
    end
    with_row_highlight(self, function()
      orig_row(self, row)
    end)
    self.marks:add(self.config, false, row.node.start_row, row.node.start_col, {
      end_row = row.node.start_row,
      end_col = row.node.end_col,
      hl_group = ALT,
      hl_eol = false,
      priority = 0,
    })
  end

  local orig_wrapped_row = Render.wrapped_row
  function Render:wrapped_row(row)
    if not striped(self, row) then
      return orig_wrapped_row(self, row)
    end
    return with_row_highlight(self, function()
      return orig_wrapped_row(self, row)
    end)
  end

  local orig_wrap = Parser.wrap
  function Parser.wrap(units, width)
    local lines = orig_wrap(units, width)
    if rendering_striped then
      for _, line in ipairs(lines) do
        for _, chunk in ipairs(line) do
          chunk[2] = recolour(chunk[2])
        end
      end
    end
    return lines
  end
end

return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = function(_, opts)
    patch()
    define_highlight()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("render_markdown_table_stripes", { clear = true }),
      callback = define_highlight,
    })
    return opts
  end,
}
