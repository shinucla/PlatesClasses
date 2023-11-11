local moduleName = "Players"
local AceAddon = LibStub("AceAddon-3.0");
local LibLogger = LibStub("LibLogger-1.0");
local NAME_PLATE_LIB = LibStub("LibNameplate-1.0");

local addon =  AceAddon:GetAddon("PlatesClasses")
local parent = addon:GetModule("Plate Styler");
local module = parent:NewModule(moduleName);
local log = LibLogger:New(addon);
local Utils = addon.Utils;

local provider = function(nameplate) if module.db.Enabled and NAME_PLATE_LIB:GetType(nameplate) == "PLAYER" then return module.db end end

function module:OnInitialize()
	parent:AddTheme(moduleName, provider, self:BuildBlizzardOptions())
end

function module:OnEnable()
end

function module:OnDisable()
end

function module:BuildBlizzardOptions()
	local iterator = Utils.Iterator:New();
	local dbConnection = Utils.DbConfig:New(function(key) return self.db end, function() if self.db.Enabled then parent:StyleAllNameplates() end end , self);
	return parent:CreateOptionsGroup("Players", dbConnection)
end

function module:GetDbMigrations()
	local migrations = {}
	
	migrations[1] = function(db)
		parent:InitializeDb(db);
	end
	
	return migrations;
end
