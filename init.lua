
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

-- Useful for visually showing tabs
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·" }

-- System clipboard via lemonade
vim.opt.clipboard = "unnamedplus"

-- jj to exit insert mode
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-----------------------------------------------------------
-- Clipboard (lemonade over SSH)
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
          provider = function()
            return " " .. vim.fn.mode():upper() .. " "
          end,
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
          "lua", "c", "cpp", "bash", "python", "vim", "vimdoc",
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
  -- Indent guides (indent-blankline v3)
  ---------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })
    end,
  },

  ---------------------------------------------------------
  -- Completion: nvim-cmp + LuaSnip + sources
  ---------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
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

