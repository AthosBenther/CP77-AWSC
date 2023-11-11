ConfigFile = {
	Weapons = {}
}
function ConfigFile.Init()
	-- ConfigFile.AddAdditionalWeapons()
	-- MainUI.Init()
	-- dd(ConfigFile.Weapons)
	local newFile = false
	local fileValidation = ConfigFile.Validate()

	if fileValidation ~= true then
		log("ConfigFile: Weapons.json file validation failed. Errors: ")
		log(fileValidation)
		newFile = true
		ConvertSave.Init()
	end

	if newFile or config("configs.forcenew", false) then
		if newFile then
			log("ConfigFile: generating new " .. config("storage.weapons"))
		end
		ConfigFile.Generate()
	else
		ConfigFile.Load()
	end

	ConfigFile.AddAdditionalWeapons()
	ConfigFile.Save()
	log("ConfigFile: '" .. config("storage.weapons", "weapons.json") .. "' saved!")

	ConfigFile.SetAllRecords()
	MainUI.Init()
end

function ConfigFile.Save()
	local data = {
		Version = config("app.version"),
		Weapons = ConfigFile.Weapons
	}
	if data.Version then
		FileManager.saveAsJson(data, config("storage.weapons", "weapons.json"))
	else
		error("ConfigFile: Can't save Weapons Stats. Game version is not valid!")
	end
end

function ConfigFile.Load()
	ConfigFile.Weapons = (FileManager.openJson(config("storage.weapons", "weapons.json"))).Weapons
end

function ConfigFile.Generate()
	ConfigFile.weaponItemRecords = TweakDB:GetRecords("gamedataWeaponItem_Record")
	log("ConfigFile: loaded " .. table_count(ConfigFile.weaponItemRecords) .. " Weapon Item Records")
	local defaultWeapons = {}
	table_map(ConfigFile.weaponItemRecords, function(k, record)
		local record = record
		local recordPath = (record:GetRecordID()).value
		local isDefault = string_endsWith(recordPath, "Default")
		local isPreset = string_startsWith(recordPath, "Items.Preset")
		if isPreset and isDefault then
			local weaponName = Weapon.GetName(recordPath)
			local localizedName = Game.GetLocalizedItemNameByCName(record:DisplayName()) or weaponName
			if localizedName ~= "!OBSOLETE" and (not table_contains(ConfigStatics.forbiddenWeapons, weaponName)) then
				defaultWeapons[recordPath] = record
			end
		end
	end)

	log("ConfigFile: found " .. table_count(defaultWeapons) .. " valid Default Weapons")
	for weaponRecordPath, weaponRecord in pairs(defaultWeapons) do
		ConfigFile.AddWeapon(weaponRecordPath, weaponRecord)
	end
end

function ConfigFile.AddAdditionalWeapons()
	for weaponRecordPath, additionalWeaponData in pairs(ConfigStatics.additionalWeapons) do
		local weaponName = Weapon.GetName(weaponRecordPath)
		local weaponRecord = TweakDB:GetRecord(weaponRecordPath)
		local classification = Weapon.Classify(weaponRecord, weaponRecordPath)

		if additionalWeaponData.addDefault then
			local configWeapon = Weapon.Find(weaponRecordPath, classification)

			if configWeapon == nil or config("configs.forceadditionals", false) then
				log("ConfigWeapon: Adding weapon '" .. weaponName .. "'")
				ConfigFile.AddWeapon(weaponRecordPath, nil, additionalWeaponData.addVariants)
			end
		end

		if additionalWeaponData.Variants and additionalWeaponData.addVariants then
			for variantRecordPath, additionalVariantData in pairs(additionalWeaponData.Variants) do
				local configVariant = Weapon.FindVariant(variantRecordPath)
				if configVariant == nil or config("configs.forceadditionals", false) then
					log("ConfigWeapon: Adding variant '" ..
						variantRecordPath .. "' for the weapon '" .. weaponName .. "'")
					ConfigFile.AddVariant(weaponName, TweakDB:GetRecord(weaponRecordPath), variantRecordPath, nil, nil,
						weaponRecordPath)
				end
			end
		end
	end
end

---comment
---@param weaponRecordPath string
---@param weaponRecord? gamedataWeaponItem_Record
---@param addVariants? boolean
function ConfigFile.AddWeapon(weaponRecordPath, weaponRecord, addVariants)
	if addVariants == false then addVariants = false else addVariants = true end
	local weaponRecord = weaponRecord or TweakDB:GetRecord(weaponRecordPath)
	local classification = Weapon.Classify(weaponRecord, weaponRecordPath)
	local weaponName = Weapon.GetName(weaponRecordPath)


	ConfigFile.AddClassification(classification)
	if ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName] == nil then
		ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName] = {}
	end
	if ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants == nil then
		ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants = {}
	end
	local defaultVariantData = Weapon.GetVariantData(weaponName, weaponRecordPath, classification, weaponRecord)
	local oldVariant = {}
	if pcall(function()
			oldVariant = ConfigFile.oldWeapons[classification.Range][classification.Class][classification.Kind]
				[weaponName].Variants.Default
		end) then
		if oldVariant then
			for statKey, stats in pairs(defaultVariantData.Stats) do
				if statKey ~= "EffectiveRange" then
					local oldStat = oldVariant.Stats[statKey]
					if oldStat then
						defaultVariantData.Stats[statKey].custom = oldStat.custom
					end
				end
			end
		end
	else
		log("ConfigFile: The weapon " .. weaponName .. " cant be found in the old save. Creating new records...")
	end

	ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants.Default =
		defaultVariantData

	if addVariants then
		ConfigFile.AddVariants(weaponName, weaponRecord, classification)
	end
end

