function string_startsWith(string, start)
    return tostring(string):sub(1, #start) == start
end

function string_split(string, separator)
    separator = separator or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    local result = tostring(string):gsub( pattern, function(c) fields[#fields + 1] = c end)
    return fields
end