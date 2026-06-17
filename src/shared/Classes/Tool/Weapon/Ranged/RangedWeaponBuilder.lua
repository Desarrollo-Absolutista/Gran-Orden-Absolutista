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

local RangedWeapon = require("./RangedWeapon");
local WeaponBuilder = require("../WeaponBuilder");

-------------------------------------
-- Variables
-------------------------------------

local RangedWeaponBuilder = {};
RangedWeaponBuilder.__index = RangedWeaponBuilder;
setmetatable(RangedWeaponBuilder, {__index = WeaponBuilder});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of RangedWeaponBuilder
    @return A new instance of RangedWeaponBuilder
]]
function RangedWeaponBuilder.new(): RangedWeaponBuilder
    local self = WeaponBuilder.new() :: RangedWeaponBuilder;
    setmetatable(self, RangedWeaponBuilder);
    
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Builds the weapon with the given parameters
    @return A new weapon with the set parameters
    @error Cannot create a weapon with no model!
    @error Cannot create a weapon without its type!
]]
function RangedWeaponBuilder.Build(self: RangedWeaponBuilder): RangedWeapon.RangedWeapon
    assert(self._model ~= nil, "Cannot create a weapon with no model!");
    assert(self._type ~= nil, "Cannot create a weapon without its type!");

    return RangedWeapon.new(self._name, self._imageId, self._mass, self._model, self._type, self._actionCooldown, self._equipMethod, self._unequipMethod, self._damage);
end

-------------------------------------
-- Types
-------------------------------------

export type RangedWeaponBuilder = WeaponBuilder.WeaponBuilder & typeof(setmetatable(
    {} :: {},
    RangedWeaponBuilder
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(RangedWeaponBuilder) :: typeof(RangedWeaponBuilder);