--!strict
--@author Kriko_YT
--@date 2026/06/27
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;

local PlayerPacket = require(packets.Player.PlayerPacket);

-------------------------------------
-- Variables
-------------------------------------

local ShiftLockService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ShiftLockService.init(self: ShiftLockService): ()
    if isServiceInitialized then
        warn("ShiftLockService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    self:_ListenWhenActivateRobloxShiftLock();
end

--[[
    Waits for the client to tell when to activate/unactivate roblox's shift lock for client
]]
function ShiftLockService._ListenWhenActivateRobloxShiftLock(self: ShiftLockService): ()
    PlayerPacket.packets.ActivateRobloxShiftLock.listen(function(data: {enable: boolean}, player: Player?)
        if player == nil then
            warn("Player was not found!");
            return;
        end

        player.DevEnableMouseLock = data.enable;
    end)
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ShiftLockService.IsServiceInitialized(self: ShiftLockService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ShiftLockService = typeof(ShiftLockService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ShiftLockService) :: ShiftLockService;