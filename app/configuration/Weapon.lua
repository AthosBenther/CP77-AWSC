Weapon = {
    VariantData = {
        RangedWeapon = {
            HeavyWeapon = nil,
            PowerWeapon = nil,
            SmartWeapon = {
                data = {
                    Stats = {
                        SmartGunHipTimeToLock = {
                            uiDescription = "Hip Lock Time",
                            statType = "BaseStats.SmartGunHipTimeToLock",
                            uiLabel = "Hip Lock Time",
                            min = 0.001,
                            max = 3,
                            step = 0.001,
                            format = "%.3f",
                        },
                        SmartGunAdsTimeToLock = {
                            uiDescription = "Ads Lock Time",
                            statType = "BaseStats.SmartGunAdsTimeToLock",
                            uiLabel = "Ads Lock Time",
                            min = 0.001,
                            max = 3,
                            step = 0.001,
                            format = "%.3f",
                        }
                    }
                }
            },
            TechWeapon = nil,
            data = {
                LocalizedName = "",
                Stats = {
                    Crosshair = {
                        uiComponent = "SelectorString",
                        uiLabel = "Crosshair",
                        uiDescription = "Weapon Crosshair"
                    },
                    Damage = {
                        uiComponent = "Rangefloat",
                        uiLabel = "Damage",
                        uiDescription = "Damage (Scales with weapon quality)",
                        statType = "BaseStats.DPS",
                        min = 0,
                        max = 1500,
                        step = 1,
                        format = "%.0f"
                    },
                    Magazine = {
                        uiComponent = "Rangefloat",
                        uiDescription = "Magazine Capacity",
                        statType = "BaseStats.MagazineCapacityBase",
                        uiLabel = "Magazine",
                        min = 0,
                        max = 300,
                        step = 1,
                        format = "%.0f"
                    },
                    CycleTime = {
                        uiComponent = "Rangefloat",
                        uiDescription = "Cycle Time (in Milliseconds)",
                        statType = "BaseStats.CycleTimeBase",
                        uiLabel = "Cycle Time",
                        min = 0.001,
                        max = 5,
                        step = 0.001,
                        format = "%.3f"
                    }
                },
                Mods = {

                }
            }
        },
        MeleeWeapon = {
            ThrowableWeapon = {
                data = {
                    stats = {
                        EffectiveRange = {
                            uiDescription = "Thrown Range",
                            statType = "BaseStats.EffectiveRange",
                            uiLabel = "Throwing Range",
                            min = 0.1,
                            max = 100,
                            step = 0.1,
                            format = "%.1f",
                        }
                    }
                }
            },
            data = {
                LocalizedName = nil,
                Stats = {
                    Crosshair = {
                        uiComponent = "SelectorString",
                        uiLabel = "Crosshair",
                        uiDescription = "Weapon Crosshair"
                    },
                    Range = {
                        uiDescription = "Attack Range",
                        statType = "BaseStats.Range",
                        uiLabel = "Attack Range",
                        min = 0.1,
                        max = 100,
                        step = 0.1,
                        format = "%.1f",
                    },
                    Damage = {
                        uiComponent = "Rangefloat",
                        uiLabel = "Damage",
                        uiDescription = "Damage (Scales with weapon quality)",
                        statType = "BaseStats.DPS",
                        min = 0,
                        max = 1500,
                        step = 1,
                        format = "%.0f"
                    }
                }
            }
        }

    }
}

function Weapon.Classify(weapon, recordPath)
    local tags = table_map(weapon:Tags(), function(k, t) return t.value end)
    local thisRange = table_intersect(ConfigStatics.range, tags)[1]
    local thisClass = table_intersect(ConfigStatics.class, tags)[1]
    local thisKind = table_intersect(ConfigStatics.kind, tags)[1]
    if string.find(recordPath, "Pozhar") ~= nil then
        thisKind = "ShotgunWeapon"
    end
    return {
        Range = thisRange,
        Class = thisClass,
        Kind = thisKind
    }
end

