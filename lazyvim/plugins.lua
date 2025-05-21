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
    },
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", 
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
        })
    end
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      list = false,
      fillchars = {},
    },
  },
}
