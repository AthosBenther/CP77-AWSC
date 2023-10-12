GenCfg = {
    description = "Advanced Weapon Stat Customization",
    weapons = {},
    forbiddenWeapons = {
        "Silverhand",
        "Zhuo",
        "Warden",
        "Palica",
        "Authority",
        "Borg4a",
        "RocketLauncher"
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
        'OneHandedRangedWeapon',
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
    print("AWSC: loaded " .. #weaponItemRecords .. " Weapon Item Records")

    local fWeaponItemRecords = table_getValues(table_filter(weaponItemRecords,
        function(key, item)
            local weaponName = string.gsub(item:GetRecordID().value, "Items.Base_", "")
            return string_startsWith(item:GetRecordID().value, "Items.Base_")
                and #(string_split(item:GetRecordID().value, "_")) < 3
                and not table_contains(GenCfg.forbiddenWeapons, weaponName)
        end
    )
    )

    print("Filtered weapons: " .. #fWeaponItemRecords)

    for index, record in ipairs(fWeaponItemRecords) do
        local weaponName = string.gsub(record:GetRecordID().value, "Items.Base_", "")
        local tags = table_map(record:Tags(), function(k, t) return t.value end)

        local thisRange = table_intersect(GenCfg.range, tags)[1]
        local thisClass = table_intersect(GenCfg.class, tags)[1]
        local thisKind = table_intersect(GenCfg.kind, tags)[1]

        local fullyClassified =
            thisRange ~= nil
            and thisClass ~= nil
            and thisKind ~= nil
            and weaponName ~= nil

        if (fullyClassified) then
            local dmgStatsInline0 = "Items.Base_" .. weaponName .. "_Damage_Stats_inline0"
            local triggerModePath = "Items.Base_" .. weaponName 

            if (GenCfg.weapons[thisRange] == nil) then
                GenCfg.weapons[thisRange] = {}
            end
            if (GenCfg.weapons[thisRange][thisClass] == nil) then
                GenCfg.weapons[thisRange][thisClass] = {}
            end
            if (GenCfg.weapons[thisRange][thisClass][thisKind] == nil) then
                GenCfg.weapons[thisRange][thisClass][thisKind] = {}
            end

            local magFlatPath = GenCfg.findFlat(
                "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers",
                "BaseStats.MagazineCapacityBase"
            )
            local cycleFlatPath = GenCfg.findFlat(
                "Items.Base_" .. weaponName .. "_Technical_Stats.statModifiers",
                "BaseStats.CycleTimeBase"
            )
            
            local triggerMode = {
                flatPath = triggerModePath,
                statType = "BaseStats.TriggerMode",
                default = TweakDB:GetFlat(triggerModePath .. ".primaryTriggerMode").value,
                custom = TweakDB:GetFlat(triggerModePath .. ".primaryTriggerMode").value,
            }

            local stats = {
                damage = {
                    flatPath = dmgStatsInline0,
                    statType = "BaseStats.DPS",
                    default = TweakDB:GetFlat(dmgStatsInline0 .. '.value'),
                    custom = TweakDB:GetFlat(dmgStatsInline0 .. '.value'),
                },
                triggerMode = triggerMode
            }

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

            GenCfg.weapons[thisRange][thisClass][thisKind][weaponName] = {
                LocalizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()),
                stats = stats,
                tags = tags
            }
        end
    end

    FileManager.saveAsJson(GenCfg.weapons, "weapons.json")
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
