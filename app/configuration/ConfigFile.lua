ConfigFile = {
    description = "Advanced Weapon Stat Customization",
    weaponItemRecords = {},
    weapons = {}
}

---Generates the configurations file
---@param newFile boolean Indicates if a new file should be generated, or if it should try to update an existing file
function ConfigFile.Generate(newFile)
    local newFile = newFile or false
    --FileManager.saveAsJson(nil, 'weapons.json')

    -- loads config file if not forcing the cration of a new one
    if not newFile or config("configs.forcenew", false) then
        --ConfigFile.weapons = FileManager.openJson('weapons.json');
    end

    ConfigFile.weaponItemRecords = TweakDB:GetRecords('gamedataWeaponItem_Record')
    log("AWSC: loaded " .. table_count(ConfigFile.weaponItemRecords) .. " Weapon Item Records")


    local recs = {}
    local DPSs = {}

    local defaultWeapons = {}

    for k, record in pairs(ConfigFile.weaponItemRecords) do
        local recordPath = record:GetRecordID().value
        local isDefault = string_endswith(recordPath, "Default")
        if not isDefault then goto continue end
        local weaponName = Weapon.GetName(recordPath)

        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName


        if
            isDefault
            and localizedName ~= "!OBSOLETE"
            and not table_contains(ConfigStatics.forbiddenWeapons, weaponName)
        then
            defaultWeapons[recordPath] = record
        end

        ::continue::
    end

    for weaponRecordPath, weaponRecord in pairs(defaultWeapons) do
        local classification = Weapon.Classify(weaponRecord, weaponRecordPath)
        local weaponName = Weapon.GetName(weaponRecordPath)
        if (ConfigFile.weapons[classification.Range] == nil) then
            ConfigFile.weapons[classification.Range] = {}
        end
        if (ConfigFile.weapons[classification.Range][classification.Class] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"] = {}
        end

        local defaultVariantData = Weapon.GetVariantData(weaponName, weaponRecordPath, classification)
        ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"]["Default"] =
            defaultVariantData



        local variants = {}

        for k, record in pairs(ConfigFile.weaponItemRecords) do
            local recordPath = record:GetRecordID().value

            local isVariant = string_startsWith(recordPath, "Items.Preset_" .. weaponName)
            local isValidVariant = not string_contains(recordPath, ConfigStatics.forbiddenVariationTerms)
            local tags = table_map(record:Tags(), function(k, t) return t.value end)
            local isDeprecatedIconic = table_contains(tags, "DeprecatedIconic")

            if isVariant
                and isValidVariant
                and not string_endswith(recordPath, "Default")
                and not isDeprecatedIconic
            then
                variants[recordPath] =
                    record
            end
        end

        for variantRecordPath, variantRecord in pairs(variants) do
            local variantName = Weapon.GetVariantName(variantRecordPath, variantRecord)
            local variantClassification = Weapon.Classify(variantRecord, variantRecordPath)

            local variantData = Weapon.GetVariantData(variantName, variantRecordPath, variantClassification)

            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"][variantName] =
                variantData
        end
    end


    --dd(ConfigFile.weapons)
    FileManager.saveAsJson(ConfigFile.weapons, "a.json")
    dd("file saved")



    local baseWeaponItemRecords = table_values(
        table_filter(
            ConfigFile.weaponItemRecords,
            function(key, record)
                local recordName = record:GetRecordID().value
                local weaponName = string.gsub(recordName, "Items.Base_", "")
                local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName
                local nameParts = string_split(recordName, "_")

                --if string_startsWith(recordName, "Items.Base_") and #nameParts > 2 then dd(nameParts) end

                return string_startsWith(recordName, "Items.Base_")
                    and not table_contains(ConfigStatics.class, nameParts[2] .. "Weapon")
                    and localizedName ~= "!OBSOLETE"
                    and not table_contains(ConfigStatics.forbiddenWeapons, weaponName)
            end
        )
    )

    log("Filtered base weapons: " .. #baseWeaponItemRecords)

    for index, record in ipairs(baseWeaponItemRecords) do
        local weaponName = string.gsub(record:GetRecordID().value, "Items.Base_", "")
        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName())
        if localizedName == "" then localizedName = weaponName end
        local tags = table_map(record:Tags(), function(k, t) return t.value end)

        local thisRanges = table_intersect(ConfigStatics.range, tags)
        local thisClasses = table_intersect(ConfigStatics.class, tags)
        local thisKinds = table_intersect(ConfigStatics.kind, tags)

        local uniqueKinds = {}
        for index, value in ipairs(thisKinds) do
            uniqueKinds[value] = index
        end
        thisKinds = table_keys(uniqueKinds)

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
                    variants = ConfigFile.GetVariants(weaponName, localizedName)
                }

                newWeapon.variants.Base = ConfigFile.Ranged(weaponName, thisClass, thisKind)

                ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] = table_update(weapon, newWeapon)
            else
                local weapon = ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] or {}

                local newWeapon = {
                    LocalizedName = localizedName,
                    variants = ConfigFile.GetVariants(weaponName, localizedName)
                }

                newWeapon.variants.Base = ConfigFile.Ranged(weaponName, thisClass, thisKind)

                ConfigFile.weapons[thisRange][thisClass][thisKind][weaponName] = table_update(weapon, newWeapon)
            end
        end
    end
    FileManager.saveAsJson(ConfigFile.weapons, "weapons.json")
    Main.weapons = ConfigFile.weapons
    ConfigFile.weapons = nil
end

function ConfigFile.GetVariants(weaponName, baseLocName)
    local vWeaponItemRecords = table_values(
        table_filter(
            ConfigFile.weaponItemRecords,
            function(key, record)
                local recordName = record:GetRecordID().value
                local tags = table_map(record:Tags(), function(k, t) return t.value end)
                local isDeprecatedIconic = table_contains(tags, "DeprecatedIconic")
                local isLeftHand = string.find(recordName, "_Left_Hand") ~= nil
                local isRetrofix = string.find(recordName, "Retrofix") ~= nil
                local isForbiddenVariant = table_contains(ConfigStatics.forbiddenVariations,
                    string.gsub(recordName, "Items.", ""))

                return string_startsWith(recordName, "Items.Preset_" .. weaponName)
                    --and isIconic
                    and not isDeprecatedIconic
                    and not isLeftHand
                    and not isRetrofix
                    and not isForbiddenVariant
            end
        )
    )

    local data = {}

    for key, record in pairs(vWeaponItemRecords) do
        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName())
        local vTag = table_map(record:VisualTags(), function(k, t) return t.value end)[1]

        local result = {
            recordName = record:GetRecordID().value,
            isIconic = table_contains(table_map(record:Tags(), function(k, t) return t.value end), "IconicWeapon"),
            -- tags = table_map(record:Tags(), function(k, t) return t.value end)
            vTag = vTag
        }

        if baseLocName ~= localizedName then
            result["localizedName"] = localizedName
        end

        data[vTag] = result
    end

    return data
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
