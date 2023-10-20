Melee = {}

function Melee.Init()
    local ui = Main.UI

    ui.addTab(
        "/AWSCMelee",
        "Adv. Melees Stats"
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
                local weaponRecordName = weapons[value]
                local weaponProperties = Main.weapons.MeleeWeapon[class][kind][weaponRecordName]
                local stats = weaponProperties.stats
                local weaponName = weaponProperties.LocalizedName
                log(weaponName)
                ui.addSubcategory(
                    "/AWSCMelee/weapon",
                    weaponName
                )

                -- Range
                ui.addRangeFloat(
                    "/AWSCMelee/weapon",                       --path
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

return Melee
