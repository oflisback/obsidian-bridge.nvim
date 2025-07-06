-- This is the encodeURI implementation from lua-http, see
-- https://github.com/daurnimator/lua-http/blob/master/http/util.lua

-- Encodes a character as a percent encoded string
local function char_to_pchar(c)
    return string.format("%%%02X", c:byte(1, 1))
end

local M = {}

-- encodeURI replaces all characters except the following with the appropriate UTF-8 escape sequences:
-- ; , / ? : @ & = + $
-- alphabetic, decimal digits, - _ . ! ~ * ' ( )
-- #
M.EncodeURI = function(str)
    return (str:gsub("[^%;%,%/%?%:%@%&%=%+%$%w%-%_%.%!%~%*%'%(%)%#]", char_to_pchar))
end


-- This is the decodeURI from: https://stackoverflow.com/a/20407113
local hex = {}
for i = 0, 255 do
    hex[string.format("%02x", i)] = string.char(i)
    hex[string.format("%02X", i)] = string.char(i)
end

M.DecodeURI = function(str)
    return (str:gsub('%%(%x%x)', hex))
end


-- joins path in an OS-agnostic manner
M.pathJoin = function(from, to)
    -- https://stackoverflow.com/a/37953903
    local path_separator = package.config:sub(1, 1)
    -- Remove trailing separator from 'from' if it exists
    if from:sub(-1) == path_separator then
        from = from:sub(1, -2)
    end
    -- Remove leading separator from 'to' if it exists
    if to:sub(1, 1) == path_separator then
        to = to:sub(2)
    end
    -- Concatenate the paths with a single separator
    return from .. path_separator .. to
end

M.parseRequestHeaders = function(headerArray)
    local headers = {}
    for _, header in ipairs(headerArray) do
        -- Find the position of the first colon
        local colonPos = header:find(":")
        if colonPos then
            -- Extract the header name and value
            local name = header:sub(1, colonPos - 1):gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
            local value = header:sub(colonPos + 1):gsub("^%s*(.-)%s*$", "%1")   -- Trim whitespace
            -- Initialize the table for this header if it doesn't exist
            if not headers[name] then
                headers[name] = {}
            end
            -- Insert the value into the table
            table.insert(headers[name], value)
        end
    end
    return headers
end

return M
