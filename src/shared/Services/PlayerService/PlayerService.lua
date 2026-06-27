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

local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local GuiService = game:GetService("GuiService");
local Players = game:GetService("Players")
local VRService = game:GetService("VRService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;

local PlayerPacket = require(packets.Player.PlayerPacket);

local DeviceType = require("./DeviceType");
local PlayerTypes = require("./PlayerTypes");

-------------------------------------
-- Variables
-------------------------------------

local PlayerService = {};
local isServiceInitialized: boolean = false;

local player = Players.LocalPlayer :: Player;

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
	@error This method can only be ran on client-side!
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
	Checks if the local player is in first person view
	@return True if the local player is in first person view, false otherwise
	@error This method can only be ran on client-side!
]]
function PlayerService.IsPlayerInFirstPerson(self: PlayerService): boolean
	assert(RunService:IsClient(), "This method can only be ran on client-side!");

	local character = player.Character :: PlayerTypes.CharacterR15;
	if character == nil then
		return false;
	end

	return character.Head.LocalTransparencyModifier == 1;
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