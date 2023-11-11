Mod = {
    descrition = "Advanced Weapon Stat Customization"
}

require("vendors/autoloader")
Autoloader.init()
Config.Init()
local a = config("app.enabled", true)

FileManager.save("", "../" .. config("app.shortName") .. ".log")

if config("app.enabled", true) then
    Mod.init = Main.init()
else
    Mod.init = os.exit()
end

return Mod
