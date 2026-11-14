return {
  -- Load all theme plugins but don't apply them.
  -- This ensures all colorschemes are available for hot-reloading.
  --
  -- The list matches the plugins Omarchy 4.5's themes use: the themes that ship
  -- their own neovim.lua, plus aether for the themes generated from
  -- default/themed/neovim.lua.tpl.
  {
    -- URL, name and branch must match Omarchy's generated theme spec
    -- (default/themed/neovim.lua.tpl), or lazy clones a second copy at runtime.
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    lazy = true,
    priority = 1000,
  },
  {
    "ficcdaf/ashen.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
  },
  {
    "neanias/everforest-nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "kepano/flexoki-neovim",
    lazy = true,
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "bjarneo/hackerman.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "omacom-io/lumon.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "tahayvr/matteblack.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "OldJobobo/retro-82.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
  },
}
