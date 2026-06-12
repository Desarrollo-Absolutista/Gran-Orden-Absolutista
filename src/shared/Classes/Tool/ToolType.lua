--!strict
--@author Kriko_YT
--@date 2026/06/09
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local ToolType: ToolType = {
    Weapons = 0,
    Ammunition = 1,
    Consumables = 2,
    Tools = 3,
};

setmetatable(ToolType, {
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

export type ToolTypeValues = number;

export type ToolType = {
    Weapons: ToolTypeValues,
    Ammunition: ToolTypeValues,
    Consumables: ToolTypeValues,
    Tools: ToolTypeValues
};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolType);