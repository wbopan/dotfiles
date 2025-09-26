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
vim.opt.wrap = true                -- Enable line wrap
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
vim.opt.showtabline = 0            -- Show tabline when multiple tabs
vim.opt.autoread = true            -- Auto-reload files changed outside of Vim

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
  { 
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
      }
    },
  },

  -- File Explorer
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },

  -- Editing Enhancements
  {
    "windwp/nvim-autopairs",
    opts = {},
  },
  "tpope/vim-surround",
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  
  -- Visual Improvements
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  
  -- Quality of Life
  {
    "folke/which-key.nvim",
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      }
    },
  },

  -- Colorscheme
  { 
    "catppuccin/nvim", 
    name = "catppuccin",
    opts = {
      flavour = "auto", -- will respect terminal's background
      transparent_background = true,
      background = { -- only works when flavour = "auto"
        light = "latte",
        dark = "mocha",
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  }
})

-- ============================================================================
-- KEY MAPPINGS
-- ============================================================================

-- Clear search highlight
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })

-- Quit insert mode with jk
vim.keymap.set("i", "jk", "<Esc>", { desc = "Quit insert mode" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Toggle file explorer
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Telescope mappings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all force" })

-- Paste without yanking in visual mode
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Copy file paths to clipboard
vim.keymap.set("n", "<leader>cp", ":let @+=expand('%:p')<CR>", { desc = "Copy absolute file path" })
vim.keymap.set("n", "<leader>cc", ":let @+=expand('%')<CR>", { desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>cd", ":let @+=expand('%:p:h')<CR>", { desc = "Copy directory path" })

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

-- ============================================================================
-- AUTO-RELOAD FILES ON EXTERNAL CHANGES
-- ============================================================================

-- Simple auto-reload: reload files when they change externally, but only if no unsaved changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    -- Skip if in command mode or if buffer has unsaved changes
    if vim.fn.mode() == "c" or vim.bo.modified then
      return
    end
    -- Check and reload files that changed externally
    vim.cmd("checktime")
  end,
})
