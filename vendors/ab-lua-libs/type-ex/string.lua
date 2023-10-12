function string_startsWith(subject, start)
    return tostring(subject):sub(1, #start) == start
end

function string_split(subject, separator)
    separator = separator or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    local result = tostring(subject):gsub( pattern, function(c) fields[#fields + 1] = c end)
    return fields
end