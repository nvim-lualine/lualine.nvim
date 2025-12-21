-- Current Language
-- local lang = string.sub(vim.v.lang, 1, 2)

local lang = os.getenv("NVIM_TEST") and "en" or string.sub(vim.v.lang, 1, 2)
local M = {}
local info = debug.getinfo(1, "S")
local script_dir = info.source:sub(2):match("(.*/)")
local po_path = script_dir .. "/../../po/" .. lang .. ".po"

-- Basic PO file parser
local function parse_po(path)
    local file = io.open(path, "r")
    if not file then return {} end

    local translations = {}
    local mode = nil
    local current_msgid = {}
    local current_msgstr = {}

    local function unescape(str)
        return str:gsub('\\"', '"'):gsub("\\n", "\n")
    end

    for line in file:lines() do
        if line:match('^msgid%s+"') then
            mode = "msgid"
            current_msgid = { line:match('^msgid%s+"(.*)"') }
            current_msgstr = {}
        elseif line:match('^msgstr%s+"') then
            mode = "msgstr"
            current_msgstr = { line:match('^msgstr%s+"(.*)"') }
        elseif line:match('^"') then
            local str = line:match('^"(.*)"')
            if mode == "msgid" then
                table.insert(current_msgid, str)
            elseif mode == "msgstr" then
                table.insert(current_msgstr, str)
            end
        elseif line == "" then
            -- End of one entry
            if #current_msgid > 0 and #current_msgstr > 0 then
                local msgid_text = unescape(table.concat(current_msgid))
                local msgstr_text = unescape(table.concat(current_msgstr))
                translations[msgid_text] = msgstr_text
            end
            mode = nil
            current_msgid = {}
            current_msgstr = {}
        end
    end

    -- Handle the last entry if file doesn't end with blank line
    if #current_msgid > 0 and #current_msgstr > 0 then
        local msgid_text = unescape(table.concat(current_msgid))
        local msgstr_text = unescape(table.concat(current_msgstr))
        translations[msgid_text] = msgstr_text
    end

    file:close()
    return translations
end

-- Load translations
local translatedTable = parse_po(po_path)

--- This function returns the translation if available and not empty
--- @param description string Description to translate
--- @param values string[]? Optional list of variables
--- @return string
function M.Msgstr(description, values)
    local translated = translatedTable[description]
    if not translated or translated == "" then
        translated = description
    end

    if values then
        local unpack = table.unpack or unpack

        local ok, formatted = pcall(string.format, translated, unpack(values))
        if ok then
            translated = formatted
        end
    end

    return translated
end

return M
