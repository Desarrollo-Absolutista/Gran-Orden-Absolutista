--!strict
--@author Kriko_YT
--@date 2026/06/04
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local PROXIMITY_PROMPT_ATTRIBUTE: string = "ProximityPrompt";

local MAXIMUM_RADIUS_PROXIMITY_PROMPT_ATTRIBUTE_NAME: string = "MaxDistance";
local METHOD_NAME_ATTRIBUTE_NAME: string = "Method%i";
local METHOD_MESSAGE_ATTRIBUTE_NAME: string = "Method%iMessage";
local MOVABLE_ATTRIBUTE_NAME: string = "Movable";

local MAXIMUM_METHODS_PER_PROXIMITY_PROMPT: number = 4;

local RAYCAST_PARAMS: RaycastParams = RaycastParams.new();

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local classes = ReplicatedStorage.Classes;
local packages = ReplicatedStorage.Packages;
local configurations = ReplicatedStorage.Configurations;

local ProximityPromptTypes = require(classes.ProximityPrompt.ProximityPromptTypes);
local ProximityPromptBuilder = require(classes.ProximityPrompt.ProximityPromptBuilder);
local ProximityPrompt = require(classes.ProximityPrompt.ProximityPrompt);

local Octree = require(packages.Octree);

local Config = require(configurations.ProximityPromptService.Config_ProximityPromptService);

-------------------------------------
-- Variables
-------------------------------------

local ProximityPromptService = {};
local isServiceInitialized: boolean = false;

local proximityPromptsEvent = setmetatable({}, { __mode = "k" });

local proximityPromptsOctree = Octree.new();

local currentProximityPrompt: ProximityPrompt.ProximityPrompt? = nil;

local localPlayer: Player = Players.LocalPlayer :: Player;
local camera: Camera = workspace.CurrentCamera :: Camera;
local character: Character = localPlayer.Character or localPlayer.CharacterAdded:Wait() :: Character;
local humanoidRootPart: BasePart = character:WaitForChild("HumanoidRootPart") :: BasePart;

local proximityPromptMethodsFolder = script.Parent.Methods;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ProximityPromptService.init(self: ProximityPromptService): ()
	if RunService:IsServer() then
		warn("ProximityPromptService can only be initialized on the client!");
		return;
	end

	if isServiceInitialized then
		warn("ProximityPromptService is already initialized!");
		return;
	end

	isServiceInitialized = true;

	self:_SetUpCamera();
	self:_SetUpCharacter();
	self:_ConnectEventWhenAddingNewProximityPrompt();
	self:_SetUpAllProximityPrompts();
	self:_StartLoop();
end

--[[
    Sets up the camera
]]
function ProximityPromptService._SetUpCamera(self: ProximityPromptService): ()
	if camera then
		return;
	end

	camera = workspace.CurrentCamera :: Camera;
	task.wait(0.1);

	self:_SetUpCamera();
end

--[[
    Sets up the local player's character
]]
---@inline
function ProximityPromptService._SetUpCharacter(self: ProximityPromptService): ()
	localPlayer.CharacterAdded:Connect(function(newCharacter: Model)
		character = newCharacter :: Character;
		humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart;
	end);
end

--[[
    Sets up all the proximity prompts
]]
function ProximityPromptService._SetUpAllProximityPrompts(self: ProximityPromptService): ()
	local proximities = CollectionService:GetTagged(PROXIMITY_PROMPT_ATTRIBUTE) :: { BasePart };

	for _, proximityPart: BasePart in ipairs(proximities) do
		if not proximityPart:IsA("BasePart") then
			continue;
		end

		self:AddProximityPrompt(proximityPart);
	end
end

--[[
    Returns the key data for a proximity prompt
    @param proximityPart The part containing proximity prompt attributes
    @return A table of keybind data for the proximity prompt
]]
function ProximityPromptService._GetKeyDataFromProximityPart(self: ProximityPromptService, proximityPart: BasePart): {ProximityPromptTypes.KeybindData}
	local keyData: {ProximityPromptTypes.KeybindData} = {};

	for i: number = 1, MAXIMUM_METHODS_PER_PROXIMITY_PROMPT do
		local methodName = proximityPart:GetAttribute(string.format(METHOD_NAME_ATTRIBUTE_NAME, i)) or "";

		if methodName == nil then
			break;
		end

		local methodModule = proximityPromptMethodsFolder:FindFirstChild(methodName) :: ModuleScript?;

		if methodModule == nil then
			continue;
		end

		table.insert(keyData, {
			keys = Config.keys[i],
			methodMessage = proximityPart:GetAttribute(string.format(METHOD_MESSAGE_ATTRIBUTE_NAME, i)) :: string or "",
			method = require(methodModule) :: ProximityPromptTypes.EventMethod,
		});
	end

	return keyData;
end

--[[
    Connects the events for new proximity prompts
]]
---@inline
function ProximityPromptService._ConnectEventWhenAddingNewProximityPrompt(self: ProximityPromptService): ()
	CollectionService:GetInstanceAddedSignal(PROXIMITY_PROMPT_ATTRIBUTE):Connect(function(proximityPart: BasePart)
		self:AddProximityPrompt(proximityPart);
	end);
