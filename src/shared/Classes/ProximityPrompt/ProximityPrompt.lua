--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local TextService = game:GetService("TextService");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local packages = ReplicatedStorage.Packages;
local classes = ReplicatedStorage.Classes;
local configurtions = ReplicatedStorage.Configurations;

local ProximityPromptTypes = require("./ProximityPromptTypes");

local Trove = require(packages.Trove);

local ObjectPooling = require(classes.ObjectPooling.ObjectPooling);

local Configuration = require(configurtions.ProximityPromptService.Config_ProximityPromptService);

-------------------------------------
-- Variables
-------------------------------------

local ProximityPrompt = {};
ProximityPrompt.__index = ProximityPrompt;
ProximityPrompt.__tostring = function()
	return "Proximity prompt instance";
end

local assets = ReplicatedStorage.Assets.ProximityPromptService;
local keyPromptTemplate: ProximityPromptTypes.KeyPromptUi = assets.KeyPrompt;

local player = Players.LocalPlayer :: Player;
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui;
local proximityPromptUi = playerGui:WaitForChild("ProximityPromptUI") :: ScreenGui;
local proximityPromptFrame = proximityPromptUi:WaitForChild("ProximityPromptFrame") :: Frame;

local textBoundsParams: GetTextBoundsParams = Instance.new("GetTextBoundsParams");

local onPoolMethod = function(newKeyPrompt: ProximityPromptTypes.KeyPromptUi)
	textBoundsParams.Text = newKeyPrompt.TextLabel.Text;
	textBoundsParams.Size = newKeyPrompt.TextLabel.TextSize;
	textBoundsParams.Font = newKeyPrompt.TextLabel.FontFace;
	textBoundsParams.Width = math.huge;
	
	local textBounds = TextService:GetTextBoundsAsync(textBoundsParams);

	newKeyPrompt.TextLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y);
	newKeyPrompt.Size = UDim2.fromOffset(textBounds.X + textBoundsParams.Size + 10, textBounds.Y);

	newKeyPrompt.Parent = proximityPromptFrame;
end

local onUnpoolMethod = function(newKeyPrompt: ProximityPromptTypes.KeyPromptUi, parent: Instance)
	newKeyPrompt.Parent = parent;
end

local objectPooling = ObjectPooling.new(keyPromptTemplate, #Configuration.keys, "ProximityPrompt", onPoolMethod, onUnpoolMethod);

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ProximityPrompt
    @param instance Instance reference to a specific object
    @param position The position of the ProximityPrompt
    @param maxDistance The maximum distance the player can be from the ProximityPrompt to trigger it
    @param onFocusMethod The method to call when the ProximityPrompt is focused
    @param onUnfocusMethod The method to call when the ProximityPrompt is unfocused
    @param keysData The keybind data for the ProximityPrompt
    @return A new instance of ProximityPrompt
]]
function ProximityPrompt.new(instance: Instance?, position: Vector3, maxDistance: number, onFocusMethod: ProximityPromptTypes.EventMethod?, onUnfocusMethod: ProximityPromptTypes.EventMethod?, keysData: {ProximityPromptTypes.KeybindData}): ProximityPrompt
	local self = setmetatable({}, ProximityPrompt) :: ProximityPrompt;

	self._trove = Trove.new();

	self._isBeingShown = false;

	self._instance = instance;
	self._position = position;
	self._maxDistance = maxDistance;

	self._onFocusMethod = onFocusMethod;
	self._onUnfocusMethod = onUnfocusMethod;
	self._keys = keysData;

	self._keyEvents = nil;

	return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
	Refreshes the proximity prompt's data
]]
function ProximityPrompt._Refresh(self: ProximityPrompt): ()
	if not self._isBeingShown then
		return;
	end

	self:Hide();
	self:Show();
end

