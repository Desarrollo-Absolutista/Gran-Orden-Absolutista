--!strict
--@author Kriko_YT
--@date 2026/06/11
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local HotbarScrollDirection: HotbarScrollDirection = {
    Down = -1,
    Up = 1,
};

setmetatable(HotbarScrollDirection, {
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

export type HotbarScrollDirectionValues = number;

export type HotbarScrollDirection = {
    Up: HotbarScrollDirectionValues,
    Down: HotbarScrollDirectionValues
};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(HotbarScrollDirection);