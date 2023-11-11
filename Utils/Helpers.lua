local AceAddon = LibStub("AceAddon-3.0");
local addon = AceAddon:GetAddon("PlatesClasses");
local LibLogger = LibStub("LibLogger-1.0");
local NAME_PLATE_LIB = LibStub("LibNameplate-1.0");

local Utils = addon.Utils;
local Logger = LibLogger:New(addon);

function Utils:SetVisible(frame, isVisible, useAlphaValue)
	if frame == nil then 
		Logger(1, "nil frame was passed to 'SetVisible'. It could be a bug.");
		return nil
	end
	
	if isVisible then
		if useAlphaValue then
			frame:SetAlpha(useAlphaValue);
		else
			frame:Show();
		end
	else
		if useAlphaValue then
			frame:SetAlpha(0);
		else
			frame:Hide();
		end
	end
end

function Utils:IsHostile(nameplate, unitId)
	if unitId ~= nil then
		return UnitReaction("player", unitId) < 4;
	else
		local reaction, unitType = NAME_PLATE_LIB:GetReaction(nameplate);
		return reaction == "HOSTILE";
	end
end
