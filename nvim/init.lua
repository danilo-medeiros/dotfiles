vim.g.mapleader = " "

vim.g.have_nerd_font = true
-- Make line numbers default
vim.opt.number = true

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wrap = false
vim.opt.swapfile = false

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-v>", "<C-w><C-v>", { desc = "Split tab vertically" })

local get_relative_path = function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.")
  return path
end

local get_relative_path_with_line = function()
  local path = get_relative_path()
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  return path .. ":" .. linenr
end

-- Copy the current file path to the clipboard.
vim.api.nvim_create_user_command("Path", function()
  local path = get_relative_path()
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, {})

-- Copy the current file path and line number to the clipboard
vim.api.nvim_create_user_command("Line", function()
  local result = get_relative_path_with_line()
  vim.fn.setreg("+", result)
  print("Copied: " .. result)
end, {})

-- Copy the current file path and line range to the clipboard, formatted for GitHub.
vim.api.nvim_create_user_command("LineRepo", function(opts)
  local repo = vim.trim(
    vim.fn.system("git remote get-url origin | sed -e 's#git@github.com:#https://github.com/#' -e 's/\\.git$//'")
  )
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.")
  -- If the start line is different than 0, use the line range
  -- Otherwise, use the cursor line
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local line_range = "#L" .. start_line .. "-L" .. end_line

  if opts.range == 0 then
    line_range = "#L" .. vim.api.nvim_win_get_cursor(0)[1]
  end

  local branch = vim.trim(vim.fn.system("git branch --show-current"))
  local result = repo .. "/blob/" .. branch .. "/" .. path .. line_range
  vim.fn.setreg("+", result)
  print("Copied: " .. result)
end, { range = true })

vim.api.nvim_create_user_command("R", function()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" then
    vim.cmd("e")
    vim.cmd("Gitsigns refresh")
    print("Refreshed")
  end
end, {})

-- Keybinds to make tab navigation easier.
vim.keymap.set("n", "<C-t>", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<right>", ":tabnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<left>", ":tabprevious<CR>", { noremap = true, silent = true })
-- Close the current tab
vim.keymap.set("n", "<C-x>", "<cmd>tabclose<CR>", { desc = "Close current tab" })

-- Show File explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Fugitive
vim.keymap.set(
  "n",
  "<leader>gb",
  ":Git blame<CR>",
  { noremap = true, silent = true, desc = "Show blame for current buffer" }
)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      'ibhagwan/fzf-lua',
      config = function()
        vim.keymap.set('n', '<C-p>', require('fzf-lua').git_files)
        vim.keymap.set('n', '<C-g>', require('fzf-lua').live_grep)
      end,
    },

    -- See `:help gitsigns` to understand what the configuration keys do
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' }
        },
      },
    },

    { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      lazy = false,
      opts = {
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'query', 'vim', 'vimdoc', 'javascript', 'python', 'javascript' },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = { enable = true },
      },
      config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
      end,
    },

    {
      "projekt0n/github-nvim-theme",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd("colorscheme github_dark_default") -- choose the specific variant
      end,
    },

    {
      "neovim/nvim-lspconfig",
      config = function()
        vim.lsp.set_log_level("debug")

        require("lspconfig").pyright.setup({})
        require("lspconfig").lua_ls.setup({})
        require("lspconfig").ts_ls.setup({})

        -- Install gopls with `go install golang.org/x/tools/gopls@latest`
        require("lspconfig").gopls.setup({})

        vim.lsp.config("elixirls", {
          -- Download elixir-ls on https://github.com/elixir-lsp/elixir-ls/releases/latest/
          -- Unzip and move to ~/.local/share/elixir-ls
          cmd = { vim.fn.expand("~/.local/share/elixir-ls/language_server.sh") };
        })

        vim.lsp.enable("elixirls")

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      end
    },

    {
      "github/copilot.vim"
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})

require("gitsigns").setup({
  current_line_blame = true
})

vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
vim.diagnostic.config({ virtual_text = true })
