Weapon = {
    VariantData = {
        RangedWeapon = {
            HeavyWeapon = {},
            PowerWeapon = {},
            SmartWeapon = {
                data = {}
            },
            TechWeapon = {},
            data = {
                damage = {
                    uiLabel = "Base Damage",
                    uiDescription = "Base Damage (Scales with weapon quality)",
                    statType = "BaseStats.DPS",
                    min = 0,
                    max = 1500,
                    step = 1,
                    format = "%f"
                }
            }
        },
        MeleeWeapon = {

            data = {}
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

function Weapon.GetVariantData(weapon, recordPath, classification)
    local variantData = {}

    local classiData = Weapon.VariantData[classification.Range].data
    if classiData then
        variantData = Weapon.genVarData(classiData, recordPath)
    end
    return variantData
end

function Weapon.genVarData(classiData, recordPath)
    local result = {}
    for key, data in pairs(classiData) do
        result[key] = {}
        for key2, value2 in pairs(data) do
            result[key][key2] = value2
        end
        local flatPath = Weapon.findStatModifier(data.statType, recordPath2)

        result[key]["flatPath"] = flatPath
        result[key]["default"] = TweakDB:GetFlat(flatPath .. ".value")
        result[key]["custom"] = result[key]["default"]
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

return Weapon
