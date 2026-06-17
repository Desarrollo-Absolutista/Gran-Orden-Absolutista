--!strict
--@author Kriko_YT
--@date 2026/06/09
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local classes = ReplicatedStorage.Classes;
local packets = ReplicatedStorage.Packets;

local ToolType = require(classes.Tool.ToolType);

local HotbarPacket = require(packets.Hotbar.HotbarPacket);

-------------------------------------
-- Variables
-------------------------------------

local HotbarService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function HotbarService.init(self: HotbarService): ()
    if isServiceInitialized then
        warn("HotbarService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    Players.PlayerAdded:Connect(function(player: Player)        
        
    end)
end

--[[
    Sets the given tool to the client's hotbar
    @param client Client to contain the hotbar
    @param name Tool's name
    @param toolType Tool's type
]]
function HotbarService.SetToolToHotbar(self: HotbarService, client: Player, name: string, toolType: ToolType.ToolTypeValues): ()
    HotbarPacket.packets.SetToolToHotbar.sendTo(
        {
            toolName = name,
            toolType = toolType;
        }, 
        client
    );
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function HotbarService.IsServiceInitialized(self: HotbarService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type HotbarService = typeof(HotbarService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(HotbarService) :: HotbarService;