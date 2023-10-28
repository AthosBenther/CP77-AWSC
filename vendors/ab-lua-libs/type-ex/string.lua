---@diagnostic disable: lowercase-global
function string_startsWith(subject, start)
    return tostring(subject):sub(1, #start) == start
end

function string_endsWith(subject, ending)
    return ending == "" or tostring(subject):sub(- #ending) == ending
end

function string_split(subject, separator)
    separator = separator or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    local result = tostring(subject):gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string_contains(subject, ...)
    local args = ...

    if type(...) == "string" then
        args = {...}
    end

    for index, arg in ipairs(args) do
        if string.find(subject, arg, 1, true) ~= nil then return true end
    end
    return false
end
