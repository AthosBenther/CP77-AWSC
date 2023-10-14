Retcon = {
    weapons = {}
}


function Retcon.init()
    Retcon.weapons = FileManager.loadJson("weapons.json")

    if Retcon.weapons ~= {} and Retcon.weapons ~= nil then
        FixPozhar()
    end
end
