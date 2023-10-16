ConfigFile = {
    description = "Advanced Weapon Stat Customization",
    weapons = {},
    forbiddenWeapons = {
        -- "Silverhand",
        -- "Zhuo",
        -- "Warden",
        -- "Palica",
        -- "Authority",
        -- "Borg4a",
        "RocketLauncher",
        "Blade",
        "Vehicle_Power_Weapon",
        "Vehicle_Power_Weapon_OutlawHeist",
        "Machete_Kukri",
        "Machete_Borg"
    },
    range = {
        'MeleeWeapon',
        'RangedWeapon'
    },
    class = {
        'BladeWeapon',
        'BluntWeapon',
        'HeavyWeapon',
        'PowerWeapon',
        'SmartWeapon',
        'TechWeapon',
        'ThrowableWeapon',
        --'OneHandedRangedWeapon',
        'Special'
    },
    kind = {
        'Grenade Launcher',
        'Handgun',
        'HMG',
        'LMG',
        'Revolver',
        'Rifle Assault',
        'Rifle Precision',
        'Rifle Sniper',
        'ShotgunWeapon',
        'Shotgun Dual',
        'SMG',

        'Baton',
        'BladeWeapon',
        'One Hand Blade',
        'One Hand Club',
        'Katana',
        'Knife',
        'Two Hand Club',
        'Two Hand Hammer',
        'Knuckles'
    }
}

function ConfigFile.Generate(newFile)
    local newFile = newFile or false
    --FileManager.saveAsJson(nil, 'weapons.json')

    if not newFile then
        ConfigFile.weapons = FileManager.openJson('weapons.json');
    end

    local weaponItemRecords = TweakDB:GetRecords('gamedataWeaponItem_Record')
    log("AWSC: loaded " .. #weaponItemRecords .. " Weapon Item Records")

    local fWeaponItemRecords = table_getValues(
        table_filter(
            weaponItemRecords,
            function(key, record)
                local recordName = record:GetRecordID().value
                local weaponName = string.gsub(recordName, "Items.Base_", "")
                local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName
                local nameParts = string_split(recordName, "_")

                --if string_startsWith(recordName, "Items.Base_") and #nameParts > 2 then dd(nameParts) end

                return string_startsWith(recordName, "Items.Base_")
                    and not table_contains(ConfigFile.class, nameParts[2] .. "Weapon")
                    and localizedName ~= "!OBSOLETE"
                    and not table_contains(ConfigFile.forbiddenWeapons, weaponName)
            end
        )
    )

    log("Filtered weapons: " .. #fWeaponItemRecords)

    for index, record in ipairs(fWeaponItemRecords) do
        local weaponName = string.gsub(record:GetRecordID().value, "Items.Base_", "")
        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName())
        if localizedName == "" then localizedName = weaponName end
        local tags = table_map(record:Tags(), function(k, t) return t.value end)

        local thisRanges = table_intersect(ConfigFile.range, tags)
        local thisClasses = table_intersect(ConfigFile.class, tags)
        local thisKinds = table_intersect(ConfigFile.kind, tags)

        local uKinds = {}
        for index, value in ipairs(thisKinds) do
            uKinds[value] = index
        end
        thisKinds = table_keys(uKinds)

        local thisRange = thisRanges[1]
        local thisClass = thisClasses[1]
        local thisKind = thisKinds[1]

        if weaponName == "Pozhar" then
            thisKind = "ShotgunWeapon"
        end

        local fullyClassified =
            thisRange ~= nil
            and thisClass ~= nil
            and thisKind ~= nil
            and weaponName ~= nil

        if (fullyClassified) then
            -- log(weaponName .. ": " .. localizedName)
            if (ConfigFile.weapons[thisRange] == nil) then
                ConfigFile.weapons[thisRange] = {}
            end
            if (ConfigFile.weapons[thisRange][thisClass] == nil) then
                ConfigFile.weapons[thisRange][thisClass] = {}
            end

            if (ConfigFile.weapons[thisRange][thisClass][thisKind] == nil) then
                ConfigFile.weapons[thisRange][thisClass][thisKind] = {}
            end

            if (thisRange == "RangedWeapon") then
                local weapon = ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] or {}

                local newWeapon = {
                    LocalizedName = localizedName,
                    stats = ConfigFile.Ranged(weaponName, thisClass, thisKind),
                    -- tags = tags
                }

                ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] = table_update(weapon, newWeapon)
            else
                local weapon = ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] or {}

                local newWeapon = {
                    LocalizedName = localizedName,
                    stats = ConfigFile.Melee(weaponName, thisClass, thisKind),
                    -- tags = tags
                }

                ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] = table_update(weapon, newWeapon)
            end
        end
    end
    FileManager.saveAsJson(ConfigFile.weapons, "weapons.json")
    Main.weapons = ConfigFile.weapons
    ConfigFile.weapons = nil
end

