local Logger = LibStub:NewLibrary("LibLogger-1.0", 2);
if Logger ~= nil then 
	Logger.Initialization = true;
	
	function Logger:UpdateRequired()
		return self.Initialization;
	end
end