# blink-cmp-omni

[blink.cmp](https://github.com/saghen/blink.cmp) source for Neovim's omni-func completions.

## Requirements
- Neovim 0.10+
- blink.cmp

## Installation

### Lazy.nvim
```lua
{
    "saghen/blink.cmp",
    dependencies = {
        "FerretDetective/blink-cmp-omni",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "lazydev", "omni" },
            providers = {
                omni = {
                    name = "blink-cmp-omni",
                    module = "blink-cmp-omni",
                    ---@module "blink-cmp-omni"
                    ---@type blink-cmp-omni.Options
                    opts = {
                        -- Default configuration

                        -- Disable the source on certain omnifuncs
                        ---@type string[]?
                        disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },

                        -- Disable the source on certain filetypes
                        ---@type string[]?
                        disable_filetypes = {},
                    },
                },
            },
        },
    },
}
```
