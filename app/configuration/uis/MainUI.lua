MainUI = {
    UI = nil,
    xhairsOptions = {
        [1] = "Basic",
        [2] = "BlackwallForce",
        [3] = "Custom_HMG",
        [4] = "Cyberware_Mantis_Blades",
        [5] = "Cyberware_Projectile_Launcher",
        [6] = "Driver_Combat_Missile_Launcher",
        [7] = "Driver_Combat_Power_Weapon",
        [8] = "Hercules",
        [9] = "Hex",
        [10] = "Jailbreak_power",
        [11] = "Jailbreak_smart",
        [12] = "Jailbreak_tech",
        [13] = "Melee_Bottle",
        [14] = "Melee_Hammer",
        [15] = "Melee_Knife",
        [16] = "Melee_Nano_Wire",
        [17] = "Melee_Strong_Arms",
        [18] = "Melee",
        [19] = "None",
        [20] = "NoWeapon",
        [21] = "Pistol",
        [22] = "Power_Defender",
        [23] = "Power_Overture",
        [24] = "Power_Saratoga",
        [25] = "Rasetsu",
        [26] = "Simple",
        [27] = "SmartGun",
        [28] = "Tech_Hex",
        [29] = "Tech_Round",
        [30] = "Tech_Simple"
    }
}


function MainUI.Init()
    MainUI.UI = GetMod("nativeSettings")

    if MainUI.UI then
        log("MainUI: Starting...")

        local status, errorMessage = pcall(function()
            RangedUI.Init()
            log("MainUI: Ranged UI started!")
            MeleeUI.Init()
            log("MainUI: Melee UI started!")
        end)

        if not status then
            log("MainUI: UI Initialization failed. Error:")
            log(errorMessage)
        end
    else
        log("MainUI: Native Settings UI not found.")
    end
end

return MainUI
