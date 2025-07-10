-- ============================================================================
-- MINIMAL NEOVIM CONFIG WITH ESSENTIAL PLUGINS
-- ============================================================================

-- ============================================================================
-- BASIC OPTIONS
-- ============================================================================
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.tabstop = 4                -- Tab width
vim.opt.shiftwidth = 4             -- Indent width
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.smartindent = true         -- Smart indentation
vim.opt.wrap = false               -- Disable line wrap
vim.opt.swapfile = false           -- Disable swap files
vim.opt.backup = false             -- Disable backup files
vim.opt.undofile = true            -- Enable persistent undo
vim.opt.termguicolors = true       -- Enable 24-bit colors
vim.opt.scrolloff = 8              -- Keep 8 lines visible when scrolling
vim.opt.signcolumn = "yes"         -- Always show sign column
vim.opt.updatetime = 50            -- Faster completion
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.ignorecase = true          -- Case insensitive search
vim.opt.smartcase = true           -- Override ignorecase if search contains capitals
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.incsearch = true           -- Incremental search
vim.opt.splitbelow = true          -- Horizontal splits go below
vim.opt.splitright = true          -- Vertical splits go right
vim.opt.cursorline = true          -- Highlight current line
vim.opt.confirm = true             -- Ask to save before quitting
vim.opt.showtabline = 0            -- Never show tabline

-- ============================================================================
-- LEADER KEY
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- BOOTSTRAP LAZY.NVIM
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGIN SETUP
-- ============================================================================
require("lazy").setup({
  -- File Management
  "nvim-telescope/telescope.nvim",
  "nvim-tree/nvim-tree.lua",
  
  -- Editing Enhancements
  "windwp/nvim-autopairs",
  "tpope/vim-surround",
  "numToStr/Comment.nvim",
  
  -- Visual Improvements
  "lukas-reineke/indent-blankline.nvim",
  
  -- Quality of Life
  "folke/which-key.nvim",
  "nvim-lualine/lualine.nvim",
  
  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin" },
  
  -- Dependencies
  "nvim-lua/plenary.nvim",  -- Required by telescope
})

-- ============================================================================
-- PLUGIN CONFIGURATIONS
-- ============================================================================

-- Autopairs
require('nvim-autopairs').setup({})

-- Comment
require('Comment').setup()

-- Catppuccin
require("catppuccin").setup({
  flavour = "auto", -- will respect terminal's background
  transparent_background = true,
  background = { -- only works when flavour = "auto"
    light = "latte",
    dark = "mocha",
  },
})
vim.cmd.colorscheme("catppuccin")

-- Indent Blankline
require("ibl").setup()

-- Which Key
require("which-key").setup()

-- Lualine
require('lualine').setup({
  options = {
    theme = 'catppuccin',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  }
})

-- Telescope
require('telescope').setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/" },
  }
})

-- Nvim-tree
require("nvim-tree").setup({
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

-- ============================================================================
-- KEY MAPPINGS
-- ============================================================================

-- Clear search highlight
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Telescope mappings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- Nvim-tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all force" })

-- Paste without yanking in visual mode
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- ============================================================================
-- MACOS/EMACS-STYLE INSERT MODE NAVIGATION
-- ============================================================================

-- Beginning and end of line (Emacs-style)
vim.keymap.set('i', '<C-a>', '<C-o>^', { desc = 'Move to beginning of line' })
vim.keymap.set('i', '<C-e>', '<C-o>$', { desc = 'Move to end of line' })

-- Word navigation with Alt/Option keys
vim.keymap.set('i', '<M-Left>', '<C-o>b', { desc = 'Move back one word' })
vim.keymap.set('i', '<M-Right>', '<C-o>w', { desc = 'Move forward one word' })

-- Word navigation with Cmd keys (if terminal supports it)
vim.keymap.set('i', '<D-Left>', '<C-o>^', { desc = 'Move to beginning of line' })
vim.keymap.set('i', '<D-Right>', '<C-o>$', { desc = 'Move to end of line' })

-- Word deletion with backspace
vim.keymap.set('i', '<C-w>', '<C-o>db', { desc = 'Delete word backwards' })
vim.keymap.set('i', '<M-BS>', '<C-w>', { desc = 'Delete word backwards (Alt+Backspace)' })
