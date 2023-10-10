function dd(data)
    print(dump(data))
    error("DUMP AND DIE")
end

function dump(data)
    
    local function genDump(data, depth)
        depth = depth or 0
        local tabs = string.rep('\t', depth)
        if type(data) == 'table' then
            local s = '\n\t' .. tabs .. '{ '
            local i = 0

            for k, v in pairs(data) do
                if type(k) ~= 'number' then k = '"' .. k .. '"' end
                s = s .. '\n\t' .. tabs .. '[' .. k .. '] = ' .. genDump(v, depth + 1)
                i = i + 1
                if (#data >= i) then s = s .. ',' end
            end
            return s .. '\n\t' .. tabs .. '} '
        else
            return tostring(data)
        end
    end
    print(genDump(data, 0))
end
