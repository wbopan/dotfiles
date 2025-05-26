vim.g.snacks_animate = false
-- vim.notify("Hello, world!", "info", { title = "Hello, world!" })
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true,
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "super-tab" },
      sources = {
        -- Disable LSP source, keep other sources
        default = { "buffer", "path", "snippets" },
        providers = {
          lsp = { enabled = false },
        },
      },
    },
  },
  -- Disable nvim-lspconfig (LSP)
  { "neovim/nvim-lspconfig", enabled = false },
  -- Disable mason (LSP installer)
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  -- Disable other LSP-related plugins
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", 
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
        })
    end
  },
  -- Disable GitHub Copilot
  { "github/copilot.vim", enabled = false },
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },
  -- Disable indent lines
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  -- Disable mini.indentscope (shows animated indent guides)
  { "echasnovski/mini.indentscope", enabled = false },
  -- Disable snacks indent (if it exists)
  { "folke/snacks.nvim", opts = { indent = { enabled = false } } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      list = false,
      fillchars = {},
    },
  },
}
