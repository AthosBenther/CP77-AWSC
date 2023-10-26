ConfigFile = {
    weapons = {}
}

function ConfigFile.Init(newFile)
    local newFile = newFile or false

    -- loads config file if not forcing the cration of a new one
    if newFile or config("configs.forcenew", false) then
        ConfigFile.Generate()
        MainUI.Init()
    else
        ConfigFile.weapons = FileManager.openJson(config("storage.weapons", "weapons.json"))
        MainUI.Init()
    end

    ConfigFile.SetAllRecords()
end

function ConfigFile.Generate()
    ConfigFile.weaponItemRecords = TweakDB:GetRecords('gamedataWeaponItem_Record')

    log("AWSC: loaded " .. table_count(ConfigFile.weaponItemRecords) .. " Weapon Item Records")

    local defaultWeapons = {}


    for k, record in pairs(ConfigFile.weaponItemRecords) do
        ---@type gamedataWeaponItem_Record
        local record = record

        local recordPath = record:GetRecordID().value
        local isDefault = string_endswith(recordPath, "Default")
        if not isDefault then goto continue end
        local weaponName = Weapon.GetName(recordPath)

        local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName


        if
            isDefault
            and localizedName ~= "!OBSOLETE"
            and not table_contains(ConfigStatics.forbiddenWeapons, weaponName)
        then
            defaultWeapons[recordPath] = record
        end

        ::continue::
    end

    for weaponRecordPath, weaponRecord in pairs(defaultWeapons) do
        local classification = Weapon.Classify(weaponRecord, weaponRecordPath)
        local weaponName = Weapon.GetName(weaponRecordPath)
        if (ConfigFile.weapons[classification.Range] == nil) then
            ConfigFile.weapons[classification.Range] = {}
        end
        if (ConfigFile.weapons[classification.Range][classification.Class] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName] = {}
        end

        if (ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"] == nil) then
            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"] = {}
        end

        local defaultVariantData = Weapon.GetVariantData(weaponName, weaponRecordPath, classification, weaponRecord)
        ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"]["Default"] =
            defaultVariantData



        local variants = {}

        for k, record in pairs(ConfigFile.weaponItemRecords) do
            local recordPath = record:GetRecordID().value

            local isVariant = string_startsWith(recordPath, "Items.Preset_" .. weaponName)
            local isValidVariant = not string_contains(recordPath, ConfigStatics.forbiddenVariationTerms)
            local tags = table_map(record:Tags(), function(k, t) return t.value end)
            local isDeprecatedIconic = table_contains(tags, "DeprecatedIconic")
            local isIconic = Weapon.IsIconic(record)

            if isVariant
                and isValidVariant
                and not string_endswith(recordPath, "Default")
                and not isDeprecatedIconic
                and isIconic
            then
                variants[recordPath] =
                    record
            end
        end

        for variantRecordPath, variantRecord in pairs(variants) do
            local variantName = Weapon.GetVariantName(variantRecordPath, variantRecord)
            local variantClassification = Weapon.Classify(variantRecord, variantRecordPath)

            local variantData = Weapon.GetVariantData(weaponName, variantRecordPath, variantClassification, weaponRecord)

            ConfigFile.weapons[classification.Range][classification.Class][classification.Kind][weaponName]["Variants"][variantName] =
                variantData
        end
    end


    --dd(ConfigFile.weapons)
    FileManager.saveAsJson(ConfigFile.weapons, config("storage.weapons", "weapons.json"))
end

function ConfigFile.Validate()
    local weapons = nil
    local tests = {
        [1] = {
            name = "fileExists",
            assertTrue = function() return FileManager.Exists(config("storage.weapons")) end,
            errorMessage = "File 'weapons.json' does not exists or could not be read",
            breakOnError = true
        },
        [2] = {
            name = "jsonIsValid",
            assertTrue = function() return pcall(function() FileManager.openJson(config("storage.weapons")) end) end,
            onPass = function() weapons = FileManager.openJson(config("storage.weapons")) end,
            errorMessage = "File 'weapons.json' is not a valid json",
            breakOnError = true
        },
        [3] = {
            name = "notNil",
            assertTrue = function() return weapons ~= nil end,
            errorMessage = "'Weapons' is nil",
            breakOnError = true
        },
        [4] = {
            name = "isTable",
            assertTrue = function() return type(weapons) == "table" end,
            errorMessage = "'Weapons' is not a table",
            breakOnError = true
        },
        [5] = {
            name = "isEmptyTable",
            assertTrue = function() return weapons ~= {} end,
            errorMessage = "'Weapons' is and empty table",
            breakOnError = true
        },
        [6] = {
            name = "rangedWeaponsPresent",
            assertTrue = function()
                return table_containsKey(weapons, "RangedWeapon")
            end,
            errorMessage = "'Weapons' does not have RangedWeapon",
            breakOnError = false
        },
        [7] = {
            name = "meleeWeaponsPresent",
            assertTrue = function()
                return table_containsKey(weapons, "MeleeWeapon")
            end,
            errorMessage = "'Weapons' does not have MeleeWeapon",
            breakOnError = false
        }
    }
    local errors = {}


    local tKeys = table_keys(tests)
    local tCount = table_count(tKeys)
    table.sort(tKeys)

    for i = 1, tCount, 1 do
        local test = tests[tKeys[i]]
        local testName = test.name
        if (test.assertTrue() == false) then
            local error = "AWSC Weapons validation failed on " .. testName .. " test: " .. test.errorMessage
            errors[testName] = error
            if (test.breakOnError) then
                return errors
            end
            if table_containsKey(test, "onFail") then test.onFail() end
        else
            if table_containsKey(test, "onPass") then test.onPass() end
        end
    end
    if table_count(errors) == 0 then return true else return errors end
end

function ConfigFile.SetAllRecords()
    log("configFile: Setting all records")
    for range, classes in pairs(ConfigFile.weapons) do
        for class, kinds in pairs(classes) do
            for kind, weapons in pairs(kinds) do
                for weapon, weaponData in pairs(weapons) do
                    for variant, stats in pairs(weaponData.Variants) do
                        for k, stat in pairs(stats) do
                            if
                                stat.flatPath
                                and stat.custom
                            then
                                Main.SetRecordValue(stat.flatPath, "value", stat.custom)
                            end
                        end
                    end
                end
            end
        end
    end
    log("configFile: All records set!")
end

return ConfigFile

-- Items.Base_Nue.statModifierGroups
