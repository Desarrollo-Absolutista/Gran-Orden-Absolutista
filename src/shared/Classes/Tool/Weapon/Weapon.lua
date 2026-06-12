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

local Tool = require("../Tool");

-------------------------------------
-- Variables
-------------------------------------

local Weapon = {};
Weapon.__index = Weapon;
setmetatable(Weapon, {__index = Tool});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of Weapon
    @param damage Damage that a player will receive after being attacked by this weapon
    @return A new instance of Weapon
]]
function Weapon.new(damage: number): Weapon
    local self = setmetatable({}, Weapon) :: Weapon;

    self._damage = damage;

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Gets the weapon's damage
    @return The weapon's damage
]]
function Weapon.GetDamage(self: Weapon): number
    return self._damage;
end

-------------------------------------
-- Types
-------------------------------------

export type Weapon = typeof(setmetatable(
    {} :: {
        _damage: number
    },
    Weapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Weapon) :: typeof(Weapon);