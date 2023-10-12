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
    recPath = "gamedataCombinedStatModifier_Record";

    recs = TweakDB:GetRecords(recPath);

    recsTable = {}
    for key, rec in pairs(recs) do
        recID = rec:GetID().value

        pcall(function()
            if (string_startsWith(recID, "Items.Base_Weapon_inline")) then
                recsTable[recID] = {
                    refStat = rec:RefStat():GetRecordID().value,
                    statType = rec:StatType():GetRecordID().value
                }
            end
        end
        )
    end

    FileManager.saveAsJson(recsTable, "recstable.json")
end