function ConfigFile.Ranged(weaponName, thisClass, thisKind)
    local thisRange = "RangedWeapon"


    local inlines = {
        -- Common stats
        DPS = {
            jsonAlias = "damage",
            uiLabel = "Base Damage",
            uiDescription = "Base Damage (Scales with weapon quality)",
            statModifiers = "Items.Base_" .. weaponName .. "_Damage_Stats.statModifiers"
        },
        MagazineCapacityBase = {
            jsonAlias = "magazine",
            uiLabel = "Magazine",
            uiDescription = "Base Magazine Capacity",
            statModifiers = "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers"
        },
        CycleTimeBase = {
            jsonAlias = "cycleTime",
            uiLabel = "Cycle Time",
            uiDescription = "Base Cycle Time (in Milliseconds)",
            statModifiers = "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers"
        },
        EffectiveRange = {
            uiLabel = "Effective Range"
        },
        Range = {
            uiLabel = "Quick Attack Range"
        },

        -- Smart Stats
        SmartGunHipTimeToLock = {
            uiLabel = "Hip Lock Time",
            statModifiers = "Items.Base_" .. weaponName .. "_SmartGun_Stats.statModifiers"
        }
        ,
        SmartGunAdsTimeToLock = {
            uiLabel = "Ads Lock Time",
            statModifiers = "Items.Base_" .. weaponName .. "_SmartGun_Stats.statModifiers"
        }

    }


    local stats = {}

    for BaseStat, data in pairs(inlines) do
        local fullBaseStat = "BaseStats." .. BaseStat
        local flatPath = ConfigFile.FindFlat(data.statModifiers, fullBaseStat, weaponName)
        if flatPath then
            stats[data.jsonAlias or BaseStat] = {
                uiLabel = data.uiLabel,
                uiDescription = data.uiDescription or data.uiLabel,
                flatPath = flatPath,
                statType = fullBaseStat,
                default = TweakDB:GetFlat(flatPath .. '.value'),
                custom = TweakDB:GetFlat(flatPath .. '.value'),
            }
        end
    end

    return stats
end

function ConfigFile.Melee(weaponName, thisClass, thisKind)
    local thisRange = "MeleeWeapon"

    local inlines = {
        Range = {
            uiLabel = "Attack Range"
        }
    }

    local stats = {}

    for BaseStat, data in pairs(inlines) do
        local fullBaseStat = "BaseStats." .. BaseStat
        local flatPath = ConfigFile.FindFlat(data.statModifiers, fullBaseStat, weaponName)
        if flatPath then
            stats[data.jsonAlias or BaseStat] = {
                uiLabel = data.uiLabel,
                uiDescription = data.uiDescription or data.uiLabel,
                flatPath = flatPath,
                statType = fullBaseStat,
                default = TweakDB:GetFlat(flatPath .. '.value'),
                custom = TweakDB:GetFlat(flatPath .. '.value'),
            }
        end
    end

    return stats
end

function ConfigFile.FindFlat(statGroup, statType, weaponName)
    weaponName = weaponName or nil

    if statGroup == nil then
        local inline = ConfigFile.fullFlatSearch(statType, weaponName)
        return inline
    end
    local mods = TweakDB:GetFlat(statGroup)
    for key, mod in pairs(mods or {}) do
        local dbStatType = TweakDB:GetFlat(mod.value .. ".statType").value
        if dbStatType == statType then return mod.value end
    end
    return nil
end

function ConfigFile.fullFlatSearch(statType, weaponName)
    local statGroups = TweakDB:GetFlat("Items.Base_" .. weaponName .. ".statModifierGroups")

    for key, statGroup in pairs(statGroups) do
        local inline = ConfigFile.FindFlat(statGroup.value .. ".statModifiers", statType)
        if inline then return inline end
    end
end

function ConfigFile.Validate()
    local weapons = nil
    local tests = {
        [1] = {
            name = "fileExists",
            assertTrue = function() return FileManager.Exists(config("storage.weapons")) end,
            errorMessage = "File 'weapons.json' does not exists or could not be read",
            breakOnError = true
        },
        [2] = {
            name = "jsonIsValid",
            assertTrue = function() return pcall(function() FileManager.openJson(config("storage.weapons")) end) end,
            onPass = function() weapons = FileManager.openJson(config("storage.weapons")) end,
            errorMessage = "File 'weapons.json' is not a valid json",
            breakOnError = true
        },
        [3] = {
            name = "notNil",
            assertTrue = function() return weapons ~= nil end,
            errorMessage = "'Weapons' is nil",
            breakOnError = true
        },
        [4] = {
            name = "isTable",
            assertTrue = function() return type(weapons) == "table" end,
            errorMessage = "'Weapons' is not a table",
            breakOnError = true
        },
        [5] = {
            name = "isEmptyTable",
            assertTrue = function() return weapons ~= {} end,
            errorMessage = "'Weapons' is and empty table",
            breakOnError = true
        },
        [6] = {
            name = "rangedWeaponsPresent",
            assertTrue = function()
                return table_containsKey(weapons, "RangedWeapon")
            end,
            errorMessage = "'Weapons' does not have RangedWeapon",
            breakOnError = false
        },
        [7] = {
            name = "meleeWeaponsPresent",
            assertTrue = function()
                return table_containsKey(weapons, "MeleeWeapon")
            end,
            errorMessage = "'Weapons' does not have MeleeWeapon",
            breakOnError = false
        }
    }
    local errors = {}


    local tKeys = table_keys(tests)
    local tCount = table_count(tKeys)
    table.sort(tKeys)

    for i = 1, tCount, 1 do
        local test = tests[tKeys[i]]
        local testName = test.name
        if (test.assertTrue() == false) then
            local error = "AWSC Weapons validation failed on " .. testName .. " test: " .. test.errorMessage
            errors[testName] = error
            if (test.breakOnError) then
                return errors
            end
            if table_containsKey(test, "onFail") then test.onFail() end
        else
            if table_containsKey(test, "onPass") then test.onPass() end
        end
    end
    if table_count(errors) == 0 then return true else return errors end
end

return ConfigFile

-- Items.Base_Nue.statModifierGroups
