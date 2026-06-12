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

local MeleeWeapon = {};
MeleeWeapon.__index = MeleeWeapon;
setmetatable(MeleeWeapon, {__index = Weapon});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of MeleeWeapon
    @return A new instance of MeleeWeapon
]]
function MeleeWeapon.new(): MeleeWeapon
    local self = setmetatable({}, MeleeWeapon) :: MeleeWeapon;
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type MeleeWeapon = typeof(setmetatable(
    {} :: {},
    MeleeWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(MeleeWeapon) :: typeof(MeleeWeapon);