end

--[[
    Adds a proximity prompt to the octree
    @param proximityPart The part to create a proximity prompt from
]]
function ProximityPromptService.AddProximityPrompt(self: ProximityPromptService, proximityPart: BasePart): ()
	local objectValue = proximityPart:FindFirstChildWhichIsA("ObjectValue");
	local affectedInstance: Instance? = nil;

	if objectValue then
		affectedInstance = objectValue.Value;
	end

	local proximityPrompt = ProximityPromptBuilder.new()
		:SetPosition(proximityPart.Position)
		:SetMaxDistance(proximityPart:GetAttribute(MAXIMUM_RADIUS_PROXIMITY_PROMPT_ATTRIBUTE_NAME) :: number or 0)
		:SetInstance(affectedInstance)
		:SetOnFocusMethod(Config.defaultOnFocusMethod)
		:SetOnUnfocusMethod(Config.defaultOnUnfocusMethod)
		:SetKeysData(self:_GetKeyDataFromProximityPart(proximityPart))
		:Build();

	proximityPromptsOctree:CreateNode(proximityPart.Position, proximityPrompt);

	if proximityPart:GetAttribute(MOVABLE_ATTRIBUTE_NAME) == true then
		proximityPromptsEvent[proximityPart] = proximityPart:GetPropertyChangedSignal("Position"):Connect(function()
			proximityPrompt:SetPosition(proximityPart.Position);
			self:_UpdateProximityPrompts();
		end);
	end
end

--[[
    Checks if there is something between the player and the proximity prompt
    @param proximityPrompt The proximity prompt to check against
    @return True if there is an obstruction, false otherwise
]]
---@inline
function ProximityPromptService._IsThereAnythingBetweenPlayerAndProximityPrompt(self: ProximityPromptService, proximityPrompt: ProximityPrompt.ProximityPrompt): boolean
	RAYCAST_PARAMS.FilterType = Enum.RaycastFilterType.Exclude;
	RAYCAST_PARAMS.FilterDescendantsInstances = { character, proximityPrompt:GetInstance() :: Instance };

	local distance = (character:GetPivot().Position - proximityPrompt:GetPosition()).Magnitude;
	local raycastResult = workspace:Raycast(
		character:GetPivot().Position,
		(proximityPrompt:GetPosition() - character:GetPivot().Position).Unit * distance,
		RAYCAST_PARAMS
	);

	return raycastResult ~= nil;
end

--[[
    Picks the nearest proximity prompt
    @return The nearest proximity prompt, or nil if none found
]]
@native
function ProximityPromptService._PickNearestProximityPrompt(self: ProximityPromptService): ProximityPrompt.ProximityPrompt?
	local playerCamera = workspace.CurrentCamera;
	if playerCamera == nil then
		warn("Camera not detected!");
		return nil;
	end

	local candidatePrompts = proximityPromptsOctree:SearchRadius(playerCamera.CFrame.Position, Config.maximumRadiusLimit :: number);

	local proximityPrompt: ProximityPrompt.ProximityPrompt? = nil;
	local minDistance: number = math.huge;

	local maximumDot = math.cos(math.rad(camera.FieldOfView));

	for _, candidatePrompt in ipairs(candidatePrompts) do
		local candidatePromptInstance = candidatePrompt.Object :: ProximityPrompt.ProximityPrompt;
		local isProximityPartBehind = playerCamera.CFrame.LookVector:Dot((candidatePromptInstance:GetPosition() - playerCamera.CFrame.Position).Unit) < maximumDot;

		if isProximityPartBehind then
			continue;
		end

		local distanceToCamera = (candidatePromptInstance:GetPosition() - playerCamera.CFrame.Position).Magnitude;

		if distanceToCamera > candidatePromptInstance:GetMaxDistance() then
			continue;
		end

		if self:_IsThereAnythingBetweenPlayerAndProximityPrompt(candidatePromptInstance) then
			continue;
		end

		if minDistance > distanceToCamera then
			minDistance = distanceToCamera;
			proximityPrompt = candidatePromptInstance;
		end
	end

	return proximityPrompt;
end

--[[
    Updates the proximity prompts
]]
function ProximityPromptService._UpdateProximityPrompts(self: ProximityPromptService): ()
	local proximityPrompt = self:_PickNearestProximityPrompt();

	if proximityPrompt == currentProximityPrompt then
		return;
	end

	if currentProximityPrompt then
		currentProximityPrompt:Hide();
	end

	currentProximityPrompt = proximityPrompt;
	if currentProximityPrompt then
		currentProximityPrompt:Show();
	end
end

--[[
    Starts the proximity prompts loop
]]
function ProximityPromptService._StartLoop(self: ProximityPromptService): ()
	humanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
		self:_UpdateProximityPrompts();
	end);

	camera:GetPropertyChangedSignal("CFrame"):Connect(function()
		self:_UpdateProximityPrompts();
	end);
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ProximityPromptService.IsServiceInitialized(self: ProximityPromptService): boolean
	return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

type Character = Model & {
	HumanoidRootPart: BasePart,
}

export type ProximityPromptService = typeof(ProximityPromptService) & {}

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ProximityPromptService) :: ProximityPromptService;