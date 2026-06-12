--!strict
--@author Kriko_YT
--@date 2026/06/12
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

local Weapon = require("../Weapon");

-------------------------------------
-- Variables
-------------------------------------

local RangedWeapon = {};
RangedWeapon.__index = RangedWeapon;
setmetatable(RangedWeapon, {__index = Weapon});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of RangedWeapon
    @return A new instance of RangedWeapon
]]
function RangedWeapon.new(): RangedWeapon
    local self = setmetatable({}, RangedWeapon) :: RangedWeapon;
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type RangedWeapon = typeof(setmetatable(
    {} :: {},
    RangedWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(RangedWeapon) :: typeof(RangedWeapon);