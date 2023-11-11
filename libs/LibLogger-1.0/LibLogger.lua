-- LibLogger manages logging messages.
-- Example:

--	local debugLevel = 3; 																	-- you can increase this value for debugging purposes.
--	local logger = LibStub("LibLogger-1.0"):New("My flashing addon logger", debugLevel);	-- creates logger for your addon with name "My flashing addon logger" and debugLevel = 3;
--	logger:Log(0, "Addon hello message");													-- will print as long as debugLevel is higher than 0.
--	logger:Log(1, "Information for everyone");												-- will print as long as debugLevel is higher than 1.
--	logger:Log(5, "Very sensitive information for debugging");								-- will not be printed unless debugLevel is less than 5.
--	logger:Log(20, "Not important information, might be needed only for deep debugging.")	-- will not be printed unless debugLevel is less than 20.
--	logger:Log(60, "Just debug labels for addon development.")								-- will not be printed unless debugLevel is less than 60.

local lib = LibStub("LibLogger-1.0"); -- originally created in InitBegin.lua
if not lib:UpdateRequired() then return end

local LibPrototype = LibStub("LibPrototype-1.0");
lib.defaultRedirectCountLimit = 2; -- depth for table description

-- Creates logger instance.
--	@namedObjectOrName - String or table. If table passed, this object is considered as logger owner.
--		 Logger reads 'logger', 'maximumLogLevel', 'name' fields of this table and sets 'logger' field.
--	@maximumLogLevel -  sets filter for messages to be pushed. Log entries with higher value then this will not be displayed. namedObjectOrName.maximumLogLevel is used on no value providen.
--	@prescription - sets head for the generated messages.
--	@printMethod -- function that is used for printing messages. Default is used if no value providen (function(message) print(message) end).
--	@redirectCountLimit - recursion depth for expanding passed object for logging fields.
-- Logger instance has following methods:
-- 1. Log(logLevel, ...) - creates log entry
--	@logLevel - the higher, the less important
--	@... - message parts that are going to be combined to build log message. Either strings or tables allowed.
--	Example:
--		local logger = LibStub("LibLogger-1.0"):New("My flashing addon logger");
--		logger:Log(1, "Initialized!");
--	printed: My flashing addon logger: Initialized!
-- 2. Error(errorMessage, ...) - logs error and throws error
--	@errorMessage - message to be passed to 'error()'
--	@... - message parts that are going to be combined to build log message.
-- 3. LogVariable(level, variableName, value) - creates log entry in following format: "[VARIABLENAME] = VALUE"
-- 4. SetMaximumLogLevel(logLevel) -- sets filter for messages to be pushed
--	@logLevel - sets filter for messages to be pushed. Log entries with higher value then this will not be displayed.
-- 5. GetMaximumLogLevel() -- returns maximum logging level.
-- 6. CreateLocalLogger(prescription) -- returns localLogger and debugInfo that is going to be used for each logging entry. 
--	@prescription - sets head for the generated messages.
--	Example: 
--		local logger = LibStub("LibLogger-1.0"):New("My flashing addon logger");
--		local localLogger, dbgInfo = logger:CreateLocalLogger();
--		dbgInfo.CurrentFunction = "AddFlashEffect"; 
--		localLogger:Log(1, "FlashEffect added");
--	printed: My flashing addon logger: FlashEffect added { CurrentFunction:"AddFlashEffect"}
function lib:New(namedObjectOrName, maximumLogLevel, prescription, printMethod, redirectCountLimit)
	if namedObjectOrName == nil then 
		namedObjectOrName = "Unnamed logger" 
	end
	
	local instance = self.LoggerPrototype:CreateChild();
	
	if type(namedObjectOrName) == "table" then
		if namedObjectOrName.logger ~= nil then
			return namedObjectOrName.logger;
		end
	
		if namedObjectOrName.name == nil then 
			error("namedObjectOrName should be name or table with name field");
		end
		
		namedObjectOrName.logger = instance;
		instance.owner = namedObjectOrName;
		
		if maximumLogLevel == nil then
			maximumLogLevel = namedObjectOrName.logLevel;
		end
		
		namedObjectOrName = namedObjectOrName.name
	end

	instance.maximumLogLevel = maximumLogLevel or 1;
	instance.prescription = prescription or "";
	instance.printMethod = printMethod or function(message) print(message) end;
	instance.redirectCountLimit = redirectCountLimit or self.defaultRedirectCountLimit;
	
	LibPrototype:SetName(instance, namedObjectOrName or "")

	local metatable = getmetatable(instance);
	
	if metatable.__call == nil then
		metatable.__call = function(self, ...) self:Log(...) end;
	end
	
	setmetatable(instance, metatable);

	return instance
end

-- Overrides logging level for all loggers created by this library. Used for global testing purposes.
function lib:SetGlobalMaximumLogLevelOverride(logLevel)
	self.globalMaximumLogLevelOverride = logLevel;
	self:Log(logLevel, "Global log level was set to", logLevel);
end

-- Gets logging level override if set.
function lib:GetGlobalMaximumLogLevelOverride(logLevel)
	return self.globalMaximumLogLevelOverride;
end
