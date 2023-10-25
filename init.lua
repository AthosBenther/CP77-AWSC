Mod = {
    descrition = "Sandbox"
}

require("vendors/autoloader")
Autoloader.init()
Config.Init()
Mod.init = Main.init()
FileManager.save("", "../" .. config("app.shortName") .. ".log")
dd("app_enable", config("app.enable", true))
if config("app.enabled", true) then return Mod end
