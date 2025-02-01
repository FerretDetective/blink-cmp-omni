# blink-cmp-omni

> [!WARNING]
> This plugin will no longer be maintained as of the next blink.cmp release (0.11.x) since the feature has been upstreamed in this [PR](https://github.com/Saghen/blink.cmp/pull/1114).

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
                    ---@type blink-cmp-omni.OmniOpts
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
