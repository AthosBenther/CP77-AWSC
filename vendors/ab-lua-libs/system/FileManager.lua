FileManager = {
}

function FileManager.load(file)
    local file = io.open("storage/" .. file, "r");
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function FileManager.loadJson(file)
    local file = io.open("storage/" .. file, "r");
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return json.decode(content)
end

function FileManager.saveAsJson(array,file)
    local content = json.encode(array)
    local file = io.open("storage/" .. file, "w+");
    if not file then return nil end
    file:write(content)
    file:close()
end

function FileManager.save(content,file)
    local file = io.open("storage/" .. file, "w+");
    if not file then return nil end
    file:write(content)
    file:close()
end