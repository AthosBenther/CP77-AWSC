GenCfg = {
    description = "Advanced Weapon Stat Customization",
    weapons = {},
    forbiddenWeapons = {
        "Silverhand",
        "Zhuo",
        "Warden",
        "Palica",
        "Authority",
        "Borg4a"
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
        local tags = table_map(record:Tags(), function(t) return t.value end)

        local thisRange = table_intersect(GenCfg.range, tags)[1]
        local thisClass = table_intersect(GenCfg.class, tags)[1]
        local thisKind = table_intersect(GenCfg.kind, tags)[1]

        local fullyClassified =
            thisRange ~= nil
            and thisClass ~= nil
            and thisKind ~= nil
            and weaponName ~= nil

        if (fullyClassified) then
            local techStatsInline = "Base_" .. weaponName .. "_Technical_Stats_inline"
            local dmgStatsInline0 = "Base_" .. weaponName .. "_Damage_Stats_inline0"
            local magInlineNo = 2

            if (table_contains(tags, "SmartWeapon")) then magInlineNo = 5 end
            if (table_contains(tags, "TechWeapon")) then magInlineNo = 6 end

            if (GenCfg.weapons[thisRange] == nil) then
                GenCfg.weapons[thisRange] = {}
            end
            if (GenCfg.weapons[thisRange][thisClass] == nil) then
                GenCfg.weapons[thisRange][thisClass] = {}
            end
            if (GenCfg.weapons[thisRange][thisClass][thisKind] == nil) then
                GenCfg.weapons[thisRange][thisClass][thisKind] = {}
            end

            GenCfg.weapons[thisRange][thisClass][thisKind][weaponName] = {
                LocalizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()),
                stats = {
                    -- baseEmptyReloadTime = weaponItemRecord:BaseEmptyReloadTime(),
                    -- baseReloadTime = weaponItemRecord:BaseReloadTime(),
                    magazine = {
                        flatPath = techStatsInline .. magInlineNo,
                        statType = "BaseStats.MagazineCapacityBase",
                        default = TweakDB:GetFlat('Items.' .. techStatsInline .. magInlineNo .. '.value'),
                        custom = TweakDB:GetFlat('Items.' .. techStatsInline .. magInlineNo .. '.value')
                    },
                    damage = {
                        flatPath = dmgStatsInline0,
                        statType = "BaseStats.DPS",
                        default = TweakDB:GetFlat('Items.' .. dmgStatsInline0 .. '.value'),
                        custom = TweakDB:GetFlat('Items.' .. dmgStatsInline0 .. '.value'),
                    },
                    cycleTime = {
                        flatPath = techStatsInline .. "1",
                        statType = "BaseStats.CycleBaseTime",
                        default = TweakDB:GetFlat('Items.' .. techStatsInline .. '1.value'),
                        custom = TweakDB:GetFlat('Items.' .. techStatsInline .. '1.value'),
                    }
                },
                tags = tags
            }
        end
    end

    FileManager.saveAsJson(GenCfg.weapons, "weapons.json")
end

return GenCfg
