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
    forbiddenVariationTerms = {
        "Retrofix",
        "Left_Hand",
        "Scene",
        "Hologram",
        "2020",
        "Unbreakable"
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
            HasVariants = false,
            Tags = {
                "RangedWeapon",
                "PowerWeapon",
                "Handgun"
            }
        },
        ["Items.Preset_Nue_Default"] = {
            Variants = {
                ["Items.Preset_Nue_Arasaka_2077"] = {
                    localizedName = "Tamayura (2077)"
                },
                ["Items.Preset_Nue_Arasaka_2020"] = {
                    localizedName = "Tamayura (2020)"
                }
            }
        }

    }
}

return ConfigStatics
