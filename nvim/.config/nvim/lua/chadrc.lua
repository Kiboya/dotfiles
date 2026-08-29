---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  -- Remaps NvChad's built-in "catppuccin" theme (which is Mocha) to the
  -- real Catppuccin Frappe palette, to match Ghostty/btop/fish elsewhere
  -- in this setup. Field names come from NvChad/base46's catppuccin.lua.
  changed_themes = {
    catppuccin = {
      base_30 = {
        white = "#c6d0f5",
        darker_black = "#232634",
        black = "#303446", -- nvim bg
        black2 = "#292c3c",
        one_bg = "#414559",
        one_bg2 = "#51576d",
        one_bg3 = "#626880",
        grey = "#737994",
        grey_fg = "#838ba7",
        grey_fg2 = "#949cbb",
        light_grey = "#a5adce",
        red = "#e78284",
        baby_pink = "#eebebe",
        pink = "#f4b8e4",
        line = "#51576d",
        green = "#a6d189",
        vibrant_green = "#81c8be",
        nord_blue = "#85c1dc",
        blue = "#8caaee",
        yellow = "#e5c890",
        sun = "#ef9f76",
        purple = "#ca9ee6",
        dark_purple = "#ca9ee6",
        teal = "#81c8be",
        orange = "#ef9f76",
        cyan = "#99d1db",
        statusline_bg = "#292c3c",
        lightbg = "#414559",
        pmenu_bg = "#a6d189",
        folder_bg = "#8caaee",
        lavender = "#babbf1",
      },
      -- base_30 alone isn't enough: some core groups (e.g. Normal's bg) are
      -- pulled from base_16 (see base46/integrations/defaults.lua's
      -- `Normal = { bg = theme.base00 }`), a separate table with its own
      -- hardcoded hex values that base_30 overrides don't touch.
      base_16 = {
        base00 = "#303446",
        base01 = "#292c3c",
        base02 = "#414559",
        base03 = "#51576d",
        base04 = "#626880",
        base05 = "#c6d0f5",
        base06 = "#f2d5cf",
        base07 = "#babbf1",
        base08 = "#e78284",
        base09 = "#ef9f76",
        base0A = "#e5c890",
        base0B = "#a6d189",
        base0C = "#81c8be",
        base0D = "#8caaee",
        base0E = "#ca9ee6",
        base0F = "#eebebe",
      },
    },
  },
}

return M
