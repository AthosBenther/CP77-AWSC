Mod = {
    descrition = "Sandbox"
}

require("vendors/autoloader")
Autoloader.init()
Config.Init()
Mod.init = Main.init()
FileManager.save("", "../" .. config("app.shortName") .. ".log")

return Mod