--[[
    Shows the ProximityPrompt
]]
function ProximityPrompt.Show(self: ProximityPrompt): ()
	if self._isBeingShown then
		warn("The proximity prompt is already being shown!");
		return;
	end

	self._isBeingShown = true;

	if self._onFocusMethod then
		(self._onFocusMethod :: ProximityPromptTypes.EventMethod)(self._instance);
	end
	self:_ConnectEvents();

	self:_ShowUi();
end

--[[
    Hides the ProximityPrompt
]]
function ProximityPrompt.Hide(self: ProximityPrompt): ()
	if not self._isBeingShown then
		warn("The proximity prompt is already hidden!");
		return;
	end

	self._isBeingShown = false;

	if self._onUnfocusMethod then
		(self._onUnfocusMethod :: ProximityPromptTypes.EventMethod)(self._instance);
	end
	self:_DisonnectEvents();

	self:_HideUi();
end

--[[
    Connects the events of the ProximityPrompt
]]
function ProximityPrompt._ConnectEvents(self: ProximityPrompt): ()
	self._keyEvents = self._trove:Add(UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return;
		end

		for _, keyData in self._keys do
			if table.find(keyData.keys, input.KeyCode) == nil then
				continue;
			end

			if keyData.method then
				keyData.method(self._instance, self);
			end
		end
	end));
end

--[[
    Disonnects the events of the ProximityPrompt
]]
function ProximityPrompt._DisonnectEvents(self: ProximityPrompt): ()
	if self._keyEvents == nil then
		return;
	end

	self._keyEvents:Disconnect();
	self._keyEvents = nil;
end

--[[
    Shows the UI of the ProximityPrompt
]]
function ProximityPrompt._ShowUi(self: ProximityPrompt)
    for _, keyData in self._keys do
        local newKeyPrompt = objectPooling:Pool();

		newKeyPrompt.Key.Text = keyData.keys[1].Name;
		newKeyPrompt.TextLabel.Text = keyData.methodMessage or "";
    end
end

--[[
    Hides the UI of the ProximityPrompt
]]
function ProximityPrompt._HideUi(self: ProximityPrompt)
    objectPooling:UnpoolAll();
end

--[[
    Checks if the proximity prompt is being shown
    @return True if the proximity prompt is being shown, false otherwise
]]
function ProximityPrompt.IsBeingShown(self: ProximityPrompt): boolean
	return self._isBeingShown;
end

--[[
    Gets the position of the ProximityPrompt
    @return The position of the ProximityPrompt
]]
function ProximityPrompt.GetPosition(self: ProximityPrompt): Vector3
	return self._position;
end

--[[
    Sets the position of the ProximityPrompt
    @param position The new position of the ProximityPrompt
]]
function ProximityPrompt.SetPosition(self: ProximityPrompt, position: Vector3): ()
	self._position = position;
end

--[[
    Gets the max distance of the ProximityPrompt
    @return The max distance of the ProximityPrompt
]]
function ProximityPrompt.GetMaxDistance(self: ProximityPrompt): number
	return self._maxDistance;
end

--[[
    Sets the max distance of the ProximityPrompt
    @param maxDistance The new max distance of the ProximityPrompt
]]
function ProximityPrompt.SetMaxDistance(self: ProximityPrompt, maxDistance: number): ()
	self._maxDistance = maxDistance;
end

--[[
    Gets the keys's data
    @return The keys's data
]]
function ProximityPrompt.GetKeysData(self: ProximityPrompt): {ProximityPromptTypes.KeybindData}
	return self._keys;
end

--[[
    Sets the keys's data
    @param keysData The keys's data
]]
function ProximityPrompt.SetKeysData(self: ProximityPrompt, keysData: {ProximityPromptTypes.KeybindData}): ()
	self._keys = keysData;

	if (self._isBeingShown) then
		self:_Refresh();
	end
end

