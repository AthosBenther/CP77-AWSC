MoveBase = {}

function MoveBase.init()
    Main.weapons = FileManager.openJson("weapons.json")
    for class, kinds in pairs(Main.weapons.RangedWeapon) do
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
                Main.weapons.RangedWeapon[class][kind][weapon].weaponProps = weaponProps
            end
        end
    end
    FileManager.saveAsJson(Main.weapons, "weapons2.json")
end

return MoveBase
