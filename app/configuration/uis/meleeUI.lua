MeleeUI = {}

function MeleeUI.Init()
    local ui = GetMod("nativeSettings")

    ui.addTab(
        "/AWSCMelee",
        "Adv. Melee Stats"
    )

    local uiOptions = {}

    ui.addSubcategory(
        "/AWSCMelee/classSelector",
        "Class"
    )

    local options = table_keys(Main.weapons.MeleeWeapon)
    local optionsLabels = table_map(options, function(k, v) return Main.classLabels[v] end)

    local activeClass = nil
    local setClass = function(value)
        ui.removeSubcategory("/AWSCMelee/class")
        ui.removeSubcategory("/AWSCMelee/kind")
        ui.removeSubcategory("/AWSCMelee/weapon")
        ui.removeSubcategory("/AWSCMelee/variant")

        local class = options[value]
        local classLabel = Main.classLabels[class]
        ui.addSubcategory(
            "/AWSCMelee/class",
            classLabel
        )

        local kinds = table_keys(Main.weapons.MeleeWeapon[class])
        local kindLabels = table_map(kinds, function(k, kind) return Main.kindLabels[kind] end)

        local setKind = function(value)
            ui.removeSubcategory("/AWSCMelee/kind")
            ui.removeSubcategory("/AWSCMelee/weapon")
            ui.removeSubcategory("/AWSCMelee/variant")

            local kind = kinds[value]
            local kindLabel = Main.kindLabels[kind]
            ui.addSubcategory(
                "/AWSCMelee/kind",
                kindLabel
            )

            local weapons = table_keys(Main.weapons.MeleeWeapon[class][kind])
            local weaponNames = table_map(weapons,
                function(k, weapon) return Main.weapons.MeleeWeapon[class][kind][weapon].LocalizedName end)

            local setWeapon = function(value)
                ui.removeSubcategory("/AWSCMelee/weapon")
                ui.removeSubcategory("/AWSCMelee/variant")

                local weaponLabel = weaponNames[value]
                local weaponRecordName = weapons[value]

                local weaponName = table_filter(weapons,
                    function(k, weapon)
                        return Main.weapons.MeleeWeapon[class][kind][weapon].LocalizedName ==
                            weaponLabel
                    end)[1]
                local weapon = Main.weapons.MeleeWeapon[class][kind][weaponName]
                local variantNames = {
                    [1] = "Base",
                    [2] = "Default"
                }

                local vars = table_values(table_map(weapon.variants, function(k, w) return w.localizedName or k end))

                for key, name in pairs(vars) do
                    if not table_contains(variantNames, name) then table.insert(variantNames, name) end
                end

                ui.addSubcategory(
                    "/AWSCMelee/weapon",
                    weaponName
                )

                local setVariant = function(value)
                    ui.removeSubcategory("/AWSCMelee/variant")

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

                    -- local weaponProperties = Main.weapons.MeleeWeapon[class][kind][weaponRecordName].variants
                    --     [variantKey]
                    -- local variant = weaponProperties.variant


                    ui.addSubcategory(
                        "/AWSCMelee/variant",
                        variantName
                    )

                    -- Range
                    pcall(ui.addRangeFloat(
                        "/AWSCMelee/variant",                      --path
                        "Base Range",                              --label
                        "Base Range (Scales with weapon quality)", --description
                        1,                                         --min
                        30,                                        --max
                        1,                                         --step
                        "%.0f",                                    --format
                        variant.Range.custom + 0.0,                --currentValue
                        variant.Range.default + 0.0,               --defaultValue
                        function(value)                            --callback
                            Main.SetRecordValue(variant.Range.flatPath, "value", value)
                            Main.weapons.MeleeWeapon[class][kind][weaponRecordName].variant.Range.custom =
                                value
                            FileManager.saveAsJson(Main.weapons, 'weapons.json')
                        end
                    ))
                    Main.SetRecordValue(variant.Range.flatPath, "value", variant.Range.custom)
                end

                ui.addSelectorString(
                    "/AWSCMelee/weapon",
                    "Variants",
                    "Choose a weapon variant",
                    variantNames,
                    1,
                    1,
                    setVariant
                )

                setVariant(1)
            end

            ui.addSelectorString(
                "/AWSCMelee/kind",
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
            "/AWSCMelee/class",
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
        "/AWSCMelee/classSelector",
        "Classes",
        "Choose a class",
        optionsLabels,
        1,
        1,
        setClass
    )

    setClass(1)
end

return MeleeUI
