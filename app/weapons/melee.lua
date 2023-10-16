Melee = {}

function Melee.Init()
    local ui = GetMod("nativeSettings")

    ui.addTab(
        "/AWSCMelee",
        "Adv. Melee Stats"
    )

    local uiOptions = {}
    for class, kinds in pairs(Main.weapons.MeleeWeapon) do
        uiOptions[class] = {}
        local iClass = (table_indexOfKey(Main.weapons.MeleeWeapon, class) * 1000)

        -- ui.addSubcategory(
        --     "/AWSCMelee/" .. class,
        --     iClass .. " " .. Main.classLabels[class],
        --     iClass
        -- )

        for kind, weapons in pairs(kinds) do
            uiOptions[class][kind] = {}
            local iKind = iClass + (table_indexOfKey(Main.weapons.MeleeWeapon[class], kind) * 100)

            -- ui.addSubcategory(
            --     "/AWSCMelee/" .. class .. kind,
            --     iKind .. "      " .. Main.kindLabels[kind],
            --     iKind
            -- )

            for weaponRecordName, weaponProperties in pairs(weapons) do
                local iWeapon = iKind + (table_indexOfKey(weapons, weaponRecordName) * 10)
                uiOptions[class][kind][weaponRecordName] = {}
                weaponProperties.LocalizedName = weaponRecordName


                local label = table.concat({
                    Main.classLabels[class],
                    Main.kindLabels[kind]
                }, " \\\\ ")

                local stats = weaponProperties.stats
                local subCategory = "/AWSCMelee/" .. weaponRecordName

                ui.addSubcategory(
                    subCategory,
                    label .. " \\\\ " .. weaponProperties.LocalizedName
                )

                -- Range
                uiOptions[class][kind][weaponRecordName]["Range"] =
                    ui.addRangeFloat(
                        "/AWSCMelee/" .. weaponRecordName,         --path
                        "Base Range",                              --label
                        "Base Range (Scales with weapon quality)", --description
                        1,                                         --min
                        30,                                        --max
                        1,                                         --step
                        "%.0f",                                    --format
                        stats.Range.custom + 0.0,                  --currentValue
                        stats.Range.default + 0.0,                 --defaultValue
                        function(value)                            --callback
                            Main.SetRecordValue(stats.Range.flatPath, "value", value)
                            Main.weapons.MeleeWeapon[class][kind][weaponRecordName].stats.Range.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    )
                Main.SetRecordValue(stats.Range.flatPath, "value", stats.Range.custom)
            end
        end
    end
end

return Melee
