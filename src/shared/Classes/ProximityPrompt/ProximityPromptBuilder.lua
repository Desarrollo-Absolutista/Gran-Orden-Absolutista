--!strict

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

-------------------------------------
-- Dependencies
-------------------------------------

local ProximityPrompt = require("./ProximityPrompt");
local ProximityPromptTypes = require("./ProximityPromptTypes");

-------------------------------------
-- Variables
-------------------------------------

local ProximityPromptBuilder = {};
ProximityPromptBuilder.__index = ProximityPromptBuilder;

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ProximityPromptBuilder
    @return A new instance of ProximityPromptBuilder
]]
function ProximityPromptBuilder.new(): ProximityPromptBuilder
	local self = setmetatable({}, ProximityPromptBuilder) :: ProximityPromptBuilder;

	self._instance = nil;
	self._position = Vector3.zero;
	self._maxDistance = 150;

	self._onFocusMethod = nil;
	self._onUnfocusMethod = nil;
	self._keysData = {};

	return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Sets the instance of the ProximityPrompt
    @param instance The new instance of the ProximityPrompt
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.SetInstance(self: ProximityPromptBuilder, instance: Instance?): ProximityPromptBuilder
	self._instance = instance;
	return self;
end

--[[
    Sets the position of the ProximityPrompt
    @param position The new position of the ProximityPrompt
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.SetPosition(self: ProximityPromptBuilder, position: Vector3): ProximityPromptBuilder
	self._position = position;
	return self;
end

--[[
    Sets the max distance of the ProximityPrompt
    @param maxDistance The new max distance of the ProximityPrompt
    @return The ProximityPromptBuilder
    @error The max distance must be greater than 0
]]
function ProximityPromptBuilder.SetMaxDistance(self: ProximityPromptBuilder, maxDistance: number): ProximityPromptBuilder
	assert(maxDistance > 0, "Max distance must be greater than 0");

	self._maxDistance = maxDistance;
	return self;
end

--[[
    Sets the on focus method of the ProximityPrompt
    @param onFocusMethod The new on focus method of the ProximityPrompt
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.SetOnFocusMethod(self: ProximityPromptBuilder, onFocusMethod: ProximityPromptTypes.EventMethod): ProximityPromptBuilder
	self._onFocusMethod = onFocusMethod;
	return self;
end

--[[
    Sets the on unfocus method of the ProximityPrompt
    @param onUnfocusMethod The new on unfocus method of the ProximityPrompt
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.SetOnUnfocusMethod(self: ProximityPromptBuilder, onUnfocusMethod: ProximityPromptTypes.EventMethod): ProximityPromptBuilder
	self._onUnfocusMethod = onUnfocusMethod;
	return self;
end

--[[
    Sets the keys data of the ProximityPrompt
    @param keysData The new keys data of the ProximityPrompt
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.SetKeysData(self: ProximityPromptBuilder, keysData: { ProximityPromptTypes.KeybindData }): ProximityPromptBuilder
	self._keysData = keysData;
	return self;
end

--[[
    Adds a key data to the ProximityPrompt
    @param keyData The key data to add
    @return The ProximityPromptBuilder
]]
function ProximityPromptBuilder.AddKeyData(self: ProximityPromptBuilder, keyData: ProximityPromptTypes.KeybindData): ProximityPromptBuilder
	table.insert(self._keysData, keyData);
	return self;
end

--[[
    Builds the ProximityPrompt
    @return The ProximityPrompt
]]
function ProximityPromptBuilder.Build(self: ProximityPromptBuilder): ProximityPrompt.ProximityPrompt
	return ProximityPrompt.new(
		self._instance,
		self._position,
		self._maxDistance,
		self._onFocusMethod,
		self._onUnfocusMethod,
		self._keysData
	);
end

-------------------------------------
-- Types
-------------------------------------

export type ProximityPromptBuilder = typeof(setmetatable(
	{} :: {
		_instance: Instance?,
		_position: Vector3,
		_maxDistance: number,

		_onFocusMethod: ProximityPromptTypes.EventMethod?,
		_onUnfocusMethod: ProximityPromptTypes.EventMethod?,
		_keysData: { ProximityPromptTypes.KeybindData },
	},
	ProximityPromptBuilder
))

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ProximityPromptBuilder) :: typeof(ProximityPromptBuilder);