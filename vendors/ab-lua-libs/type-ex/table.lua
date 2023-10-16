---@diagnostic disable: lowercase-global


function table_contains(data, term)
    for index, value in ipairs(data) do
        if value == term then return true end
    end
    return false
end

function table_containsKey(data, term)
    if not data then return false end
    return table_contains(table_keys(data), term)
end

--- Counts table values.
---@param data table The table to be counted
---@param recursive? boolean Counts values of subtables
---@return integer count
function table_count(data, recursive)
    recursive = recursive or false
    local count = 0

    for _, v in pairs(data) do
        if type(v) == "table" then
            if recursive then
            else
                count = count + 1
            end
        else
            count = count + 1
        end
    end
    return count
end

function table_filter(data, callback)
    local result = {}
    for key, value in ipairs(data) do
        if callback(key, value) then
            result[key] = value
        end
    end
    return result
end

---Iterates through a table following the keys order
---@param data table
---@param callback function
---@return nil
function table_foreach(data, callback)
    if data == nil then return nil end
    local tKeys = table_keys(data)
    local tCount = table_count(tKeys)
    table.sort(tKeys)

    for i = 1, tCount, 1 do
        local tKey = tKeys[i]
        return callback(tKey, data[tKey])
    end
end

function table_getValues(data)
    local result = {}
    for key, value in pairs(data) do
        table.insert(result, value)
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

---Computes the intersection of arrays
---@param dataA table The table with master values to check.
---@param dataB table Table to compare values against
---@param keepKeys? boolean Indicates if keys are preserved
---@return table result Returns a table containing all the values of tables that are present in all the arguments

function table_unset(data, key)
    local result = {}
    for tKey, value in pairs(data) do
        if key ~= tKey then
            result[tKey] = value
        end
    end
    return result;
end

function table_update(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            table_update(target[key], value)
        else
            if target[key] == nil then
                target[key] = value
            end
        end
    end
    return target
end
