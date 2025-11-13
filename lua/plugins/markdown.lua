-- Enable LazyVim Markdown Extra
-- This includes:
-- - render-markdown.nvim for in-editor markdown rendering
-- - marksman LSP for markdown language support
-- - markdownlint-cli2 for linting
-- - markdown-toc for table of contents generation
-- - markdown-preview.nvim for live preview

return {
  -- Import the LazyVim markdown extra
  { import = "lazyvim.plugins.extras.lang.markdown" },
}
