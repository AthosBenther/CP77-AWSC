Main = {
    description = "Advanced Weapon Stat Customization",
    weapons = nil,
    rangeLabels = {
        ['MeleeWeapon'] = "Melee",
        ['RangedWeapon'] = "Weapons"
    },
    classLabels = {
        ['BladeWeapon'] = "Blades",
        ['BluntWeapon'] = "Blunt",
        ['HeavyWeapon'] = "Heavy",
        ['PowerWeapon'] = "Power Weapons",
        ['SmartWeapon'] = "Smart Weapons",
        ['TechWeapon'] = "Tech Weapons",
        ['ThrowableWeapon'] = "Throwable",
        ['OneHandedRangedWeapon'] = "One-Handed",
        ['Special'] = "Special"
    },
    kindLabels = {
        ['Grenade Launcher'] = "Grenade Launcher",
        ['Handgun'] = "Handgun",
        ['HMG'] = "HMG",
        ['LMG'] = "LMG",
        ['Revolver'] = "Revolver",
        ['Rifle Assault'] = "Assault Rifles",
        ['Rifle Precision'] = "Precision Rifles",
        ['Rifle Sniper'] = "Snipers",
        ['ShotgunWeapon'] = "Shotguns",
        ['Shotgun Dual'] = "Dual-Barrel Shotguns",
        ['SMG'] = "Submachineguns",

        ['Baton'] = "Batons",
        ['BladeWeapon'] = "Blades",
        ['One Hand Blade'] = "One-Handed Blades",
        ['One Hand Club'] = "One-Handed Clubs",
        ['Katana'] = "Katanas",
        ['Knife'] = "Knives",
        ['Two Hand Club'] = "Two-Handed Clubs",
        ['Two Hand Hammer'] = "Two-Handed Hammers",
        ['Knuckles'] = "Knuckle Sandwich"
    },
    triggerModes = {
        [1] = "Semi-Auto",
        [2] = "Burst",
        [3] = "Full-Auto",
        [4] = "Charge",
        [5] = "Windup",
        [6] = "Lock"
    },
    triggerModesLabels = {
        ["Semi-Auto"] = "TriggerMode.FullAuto",
        ["Burst"] = "TriggerMode.Burst",
        ["Full-Auto"] = "TriggerMode.SemiAuto",
        ["Charge"] = "TriggerMode.Charge",
        ["Windup"] = "TriggerMode.Windup",
        ["Lock"] = "TriggerMode.Loc"
    }
}
function Main.init()
    registerForEvent("onInit", function()
        log("AWSC: Hello World!")

        local fileValidation = ConfigFile.Validate()
        Main.UI = GetMod("nativeSettings")

        if fileValidation ~= true then
            log("Weapons.json file validation failed. Errors: ")
            log(fileValidation)
        end

        ConfigFile.Generate(fileValidation ~= true or config("configs.forcenew", false))


        for range, classes in pairs(Main.weapons) do
            for class, kinds in pairs(classes) do
                for kind, weapons in pairs(kinds) do
                    for weapon, weaponProps in pairs(weapons) do
                        for statIndex, stat in pairs(weaponProps.stats) do
                            Main.SetRecordValue(stat.flatPath, "value", stat.custom)
                        end
                    end
                end
            end
        end

        if Main.UI then
            Ranged.Init()
            Melee.Init()
        end
    end)
end

function Main.SetRecordValue(path, field, value)
    if not TweakDB:SetFlatNoUpdate(path .. "." .. field, value) then
        log("Error SetFlat: '" ..
            path .. "." .. field .. "' as '" .. value .. "'")
    end
    if not TweakDB:Update(path) then log("Error Update: " .. path) end
end

return Main
