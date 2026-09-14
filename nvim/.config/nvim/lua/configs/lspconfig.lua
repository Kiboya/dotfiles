require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- NvChad's wildcard on_init (nvchad.configs.lspconfig, set via `defaults()`
-- above) deletes semanticTokensProvider from every client's capabilities as
-- its default opt-out for semantic highlighting. `ty` advertises this
-- capability and Neovim's semantic tokens engine is enabled by default, so
-- override on_init for `ty` only, as a no-op, letting its capability survive.
-- Must be set before `vim.lsp.enable` below: if the buffer's FileType has
-- already fired (e.g. `nvim src/main.py` straight from the shell), enable()
-- starts the client synchronously using whatever config exists at that point.
vim.lsp.config("ty", {
  on_init = function() end,
})

-- ty (type checker) + ruff (linter/formatter), shipped by nvim-lspconfig's
-- lsp/ty.lua and lsp/ruff.lua; installed via `uv tool install ty|ruff`
vim.lsp.enable({ "ty", "ruff" })

-- read :h vim.lsp.config for changing options of lsp servers 
