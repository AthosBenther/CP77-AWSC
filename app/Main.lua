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

        ConfigFile.Init()
    end)
end

function Main.SetRecordValue(path, field, value)
    if path == nil then log("Cannot set a record because it's path is not set") end
    if field == nil then log("Cannot set a record because it's field is not set") end
    if value == nil then log("Cannot set a record because it's value is not set") end

    if path == nil
        or field == nil
        or value == nil
    then
        log(
            {
                path,
                field,
                value
            }
        )
        return false
    end

    if TweakDB:GetFlat(path .. "." .. field) then
        if not TweakDB:SetFlat(path .. "." .. field, value) then
            log("Main: Failed to SetFlat: '" ..
                path .. "." .. field .. "' as '" .. value .. "'")
            return false
        end
    else
        if not field == "crosshair" then
            log("Main: the flat '" .. path .. "." .. field .. "' does not exist.")
        end
    end
    return true
end

return Main
