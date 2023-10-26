MoveBase = {}

function MoveBase.init()
    ConfigFile.weapons = FileManager.openJson("weapons.json")
    for class, kinds in pairs(ConfigFile.weapons.RangedWeapon) do
        for kind, weapons in pairs(kinds) do
            for weapon, weaponProps in pairs(weapons) do
                if not weaponProps.variants then
                    weaponProps.variants = {}
                end
                if not weaponProps.variants.base then
                    if not weaponProps.stats then
                        dd(weapon .. " doesnt have stats")
                    else
                        weaponProps.variants.base = weaponProps.stats
                        weaponProps = table_remove(weaponProps,"stats")
                    end
                end
                ConfigFile.weapons.RangedWeapon[class][kind][weapon].weaponProps = weaponProps
            end
        end
    end
    FileManager.saveAsJson(ConfigFile.weapons, "weapons2.json")
end

return MoveBase
