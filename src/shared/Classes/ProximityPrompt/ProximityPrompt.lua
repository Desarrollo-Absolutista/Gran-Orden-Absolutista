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
				keyData.method(self._instance);
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
    Returns the position of the ProximityPrompt
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
    Returns the max distance of the ProximityPrompt
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
    Returns the ProximityPrompt's refered instance
    @return The ProximityPrompt's refered instance
]]
function ProximityPrompt.GetInstance(self: ProximityPrompt): Instance?
	return self._instance;
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