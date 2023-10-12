Autoloader = {
    folders = {
        'app',
        'vendors'
    },
    modulesLoaded = {}
}

function Autoloader.init()
    for index, folder in ipairs(Autoloader.folders) do
        Autoloader.scanAndLoad(folder)
    end
end

function Autoloader.scanAndLoad(folder, absolutePath)
    absolutePath = absolutePath or ""
    local dirInfo = dir("./" .. folder)
    if  type(dirInfo) ~= "table" then log({dirInfo,folder,absolutePath}) end
    for _, path in pairs(dirInfo) do
        local kind = path.type
        local name = path.name
        if (kind == "file"
                and string.sub(name, - #".lua") == ".lua"
                and name ~= 'autoloader.lua') then
            if not (require(folder .. "/" .. name) == false) then
                table.insert(Autoloader.modulesLoaded, folder .. "/" .. name)
            end
        elseif kind == "directory" then
            Autoloader.scanAndLoad(folder .. "/" .. name, absolutePath .. "/" .. folder)
        end
    end
end
