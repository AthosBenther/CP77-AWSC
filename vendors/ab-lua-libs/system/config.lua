---@diagnostic disable: lowercase-global
Config = {
}

local configs = {}

function Config.Init()
    local dirInfo = dir("./config")
    for _, path in pairs(dirInfo) do
        local kind = path.type
        local name = path.name
        if (kind == "file"
                and string.sub(name, - #".lua") == ".lua"
                and name ~= 'autoloader.lua') then
            local cfg = string.sub(name, 1, -1 - #".lua")
            configs[cfg] = dofile("./config/" .. name)[cfg]
                    end
    end
end

function config(config, default)
    default = default or nil

    local params = string_split(config, ".")
    local cfgLvl = configs

    for _, value in pairs(params) do
        cfgLvl = cfgLvl[value] or nil
    end

    return cfgLvl or default
end