---comment
---@param weaponName string
---@param recordPath string
---@param classification table
---@param weaponRecord gamedataWeaponItem_Record
---@return table
function Weapon.GetVariantData(weaponName, recordPath, classification, weaponRecord)
    local variantData = {
        recordPath = recordPath
    }

    if Weapon.VariantData[classification.Range] then
        local classiDataRange = Weapon.VariantData[classification.Range].data
        variantData = table_merge(variantData,
            Weapon.genVarData(classiDataRange, recordPath, weaponName, classification, weaponRecord))

        if Weapon.VariantData[classification.Range][classification.Class] then
            local classiDataClass = Weapon.VariantData[classification.Range][classification.Class].data
            variantData = table_merge(variantData,
                Weapon.genVarData(
                    classiDataClass,
                    recordPath,
                    weaponName,
                    classification,
                    weaponRecord
                )
            )

            if Weapon.VariantData[classification.Range][classification.Class][classification.Type] then
                local classiDataKind = Weapon.VariantData[classification.Range][classification.Class]
                    [classification.Type]
                    .data
                variantData = table_merge(variantData,
                    Weapon.genVarData(
                        classiDataKind,
                        recordPath,
                        weaponName,
                        classification,
                        weaponRecord
                    )
                )
            end
        end
    end

    return variantData
end

---comment
---@param classiData table
---@param recordPath string
---@param weaponName string
---@param classification table
---@param weaponRecord gamedataWeaponItem_Record
---@return table
function Weapon.genVarData(classiData, recordPath, weaponName, classification, weaponRecord)
    local result = {}
    for dataGroupKey, dataGroup in pairs(classiData) do
        if dataGroupKey == "LocalizedName" then
            result[dataGroupKey] = Weapon.GetLocalizedName(recordPath)
        elseif type(dataGroup) == "table" then
            local dataGroupKey = dataGroupKey
            result[dataGroupKey] = {}
            for statsKey, statsData in pairs(dataGroup) do
                local classiResult = {}
                local tableWeapon = Weapon.Find(weaponName, classification)

                if type(statsData) == "table" then
                    for stat, statValue in pairs(statsData) do
                        classiResult[stat] = statValue
                    end
                end

                if statsKey == "Crosshair" then
                    local xh = weaponRecord:Crosshair():GetRecordID().value
                    xh = string.gsub(xh, "Crosshairs.", "")
                    result[dataGroupKey][statsKey] = {}
                    result[dataGroupKey][statsKey]['default'] = xh
                    result[dataGroupKey][statsKey]['custom'] = xh
                else
                    local flatPath = Weapon.findStatModifier(statsData.statType, recordPath)

                    local defaultFlatPath = nil

                    if tableWeapon then
                        if table_count(tableWeapon.Variants) > 0 then
                            pcall(
                                function()
                                    defaultFlatPath = tableWeapon.Variants.Default[statsKey].flatPath
                                end
                            )
                        end
                    end

                    if flatPath and defaultFlatPath ~= flatPath then
                        classiResult["flatPath"] = flatPath
                        classiResult["modifierType"] = TweakDB:GetFlat(flatPath .. ".modifierType").value
                        classiResult["default"] = TweakDB:GetFlat(flatPath .. ".value")
                        classiResult["custom"] = classiResult["default"]

                        result[dataGroupKey][statsKey] = classiResult
                    end
                end
            end
        end
    end
    return result
end

