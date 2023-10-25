Weapon = {
    VariantData = {
        RangedWeapon = {
            HeavyWeapon = nil,
            PowerWeapon = nil,
            SmartWeapon = {
                data = {
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
            },
            TechWeapon = nil,
            data = {
                LocalizedName = "",
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
                },
                EffectiveRange = {
                    uiComponent = "Rangefloat",
                    uiDescription = "Effective Range",
                    statType = "BaseStats.EffectiveRange",
                    uiLabel = "Effective Range",
                    min = 0.1,
                    max = 100,
                    step = 0.1,
                    format = "%.1f",
                }

            }
        },
        MeleeWeapon = {
            ThrowableWeapon = {
                data = {
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
            },
            data = {
                LocalizedName = nil,
                Range = {
                    uiDescription = "Attack Range",
                    statType = "BaseStats.Range",
                    uiLabel = "Attack Range",
                    min = 0.1,
                    max = 100,
                    step = 0.1,
                    format = "%.1f",
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
    for statsKey, statsData in pairs(classiData) do
        local classiResult = {}
        local tableWeapon = Weapon.Find(weaponName, classification)

        if type(statsData) == "table" then
            for stat, statValue in pairs(statsData) do
                classiResult[stat] = statValue
            end
        end

        if statsKey == "LocalizedName" then
            result[statsKey] = Weapon.GetLocalizedName(recordPath)
        elseif statsKey == "Crosshair" then
            local xh = weaponRecord:Crosshair():GetRecordID().value
            xh = string.gsub(xh, "Crosshairs.", "")
            result[statsKey] = {}
            result[statsKey]['default'] = xh
            result[statsKey]['custom'] = xh
        else
            local flatPath = Weapon.findStatModifier(statsData.statType, recordPath)

            if not flatPath then
                log("Weapon.lua:203: Can't find the flatPath for the weapon " ..
                    recordPath .. ", stat " .. statsKey)
            end

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

            if defaultFlatPath ~= flatPath then
                classiResult["flatPath"] = flatPath
                classiResult["modifierType"] = TweakDB:GetFlat(flatPath .. ".modifierType").value
                classiResult["default"] = TweakDB:GetFlat(flatPath .. ".value")
                classiResult["custom"] = classiResult["default"]

                result[statsKey] = classiResult
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
    for key, statGroup in pairs(statGroups) do
        local modifiers = TweakDB:GetRecord(statGroup):StatModifiers()
        for key, modifier in pairs(modifiers or {}) do
            local dbStatType = modifier:StatType():GetRecordID().value
            local inline = modifier:GetRecordID().value
            if dbStatType == statType and string_contains(inline, "inline") then return inline end
        end
    end
    return nil
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

function Weapon.GetName(data, stopOn)
    local stopOn = stopOn or ""
    local parts = string_split(data, "_")
    table.remove(parts, 1)
    local stop = table_indexOf(parts, "Default") - 1
    local nameParts = {}
    for i = 1, stop, 1 do
        nameParts[i] = parts[i]
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
