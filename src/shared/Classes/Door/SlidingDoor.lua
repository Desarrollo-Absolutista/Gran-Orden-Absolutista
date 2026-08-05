--!strict
--@author Kriko_YT
--@date 2026/07/10
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

-------------------------------------
-- Dependencies
-------------------------------------

local Door = require("./Door");
local DoorType = require("./DoorType");

-------------------------------------
-- Variables
-------------------------------------

local SlidingDoor = {};
SlidingDoor.__index = SlidingDoor;
setmetatable(SlidingDoor, {__index = Door});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of SlidingDoor
    @return A new instance of SlidingDoor
]]
function SlidingDoor.new(doorModel: BasePart | Model, doorType: DoorType.DoorTypeValues): SlidingDoor
    local self = Door.new(doorModel) :: SlidingDoor;
    setmetatable(self, SlidingDoor);

    self._openedCFrame = self._closedCFrame * CFrame.new(doorType * self._doorXSize * 0.5, 0, 0);
    
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Opens the door
]]
function SlidingDoor.Open(self: SlidingDoor): ()
    if self._status == "Opened" then
        warn("The door is already opened!");
        return;
    end

    
end

-------------------------------------
-- Types
-------------------------------------

export type SlidingDoor = Door.Door & typeof(setmetatable(
    {} :: {
        _openedCFrame: CFrame
    },
    SlidingDoor
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(SlidingDoor) :: typeof(SlidingDoor);