RangedUI = {
    xhairsOptions = {
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
}

function RangedUI.Init()
    local ui = MainUI.UI

    ui.addTab(
        "/AWSCRanged",
        "Adv. Weapons Stats"
    )

    local uiOptions = {}

    ui.addSubcategory(
        "/AWSCRanged/classSelector",
        "Class"
    )

    local options = table_keys(ConfigFile.Weapons.RangedWeapon)
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

        local kinds = table_keys(ConfigFile.Weapons.RangedWeapon[class])
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

            local weapons = table_keys(ConfigFile.Weapons.RangedWeapon[class][kind])
            local weaponNames = {}

            table_map(weapons,
                function(k, weapon)
                    weaponNames[k] = ConfigFile.Weapons.RangedWeapon[class][kind][weapon].Variants.Default.LocalizedName
                end
            )

            local setWeapon = function(value)
                ui.removeSubcategory("/AWSCRanged/weapon")
                ui.removeSubcategory("/AWSCRanged/variant")
                log("RangedUI: setWeapon(" .. value .. ")")

                local weaponLabel = weaponNames[value]
                local weaponRecordName = weapons[value]

                local storageWeapon = Weapon.Find(
                    weaponRecordName,
                    {
                        Range = "RangedWeapon",
                        Class = class,
                        Kind = kind
                    },
                    ConfigFile.Weapons
                )

                local variantNames = {
                    [1] = "Default"
                }

                local variantLabels = {
                    [1] = "Default"
                }

                if not pcall(function()
                        table_map(
                            storageWeapon.Variants,
                            function(variantName, storageVariant)
                                if table_count(storageVariant) > 1 and variantName ~= "Default" then
                                    if storageVariant.LocalizedName == storageWeapon.Variants.Default.LocalizedName then
                                        table.insert(variantNames, variantName)
                                        table.insert(variantLabels, variantName)
                                    else
                                        table.insert(variantLabels, storageVariant.LocalizedName)
                                        table.insert(variantNames, variantName)
                                    end
                                end
                            end
                        )
                    end) then
                    log("RanderUI: Inserting one or more " .. weaponLabel .. " variants failed")
                end

                ui.addSubcategory(
                    "/AWSCRanged/weapon",
                    weaponLabel
                )


                local setVariant = function(value)
                    ui.removeSubcategory("/AWSCRanged/variant")
                    ui.removeSubcategory("/AWSCRanged/iconicDisclaimer")



                    local variantName = variantNames[value]
                    local variantLabel = variantLabels[value]


                    local storageVariant = storageWeapon.Variants[variantName]

                    log("RangedUI: Setting variant " .. variantLabel)

                    ---@type gamedataWeaponItem_Record
                    --local variantRecord = TweakDB:GetRecord(storageVariant.recordPath)


                    ui.addSubcategory(
                        "/AWSCRanged/variant",
                        variantLabel
                    )

                    local isIconic = false

                    if variantName == "Default" and storageVariant.Stats.Crosshair then
                        local xhsuccess, errorMessage = pcall(
                            function()
                                ui.addSelectorString(
                                    "/AWSCRanged/variant",
                                    "Crosshair",
                                    "Crosshair",
                                    RangedUI.xhairsOptions,
                                    table_indexOf(RangedUI.xhairsOptions, storageVariant.Stats.Crosshair.custom),
                                    table_indexOf(RangedUI.xhairsOptions, storageVariant.Stats.Crosshair.default),
                                    function(value)
                                        local flatSuccess = Weapon.SetCrosshair(storageWeapon,
                                            RangedUI.xhairsOptions[value])

                                        if flatSuccess then
                                            ConfigFile.Weapons.RangedWeapon[class][kind][weaponRecordName].Variants.Default.Stats.Crosshair.custom =
                                                RangedUI.xhairsOptions[value]

                                            ConfigFile.Save()

                                            log("RangedUI: Setting the crosshair for the '" ..
                                                variantLabel .. "' variant of '" .. weaponLabel .. "'")
                                        else
                                            log("RangedUI: Failed setting the crosshair for the '" ..
                                                variantLabel .. "' variant of '" .. weaponLabel .. "'")
                                        end
                                    end)
                            end
                        )
                        if xhsuccess then
                            --storageVariant.Stats = table_remove(storageVariant.Stats, "Crosshair")
                        else
                            log("RangedUI: Failed to create the Crosshair control for the '" ..
                                variantLabel .. "' variant of '" .. weaponLabel .. "'")
                            log(errorMessage)
                        end
                    else
                        isIconic = true
                        storageVariant.Stats = table_remove(storageVariant.Stats, "Crosshair")
                        log("RangedUI: '" ..
                            variantLabel .. "' Identified as an Iconic")

                        if table_count(storageVariant.Stats) < 3 then
                            ui.removeSubcategory("/AWSCRanged/variant")
                            ui.addSubcategory(
                                "/AWSCRanged/iconicDisclaimer",
                                variantName ..
                                " inherit all its stats from Default, and may have hidden mods affecting certain attributes"
                            )
                        else
                            ui.addSubcategory(
                                "/AWSCRanged/iconicDisclaimer",
                                "Note: Iconics inherit some stats from Default, and may have hidden mods affecting certain attributes"
                            )
                        end
                    end

                    local subcat = "/AWSCRanged/variant"
                    if isIconic then subcat = "/AWSCRanged/iconicDisclaimer" end

                    local validStats = table_filter(storageVariant.Stats, function(k, v) return type(v) == "table" end)


                    log("RangedUI: " .. table_count(validStats) .. " stats identified:")
                    log(table_keys(validStats))

                    for stat, statValues in pairs(validStats) do
                        if stat ~= "Crosshair" then
                            log("RangedUI: creating the control for " .. stat)

                            local status, errorMessage = pcall(function()
                                log("RangedUI: Creating the " ..
                                    statValues.uiLabel ..
                                    " control for the '" .. variantLabel .. "' variant of '" .. weaponLabel .. "'")

                                local label = statValues.uiLabel
                                local desc = statValues.uiDescription
                                if statValues.modifierType == "Multiplier" then
                                    label = label .. " Multiplier"
                                    desc = desc .. " Multiplier"
                                end
                                ui.addRangeFloat(
                                    subcat,               --path
                                    label,                --label
                                    statValues.uiDescription, --description
                                    statValues.min,       --min
                                    statValues.max,       --max
                                    statValues.step,      --step
                                    statValues.format,    --format
                                    statValues.custom + 0.0, --currentValue
                                    statValues.default + 0.0, --defaultValue
                                    function(value)       --callback
                                        log("RangedUI: Setting " ..
                                            statValues.uiLabel ..
                                            " for the '" ..
                                            variantLabel .. "' variant of '" .. weaponLabel .. "'")
                                        Main.SetRecordValue(statValues.flatPath, "value", value)
                                        ConfigFile.Weapons.RangedWeapon[class][kind][weaponRecordName].Variants[variantName].Stats[stat].custom =
                                            value
                                        ConfigFile.Save()
                                    end
                                )
                            end
                            )

                            if not status then
                                log("RangedUI: Failed to create the control for the " ..
                                    stat ..
                                    " stat for the '" .. variantLabel .. "' variant of '" .. weaponLabel .. "'")
                                log(errorMessage)
                                log(statValues)
                            end
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
