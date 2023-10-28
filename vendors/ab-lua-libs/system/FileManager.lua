FileManager = {
}

function FileManager.open(file)
    local file = io.open("storage/" .. file, "r");
    if not file then error("Could not read file '" .. file .. "'") end
    local content = file:read "*a"
    file:close()
    return content
end

function FileManager.openJson(file)
    local file = io.open("storage/" .. file, "r");
    if not file then error("Could not read file '" .. file .. "'") end
    local content = file:read "*a"
    file:close()
    return json.decode(content) or nil
end

function FileManager.saveAsJson(data, file)
    local content = json.encode(data)
    local file = io.open("storage/" .. file, "w+");
    if not file then error("Could not read file '" .. file .. "'") end
    file:write(content)
    file:close()
end

function FileManager.save(content, file)
    local file = io.open("storage/" .. file, "w+");
    if not file then error("Could not read file '" .. file .. "'") end
    file:write(content)
    file:close()
end

function FileManager.Exists(file)
    local file = io.open("storage/" .. file, "r");
    local exists = file ~= nil
    if exists then file:close() end
    return exists
end
