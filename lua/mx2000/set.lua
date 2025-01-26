-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.breakindent = true -- maintain indent when wrapping
vim.opt.linebreak = true -- break at word boundaries

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI Improvements
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.showmode = false -- mode is shown in statusline
vim.opt.wrap = false
vim.opt.pumheight = 10 -- pop up menu height
vim.opt.conceallevel = 0 -- show `` in markdown files

-- Performance
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

-- Backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Split Windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- System Integration
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.mouse = "a" -- enable mouse for all modes

-- Search
vim.opt.path:append { "**" } -- Search into subfolders
vim.opt.wildignore:append { "*/node_modules/*" }

-- Misc
vim.opt.iskeyword:append("-") -- treat dash separated words as a word text object