---comment
---@param weaponName string
---@param weaponRecord gamedataWeaponItem_Record
---@param variantRecordPath string
---@param variantRecord? gamedataWeaponItem_Record
---@param weaponRecordPath? string
---@param classification? table
function ConfigFile.AddVariant(weaponName, weaponRecord, variantRecordPath, variantRecord, classification,
							   weaponRecordPath)
	local variantRecord = variantRecord or TweakDB:GetRecord(variantRecordPath)
	local classification = classification or Weapon.Classify(nil, variantRecordPath)


	local variantName = Weapon.GetVariantName(variantRecordPath, variantRecord)
	local variantClassification = Weapon.Classify(variantRecord, variantRecordPath)
	local variantData = Weapon.GetVariantData(weaponName, variantRecordPath, variantClassification, weaponRecord)

	ConfigFile.AddClassification(classification)

	if not ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName] then
		ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName] = {}
	end

	if not ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants then
		ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants = {}
	end

	ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants[variantName] =
		variantData

	if weaponRecordPath then
		if ConfigStatics.additionalWeapons[weaponRecordPath] then
			log(weaponRecordPath)
			if ConfigStatics.additionalWeapons[weaponRecordPath].Variants[variantRecordPath] then
				log(variantRecordPath)
				if ConfigStatics.additionalWeapons[weaponRecordPath].Variants[variantRecordPath].disclaimer then
					local disclaimer = ConfigStatics.additionalWeapons[weaponRecordPath].Variants[variantRecordPath]
						.disclaimer

					ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind][weaponName].Variants[variantName].Disclaimer =
						disclaimer
				end
			end
		end
	end
end

function ConfigFile.AddVariants(weaponName, weaponRecord, classification)
	local variants = {}
	for k, record in pairs(ConfigFile.weaponItemRecords) do
		local recordPath = (record:GetRecordID()).value
		local isVariant = string_startsWith(recordPath, "Items.Preset_" .. weaponName)
		local isValidVariant = not string_contains(recordPath, ConfigStatics.forbiddenVariantTerms)

		if not string_endsWith(recordPath, "Default") and isVariant and isValidVariant then
			local tags = table_map(record:Tags(), function(k, t)
				return t.value
			end)

			local isDeprecatedIconic = table_contains(tags, "DeprecatedIconic")
			local isIconic = Weapon.IsIconic(record)
			if isVariant and isValidVariant and (not isDeprecatedIconic) and isIconic then
				variants[recordPath] = record
			end
		end
	end
	for variantRecordPath, variantRecord in pairs(variants) do
		ConfigFile.AddVariant(weaponName, weaponRecord, variantRecordPath, variantRecord, classification)
	end
end

function ConfigFile.AddClassification(classification)
	if ConfigFile.Weapons[classification.Range] == nil then
		ConfigFile.Weapons[classification.Range] = {}
	end
	if ConfigFile.Weapons[classification.Range][classification.Class] == nil then
		ConfigFile.Weapons[classification.Range][classification.Class] = {}
	end
	if ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind] == nil then
		ConfigFile.Weapons[classification.Range][classification.Class][classification.Kind] = {}
	end
end

function ConfigFile.Validate()
	local weapons = nil
	local file = nil
	local tests = {
		[1] = {
			name = "fileExists",
			assertTrue = function()
				return FileManager.Exists(config("storage.weapons"))
			end,
			errorMessage = "File 'weapons.json' does not exists or could not be read",
			breakOnError = true
		},
		[2] = {
			name = "jsonIsValid",
			assertTrue = function()
				return pcall(function()
					FileManager.openJson(config("storage.weapons"))
				end)
			end,
			onPass = function()
				file = FileManager.openJson(config("storage.weapons"))
			end,
			errorMessage = "File " .. config("storage.weapons") .. " is not a valid json",
			breakOnError = true
		},
		[3] = {
			name = "fileFormatIsValid",
			assertTrue = function()
				return type(file.Version) == "string" and file.Version == config("app.version") and
					type(file.Weapons) == "table"
			end,
			onPass = function()
				weapons = file.Weapons
			end,
			errorMessage = "File " .. config("storage.weapons") .. " is not correctly formatted",
			breakOnError = true
		},
		[4] = {
			name = "isTable",
			assertTrue = function()
				return type(weapons) == "table"
			end,
			errorMessage = "'Weapons' is not a table",
			breakOnError = true
		},
		[5] = {
			name = "isEmptyTable",
			assertTrue = function()
				return weapons ~= {}
			end,
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
		if test.assertTrue() == false then
			local error = "AWSC Weapons validation failed on " .. testName .. " test: " .. test.errorMessage
			errors[testName] = error
			if test.breakOnError then
				return errors
			end
			if table_containsKey(test, "onFail") then
				test.onFail()
			end
		elseif table_containsKey(test, "onPass") then
			test.onPass()
		end
	end
	if table_count(errors) == 0 then
		return true
	else
		return errors
	end
end

function ConfigFile.SetAllRecords()
	log("ConfigFile: Setting records...")
	for range, classes in pairs(ConfigFile.Weapons) do
		for class, kinds in pairs(classes) do
			for kind, weapons in pairs(kinds) do
				for weapon, weaponData in pairs(weapons) do
					for variant, properties in pairs(weaponData.Variants) do
						for propK, propValues in pairs(properties) do
							if type(propValues) == "table" then
								for statName, stat in pairs(propValues) do
									if stat.flatPath and stat.custom then
										Main.SetRecordValue(stat.flatPath, "value", stat.custom)
									elseif statName == "Crosshair" then
										Weapon.SetCrosshair(weaponData, stat.custom)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	log("ConfigFile: All records set!")
end

return ConfigFile
