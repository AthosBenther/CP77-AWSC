RangedUI = {}

function RangedUI.Init()
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
        ui.removeSubcategory("/AWSCRanged/variant")

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
            ui.removeSubcategory("/AWSCRanged/variant")

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
                ui.removeSubcategory("/AWSCRanged/variant")

                local weaponLabel = weaponNames[value]
                local weaponRecordName = weapons[value]

                local weaponName = table_filter(weapons,
                    function(k, weapon)
                        return Main.weapons.RangedWeapon[class][kind][weapon].LocalizedName ==
                            weaponLabel
                    end)[1]
                local weapon = Main.weapons.RangedWeapon[class][kind][weaponName]
                local variantNames = {
                    [1] = "Base",
                    [2] = "Default"
                }

                local vars = table_values(table_map(weapon.variants, function(k, w) return w.localizedName or k end))

                for key, name in pairs(vars) do
                    if not table_contains(variantNames, name) then table.insert(variantNames, name) end
                end

                ui.addSubcategory(
                    "/AWSCRanged/weapon",
                    weaponName
                )

                local setVariant = function(value)
                    ui.removeSubcategory("/AWSCRanged/variant")

                    local variantName = variantNames[value]


                    local vKey = ""

                    for variantKey, variantValue in pairs(weapon.variants) do
                        if weapon.variants.LocalizedName then
                            if weapon.variants.LocalizedName == variantName then vKey = variantKey end
                        elseif variantKey == variantName then
                            vKey = variantKey
                        end
                    end

                    local variant = weapon.variants[vKey]

                    -- local weaponProperties = Main.weapons.RangedWeapon[class][kind][weaponRecordName].variants
                    --     [variantKey]
                    -- local stats = weaponProperties.stats


                    ui.addSubcategory(
                        "/AWSCRanged/variant",
                        variantName
                    )


                    -- Damage

                    pcall(ui.addRangeFloat(
                        "/AWSCRanged/variant",                      --path
                        "Base Damage",                              --label
                        "Base Damage (Scales with weapon quality)", --description
                        1,                                          --min
                        3000,                                       --max
                        1,                                          --step
                        "%.0f",                                     --format
                        variant.damage.custom + 0.0,                --currentValue
                        variant.damage.default + 0.0,               --defaultValue
                        function(value)                             --callback
                            Main.SetRecordValue(variant.damage.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.damage.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    ))
                    Main.SetRecordValue(variant.damage.flatPath, "value", variant.damage.custom)

                    -- MAGAZINE

                    pcall(ui.addRangeFloat(
                        "/AWSCRanged/variant",          --path
                        "Magazine",                     --label
                        "Base Magazine Capacity",       --description
                        1,                              --min
                        300,                            --max
                        1,                              --step
                        "%.0f",                         --format
                        variant.magazine.custom + 0.0,  --currentValue
                        variant.magazine.default + 0.0, --defaultValue
                        function(value)                 --callback
                            Main.SetRecordValue(variant.magazine.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.magazine.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    ))
                    Main.SetRecordValue(variant.magazine.flatPath, "value", variant.magazine.custom)


                    -- CYCLE TIME

                    pcall(ui.addRangeFloat(
                        "/AWSCRanged/variant",               --path
                        "Cycle Time",                        --label
                        "Base Cycle Time (in Milliseconds)", --description
                        0.01,                                --min
                        5,                                   --max
                        0.001,                               --step
                        "%.3f",                              --format
                        variant.cycleTime.custom + 0.0,      --currentValue
                        variant.cycleTime.default + 0.0,     --defaultValue
                        function(value)                      --callback
                            Main.SetRecordValue(variant.cycleTime.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.cycleTime.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    ))
                    Main.SetRecordValue(variant.cycleTime.flatPath, "value", variant.cycleTime.custom)

                    -- EFFECTIVE RANGE

                    pcall(ui.addRangeFloat(
                        "/AWSCRanged/variant",                --path
                        variant.EffectiveRange.uiLabel,       --label
                        variant.EffectiveRange.uiDescription, --description
                        0.1,                                  --min
                        100,                                  --max
                        0.1,                                  --step
                        "%.1f",                               --format
                        variant.EffectiveRange.custom + 0.0,  --currentValue
                        variant.EffectiveRange.default + 0.0, --defaultValue
                        function(value)                       --callback
                            Main.SetRecordValue(variant.EffectiveRange.flatPath, "value", value)
                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.EffectiveRange.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    ))
                    Main.SetRecordValue(variant.EffectiveRange.flatPath, "value", variant.EffectiveRange.custom)


                    if class == "SmartWeapon" then
                        -- SmartGunHipTimeToLock

                        pcall(ui.addRangeFloat(
                            "/AWSCRanged/variant",                       --path
                            variant.SmartGunHipTimeToLock.uiLabel,       --label
                            variant.SmartGunHipTimeToLock.uiDescription, --description
                            0.001,                                       --min
                            3,                                           --max
                            0.001,                                       --step
                            "%.3f",                                      --format
                            variant.SmartGunHipTimeToLock.custom + 0.0,  --currentValue
                            variant.SmartGunHipTimeToLock.default + 0.0, --defaultValue
                            function(value)                              --callback
                                Main.SetRecordValue(variant.SmartGunHipTimeToLock.flatPath, "value", value)
                                Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.SmartGunHipTimeToLock.custom =
                                    value
                                FileManager.saveAsJson(Main.weapons, 'weapons.json')
                            end
                        ))
                        Main.SetRecordValue(variant.SmartGunHipTimeToLock.flatPath, "value",
                            variant.SmartGunHipTimeToLock
                            .custom)

                        -- SmartGunAdsTimeToLock

                        pcall(ui.addRangeFloat(
                            "/AWSCRanged/variant",                       --path
                            variant.SmartGunAdsTimeToLock.uiLabel,       --label
                            variant.SmartGunAdsTimeToLock.uiDescription, --description
                            0.001,                                       --min
                            3,                                           --max
                            0.001,                                       --step
                            "%.3f",                                      --format
                            variant.SmartGunAdsTimeToLock.custom + 0.0,  --currentValue
                            variant.SmartGunAdsTimeToLock.default + 0.0, --defaultValue
                            function(value)                              --callback
                                Main.SetRecordValue(variant.SmartGunAdsTimeToLock.flatPath, "value", value)
                                Main.weapons.RangedWeapon[class][kind][weaponRecordName].variant.SmartGunAdsTimeToLock.custom =
                                    value
                                FileManager.saveAsJson(Main.weapons, 'weapons.json')
                            end
                        ))
                        Main.SetRecordValue(variant.SmartGunAdsTimeToLock.flatPath, "value",
                            variant.SmartGunAdsTimeToLock
                            .custom)
                    end
                end

                ui.addSelectorString(
                    "/AWSCRanged/weapon",
                    "Variants",
                    "Choose a weapon variant",
                    variantNames,
                    1,
                    1,
                    setVariant
                )

                --setVariant(1)
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
end

return RangedUI
