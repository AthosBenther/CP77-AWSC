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
                damage = {
                    uiLabel = "Base Damage",
                    uiDescription = "Base Damage (Scales with weapon quality)",
                    statType = "BaseStats.DPS",
                    min = 0,
                    max = 1500,
                    step = 1,
                    format = "%f"
                },
                magazine = {
                    uiDescription = "Base Magazine Capacity",
                    statType = "BaseStats.MagazineCapacityBase",
                    uiLabel = "Magazine",
                    min = 0,
                    max = 300,
                    step = 1,
                    format = "%f"
                },
                cycleTime = {
                    uiDescription = "Base Cycle Time (in Milliseconds)",
                    statType = "BaseStats.CycleTimeBase",
                    uiLabel = "Cycle Time",
                    min = 0.001,
                    max = 5,
                    step = 0.001,
                    format = "%.3f"
                },
                EffectiveRange = {
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

function Weapon.GetVariantData(weaponName, recordPath, classification)
    local variantData = {}

    if Weapon.VariantData[classification.Range] then
        local classiDataRange = Weapon.VariantData[classification.Range].data
        variantData = table_merge(variantData, Weapon.genVarData(classiDataRange, recordPath, weaponName, classification))

        if Weapon.VariantData[classification.Range][classification.Class] then
            local classiDataClass = Weapon.VariantData[classification.Range][classification.Class].data
            variantData = table_merge(variantData,
                Weapon.genVarData(classiDataClass, recordPath, weaponName, classification))

            if Weapon.VariantData[classification.Range][classification.Class][classification.Type] then
                local classiDataKind = Weapon.VariantData[classification.Range][classification.Class]
                    [classification.Type]
                    .data
                variantData = table_merge(variantData,
                    Weapon.genVarData(classiDataKind, recordPath, weaponName, classification))
            end
        end
    end

    return variantData
end

function Weapon.genVarData(classiData, recordPath, weaponName, classification)
    local result = {}
    for key, data in pairs(classiData) do
        result[key] = {}
        for key2, value2 in pairs(data) do
            result[key][key2] = value2
        end
        local flatPath = Weapon.findStatModifier(data.statType, recordPath)

        if not flatPath then dd(data, recordPath, classification) end

        local weapon = Weapon.Find(weaponName, classification)
        local defaultFlatPath = nil

        if weapon then
            if weapon.Variants.Default then
                defaultFlatPath = weapon.Variants.Default[key].flatPath
            end
        end

        if defaultFlatPath == flatPath then goto continue end

        result[key]["flatPath"] = flatPath
        result[key]["default"] = TweakDB:GetFlat(flatPath .. ".value")
        result[key]["custom"] = result[key]["default"]

        ::continue::
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
    return Game.GetLocalizedItemNameByCName(weaponRecord:DisplayName())
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

return Weapon
