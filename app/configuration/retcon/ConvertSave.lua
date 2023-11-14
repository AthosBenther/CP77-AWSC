ConvertSave = {}

function ConvertSave.Init()
    if FileManager.Exists(config("storage.weapons")) then
        FileManager.save(FileManager.open(config("storage.weapons")),
            "bkp/" .. get_date_time_safe_string() .. "-weapons.json")


        local file = FileManager.openJson(config("storage.weapons"))
        if not file.Version then
            ConfigFile.oldWeapons = FileManager.openJson(config("storage.weapons"))
            for range, classes in pairs(ConfigFile.oldWeapons) do
                for class, kinds in pairs(classes) do
                    for kind, weapons in pairs(kinds) do
                        for weapon, wStats in pairs(weapons) do
                            --dd(wStats.stats)
                            local Stats = {}
                            Stats.Variants = {}
                            Stats.Variants.Default = {}
                            Stats.Variants.Default.Stats = {}

                            if not wStats.stats then
                                log("ConvertSave: " .. weapon .. " doesnt have stats")
                            else
                                for statKey, statValues in pairs(wStats.stats) do
                                    Stats.Variants.Default.Stats[string_capitalize(statKey)] = statValues
                                end
                            end

                            ConfigFile.oldWeapons[range][class][kind][weapon] = Stats
                        end
                    end
                end
            end
        elseif file.Version == "0.7" then
            ConfigFile.oldWeapons = FileManager.openJson(config("storage.weapons"))
        else
            log("ConvertSave: the file '" ..
            config("storage.weapons") .. "' is not a an recognized (^0.6) AWSC save file. ")
            return false
        end
        return true
    end
end

return ConvertSave
