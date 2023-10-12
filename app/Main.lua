Main = {
    description = "Advanced Weapon Stat Customization",
    weapons = nil,
    rangeLabels = {
        ['MeleeWeapon'] = "Melee",
        ['RangedWeapon'] = "Weapons"
    },
    classLabels = {
        ['BladeWeapon'] = "Blades",
        ['BluntWeapon'] = "Blunt",
        ['HeavyWeapon'] = "Heavy",
        ['PowerWeapon'] = "Power Weapons",
        ['SmartWeapon'] = "Smart Weapons",
        ['TechWeapon'] = "Tech Weapons",
        ['ThrowableWeapon'] = "Throwable",
        ['OneHandedRangedWeapon'] = "One-Handed",
        ['Special'] = "Special"
    },
    kindLabels = {
        ['Grenade Launcher'] = "Grenade Launcher",
        ['Handgun'] = "Handgun",
        ['HMG'] = "HMG",
        ['LMG'] = "LMG",
        ['Revolver'] = "Revolver",
        ['Rifle Assault'] = "Assault Rifles",
        ['Rifle Precision'] = "Precision Rifles",
        ['Rifle Sniper'] = "Snipers",
        ['ShotgunWeapon'] = "Shotguns",
        ['Shotgun Dual'] = "Dual-Barrel Shotguns",
        ['SMG'] = "Submachineguns",

        ['Baton'] = "Batons",
        ['BladeWeapon'] = "Blades",
        ['One Hand Blade'] = "One-Handed Blades",
        ['One Hand Club'] = "One-Handed Clubs",
        ['Katana'] = "Katanas",
        ['Knife'] = "Knives",
        ['Two Hand Club'] = "Two-Handed Clubs",
        ['Two Hand Hammer'] = "Two-Handed Hammers",
        ['Knuckles'] = "Knuckle Sandwich"
    },
    triggerModes = {
        [1] = "Semi-Auto",
        [2] = "Burst",
        [3] = "Full-Auto",
        [4] = "Charge",
        [5] = "Windup",
        [6] = "Lock"
    },
    triggerModesLabels = {
        ["Semi-Auto"] = "TriggerMode.FullAuto",
        ["Burst"] = "TriggerMode.Burst",
        ["Full-Auto"] = "TriggerMode.SemiAuto",
        ["Charge"] = "TriggerMode.Charge",
        ["Windup"] = "TriggerMode.Windup",
        ["Lock"] = "TriggerMode.Loc"
    }
}
function Main.init()
    registerForEvent("onInit", function()
        print("AWSC: Hello World!")
        --Statics.FixDamage()
        Main.weapons = FileManager.loadJson('weapons.json')

        if (Main.weapons == nil) then
            print("Main: Generating new json")
            GenCfg.generate()
            Main.weapons = FileManager.loadJson('weapons.json')
        end

        Main.weapons = table_unset(Main.weapons, "MeleeWeapon")
        local ui = GetMod("nativeSettings")

        ui.addTab(
            "/AWSC",
            "Adv. Weapons Stats",
            FileManager.saveAsJson(Main.weapons, 'weapons.json')
        )

        local uiOptions = {}
        for range, classes in pairs(Main.weapons) do
            local iRange = table_indexOfKey(Main.weapons, range) * 10000
            uiOptions[range] = {}

            for class, kinds in pairs(classes) do
                uiOptions[range][class] = {}
                local iClass = (table_indexOfKey(Main.weapons[range], class) * 1000)

                -- ui.addSubcategory(
                --     "/AWSC/" .. class,
                --     iClass .. " " .. Main.classLabels[class],
                --     iClass
                -- )

                for kind, weapons in pairs(kinds) do
                    uiOptions[range][class][kind] = {}
                    local iKind = iClass + (table_indexOfKey(Main.weapons[range][class], kind) * 100)

                    -- ui.addSubcategory(
                    --     "/AWSC/" .. class .. kind,
                    --     iKind .. "      " .. Main.kindLabels[kind],
                    --     iKind
                    -- )
                    for weaponRecordName, weaponProperties in pairs(weapons) do
                        local iWeapon = iKind + (table_indexOfKey(weapons, weaponRecordName) * 10)
                        uiOptions[range][class][kind][weaponRecordName] = {}

                        if (
                                true
                                -- and table_contains(weaponProperties.tags, "Handgun") == true
                                and range == "RangedWeapon"
                            ) then
                            local label = table.concat({
                                Main.classLabels[class],
                                Main.kindLabels[kind]
                            }, " \\\\ ")

                            local stats = weaponProperties.stats

                            ui.addSubcategory(
                                "/AWSC/" .. weaponRecordName,
                                label .. " \\\\ " .. weaponProperties.LocalizedName
                            )

                            -- Damage
                            uiOptions[range][class][kind][weaponRecordName]["damage"] =
                                ui.addRangeFloat(
                                    "/AWSC/" .. weaponRecordName,               --path
                                    " Base Damage",                             --label
                                    "Base Damage (Scales with weapon quality)", --description
                                    1,                                          --min
                                    3000,                                       --max
                                    1,                                          --step
                                    "%.0f",                                     --format
                                    stats.damage.custom + 0.0,                  --currentValue
                                    stats.damage.default + 0.0,                 --defaultValue
                                    function(value)                             --callback
                                        SetRecordValue(stats.damage.flatPath, "value", value)
                                        Main.weapons[range][class][kind][weaponRecordName].stats.damage.custom =
                                            value
                                        -- FileManager.saveAsJson(Main.weapons, 'weapons.json')
                                    end
                                )
                            SetRecordValue(stats.damage.flatPath, "value", stats.damage.custom)

                            -- MAGAZINE
                            uiOptions[range][class][kind][weaponRecordName]["magazine"] =
                                ui.addRangeFloat(
                                    "/AWSC/" .. weaponRecordName, --path
                                    " Magazine",                  --label
                                    "Base Magazine Capacity",     --description
                                    1,                            --min
                                    300,                          --max
                                    1,                            --step
                                    "%.0f",                       --format
                                    stats.magazine.custom + 0.0,  --currentValue
                                    stats.magazine.default + 0.0, --defaultValue
                                    function(value)               --callback
                                        SetRecordValue(stats.magazine.flatPath, "value", value)
                                        Main.weapons[range][class][kind][weaponRecordName].stats.magazine.custom =
                                            value
                                        -- FileManager.saveAsJson(Main.weapons, 'weapons.json')
                                    end
                                )
                            SetRecordValue(stats.magazine.flatPath, "value", stats.magazine.custom)


                            -- CYCLE TIME
                            uiOptions[range][class][kind][weaponRecordName]["cycleTime"] =
                                ui.addRangeFloat(
                                    "/AWSC/" .. weaponRecordName,        --path
                                    " Cycle Time",                       --label
                                    "Base Cycle Time (in Milliseconds)", --description
                                    0.01,                                --min
                                    5,                                   --max
                                    0.01,                                --step
                                    "%.3f",                              --format
                                    stats.cycleTime.custom + 0.0,        --currentValue
                                    stats.cycleTime.default + 0.0,       --defaultValue
                                    function(value)                      --callback
                                        SetRecordValue(stats.cycleTime.flatPath, "value", value)
                                        Main.weapons[range][class][kind][weaponRecordName].stats.cycleTime.custom =
                                            value
                                        -- FileManager.saveAsJson(Main.weapons, 'weapons.json')
                                    end
                                )
                            SetRecordValue(stats.cycleTime.flatPath, "value", stats.cycleTime.custom)

                            -- TRIGGER MODE
                            -- Has to be eddited on Preset_Weapon_Default
                            -- Has to change .primaryTriggerMode AND .triggerModes
                            -- Complete pain in the ass

                            -- uiOptions[range][class][kind][weaponRecordName]["triggerMode"] =
                            --     ui.addSelectorString(
                            --         "/AWSC/" .. weaponRecordName, --path
                            --         " Trigger Mode",              --label
                            --         "Trigger Mode",               --description
                            --         Main.triggerModes,            --min
                            --         1,                            --currentValue
                            --         1,                            --defaultValue
                            --         function(value)               --callback
                            --             local label = Main.triggerModes[value]
                            --             local statValue = Main.triggerModesLabels[label]

                            --             SetRecordValue(stats.triggerMode.flatPath, statValue)
                            --             Main.weapons[range][class][kind][weaponRecordName].stats.triggerMode.custom =
                            --                 statValue
                            --         end
                            --     )
                            -- SetRecordValue(stats.triggerMode.flatPath, "triggerMode", stats.triggerMode.custom)
                        end
                    end
                end
            end
        end
    end)
end

function SetRecordValue(path, field, value)
    if not TweakDB:SetFlatNoUpdate(path .. "." .. field, value) then
        print("Error SetFlat: '" ..
            path .. "." .. field .. "' as '" .. value .. "'")
    end
    if not TweakDB:Update(path) then print("Error Update: " .. path) end
end

return Main

--   "Carnage_Recoil": 1,
--   "Carnage_Spread": 1,
--   "Carnage_Sway": 1,
--   "Carnage_ReloadTime": 1,
