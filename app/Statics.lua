Statics = {
    Invalidate = {
        85,
        96, -- Lowers DPS based on Magazine size like wtf???
        97, -- Apparently Lowers DPS based on Reload speed. To the chopping block I say...
        98  -- Lowers DPS based on Projectiles per shot
    }
}


function Statics.FixDamage()
    for key, inlineIndex in ipairs(Statics.Invalidate) do
        TweakDB:SetFlat("Items.Base_Weapon_inline" .. inlineIndex .. ".modifierType", "Invalid")
        TweakDB:SetFlat("Items.Base_Weapon_inline" .. inlineIndex .. ".value", 0)
        TweakDB:Update("Items.Base_Weapon_inline" .. inlineIndex)
    end
end

function Statics.GetModifiers()
    local recPath = "gamedataCombinedStatModifier_Record";

    local recs = TweakDB:GetRecords(recPath);

    local recsTable = {}

    recs = table_filter(recs,
        function(k, rec) return string_startsWith(rec:GetID().value, "Items.Base_Weapon_inline") end)

    table_map(recs, function(k, rec)
        pcall(function()
            local recID = rec:GetID().value

            recsTable[recID] = {
                modifierType = rec:ModifierType().value,
                opSymbol = rec:OpSymbol().value,
                refObject = rec:RefObject().value,
                refStat = rec:RefStat():GetRecordID().value,
                statType = rec:StatType():GetRecordID().value,
                value = rec:Value()
            }
        end)
    end)

    table.sort(recsTable)

    FileManager.saveAsJson(recsTable, "recstable.json")
end

return Statics
