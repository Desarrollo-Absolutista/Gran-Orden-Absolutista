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

local ThrowableWeapon = require("./ThrowableWeapon");
local WeaponBuilder = require("../WeaponBuilder");

-------------------------------------
-- Variables
-------------------------------------

local ThrowableWeaponBuilder = {};
ThrowableWeaponBuilder.__index = ThrowableWeaponBuilder;
setmetatable(ThrowableWeaponBuilder, {__index = WeaponBuilder});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ThrowableWeaponBuilder
    @return A new instance of ThrowableWeaponBuilder
]]
function ThrowableWeaponBuilder.new(): ThrowableWeaponBuilder
    local self = WeaponBuilder.new() :: ThrowableWeaponBuilder;
    setmetatable(self, ThrowableWeaponBuilder);
    
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
function ThrowableWeaponBuilder.Build(self: ThrowableWeaponBuilder): ThrowableWeapon.ThrowableWeapon
    assert(self._model ~= nil, "Cannot create a weapon with no model!");
    assert(self._type ~= nil, "Cannot create a weapon without its type!");

    return ThrowableWeapon.new(self._name, self._imageId, self._mass, self._model, self._type, self._equipMethod, self._unequipMethod, self._damage);
end

-------------------------------------
-- Types
-------------------------------------

export type ThrowableWeaponBuilder = WeaponBuilder.WeaponBuilder & typeof(setmetatable(
    {} :: {},
    ThrowableWeaponBuilder
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ThrowableWeaponBuilder) :: typeof(ThrowableWeaponBuilder);