--!strict
--@author Kriko_YT
--@date 2026/07/10
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local DoorType: DoorType = {
    Left = -1,
    Right = 1,
};

setmetatable(DoorType, {
    __index = function()
        error("Cannot index nil value!");
    end,
    
    __newindex = function()
        error("Cannot create new indices in an enum!");
    end
});

-------------------------------------
-- Types
-------------------------------------

export type DoorTypeValues = number;
export type DoorType = {[string]: DoorTypeValues};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(DoorType);