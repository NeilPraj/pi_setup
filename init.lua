
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
    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    ------------------------------------------------------------
    -- Colors (match tokyonight)
    ------------------------------------------------------------
    local colors = {
      bg       = utils.get_highlight("StatusLine").bg,
      fg       = utils.get_highlight("StatusLine").fg,
      red      = utils.get_highlight("DiagnosticError").fg,
      yellow   = utils.get_highlight("DiagnosticWarn").fg,
      blue     = utils.get_highlight("Function").fg,
      green    = utils.get_highlight("String").fg,
      magenta  = utils.get_highlight("Statement").fg,
      cyan     = utils.get_highlight("Type").fg,
    }

    ------------------------------------------------------------
    -- Helper: colored text
    ------------------------------------------------------------
    local function hl(str, group)
      return "%#" .. group .. "#" .. str .. "%*"
    end

    ------------------------------------------------------------
    -- MODE COMPONENT
    ------------------------------------------------------------
    local ViMode = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = function(self)
        local mode_names = {
          n = "NORMAL", no = "N·OP", v = "VISUAL", V = "V·LINE",
          ["\22"] = "V·BLK", i = "INSERT", R = "REPLACE",
          c = "COMMAND", s = "SELECT", S = "S·LINE", t = "TERMINAL",
        }
        local text = " " .. (mode_names[self.mode] or self.mode) .. " "
        return text
      end,
      hl = function(self)
        return {
          fg = colors.bg,
          bg = ({
            n = colors.blue,
            i = colors.green,
            v = colors.magenta,
            V = colors.magenta,
            ["\22"] = colors.magenta,
            R = colors.red,
            c = colors.yellow,
            t = colors.cyan,
          })[self.mode] or colors.blue,
          bold = true,
        }
      end,
    }

    ------------------------------------------------------------
    -- GIT BRANCH
    ------------------------------------------------------------
    local Git = {
      condition = conditions.is_git_repo,
      init = function(self)
        self.status = vim.b.gitsigns_status_dict
      end,
      provider = function(self)
        return "   " .. (self.status.head or "") .. " "
      end,
      hl = { fg = colors.yellow },
    }

    ------------------------------------------------------------
    -- DIFF INFO (added/removed/changed)
    ------------------------------------------------------------
    local GitDiff = {
      condition = conditions.is_git_repo,
      provider = function()
        local added   = vim.b.gitsigns_status_dict.added or 0
        local removed = vim.b.gitsigns_status_dict.removed or 0
        local changed = vim.b.gitsigns_status_dict.changed or 0
        return string.format(" +%d ~%d -%d ", added, changed, removed)
      end,
      hl = { fg = colors.cyan },
    }

    ------------------------------------------------------------
    -- FILE INFO (name + flags)
    ------------------------------------------------------------
    local File = {
      provider = function()
        local name = vim.fn.expand("%:t")
        if name == "" then name = "[No Name]" end
        return " " .. name .. " "
      end,
      hl = { fg = colors.fg },
    }

    ------------------------------------------------------------
    -- DIAGNOSTICS BLOCK
    ------------------------------------------------------------
    local Diagnostics = {
      condition = conditions.has_diagnostics,
      provider = function()
        local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        local s = ""
        if e > 0 then s = s .. "  " .. e end
        if w > 0 then s = s .. "  " .. w end
        return s .. " "
      end,
      hl = function()
        return {
          fg = colors.red,
        }
      end,
    }

    ------------------------------------------------------------
    -- LSP ACTIVE?
    ------------------------------------------------------------
    local LSP = {
      condition = conditions.lsp_attached,
      provider = function()
        return "   LSP "
      end,
      hl = { fg = colors.green },
    }

    ------------------------------------------------------------
    -- RULER (line:col)
    ------------------------------------------------------------
    local Ruler = {
      provider = function()
        return string.format(" %d:%d ", unpack(vim.api.nvim_win_get_cursor(0)))
      end,
      hl = { fg = colors.blue },
    }

    ------------------------------------------------------------
    -- POSITION PERCENTAGE
    ------------------------------------------------------------
    local Scroll = {
      provider = function()
        local curr = vim.fn.line(".")
        local total = vim.fn.line("$")
        if curr == 1 then return " Top " end
        if curr == total then return " Bot " end
        return string.format(" %2d%%%% ", math.floor(curr / total * 100))
      end,
      hl = { fg = colors.magenta },
    }

    ------------------------------------------------------------
    -- FINAL STATUSLINE LAYOUT
    ------------------------------------------------------------
    local StatusLine = {
      ViMode,
      Git,
      GitDiff,
      File,
      Diagnostics,
      LSP,
      { provider = "%=" }, -- Right align
      Scroll,
      Ruler,
    }

    require("heirline").setup({ statusline = StatusLine })
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

