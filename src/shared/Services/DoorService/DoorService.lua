--!strict
--@author Kriko_YT
--@date 2026/07/10
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local SLIDING_DOOR_TAG = "SlidingDoor";

-------------------------------------
-- Roblox Services
-------------------------------------

local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local classes = ReplicatedStorage.Classes;

local SlidingDoor = require(classes.Door.SlidingDoor);
local DoorType = require(classes.Door.DoorType);

local DoorServiceTypes = require("./DoorServiceTypes");

-------------------------------------
-- Variables
-------------------------------------

local DoorService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function DoorService.init(self: DoorService): ()
    if isServiceInitialized then
        warn("DoorService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    self:_ConnectDoors();
end

--[[
    Connects all the doors in game
]]
function DoorService._ConnectDoors(self: DoorService): ()
    for _, door in ipairs(CollectionService:GetTagged(SLIDING_DOOR_TAG)) do
        self:_ConnectSlidingDoor(door);
    end
end

--[[
    Connects the given door
    @param door Door to connect
]]
function DoorService._ConnectSlidingDoor(self: DoorService, door: DoorServiceTypes.Door): ()
    SlidingDoor.new(door.Left, DoorType.Left);
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function DoorService.IsServiceInitialized(self: DoorService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type DoorService = typeof(DoorService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(DoorService) :: DoorService;