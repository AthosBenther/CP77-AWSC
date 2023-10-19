Ranged = {}

function Ranged.Init()
    local ui = GetMod("nativeSettings")

    ui.addTab(
        "/AWSCRanged",
        "Adv. Weapons Stats"
    )

    local uiOptions = {}

    ui.addSubcategory(
        "/AWSCRanged/classSelector",
        "Class"
    )

    local options = table_keys(Main.weapons.RangedWeapon)
    local optionsLabels = table_map(options, function(k, v) return Main.classLabels[v] end)

    local activeClass = nil
    local setClass = function(value)
        ui.removeSubcategory("/AWSCRanged/class")
        ui.removeSubcategory("/AWSCRanged/kind")
        ui.removeSubcategory("/AWSCRanged/weapon")
        local class = options[value]
        local classLabel = Main.classLabels[class]
        ui.addSubcategory(
            "/AWSCRanged/class",
            classLabel
        )

        local kinds = table_keys(Main.weapons.RangedWeapon[class])
        local kindLabels = table_map(kinds, function(k, kind) return Main.kindLabels[kind] end)

        local setKind = function(value)
            ui.removeSubcategory("/AWSCRanged/kind")
            ui.removeSubcategory("/AWSCRanged/weapon")
            local kind = kinds[value]
            local kindLabel = Main.kindLabels[kind]
            ui.addSubcategory(
                "/AWSCRanged/kind",
                kindLabel
            )

            local weapons = table_keys(Main.weapons.RangedWeapon[class][kind])
            local weaponNames = table_map(weapons,
                function(k, weapon) return Main.weapons.RangedWeapon[class][kind][weapon].LocalizedName end)

            local setWeapon = function(value)
                ui.removeSubcategory("/AWSCRanged/weapon")
                local weaponRecordName = weapons[value]
                local weaponProperties = Main.weapons.RangedWeapon[class][kind][weaponRecordName]
                local stats = weaponProperties.stats
                local weaponName = weaponProperties.LocalizedName
                ui.addSubcategory(
                    "/AWSCRanged/weapon",
                    weaponName
                )
                -- Damage

                ui.addRangeFloat(
                    "/AWSCRanged/weapon",                       --path
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

                ui.addRangeFloat(
                    "/AWSCRanged/weapon",         --path
                    " Magazine",                  --label
                    "Base Magazine Capacity",     --description
                    1,                            --min
                    300,                          --max
                    1,                            --step
                    "%.0f",                       --format
                    stats.magazine.custom + 0.0,  --currentValue
                    stats.magazine.default + 0.0, --defaultValue
                    function(value)               --callback
                        Main.SetRecordValue(stats.magazine.flatPath, "value", value)
                        Main.weapons.RangedWeapon[class][kind][weaponRecordName].stats.magazine.custom =
                            value
                        FileManager.saveAsJson(Main.weapons, 'weapons.json')
                    end
                )
                Main.SetRecordValue(stats.magazine.flatPath, "value", stats.magazine.custom)


                -- CYCLE TIME

                ui.addRangeFloat(
                    "/AWSCRanged/weapon",                --path
                    " Cycle Time",                       --label
                    "Base Cycle Time (in Milliseconds)", --description
                    0.01,                                --min
                    5,                                   --max
                    0.001,                               --step
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

                ui.addRangeFloat(
                    "/AWSCRanged/weapon",               --path
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

                    ui.addRangeFloat(
                        "/AWSCRanged/weapon",                      --path
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

                    ui.addRangeFloat(
                        "/AWSCRanged/weapon",                      --path
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
            end

            ui.addSelectorString(
                "/AWSCRanged/kind",
                "Weapons",
                "Choose a weapon",
                weaponNames,
                1,
                1,
                setWeapon
            )

            setWeapon(1)
        end

        ui.addSelectorString(
            "/AWSCRanged/class",
            "Kinds",
            "Choose a kind",
            kindLabels,
            1,
            1,
            setKind
        )

        setKind(1)
    end

    ui.addSelectorString(
        "/AWSCRanged/classSelector",
        "Classes",
        "Choose a class",
        optionsLabels,
        1,
        1,
        setClass
    )

    setClass(1)

    for class, kinds in pairs(Main.weapons.RangedWeapon) do
        for kind, weapons in pairs(kinds) do
            for weapon, weaponProps in pairs(weapons) do
                for statIndex, stat in pairs(weaponProps.stats) do
                    Main.SetRecordValue(stat.flatPath, "value", stat.custom)
                end
            end
        end
    end
end

return Ranged
