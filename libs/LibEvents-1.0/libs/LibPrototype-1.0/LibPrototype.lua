-- LibPrototype provides API for making mixins.
--
-- Example:
--
-- local notifierPrototype = LibStub("LibPrototype-1.0"):CreatePrototype("Notifier");
-- function notifierPrototype:Notify() print("Notifier sends: " .. self:GetNotificationTemplate()); end
-- 
-- local rudeNotifier = notifierPrototype:CreateChild();
-- function rudeNotifier:GetNotificationTemplate() return "press 1 now, fast!" end
-- rudeNotifier:Notify(); -- Notifier sends: press 1 now, fast!
-- 
-- local gentleNotifier = notifierPrototype:CreateChild();
-- function gentleNotifier:GetNotificationTemplate() return "please press 1." end
-- gentleNotifier:Notify(); -- Notifier sends: please press 1.

local version = 1;
local name = "LibPrototype-1.0";
local lib = LibStub:NewLibrary(name, version);
if not lib then return; end

local function IndexParents(table, key)
	local parents = table.__parents;
	for _, parent in pairs(parents) do
		local value = parent[key]
		
		if value ~= nil then
			return value;
		end
	end
end

local function InvokeCtors(table)
	local parents = table.__parents;
	for _, parent in pairs(parents) do
		if parent.ctor ~= nil then
			parent.ctor(table);
		end
	end
end

-- Sets name of the object.
function lib:SetName(object, name)
	if name == nil then error() end
	object.name = name;
	local mt = getmetatable(object) or {};
	mt.__tostring = function(object) return object.name end
	setmetatable(object, mt);
end

-- Returns new object with providen parents.
-- 	@... parents for created object.
function lib:CreateChild(...)
	local parents = {...};

	for _, parent in pairs(parents) do
		if parent == nil then
			error("one of parents was nil");
		end
	end
	
	local child = {};
	child.__parents = parents;
	lib:AddReadInterceptor(child, IndexParents);
	child.CallBase = function(self, methodName, ...) IndexParents(self, methodName)(...) end
	
	child.InterceptRead = function(this, ...) lib:AddReadInterceptor(this, ...) end;
	child.InterceptWrite = function (this, ...) lib:SetWriteInterceptor(this, ...) end;
	
	InvokeCtors(child);
	return child;
end

-- Add interceptor for missing field read. 
-- 	@table - target object
-- 	@handler - handler function. Example: function(table, key) return myBackingTable[key]; end
function lib:AddReadInterceptor(table, handler)
	local mt = getmetatable(table)
	
	if mt ~= nil then
		local newHandler = handler;
		
		if mt.__index ~= nil then
			if type(mt.__index) == "table" then
				oldHandler = function(tbl, key) return mt.__index[key] end
			elseif type(mt.__index) == "function" then
				oldHandler = mt.__index
			else
				error()
			end
			
			newHandler = function(tbl, key) return handler(tbl, key) or oldHandler(tbl, key) end
		end
		
		mt.__index = newHandler;
	else
		setmetatable(table, {__index = handler })
	end
end

-- Sets interceptor for non existing fields assignment.
--	@table - target object.
--	@handler handler function. Example: function(table, key, value) return myBackingTable[key] = value; end
function lib:SetWriteInterceptor(table, handler)
	local mt = getmetatable(table) or {}
	mt.__newindex = handler;
end

-- returns new prototype object.
-- Object will be assigned with following methods:
--		1. CreateChild(...) - Creates child of the prototype
--			@... - additionalParents
--		2. New(...) - another alias for CreateChild.
--		3. SetConstructor(ctor) - Sets constructor for childrens
--			@ctor - function that executes for each created child. Example: function(child) child.isChild = true; end
--		4. CreatePropertyFor(fieldName, propertyName, initValue) - creates getter and setter methods for object field.
--		Example: prototype.updateFrequency = 0.3; prototype:CreatePropertyFor("updateFrequency"); print(prototype:GetUpdateFrequency()); -- 11
--			@fieldName - objects that are used for reading and assigning value to.
--			@propertyName - sets getter and setter functions names to PROPERTYNAMEGet and PROPERTYNAMESet.
--			@initValue - value to be set to target field.
-- @name - prototype name.
-- skipMixin - if set, will not set API methods (like CreateChild, CreatePropertyFor, etc)
function lib:CreatePrototype(name, skipMixin)
	local prototype = {};
	
	if name ~= nil then
		lib:SetName(prototype, name);
	end
	
	if not skipMixin then
		prototype.CreateChild = function(this, ...) return lib:CreateChild(..., this) end;
		prototype.New = prototype.CreateChild;
		prototype.SetConstructor = function (this, ctor) this.ctor = ctor end;
		prototype.CreatePropertyFor = function(this, ...) return self:CreatePropertyFor(this, ...) end;
	end
	
	return prototype;
end

-- Creates getter and setter methods for object field.
-- Example: prototype.updateFrequency = 0.3; prototype:CreatePropertyFor("updateFrequency"); print(prototype:GetUpdateFrequency()); -- 11
--	@fieldName - objects that are used for reading and assigning value to.
--	@propertyName - sets getter and setter functions names to PROPERTYNAMEGet and PROPERTYNAMESet.
--	@initValue - value to be set to target field.
function lib:CreatePropertyFor(owner, fieldName, propertyName, initValue)
	assert(fieldName)
	propertyName = propertyName or fieldName:gsub("^%l", string.upper);
	local getterName = "Get" .. propertyName;
	local setterName = "Set" .. propertyName;
	
	local getterFunc = function(self) return self[fieldName]; end;
	local setterFunc = function(self, value) self[fieldName] = value; end;
	
	owner[getterName] = getterFunc;
	owner[setterName] = setterFunc;
	
	if initValue ~= nil then
		setterFunc(owner, initValue);
	elseif getterFunc(owner) == nil then
		setterFunc(owner,{});
	end
	
	return propertyName, getterName, setterName;
end