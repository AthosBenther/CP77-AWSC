ConfigStatics = {
    forbiddenWeapons = {
        "RocketLauncher",
        -- "Blade",
        "Vehicle_Power_Weapon",
        "Vehicle_Power_Weapon_OutlawHeist",
        "Machete_Kukri",
        "Machete_Borg",
        "One_Hand_Blade"
    },
    forbiddenVariantTerms = {
        "2020",
        "Hologram",
        "Left_Hand",
        "Retrofix",
        "Scene",
        "Unbreakable",
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
    },
    additionalWeapons = {
        ["Items.Preset_Silverhand_3516"] = {
            addVariants = false,
            addDefault = true,
            statsAlias = "Silverhand",
            Tags = {
                "RangedWeapon",
                "PowerWeapon",
                "Handgun"
            }
        },
        ["Items.Preset_Borg4a_HauntedGun"] = {
            addVariants = false,
            addDefault = true,
            statsAlias = "Borg4a",
            Tags = {
                "RangedWeapon",
                "PowerWeapon",
                "SMG"
            }
        },
        ["Items.Preset_Nue_Default"] = {
            addVariants = true,
            addDefault = false,
            Variants = {
                ["Items.Preset_Nue_Arasaka_2020"] = {
                    localizedName = "Tamayura",
                    disclaimer =
                    "Tamayura does not inherit any stat from Nue, despite being listed as a variant"
                }
            }
        },
        ["Items.Preset_Masamune_Default"] = {
            addVariants = true,
            addDefault = false,
            Variants = {
                ["Items.Preset_Masamune_Arasaka_2020"] = {
                    localizedName = "Nowaki"
                }
            }
        },
        ["Items.Preset_Saratoga_Default"] = {
            addVariants = true,
            addDefault = false,
            Variants = {
                ["Items.Preset_Saratoga_Arasaka_2020"] = {
                    localizedName = "Shigure"
                }
            }
        }
    }
}

function ConfigStatics.GetAdditional(weaponRecordPath)
    if ConfigStatics.additionalWeapons[weaponRecordPath] then
        return ConfigStatics.additionalWeapons[weaponRecordPath]
    else
        for additionalWeapon, additionalWeaponStats in pairs(ConfigStatics.additionalWeapons) do
            if additionalWeaponStats.Variants then
                if additionalWeaponStats.Variants[weaponRecordPath] then
                    return additionalWeaponStats.Variants
                        [weaponRecordPath]
                end
            end
        end
    end
end

return ConfigStatics
