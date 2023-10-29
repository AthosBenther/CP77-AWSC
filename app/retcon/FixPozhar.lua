FixPozhar = {
}


function FixPozhar()
    local pRifles = Retcon.weapons.RangedWeapon.PowerWeapon['Rifle Precision']

    
    if pRifles.Pozhar then
        local pozhar = pRifles.Pozhar
        local pRiflesRetcon = {}
        for pRifleName, pRifle in pairs(pRifles) do
            if pRifleName ~= "Pozhar" then
                pRiflesRetcon[pRifleName] = pRifle
            end
        end
        Retcon.weapons.RangedWeapon.PowerWeapon.ShotgunWeapon["Pozhar"] = pozhar
        Retcon.weapons.RangedWeapon.PowerWeapon['Rifle Precision'] = pRiflesRetcon
        FileManager.saveAsJson(Retcon.weapons, "weapons.json")
    end
end

return FixPozhar
