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
    local result = {}
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

function table_unset(data, key)
    local result = {}
    for tKey, value in pairs(data) do
        if key ~= tKey then
            result[tKey] = value
        end
    end
    return result;
end

function table_indexOfKey(data, key)
    local i = 1
    for tKey, value in pairs(data) do
        if key == tKey then return i end
        i = i + 1
    end
    return nil
end

function table_keys(data)
    local keys = {}
    for key, value in pairs(data) do
        table.insert(keys, key)
    end
    return keys
end

function table_map(data, callback)
    for key, value in pairs(data) do
        data[key] = callback(key, value)
    end
    return data
end

function table_intersect(dataA, dataB, keepKeys)
    keepKeys = keepKeys or false
    local intersection = {}
    for keyA, valueA in pairs(dataA) do
        for keyB, valueB in pairs(dataB) do
            if valueA == valueB then
                if keepKeys then
                    intersection[keyA] = valueA
                else
                    table.insert(intersection, valueA)
                end
            end
        end
    end
    return intersection
end
