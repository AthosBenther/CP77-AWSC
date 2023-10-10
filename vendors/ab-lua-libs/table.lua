function table_filter(data, callback)
    local result = {}
    for key, value in ipairs(data) do
        if callback(key, value) then
            result[key] = value
        end
    end
    return result
end

function table_getValues(data)
    result = {}
    for key, value in pairs(data) do
        table.insert(result, value)
    end
    return result;
end

function table_contains(data, term)
    for index, value in ipairs(data) do
        if value == term then return true end
    end
    return false
end