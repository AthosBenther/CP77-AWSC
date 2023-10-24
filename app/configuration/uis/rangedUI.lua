RangedUI = {}

function RangedUI.Init()
    local ui = Main.UI

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
            local weaponNames = {}

            table_map(weapons,
                function(k, weapon)
                    weaponNames[k] = Main.weapons.RangedWeapon[class][kind][weapon].Variants.Default.LocalizedName
                end
            )

            local setWeapon = function(value)
                ui.removeSubcategory("/AWSCRanged/weapon")
                ui.removeSubcategory("/AWSCRanged/variant")
                log("AWSC UI: setWeapon(" .. value .. ")")

                local weaponLabel = weaponNames[value]
                local weaponRecordName = weapons[value]

                local weapon = Weapon.Find(
                    weaponRecordName,
                    {
                        Range = "RangedWeapon",
                        Class = class,
                        Kind = kind
                    },
                    Main.weapons
                )

                local variantNames = {
                    [1] = "Default"
                }

                local variantLabels = {
                    [1] = "Default"
                }

                if not pcall(function()
                        table_map(
                            weapon.Variants,
                            function(variantName, variant)
                                if table_count(variant) > 1 and variantName ~= "Default" then
                                    if variant.LocalizedName == weapon.Variants.Default.LocalizedName then
                                        table.insert(variantNames, variantName)
                                        table.insert(variantLabels, variantName)
                                    else
                                        table.insert(variantLabels, variant.LocalizedName)
                                        table.insert(variantNames, variantName)
                                    end
                                end
                            end
                        )
                    end) then
                    dd("Inserting Variant failed: ", weapon.Variants)
                end

                ui.addSubcategory(
                    "/AWSCRanged/weapon",
                    weaponLabel
                )
                log("AWSC UI: ui.addSubcategory(\"/AWSCRanged/weapon\"," .. weaponLabel .. ")")

                local setVariant = function(value)
                    log("AWSC UI: setVariant(" .. value .. ")")
                    ui.removeSubcategory("/AWSCRanged/variant")

                    local variantName = variantNames[value]
                    local variantLabel = variantLabels[value]


                    local variant = weapon.Variants[variantName]


                    ---@type gamedataWeaponItem_Record
                    local variantRecord = TweakDB:GetRecord(variant.recordPath)


                    ui.addSubcategory(
                        "/AWSCRanged/variant",
                        variantLabel
                    )

                    local xhairsOptions = {
                        [1] = "Basic",
                        [2] = "BlackwallForce",
                        [3] = "Custom_HMG",
                        [4] = "Cyberware_Mantis_Blades",
                        [5] = "Cyberware_Projectile_Launcher",
                        [6] = "Driver_Combat_Missile_Launcher",
                        [7] = "Driver_Combat_Power_Weapon",
                        [8] = "Hercules",
                        [9] = "Hex",
                        [10] = "Jailbreak_power",
                        [11] = "Jailbreak_smart",
                        [12] = "Jailbreak_tech",
                        [13] = "Melee_Bottle",
                        [14] = "Melee_Hammer",
                        [15] = "Melee_Knife",
                        [16] = "Melee_Nano_Wire",
                        [17] = "Melee_Strong_Arms",
                        [18] = "Melee",
                        [19] = "None",
                        [20] = "NoWeapon",
                        [21] = "Pistol",
                        [22] = "Power_Defender",
                        [23] = "Power_Overture",
                        [24] = "Power_Saratoga",
                        [25] = "Rasetsu",
                        [26] = "Simple",
                        [27] = "SmartGun",
                        [28] = "Tech_Hex",
                        [29] = "Tech_Round",
                        [30] = "Tech_Simple"
                    }

                    for stat, statValues in pairs(variant) do
                        if type(statValues) == "table" then
                            if variantName == "Default" then
                                local xhdefault = statValues
                                ui.addSelectorString(
                                    "/AWSCRanged/variant",
                                    "Crosshair",
                                    "Crosshair",
                                    xhairsOptions,
                                    table_indexOf(xhairsOptions, variant.Crosshair.custom),
                                    table_indexOf(xhairsOptions, variant.Crosshair.default),
                                    function(value)
                                        TweakDB:SetFlat(
                                            variantRecord:GetRecordID().value .. ".crosshair",
                                            xhairsOptions[value]
                                        )
                                    end
                                )
                            end
                            if not pcall(
                                    ui.addRangeFloat(
                                        "/AWSCRanged/variant",    --path
                                        statValues.uiLabel,       --label
                                        statValues.uiDescription, --description
                                        statValues.min,           --min
                                        statValues.max,           --max
                                        statValues.step,          --step
                                        statValues.format,        --format
                                        statValues.custom + 0.0,  --currentValue
                                        statValues.default + 0.0, --defaultValue
                                        function(value)           --callback
                                            Main.SetRecordValue(statValues.flatPath, "value", value)
                                            Main.weapons.RangedWeapon[class][kind][weaponRecordName].Variants[variantName][stat].custom =
                                                value
                                            FileManager.saveAsJson(Main.weapons,
                                                config("storage.weapons", "weapons.json"))
                                        end
                                    )
                                ) then
                                log("Failed to set the " .. stat .. " stats for " .. weaponLabel)
                            end
                            Main.SetRecordValue(variant[stat].flatPath, "value", variant[stat].custom)
                        end
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

                setVariant(1)
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
