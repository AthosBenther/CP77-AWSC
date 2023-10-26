MainUI = {
    UI = nil
}


function MainUI.Init()
    MainUI.UI = GetMod("nativeSettings")

    if MainUI.UI then
        log("MainUI: Starting...")

        local status, errorMessage = pcall(function()
            RangedUI.Init()
            --MeleeUI.Init()
            log("MainUI: All UIs started!")
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
