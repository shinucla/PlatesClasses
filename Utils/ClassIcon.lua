local NAME = "ClassIcon"

local AceAddon = LibStub("AceAddon-3.0");
local addon = AceAddon:GetAddon("PlatesClasses");

local util = {}
addon.Utils[NAME] = util;

util.nameplateIconFrameNameCounter = 1

function util:AddVariables(db)
	db.IconSettings = db.IconSettings or self:GetDefaultNameplateIconSettings();
end

function util:GetDefaultNameplateIconSettings()
	return 
	{
		Size = 32,
		Alpha = 1,
		EnemiesOnly = false,
		DisplayClassIconBorder = true,
		BorderFollowNameplateColor = true,
		OffsetX = 7,
		OffsetY = -9,
		ShowQuestionMarks = false
	}
end

function util:GetNameplateFrame(nameplate)
	return nameplate.nameplateIcon;
end

function util:GetOrCreateNameplateFrame(nameplate)
	if nameplate.nameplateIcon == nil then
		local nameplateIcon = CreateFrame("Frame", 'PlatesClassesIconFrame' .. util.nameplateIconFrameNameCounter, nameplate);
		util.nameplateIconFrameNameCounter = util.nameplateIconFrameNameCounter + 1;
		
		nameplateIcon.Clear = function(this)
			this:Hide();
			this:SetMetadata({}, nil)
			this:SetCustomAppearance(nil)
			this.classBorderTexture:Hide();
		end
		
		nameplateIcon.SetCustomAppearance = function(this, appearenceFunc)
			this.customAppearance = appearenceFunc;
		end
		
		nameplateIcon.SetMetadata = function(this, metadata, targetName)
			this.class = metadata.class;
			this.isPlayer = metadata.isPlayer;
			this.isHostile = metadata.isHostile;
			this.isPet = metadata.isPet;
			this.targetName = targetName;
		end
		
		nameplateIcon.UpdateAppearence = function(this, customSettings)
			local settings = customSettings;
			
			if settings.EnemiesOnly and this.isHostile == false then
				return
			end
			
			if this.isPlayer ~= true and settings.playersOnly ~= false then
				return
			elseif this.class == nil then
				if settings.ShowQuestionMarks then
					SetPortraitToTexture(this.classTexture,"Interface\\Icons\\Inv_misc_questionmark")
					this.classTexture:SetTexCoord(0.075, 0.925, 0.075, 0.925);
					this:Show();
				else
					this.classTexture:SetTexture(nil)
				end
			elseif this.isPlayer then
				this.classTexture:SetTexture(addon.path .. "\\images\\UI-CHARACTERCREATE-CLASSES_ROUND");
				if CLASS_ICON_TCOORDS[this.class] == nil then
					error("Unexpected class:", this.class)
				end
				this.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[this.class]));
				this:Show();
			end

			if this.class ~= nil and settings.DisplayClassIconBorder then
				this.classBorderTexture:Show();
			else
				this.classBorderTexture:Hide();
			end
			
			this.FollowNameplateColor = settings.FollowNameplateColor;
			this:SetAlpha(settings.Alpha);
			this:SetWidth(settings.Size);
			this:SetHeight(settings.Size);
			this:SetPoint("RIGHT", nameplate, "LEFT", settings.OffsetX, settings.OffsetY);
			
			if this.customAppearance ~= nil then
				this.customAppearance(this)
			end
		end
		
		local texture = nameplateIcon:CreateTexture(nil, "ARTWORK");
		texture:SetAllPoints();
		nameplateIcon.classTexture = texture;
		
		local textureBorder = nameplateIcon:CreateTexture(nil, "BORDER");
		textureBorder:SetTexture(addon.path .. "\\images\\RoundBorder");
		textureBorder:SetAllPoints()
		textureBorder:Hide()
		nameplateIcon.classBorderTexture = textureBorder;
		nameplate.nameplateIcon = nameplateIcon;
	end
	
	return nameplate.nameplateIcon;
end

function util:AddBlizzardOptions(options, dbConnection, iterator)
	if iterator == nil then
		iterator = Utils.Iterator:New();
	end
	
	options.args["ClassIconDescriptionSpace"] = 
	{
		type = "description",
		name = " ",
		fontSize = "large",
		order = iterator()
	}
	
	options.args["ClassIconDescription"] = 
	{
		type = "description",
		width = "full",
		name = "Class icon Settings:",
		fontSize = "large",
		order = iterator()
	}
	
	options.args["Size"] = 
	{
		type = "range",
		name = "Size",
		desc = "",
		min = 0,
		max = 256,
		softMin = 8,
		softMax = 64,
		step = 2,
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["Alpha"] = 
	{
		type = "range",
		name = "Alpha",
		desc = "",
		min = 0,
		max = 1,
		step = 0.1,
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}

	
	options.args["OffsetX"] = 
	{
		type = "range",
		name = "OffsetX",
		desc = "",
		softMin = -80,
		softMax = 240,
		step = 1,
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["OffsetY"] = 
	{
		type = "range",
		name = "OffsetY",
		desc = "",
		softMin = -80,
		softMax = 80,
		step = 1,
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["DisplayClassIconBorder"] = 
	{
		type = "toggle",
		name = "Display border",
		desc = "",
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["BorderFollowNameplateColor"] = 
	{
		type = "toggle",
		name = "Dynamic border color",
		desc = "Set border color to the color of the nameplate",
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["ShowQuestionMarks"] = 
	{
		type = "toggle",
		name = "Show question marks",
		desc = "Show question marks for targets with unknown status",
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
	
	options.args["EnemiesOnly"] = 
	{
		type = "toggle",
		name = "Enemies only",
		desc = "Show icons for enemies only",
		order = iterator(),
		get = dbConnection.Get,
		set = dbConnection.Set
	}
end
