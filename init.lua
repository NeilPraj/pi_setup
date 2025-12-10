-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true

-- System clipboard over lemonade
vim.opt.clipboard = "unnamedplus"

-- jj to exit
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-----------------------------------------------------------
-- Clipboard (lemonade)
-----------------------------------------------------------
vim.g.clipboard = {
  name = "lemonade",
  copy = {
    ["+"] = { "lemonade", "copy" },
    ["*"] = { "lemonade", "copy" },
  },
  paste = {
    ["+"] = { "lemonade", "paste" },
    ["*"] = { "lemonade", "paste" },
  },
  cache_enabled = 0,
}

-----------------------------------------------------------
-- Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({

  ---------------------------------------------------------
  -- Colorscheme: TokyoNight
  ---------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  ---------------------------------------------------------
  -- Heirline (statusline)
  ---------------------------------------------------------
  {
    "rebelot/heirline.nvim",
    lazy = false,
    config = function()
      local heirline = require("heirline")

      local StatusLine = {
        hl = function()
          return {
            fg = vim.api.nvim_get_hl_by_name("StatusLine", true).foreground,
            bg = vim.api.nvim_get_hl_by_name("StatusLine", true).background,
          }
        end,
        {
          provider = function() return " " .. vim.fn.mode():upper() .. " " end,
        },
        { provider = " %f " },
        { provider = "%=" },
        { provider = " %l:%c " },
      }

      heirline.setup({ statusline = StatusLine })
    end,
  },

  ---------------------------------------------------------
  -- Treesitter
  ---------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "c", "cpp", "bash", "python", "vim", "vimdoc"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  ---------------------------------------------------------
  -- Autopairs
  ---------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  ---------------------------------------------------------
  -- LaTeX: VimTeX
  ---------------------------------------------------------
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },

})


