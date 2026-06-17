--!strict
--@author Kriko_YT
--@date 2026/06/14
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

local Weapon = require("./Weapon");
local ToolBuilder = require("../ToolBuilder");

-------------------------------------
-- Variables
-------------------------------------

local WeaponBuilder = {};
WeaponBuilder.__index = WeaponBuilder;
setmetatable(WeaponBuilder, {__index = ToolBuilder});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of WeaponBuilder
    @return A new instance of WeaponBuilder
]]
function WeaponBuilder.new(): WeaponBuilder
    local self = ToolBuilder.new() :: WeaponBuilder;
    setmetatable(self, WeaponBuilder);
    
    self._damage = 0;

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Sets the damage to the weapon
    @param unequipMethod Weapon's damage
    @return The current WeaponBuilder
]]
function WeaponBuilder.SetDamage(self: WeaponBuilder, damage: number): WeaponBuilder
    self._damage = damage;
    return self;
end

--[[
    Builds the weapon with the given parameters
    @return A new weapon with the set parameters
    @error Cannot create a weapon with no model!
    @error Cannot create a weapon without its type!
]]
function WeaponBuilder.Build(self: WeaponBuilder): Weapon.Weapon
    assert(self._model ~= nil, "Cannot create a weapon with no model!");
    assert(self._type ~= nil, "Cannot create a weapon without its type!");

    return Weapon.new(self._name, self._imageId, self._mass, self._model, self._type, self._actionCooldown, self._equipMethod, self._unequipMethod, self._damage);
end

-------------------------------------
-- Types
-------------------------------------

export type WeaponBuilder = ToolBuilder.ToolBuilder & typeof(setmetatable(
    {} :: {
        _damage: number,
    },
    WeaponBuilder
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(WeaponBuilder) :: typeof(WeaponBuilder);