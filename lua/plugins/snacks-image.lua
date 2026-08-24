-- Render mermaid diagrams (and other doc images) inline in markdown buffers
-- via the Kitty graphics protocol (Ghostty supports it natively; tmux needs
-- `allow-passthrough on`, set in ~/.config/tmux/tmux.conf).
--
-- Requires on PATH: `mmdc` (npm i -g @mermaid-js/mermaid-cli) for mermaid,
-- `magick`/`convert` (ImageMagick) for other formats.
--
-- mmdc's bundled Chromium download was skipped at install time
-- (PUPPETEER_SKIP_DOWNLOAD=true); mermaid-puppeteer.json below points it at
-- the system chromium instead.
return {
  "folke/snacks.nvim",
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        -- Default 80x40 cells crushes wide/complex flowcharts into an
        -- illegible tangle. Give diagrams more on-screen room.
        max_width = 120,
        max_height = 60,
        -- Conceal the raw fenced source once it's rendered (default only
        -- conceals `math`), so mermaid blocks don't leave ~40 lines of source
        -- text between the heading and the diagram.
        conceal = function(_, type)
          return type == "math" or type == "chart"
        end,
      },
      convert = {
        mermaid = function()
          local theme = vim.o.background == "light" and "neutral" or "dark"
          -- Render at 2x the terminal's native cell scale: kitty-protocol
          -- display still fits the same on-screen cell footprint, but the
          -- extra source resolution is what makes text legible instead of
          -- blurry/cramped.
          local scale = (Snacks.image.terminal.size().scale or 1) * 2
          return {
            "-i",
            "{src}",
            "-o",
            "{file}",
            "-b",
            "transparent",
            "-t",
            theme,
            "-s",
            tostring(scale),
            "-p",
            vim.fn.stdpath("config") .. "/mermaid-puppeteer.json",
          }
        end,
      },
    },
  },
}
