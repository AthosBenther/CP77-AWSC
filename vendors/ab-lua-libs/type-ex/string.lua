---@diagnostic disable: lowercase-global

--- Capitalizes the first letter of a given string.
---@param subject string The input string.
---@return string result The modified string with the first letter capitalized.
function string_capitalize(subject)
    return subject:gsub("^%l", string.upper) or subject
end

--- Checks if a string contains any of the provided substrings.
---@param subject string The string to search in.
---@param ... string One or more strings to search for.
---@return boolean result True if any of the substrings are found, otherwise false.
function string_contains(subject, ...)
    local args = ...

    if type(...) == "string" then
        args = { ... }
    end

    for index, arg in ipairs(args) do
        if string.find(subject, arg, 1, true) ~= nil then return true end
    end
    return false
end

--- Checks if a string ends with a specific substring.
---@param subject string The string to check.
---@param ending string The substring to check for.
---@return boolean True if the string ends with the provided substring, otherwise false.
function string_endsWith(subject, ending)
    return ending == "" or tostring(subject):sub(- #ending) == ending
end

--- Splits a string into an array of substrings using a specified separator.
---@param subject string The string to split.
---@param separator string The delimiter used to split the string (default is ":").
---@return table An array of substrings.
function string_split(subject, separator)
    separator = separator or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    local result = tostring(subject):gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

--- Checks if a string starts with a specific substring.
---@param subject string The string to check.
---@param start string The substring to check for at the beginning of the string.
---@return boolean True if the string starts with the provided substring, otherwise false.
function string_startsWith(subject, start)
    return tostring(subject):sub(1, #start) == start
end
