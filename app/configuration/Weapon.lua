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
                            min = 0.01,
                            max = 3,
                            step = 0.01,
                            format = "%.2f",
                        },
                        SmartGunAdsTimeToLock = {
                            uiDescription = "Ads Lock Time",
                            statType = "BaseStats.SmartGunAdsTimeToLock",
                            uiLabel = "Ads Lock Time",
                            min = 0.01,
                            max = 3,
                            step = 0.01,
                            format = "%.2f",
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
                        uiComponent = "RangeFloat",
                        uiLabel = "Damage",
                        uiDescription = "Damage (Scales with weapon quality)",
                        statType = "BaseStats.DPS",
                        min = 0,
                        max = 5000,
                        step = 1,
                        format = "%.0f"
                    },
                    Magazine = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Magazine Capacity",
                        statType = "BaseStats.MagazineCapacityBase",
                        uiLabel = "Magazine",
                        min = 0,
                        max = 3000,
                        step = 1,
                        format = "%.0f"
                    },
                    CycleTime = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Cycle Time",
                        statType = "BaseStats.CycleTimeBase",
                        uiLabel = "Cycle Time",
                        min = 0.001,
                        max = 3,
                        step = 0.001,
                        format = "%.3f"
                    },
                    EffectiveRange = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Effective Range",
                        statType = "BaseStats.EffectiveRange",
                        uiLabel = "Effective Range",
                        min = -100,
                        max = 100,
                        step = 0.1,
                        format = "%.1f"
                    },
                    HeadshotDamageMultiplier = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Headshot Damage",
                        statType = "BaseStats.HeadshotDamageMultiplier",
                        uiLabel = "Headshot Damage",
                        min = -100,
                        max = 100,
                        step = 0.1,
                        format = "%.1f"
                    },
                    ProjectilesPerShotBase = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Projectiles Per Shot",
                        statType = "BaseStats.ProjectilesPerShotBase",
                        uiLabel = "Projectiles Per Shot",
                        min = 1,
                        max = 50,
                        step = 1,
                        format = "%.0f"
                    },
                    NumShotsToFire = {
                        uiComponent = "RangeFloat",
                        uiDescription = "Number of bullets to fire in a burst",
                        statType = "BaseStats.NumShotsToFire",
                        uiLabel = "Shots To Fire",
                        min = 1,
                        max = 20,
                        step = 1,
                        format = "%.0f"
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
                        uiComponent = "RangeFloat",
                        uiLabel = "Damage",
                        uiDescription = "Damage (Scales with weapon quality)",
                        statType = "BaseStats.DPS",
                        min = 0,
                        max = 3000,
                        step = 1,
                        format = "%.0f"
                    }
                }
            }
        }

    }
}

