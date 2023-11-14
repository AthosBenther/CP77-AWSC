---@diagnostic disable: lowercase-global
tFlat = {

    get = function(obj, path, default)

        -- get path array
        path = tFlat.split(path)

        -- vars
        local length = #path
        local current = obj
        local key

        -- loop through path
        for index = 1, length, 1 do

            -- current key
            key = path[ index ]

            -- convert key to number (sequential table)
            if tonumber(key) then
                key = tonumber(key)
            end

            -- stop searching if a child object is missing
            if current[ key ] == nil then
                return default
            end

            current = current[ key ]

        end

        return current

    end,

    has = function(obj, path)
        return tFlat.get(obj, path) ~= nil
    end,

    set = function(obj, path, val)

        -- get path array
        path = tFlat.split(path)

        -- vars
        local length = #path
        local current = obj
        local key

        -- loop through path
        for index = 1, length, 1 do

            -- current key
            key = path[ index ]

            -- convert key to number (sequential table)
            if tonumber(key) then
                key = tonumber(key)
            end

            -- set value on last key
            if index == length  then
                current[ key ] = val

            -- current key exists
            elseif current[ key ] then

                if type(current[ key ]) ~= 'table' then
                    current[ key ] = {}
                end

                current = current[ key ]

            -- current key doesn't exist
            else
                current[ key ] = {}
                current = current[ key ]

            end

        end

        -- return
        return obj

    end,

    insert = function(obj, path, val)

        -- get target
        local target = tFlat.get(obj, path)

        -- check if table and sequential
        if type(target) == 'table' and tFlat.isSequential(target) then
            table.insert(target, val)
        end

        -- return
        return obj

    end,

    delete = function(obj, path)

        -- get path array
        path = tFlat.split(path)
        
        -- vars
        local length = #path
        local current = obj
        local key

        -- loop through path
        for index = 1, length, 1 do

            -- current key
            key = path[ index ]

            -- convert key to number (sequential table)
            if tonumber(key) then
                key = tonumber(key)
            end

            -- set value on last key
            if index == length then
                current[ key ] = nil
            else
                current = current[ key ] or {}
            end

        end

        -- return
        return obj

    end,

    split = function(s)

        s = tostring(s)
        local fields = {}
        local pattern = string.format("([^%s]+)", '.')

        string.gsub(s, pattern, function(c)
            fields[ #fields + 1 ] = c
        end)

        return fields

    end,

    isSequential = function(array)
        for k, _ in pairs(array) do
            if type(k) ~= "number" then
                return false
            end
        end
        return true
    end,

}

return tFlat