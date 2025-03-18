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
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        auto_trigger = true,
      },
    },
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
