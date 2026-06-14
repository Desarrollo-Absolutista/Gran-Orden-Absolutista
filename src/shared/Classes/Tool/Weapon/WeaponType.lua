--!strict
--@author Kriko_YT
--@date 2026/06/13
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local WeaponType: WeaponType = {
    Melee = 0,
    Ranged = 1,
    Throwable = 2
};

setmetatable(WeaponType, {
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

export type WeaponTypeValues = number;

export type WeaponType = {
    Melee: WeaponTypeValues,
    Ranged: WeaponTypeValues,
    Throwable: WeaponTypeValues
};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(WeaponType);