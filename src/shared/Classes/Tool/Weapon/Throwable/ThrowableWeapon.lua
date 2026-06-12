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

local ThrowableWeapon = {};
ThrowableWeapon.__index = ThrowableWeapon;
setmetatable(ThrowableWeapon, {__index = Weapon});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ThrowableWeapon
    @return A new instance of ThrowableWeapon
]]
function ThrowableWeapon.new(): ThrowableWeapon
    local self = setmetatable({}, ThrowableWeapon) :: ThrowableWeapon;
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type ThrowableWeapon = typeof(setmetatable(
    {} :: {},
    ThrowableWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ThrowableWeapon) :: typeof(ThrowableWeapon);