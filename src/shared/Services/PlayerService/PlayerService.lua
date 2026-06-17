--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local SHIFTLOCK_CAMERA_OFFSET: Vector3 = Vector3.xAxis * 2
local RENDER_STEP_NAME: string = "ShiftLock";

-------------------------------------
-- Roblox Services
-------------------------------------

local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local GuiService = game:GetService("GuiService");
local VRService = game:GetService("VRService");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;

local PlayerPacket = require(packets.Player.PlayerPacket);

local DeviceType = require("./DeviceType");

-------------------------------------
-- Variables
-------------------------------------

local PlayerService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function PlayerService.init(self: PlayerService): ()
	if isServiceInitialized then
		warn("PlayerService is already initialized!");
		return;
	end
	
	isServiceInitialized = true;

	self:_SendCLientReadyToServer();
end

--[[
	Sends a signal to the server showing the local client is ready
]]
function PlayerService._SendCLientReadyToServer(self: PlayerService): ()
	PlayerPacket.packets.SetClientReady.send();
end

--[[
    Returns the player device type
    @return Player's device type
]]
function PlayerService.GetPlayerDevice(self: PlayerService): DeviceType.DeviceTypeValues
	assert(RunService:IsClient(), "This method can only be ran on client-side!");
	
	if VRService.VREnabled then
		return DeviceType.VR;
	end
	
	if GuiService:IsTenFootInterface() then
		return DeviceType.Console;
	end
	
	local deviceType = UserInputService:GetDeviceType();
	
	if deviceType == Enum.DeviceType.Phone then
		return DeviceType.Phone;
		
	elseif deviceType == Enum.DeviceType.Tablet then
		return DeviceType.Tablet;
		
	end
	
	return DeviceType.Computer;
end

--[[
	Calculates the looking angle
	@return The looking angle
]]
function PlayerService._GetLookingAngle(self: PlayerService): number
	local camera = workspace.CurrentCamera;
	if camera == nil then
		return 0;
	end

	local lookingTowards = camera.CFrame.LookVector;

	return math.atan2(-lookingTowards.X, -lookingTowards.Z);
end

--[[
	Activates the "forced" shift lock
	@param humanoid: Player's humanoid affected
]]
function PlayerService.EnableShiftLock(self: PlayerService): ()
	assert(RunService:IsClient(), "This method can only be ran on client-side!")

	local player = Players.LocalPlayer :: Player;
	
	RunService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Character.Value, function()
		local character = player.Character;
		if character == nil then
			return;
		end

		local humanoid = character:WaitForChild("Humanoid") :: Humanoid;

		local rootPart : Part = humanoid.RootPart :: Part
		
		humanoid.CameraOffset = SHIFTLOCK_CAMERA_OFFSET
		humanoid.AutoRotate = false
		
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter;

		local cframePosition = CFrame.new(rootPart.Position);
		local cframeRotation = CFrame.fromAxisAngle(Vector3.yAxis, self:_GetLookingAngle());
		
		rootPart.CFrame = cframePosition * cframeRotation;
	end)
end

--[[
	Desactivates the "forced" shift lock
	@param humanoid: Player"s humanoid affected
]]
function PlayerService.DisableShiftLock(self: PlayerService)
    assert(RunService:IsClient(), "This method can only be ran on client-side!");

	local player = Players.LocalPlayer :: Player;
	local character = player.Character or player.CharacterAdded:Wait();
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid;

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	
	humanoid.CameraOffset = Vector3.zero
	humanoid.AutoRotate = true
	
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function PlayerService.IsServiceInitialized(self: PlayerService): boolean
	return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type PlayerService = typeof(PlayerService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(PlayerService) :: PlayerService;