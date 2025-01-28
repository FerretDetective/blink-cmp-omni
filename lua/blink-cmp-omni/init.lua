---@module "blink.cmp"

---@class blink-cmp-omni.Source : blink.cmp.Source
---@field config blink.cmp.SourceProviderConfig
local Source = {}

---@class blink-cmp-omni.Options
local defaults = {
    ---disable on certain omnifuncs
    ---@type string[]?
    disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
    ---disable on certain filetypes
    ---@type string[]?
    disable_filetypes = {},
}

---@class blink-cmp-omni.CompleteItem
---@field word string
---@field abbr string?
---@field menu string?
---@field info string?
---@field kind string?
---@field icase integer?
---@field equal integer?
---@field dup integer?
---@field empty integer?
---@field user_data any?

---@param id string
---@param config blink.cmp.SourceProviderConfig
---@return blink-cmp-omni.Source
function Source.new(id, config)
    local self = setmetatable({}, { __index = Source })

    self.id = id
    self.name = config.name
    self.module = config.module
    self.config = config
    self.list = nil
    self.resolve_cache = {}
    self.config.opts = vim.tbl_deep_extend("force", defaults, self.config.opts or {})

    return self
end

function Source:enabled()
    return vim.bo.omnifunc ~= ""
        and vim.api.nvim_get_mode().mode == "i"
        and not vim.tbl_contains(self.config.opts.disable_omnifuncs, vim.bo.omnifunc)
        and not vim.tbl_contains(self.config.opts.disable_filetypes, vim.bo.filetype)
end

---Invoke an omnifunc handling `v:lua.*`
---@param func string
---@param ... any
---@return any
local function invoke_omnifunc(func, ...)
    local args = { ... }
    local prev_pos = vim.api.nvim_win_get_cursor(0)

    local _, result = pcall(function()
        local match = func:match("^v:lua%.(.+)$")
        if match then
            -- string.sub [2, -2] range removes surround '{' and '}'
            return loadstring(string.format("%s(%s)", match, vim.inspect(args):sub(2, -2)))()
        else
            return vim.api.nvim_call_function(func, args)
        end
    end)

    local next_pos = vim.api.nvim_win_get_cursor(0)
    if prev_pos[1] ~= next_pos[1] or prev_pos[2] ~= next_pos[2] then
        vim.api.nvim_win_set_cursor(0, prev_pos)
    end

    return result
end

---@param context blink.cmp.Context
---@param resolve fun(response?: blink.cmp.CompletionResponse)
function Source:get_completions(context, resolve)
    -- for info on omnifunc see `:h 'omnifunc'`, and `:h complete-functions`

    -- get the starting column from which completion will start
    local start_col = invoke_omnifunc(vim.bo.omnifunc, 1, "")
    local cur_line, cur_col = unpack(context.cursor)

    -- FIXME: differentiate between staying in (-2) vs leaving (-3) completions mode.
    if start_col == -2 or start_col == -3 then
        resolve()
        return
    elseif start_col < 0 or start_col > cur_col then
        start_col = cur_col
    end

    -- for info on omnifunc results see `:h complete-items`
    -- get the actual omnifunc completion results
    local cmp_results =
        invoke_omnifunc(vim.bo.omnifunc, 0, string.sub(context.line, start_col + 1, cur_col))
    cmp_results = cmp_results["words"] or cmp_results ---@type (string|blink-cmp-omni.CompleteItem)[]

    local range = {
        ["start"] = {
            line = cur_line - 1,
            character = start_col,
        },
        ["end"] = {
            line = cur_line - 1,
            character = cur_col,
        },
    }

    local items = {} ---@type blink.cmp.CompletionItem[]
    for _, cmp in ipairs(cmp_results) do
        if type(cmp) == "string" then
            table.insert(items, {
                label = cmp,
                textEdit = {
                    range = range,
                    newText = cmp,
                },
            })
        else
            table.insert(items, {
                label = cmp.abbr or cmp.word,
                textEdit = {
                    range = range,
                    newText = cmp.word,
                },
                labelDetails = {
                    detail = cmp.kind,
                    description = cmp.menu,
                },
            })
        end
    end

    resolve({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
end

return Source