---comment
---@param statType string
---@param weaponPath string
---@return unknown
function Weapon.findStatModifier(statType, weaponPath)
    local statGroups = TweakDB:GetFlat(weaponPath .. ".statModifierGroups")
    local result = nil
    local weaponName = Weapon.GetName(weaponPath)
    local nameParts = string_split(weaponName, "_")

    local defaultWeapon = weaponName
    if weaponName == "Tech_Sniper_Rifle" then defaultWeapon = "Rasetsu" end

    for key, statGroup in pairs(statGroups) do
        local statGroupName = TweakDB:GetRecord(statGroup):GetRecordID().value
        local modifiers = TweakDB:GetRecord(statGroup):StatModifiers()

        for key, modifier in pairs(modifiers or {}) do
            local dbStatType = nil
            local modifierRecordName = modifier:GetRecordID().value

            local status, errorMessage = pcall(function()
                dbStatType = modifier:StatType():GetRecordID().value



                if dbStatType and string_contains(modifierRecordName, defaultWeapon) then
                    local inline = modifier:GetRecordID().value
                    if dbStatType == statType and string_contains(inline, "inline") then
                        result = inline
                        return
                    end
                end
            end)

            if not status then
                log("Weapon.lua: Error trying to find the stat '" .. statType .. "' in '" .. weaponPath .. "'")
                log("dbStatType: " .. (dbStatType or "nil"))
                log("dbStatType: " .. (modifier:GetRecordID().value or "nil"))
                log(errorMessage)
            end
        end
    end
    if not result then
        log("Weapon.lua: Can't find the flatPath for the weapon " ..
        weaponName .. ", stat " .. statType)
    end
    return result
end

function Weapon.FindFlat(statGroup, statType, weaponPath)
    local weaponPath = weaponPath or nil
    if statGroup == nil then
        local inline = Weapon.findStatModifier(statType, weaponPath)
        return inline
    end
    local modifiers = TweakDB:GetFlat(statGroup)
    for key, modifier in pairs(modifiers or {}) do
        local dbStatType = TweakDB:GetFlat(modifier.value .. ".statType").value
        if dbStatType == statType then return modifier.value end
    end
    return nil
end

function Weapon.GetName(weaponPath, stopOn)
    local stopOn = stopOn or "Default"
    local parts = string_split(weaponPath, "_")
    table.remove(parts, 1)
    local nameParts = {}
    if stopOn and string_contains(weaponPath, stopOn) then
        local stop = table_indexOf(parts, stopOn) - 1
        for i = 1, stop, 1 do
            nameParts[i] = parts[i]
        end
    else
        nameParts = parts
    end
    local name = table_join(nameParts, "_")
    return name
end

function Weapon.GetVariantName(variantRecordName, variantRecord)
    if (Weapon.IsIconic(variantRecord)) then return Weapon.GetLocalizedName(variantRecord) end
    local vTag = table_map(variantRecord:VisualTags(), function(k, t) return t.value end)[1]
    return vTag
end

function Weapon.IsIconic(weaponRecord)
    return table_contains(table_map(weaponRecord:Tags(), function(k, t) return t.value end), "IconicWeapon")
end

function Weapon.GetLocalizedName(weaponRecord)
    local thisWeaponRecord = weaponRecord
    if type(weaponRecord) == "string" then thisWeaponRecord = TweakDB:GetRecord(weaponRecord) end
    return Game.GetLocalizedItemNameByCName(thisWeaponRecord:DisplayName())
end

function Weapon.Find(weaponName, classification, weaponsTable)
    local weaponsTable = weaponsTable or ConfigFile.weapons
    local weapon = {}
    if pcall(
            function()
                weapon = weaponsTable
                    [classification.Range]
                    [classification.Class]
                    [classification.Kind]
                    [weaponName]
            end
        ) then
        return weapon
    end
    return nil
end

function Weapon.SetCrosshair(storageWeapon, crosshair)
    local flatSuccess = true
    local commonVariants = { "Military", "Neon", "Pimp" }
    for variant, variantData in pairs(storageWeapon.Variants) do
        local variantRecord = variantData.recordPath
        flatSuccess = flatSuccess and Main.SetRecordValue(
            variantRecord, "crosshair",
            "Crosshairs." .. crosshair)
    end

    local defaultVariantRecord = storageWeapon.Variants.Default.recordPath

    for key, commonVariant in pairs(commonVariants) do
        flatSuccess = flatSuccess and Main.SetRecordValue(
            string.gsub(defaultVariantRecord, "Default", commonVariant), "crosshair",
            "Crosshairs." .. crosshair)
    end
    return flatSuccess
end

return Weapon