--[[
	Gets the give keys's data
	@param keys Key to obtain the data from
	@return The given keys's data
]]
function ProximityPrompt.GetKeyData(self: ProximityPrompt, keys: {Enum.KeyCode}): ProximityPromptTypes.KeybindData?
	local data = nil;
	local value = nil;
	local index = nil;

	repeat
		index, value = next(self._keys, index);

		if index == nil then
			break;
		end

		if value.keys == keys then
			data = value;
		end
	until data ~= nil or index == nil;

	return data;
end

--[[
	Sets a new keybind data for the given keys
	@param keysToChange The keys to change its data
	@param newKeysData The new data to set to the given set of keys
]]
function ProximityPrompt.SetKeyData(self: ProximityPrompt, keysToChange: {Enum.KeyCode}, newKeysData: ProximityPromptTypes.KeybindData)
	local changedData = false;

	local value = nil;
	local index: number? = nil;

	repeat
		index, value = next(self._keys, index);

		if index == nil then
			break;
		end

		if value.keys == keysToChange then
			changedData = true;

			self._keys[index :: number] = newKeysData;
			self:_Refresh();
		end
	until changedData or index == nil;

	if not changedData then
		table.insert(self._keys, newKeysData);
		self:_Refresh();
	end
end

--[[
	Sets a new keybind message for the given keys
	@param keysToChange The keys to change its message
	@param message The new message to set to the given set of keys
]]
function ProximityPrompt.SetKeysMessage(self: ProximityPrompt, keysToChange: {Enum.KeyCode}, message: string)
	local changedData = false;

	local value = nil;
	local index: number? = nil;

	repeat
		index, value = next(self._keys, index);

		if index == nil then
			break;
		end

		if value ~= nil and value.keys == keysToChange then
			changedData = true;
			
			value.methodMessage = message;
			self:_Refresh();
		end
	until changedData or index == nil;

	if not changedData then
	end
end

--[[
	Sets a new keybind method for the given keys
	@param keysToChange The keys to change its message
	@param method The new method to set to the given set of keys
]]
function ProximityPrompt.SetKeysMethod(self: ProximityPrompt, keysToChange: {Enum.KeyCode}, method: () -> ())
	local changedData = false;

	local value = nil;
	local index: number? = nil;

	print(self._keys)

	repeat
		index, value = next(self._keys, index);

		if index == nil then
			break;
		end

		if value.keys == keysToChange then
			changedData = true;
			
			value.method = method;
			self:_Refresh();
		end
	until changedData or index == nil;
end

--[[
	Sets all the keys data
	@param keysData All the keys information
]]
function ProximityPrompt.SetAllKeysMethods(self: ProximityPrompt, keysData: {ProximityPromptTypes.KeybindData}): ()
	self._keys = keysData;
	self:_Refresh();
end

--[[
    Gets the ProximityPrompt's refered instance
    @return The ProximityPrompt's refered instance
]]
function ProximityPrompt.GetInstance(self: ProximityPrompt): Instance?
	return self._instance;
end

--[[
	Sets the instance related to the given proximity prompt
	@param instance Instance related to the prompt
]]
function ProximityPrompt.SetInstance(self: ProximityPrompt, instance: Instance): ()
	self._instance = instance;
end

--[[
    Destroies the ProximityPrompt
]]
function ProximityPrompt.Destroy(self: ProximityPrompt): ()
	self._trove:Destroy();
	self._isBeingShown = false;
end

-------------------------------------
-- Types
-------------------------------------

export type ProximityPrompt = typeof(setmetatable(
	{} :: {
		_trove: Trove.Trove,

		_isBeingShown: boolean,

		_instance: Instance?,
		_position: Vector3,
		_maxDistance: number,

		_onFocusMethod: ProximityPromptTypes.EventMethod?,
		_onUnfocusMethod: ProximityPromptTypes.EventMethod?,
		_keys: {ProximityPromptTypes.KeybindData},

		_keyEvents: RBXScriptConnection?,

		_uis: {Frame},
	},
	ProximityPrompt
))

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ProximityPrompt) :: typeof(ProximityPrompt);