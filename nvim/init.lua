vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
