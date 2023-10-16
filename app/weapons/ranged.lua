Ranged = {}

function Ranged.Init()
    local ui = GetMod("nativeSettings")

    ui.addTab(
        "/AWSCRanged",
        "Adv. Weapons Stats"
    )

    local uiOptions = {}
    for class, kinds in pairs(Main.weapons.RangedWeapon) do
        uiOptions[class] = {}
        local iClass = (table_indexOfKey(Main.weapons.RangedWeapon, class) * 1000)

        -- ui.addSubcategory(
        --     "/AWSCRanged/" .. class,
        --     iClass .. " " .. Main.classLabels[class],
        --     iClass
        -- )

        for kind, weapons in pairs(kinds) do
            uiOptions[class][kind] = {}
            local iKind = iClass + (table_indexOfKey(Main.weapons.RangedWeapon[class], kind) * 100)

            -- ui.addSubcategory(
            --     "/AWSCRanged/" .. class .. kind,
            --     iKind .. "      " .. Main.kindLabels[kind],
            --     iKind
            -- )

            for weaponRecordName, weaponProperties in pairs(weapons) do
                local iWeapon = iKind + (table_indexOfKey(weapons, weaponRecordName) * 10)
                uiOptions[class][kind][weaponRecordName] = {}


                local label = table.concat({
                    Main.classLabels[class],
                    Main.kindLabels[kind]
                }, " \\\\ ")

                local stats = weaponProperties.stats
                local subCategory = "/AWSCRanged/" .. weaponRecordName

                ui.addSubcategory(
                    subCategory,
                    label .. " \\\\ " .. weaponProperties.LocalizedName
                )

                if not stats.damage.custom then dd(weaponRecordName) end

                -- Damage
                uiOptions[class][kind][weaponRecordName]["damage"] =
                    ui.addRangeFloat(
                        "/AWSCRanged/" .. weaponRecordName,         --path
                        " Base Damage",                             --label
                        "Base Damage (Scales with weapon quality)", --description
                        1,                                          --min
                        3000,                                       --max
                        1,                                          --step
                        "%.0f",                                     --format
                        stats.damage.custom + 0.0,                  --currentValue
                        stats.damage.default + 0.0,                 --defaultValue
                        function(value)                             --callback
                            Main.SetRecordValue(stats.damage.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.damage.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    )
                Main.SetRecordValue(stats.damage.flatPath, "value", stats.damage.custom)

                -- MAGAZINE
                uiOptions[class][kind][weaponRecordName]["magazine"] =
                    ui.addRangeFloat(
                        "/AWSCRanged/" .. weaponRecordName, --path
                        " Magazine",                        --label
                        "Base Magazine Capacity",           --description
                        1,                                  --min
                        300,                                --max
                        1,                                  --step
                        "%.0f",                             --format
                        stats.magazine.custom + 0.0,        --currentValue
                        stats.magazine.default + 0.0,       --defaultValue
                        function(value)                     --callback
                            Main.SetRecordValue(stats.magazine.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.magazine.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    )
                Main.SetRecordValue(stats.magazine.flatPath, "value", stats.magazine.custom)


                -- CYCLE TIME
                uiOptions[class][kind][weaponRecordName]["cycleTime"] =
                    ui.addRangeFloat(
                        "/AWSCRanged/" .. weaponRecordName,  --path
                        " Cycle Time",                       --label
                        "Base Cycle Time (in Milliseconds)", --description
                        0.01,                                --min
                        5,                                   --max
                        0.01,                                --step
                        "%.3f",                              --format
                        stats.cycleTime.custom + 0.0,        --currentValue
                        stats.cycleTime.default + 0.0,       --defaultValue
                        function(value)                      --callback
                            Main.SetRecordValue(stats.cycleTime.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.cycleTime.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    )
                Main.SetRecordValue(stats.cycleTime.flatPath, "value", stats.cycleTime.custom)

                -- EFFECTIVE RANGE
                uiOptions[class][kind][weaponRecordName]["EffectiveRange"] =
                    ui.addRangeFloat(
                        "/AWSCRanged/" .. weaponRecordName, --path
                        stats.EffectiveRange.uiLabel,       --label
                        stats.EffectiveRange.uiDescription, --description
                        0.1,                                --min
                        100,                                --max
                        0.1,                                --step
                        "%.1f",                             --format
                        stats.EffectiveRange.custom + 0.0,  --currentValue
                        stats.EffectiveRange.default + 0.0, --defaultValue
                        function(value)                     --callback
                            Main.SetRecordValue(stats.EffectiveRange.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.EffectiveRange.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    )
                Main.SetRecordValue(stats.EffectiveRange.flatPath, "value", stats.EffectiveRange.custom)


                if class == "SmartWeapon" then
                    -- SmartGunHipTimeToLock
                    uiOptions[class][kind][weaponRecordName]["SmartGunHipTimeToLock"] =
                        ui.addRangeFloat(
                            "/AWSCRanged/" .. weaponRecordName,        --path
                            stats.SmartGunHipTimeToLock.uiLabel,       --label
                            stats.SmartGunHipTimeToLock.uiDescription, --description
                            0.001,                                     --min
                            3,                                         --max
                            0.001,                                     --step
                            "%.3f",                                    --format
                            stats.SmartGunHipTimeToLock.custom + 0.0,  --currentValue
                            stats.SmartGunHipTimeToLock.default + 0.0, --defaultValue
                            function(value)                            --callback
                                Main.SetRecordValue(stats.SmartGunHipTimeToLock.flatPath, "value", value)
                                Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.SmartGunHipTimeToLock.custom =
                                    value
                                FileManager.saveAsJson(Main.weapons, 'weapons.json')
                            end
                        )
                    Main.SetRecordValue(stats.SmartGunHipTimeToLock.flatPath, "value", stats.SmartGunHipTimeToLock
                        .custom)

                    -- SmartGunAdsTimeToLock
                    uiOptions[class][kind][weaponRecordName]["SmartGunAdsTimeToLock"] =
                        ui.addRangeFloat(
                            "/AWSCRanged/" .. weaponRecordName,        --path
                            stats.SmartGunAdsTimeToLock.uiLabel,       --label
                            stats.SmartGunAdsTimeToLock.uiDescription, --description
                            0.001,                                     --min
                            3,                                         --max
                            0.001,                                     --step
                            "%.3f",                                    --format
                            stats.SmartGunAdsTimeToLock.custom + 0.0,  --currentValue
                            stats.SmartGunAdsTimeToLock.default + 0.0, --defaultValue
                            function(value)                            --callback
                                Main.SetRecordValue(stats.SmartGunAdsTimeToLock.flatPath, "value", value)
                                Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.SmartGunAdsTimeToLock.custom =
                                    value
                                FileManager.saveAsJson(Main.weapons, 'weapons.json')
                            end
                        )
                    Main.SetRecordValue(stats.SmartGunAdsTimeToLock.flatPath, "value", stats.SmartGunAdsTimeToLock
                        .custom)
                end

                -- TRIGGER MODE
                -- Has to be eddited on Preset_Weapon_Default
                -- Has to change .primaryTriggerMode AND .triggerModes
                -- Complete pain in the ass

                -- uiOptions[class][kind][weaponRecordName]["triggerMode"] =
                --     ui.addSelectorString(
                --         "/AWSCRanged/" .. weaponRecordName, --path
                --         " Trigger Mode",              --label
                --         "Trigger Mode",               --description
                --         Main.triggerModes,            --min
                --         1,                            --currentValue
                --         1,                            --defaultValue
                --         function(value)               --callback
                --             local label = Main.triggerModes[value]
                --             local statValue = Main.triggerModesLabels[label]

                --             Main.SetRecordValue(stats.triggerMode.flatPath, statValue)
                --             Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.triggerMode.custom =
                --                 statValue
                --         end
                --     )
                -- Main.SetRecordValue(stats.triggerMode.flatPath, "triggerMode", stats.triggerMode.custom)
            end
        end
    end
end

return Ranged
