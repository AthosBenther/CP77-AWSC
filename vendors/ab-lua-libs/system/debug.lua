local Debug = {
    channels = {
        console = 1,
        file = 2
    }
}

--- Dumps, then dies
---@param data any
function dd(data)
    log(data, nil, true)
    error("DUMP AND DIE")
end

function Debug.genDump(data, depth)
    depth = depth or 0
    local tabs = string.rep('\t', depth)
    if type(data) == 'table' then
        local s = '\n\t' .. tabs .. '{ '
        local i = 0

        for k, v in pairs(data) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '\n\t' .. tabs .. '[' .. k .. '] = ' .. Debug.genDump(v, depth + 1)
            i = i + 1
            if (#data >= i) then s = s .. ',' end
        end
        return s .. '\n\t' .. tabs .. '} '
    else
        return tostring(data)
    end
end

function log(data, toFile, die, force)
    toFile = toFile or false
    die = die or false
    force = force or false

    if config("app.debug") or force then
        if toFile then
            FileManager.save(Debug.genDump(data), "application.log")
        else
            print(Debug.genDump(data, 0))
        end
    end
    if die then error('LOG AND DIE') end
end
