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

        --Statics.FixDamage()
        Main.weapons = FileManager.loadJson('weapons.json')

        if
            Main.weapons == nil
            or table_count(Main.weapons) < 1
            or config("configs.forcenew", false)
        then
            log("Main: Generating new json")
            GenCfg.generate()
            -- Main.weapons = FileManager.loadJson('weapons.json')
        end

        Main.weapons = FileManager.loadJson('weapons.json')

        Retcon.init()

        Main.weapons = Retcon.weapons

        Ranged.Init()
        Melee.Init()
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

--   "Carnage_Recoil": 1,
--   "Carnage_Spread": 1,
--   "Carnage_Sway": 1,
--   "Carnage_ReloadTime": 1,