---comment
---@param weaponRecord gamedataWeaponItem_Record
---@param weaponRecordPath string
---@return table
function Weapon.Classify(weaponRecord, weaponRecordPath)
    local weaponRecord = weaponRecord or TweakDB:GetRecord(weaponRecordPath)
    local tags = {}


    if ConfigStatics.additionalWeapons[weaponRecordPath] then
        if ConfigStatics.additionalWeapons[weaponRecordPath].Tags then
            tags = ConfigStatics.additionalWeapons[weaponRecordPath].Tags
        else
            tags = table_map(weaponRecord:Tags(), function(k, t) return t.value end)
        end
    else
        tags = table_map(weaponRecord:Tags(), function(k, t) return t.value end)
    end

    local thisRange = table_intersect(ConfigStatics.range, tags)[1]
    local thisClass = table_intersect(ConfigStatics.class, tags)[1]
    local thisKind = table_intersect(ConfigStatics.kind, tags)[1]
    if string.find(weaponRecordPath, "Pozhar") ~= nil then
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

        local genData = Weapon.genVarData(classiDataRange, recordPath, weaponName, classification, weaponRecord)

        variantData = table_merge(
            genData,
            variantData
        )

        if Weapon.VariantData[classification.Range][classification.Class] then
            local classiDataClass = Weapon.VariantData[classification.Range][classification.Class].data
            variantData = table_merge(
                Weapon.genVarData(
                    classiDataClass,
                    recordPath,
                    weaponName,
                    classification,
                    weaponRecord
                ),
                variantData
            )

            if Weapon.VariantData[classification.Range][classification.Class][classification.Type] then
                local classiDataKind = Weapon.VariantData[classification.Range][classification.Class]
                    [classification.Type]
                    .data
                variantData = table_merge(
                    Weapon.genVarData(
                        classiDataKind,
                        recordPath,
                        weaponName,
                        classification,
                        weaponRecord
                    ),
                    variantData
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
                local tableWeapon = Weapon.Find(recordPath)

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
---@param weaponRecordPath string
---@return unknown
function Weapon.findStatModifier(statType, weaponRecordPath)
    local statGroups = TweakDB:GetFlat(weaponRecordPath .. ".statModifierGroups")
    local result = nil
    local weaponName = Weapon.GetName(weaponRecordPath)
    local nameParts = string_split(weaponName, "_")

    local defaultWeapon = weaponName
    if weaponName == "Tech_Sniper_Rifle" then defaultWeapon = "Rasetsu" end
    local additionalWeapon = ConfigStatics.GetAdditional(weaponRecordPath)

    local statGroupTerms = {
        defaultWeapon
    }
    if additionalWeapon and additionalWeapon.statsAlias then table.insert(statGroupTerms, additionalWeapon.statsAlias) end

    for key, statGroup in pairs(statGroups) do
        local statGroupName = TweakDB:GetRecord(statGroup):GetRecordID().value
        local modifiers = TweakDB:GetRecord(statGroup):StatModifiers()

        for key, modifier in pairs(modifiers or {}) do
            local dbStatType = nil
            local modifierRecordName = modifier:GetRecordID().value

            local status, errorMessage = pcall(function()
                dbStatType = modifier:StatType():GetRecordID().value



                if dbStatType and string_contains(modifierRecordName, statGroupTerms) then
                    local inline = modifier:GetRecordID().value
                    if dbStatType == statType and string_contains(inline, "inline") then
                        result = inline
                        return
                    end
                end
            end)

            if status == false then
                log("Weapon.lua: Error trying to find the stat '" .. statType .. "' in '" .. weaponRecordPath .. "'")
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

function Weapon.FindFlat(statGroup, statType, weaponRecordPath)
    local weaponRecordPath = weaponRecordPath or nil
    if statGroup == nil then
        local inline = Weapon.findStatModifier(statType, weaponRecordPath)
        return inline
    end
    local modifiers = TweakDB:GetFlat(statGroup)
    for key, modifier in pairs(modifiers or {}) do
        local dbStatType = TweakDB:GetFlat(modifier.value .. ".statType").value
        if dbStatType == statType then return modifier.value end
    end
    return nil
end

function Weapon.GetName(weaponRecordPath, stopOn)
    local stopOn = stopOn or "Default"
    local parts = string_split(weaponRecordPath, "_")
    table.remove(parts, 1)
    local nameParts = {}
    if stopOn and string_contains(weaponRecordPath, stopOn) then
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
    if (Weapon.IsIconic(variantRecord)) then return Weapon.GetLocalizedName(variantRecordName) end
    local vTag = table_map(variantRecord:VisualTags(), function(k, t) return t.value end)[1]
    return vTag
end

function Weapon.IsIconic(weaponRecord)
    return table_contains(table_map(weaponRecord:Tags(), function(k, t) return t.value end), "IconicWeapon")
end

---comment
---@param weaponRecordPath string
---@return string
function Weapon.GetLocalizedName(weaponRecordPath)
    if ConfigStatics.additionalWeapons[weaponRecordPath] then
        if ConfigStatics.additionalWeapons[weaponRecordPath].localizedName ~= nil then
            return ConfigStatics.additionalWeapons[weaponRecordPath].localizedName
        end
    else
        local result = nil
        local a = table_map(ConfigStatics.additionalWeapons,
            function(k, aw)
                if aw.Variants then
                    table_map(aw.Variants,
                        function(k, v)
                            if weaponRecordPath == k and v.localizedName then
                                result = v.localizedName
                            end
                        end
                    )
                end
            end
        )
        if result then return result end
    end

    local weaponRecord = TweakDB:GetRecord(weaponRecordPath)
    return Game.GetLocalizedItemNameByCName(weaponRecord:DisplayName())
end

function Weapon.Find(weaponRecordPath, weaponsTable)
    local weaponsTable = weaponsTable or ConfigFile.Weapons

    for range, classes in pairs(ConfigFile.Weapons) do
        for class, kinds in pairs(classes) do
            for kind, weapons in pairs(kinds) do
                for weapon, weaponData in pairs(weapons) do
                    if weaponData.Variants.Default then
                        if weaponData.Variants.Default.recordPath then
                            if weaponData.Variants.Default.recordPath == weaponRecordPath then return weaponData end
                        end
                    end
                end
            end
        end
    end
end

function Weapon.FindByName(weaponName, weaponsTable)
    local weaponsTable = weaponsTable or ConfigFile.Weapons

    for range, classes in pairs(ConfigFile.Weapons) do
        for class, kinds in pairs(classes) do
            for kind, weapons in pairs(kinds) do
                for weapon, weaponData in pairs(weapons) do
                    if weapon == weaponName then return weaponData end
                end
            end
        end
    end
end

function Weapon.FindVariant(variantRecordPath)
    for range, classes in pairs(ConfigFile.Weapons) do
        for class, kinds in pairs(classes) do
            for kind, weapons in pairs(kinds) do
                for weapon, weaponData in pairs(weapons) do
                    for variant, variantProperties in pairs(weaponData.Variants) do
                        if variantProperties.recordPath then
                            if variantProperties.recordPath == variantRecordPath then return variantProperties end
                        end
                    end
                end
            end
        end
    end
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
