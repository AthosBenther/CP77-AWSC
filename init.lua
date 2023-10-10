local AWSC = {
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
        ['PowerWeapon'] = "Power",
        ['SmartWeapon'] = "Smart",
        ['TechWeapon'] = "Tech",
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
    }
}

require("vendors/ab-lua-libs/autoloader")
function AWSC.init()
    registerForEvent("onInit", function()
        print("AWSC: Hello World!")
        --Statics.FixDamage()

        AWSC.weapons = FileManager.loadJson('weapons.json')


        if (AWSC.weapons == nil) then
            print("AWSC: Generating new json")
            GenCfg.generate()
            AWSC.weapons = FileManager.loadJson('weapons.json')
        end

        local settings = GetMod("nativeSettings")
        settings.addTab("/AWSC", "Advanced Weapons Stat Customization")

        for range, classes in pairs(AWSC.weapons) do
            for class, kinds in pairs(classes) do
                for kind, weapons in pairs(kinds) do
                    for weaponRecordName, weaponProperties in pairs(weapons) do
                        if (
                                true
                                -- and table_contains(weaponProperties.tags, "Handgun") == true
                                and range == "RangedWeapon"
                            ) then
                            local label = table.concat({
                                AWSC.rangeLabels[range],
                                AWSC.classLabels[class],
                                AWSC.kindLabels[kind]
                            }, " \\\\ ")

                            local stats = weaponProperties.stats

                            settings.addSubcategory(
                                "/AWSC/" .. weaponRecordName,
                                label .. ": " ..
                                weaponProperties.LocalizedName
                            )

                            -- Damage
                            settings.addRangeFloat(
                                "/AWSC/" .. weaponRecordName,               --path
                                "Base Damage",                              --label
                                "Base Damage (Scales with weapon quality)", --description
                                1,                                          --min
                                300,                                        --max
                                1,                                          --step
                                "%.0f",                                     --format
                                stats.damage.custom + 0.0,                  --currentValue
                                stats.damage.default + 0.0,                 --defaultValue
                                function(value)                             --callback
                                    SetRecordValue(stats.damage.flatPath, value)
                                    AWSC.weapons[range][class][kind][weaponRecordName].stats.damage.custom = value
                                    FileManager.saveAsJson(AWSC.weapons, 'weapons.json')
                                end
                            )
                            SetRecordValue(stats.damage.flatPath, stats.damage.custom)

                            -- MAGAZINE
                            settings.addRangeFloat(
                                "/AWSC/" .. weaponRecordName, --path
                                "Magazine",                   --label
                                "Base Magazine Capacity",     --description
                                1,                            --min
                                300,                          --max
                                1,                            --step
                                "%.0f",                       --format
                                stats.magazine.custom + 0.0,  --currentValue
                                stats.magazine.default + 0.0, --defaultValue
                                function(value)               --callback
                                    SetRecordValue(stats.magazine.flatPath, value)
                                    AWSC.weapons[range][class][kind][weaponRecordName].stats.magazine.custom = value
                                    FileManager.saveAsJson(AWSC.weapons, 'weapons.json')
                                end
                            )
                            SetRecordValue(stats.magazine.flatPath, stats.magazine.custom)


                            -- CYCLE TIME
                            settings.addRangeFloat(
                                "/AWSC/" .. weaponRecordName,        --path
                                "Cycle Time",                        --label
                                "Base Cycle Time (in Milliseconds)", --description
                                0.01,                                --min
                                5,                                   --max
                                0.01,                                --step
                                "%.3f",                              --format
                                stats.cycleTime.custom + 0.0,        --currentValue
                                stats.cycleTime.default + 0.0,       --defaultValue
                                function(value)                      --callback
                                    SetRecordValue(stats.cycleTime.flatPath, value)                                 
                                    AWSC.weapons[range][class][kind][weaponRecordName].stats.cycleTime.custom = value
                                    FileManager.saveAsJson(AWSC.weapons, 'weapons.json')
                                end
                            )
                            SetRecordValue(stats.cycleTime.flatPath, stats.cycleTime.custom)
                        end
                    end
                end
            end
        end
    end)
end

function SetRecordValue(path, value)
    local pathtoValue = "Items." .. path .. ".value"
    if not TweakDB:SetFlatNoUpdate(pathtoValue, value) then print("Error SetFlat: " .. path) end
    if not TweakDB:Update("Items." .. path) then print("Error Update: " .. path) end
end

return AWSC.init()

--   "Carnage_Recoil": 1,
--   "Carnage_Spread": 1,
--   "Carnage_Sway": 1,
--   "Carnage_ReloadTime": 1,
