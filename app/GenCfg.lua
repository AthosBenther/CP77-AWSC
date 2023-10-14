GenCfg = {
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

function GenCfg.generate()
    --help = GenCfg.help
    FileManager.saveAsJson(nil, 'weapons.json')

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
                    and not table_contains(GenCfg.class, nameParts[2] .. "Weapon")
                    and localizedName ~= "!OBSOLETE"
                    and not table_contains(GenCfg.forbiddenWeapons, weaponName)
            end
        )
    )

    log("Filtered weapons: " .. #fWeaponItemRecords)

    for index, record in ipairs(fWeaponItemRecords) do
        local weaponName = string.gsub(record:GetRecordID().value, "Items.Base_", "")
        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName())
        if localizedName == "" then localizedName = weaponName end
        local tags = table_map(record:Tags(), function(k, t) return t.value end)

        local thisRanges = table_intersect(GenCfg.range, tags)
        local thisClasses = table_intersect(GenCfg.class, tags)
        local thisKinds = table_intersect(GenCfg.kind, tags)

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
            if (GenCfg.weapons[thisRange] == nil) then
                GenCfg.weapons[thisRange] = {}
            end
            if (GenCfg.weapons[thisRange][thisClass] == nil) then
                GenCfg.weapons[thisRange][thisClass] = {}
            end

            if (GenCfg.weapons[thisRange][thisClass][thisKind] == nil) then
                GenCfg.weapons[thisRange][thisClass][thisKind] = {}
            end

            if (thisRange == "RangedWeapon") then
                GenCfg.weapons[thisRange][thisClass][thisKind][weaponName] = {
                    LocalizedName = localizedName,
                    stats = GenCfg.Ranged(weaponName, thisClass, thisKind),
                    tags = tags
                }
            else
                GenCfg.weapons[thisRange][thisClass][thisKind][weaponName] = {
                    LocalizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName,
                    stats = GenCfg.Melee(weaponName, thisClass, thisKind),
                    tags = tags
                }
            end
        end
    end
    FileManager.saveAsJson(GenCfg.weapons, "weapons.json")
end

function GenCfg.Ranged(weaponName, thisClass, thisKind)
    local thisRange = "RangedWeapon"
    local damageFlatPath = "Items.Base_" .. weaponName .. "_Damage_Stats_inline0"
    if(string_split(weaponName,"_")[1] == "OutlawHeist") then damageFlatPath = "Items.Base_" .. weaponName .. "_inline0" end

    local magFlatPath = GenCfg.findFlat(
        "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers",
        "BaseStats.MagazineCapacityBase"
    )
    local cycleFlatPath = GenCfg.findFlat(
        "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers",
        "BaseStats.CycleTimeBase"
    )

    local stats = {}
    if damageFlatPath ~= nil then
        stats["damage"] = {
            flatPath = damageFlatPath,
            statType = "BaseStats.DPS",
            default = TweakDB:GetFlat(damageFlatPath .. '.value'),
            custom = TweakDB:GetFlat(damageFlatPath .. '.value'),
        }
    end
    if magFlatPath ~= nil then
        stats["magazine"] = {
            flatPath = magFlatPath,
            statType = "BaseStats.MagazineCapacityBase",
            default = TweakDB:GetFlat(magFlatPath .. '.value'),
            custom = TweakDB:GetFlat(magFlatPath .. '.value')
        }
    end

    if magFlatPath ~= nil then
        stats["cycleTime"] = {
            flatPath = cycleFlatPath,
            statType = "BaseStats.CycleTimeBase",
            default = TweakDB:GetFlat(cycleFlatPath .. '.value'),
            custom = TweakDB:GetFlat(cycleFlatPath .. '.value'),
        }
    end

    return stats
end

function GenCfg.Melee(weaponName, thisClass, thisKind)
    local thisRange = "MeleeWeapon"

    local rangeFlatPath = GenCfg.findFlat(
        "Items.Base_" .. weaponName .. "_Handling_Stats.statModifiers",
        "BaseStats.Range"
    )

    local stats = {}
    if rangeFlatPath ~= nil then
        stats["range"] = {
            flatPath = rangeFlatPath,
            statType = "BaseStats.Range",
            default = TweakDB:GetFlat(rangeFlatPath .. '.value'),
            custom = TweakDB:GetFlat(rangeFlatPath .. '.value'),
        }
    end

    return stats
end

function GenCfg.findFlat(statGroup, statType)
    local mods = TweakDB:GetFlat(statGroup)
    for key, mod in pairs(mods or {}) do
        local dbStatType = TweakDB:GetFlat(mod.value .. ".statType").value
        if dbStatType == statType then return mod.value end
    end
    return nil
end

return GenCfg

-- Items.Base_Nue.statModifierGroups
