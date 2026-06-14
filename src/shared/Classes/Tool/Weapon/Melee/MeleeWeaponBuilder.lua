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

local MeleeWeapon = require("./MeleeWeapon");
local WeaponBuilder = require("../WeaponBuilder");

-------------------------------------
-- Variables
-------------------------------------

local MeleeWeaponBuilder = {};
MeleeWeaponBuilder.__index = MeleeWeaponBuilder;
setmetatable(MeleeWeaponBuilder, {__index = WeaponBuilder});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of MeleeWeaponBuilder
    @return A new instance of MeleeWeaponBuilder
]]
function MeleeWeaponBuilder.new(): MeleeWeaponBuilder
    local self = WeaponBuilder.new() :: MeleeWeaponBuilder;
    setmetatable(self, MeleeWeaponBuilder);
    
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
function MeleeWeaponBuilder.Build(self: MeleeWeaponBuilder): MeleeWeapon.MeleeWeapon
    assert(self._model ~= nil, "Cannot create a weapon with no model!");
    assert(self._type ~= nil, "Cannot create a weapon without its type!");

    return MeleeWeapon.new(self._name, self._imageId, self._mass, self._model, self._type, self._equipMethod, self._unequipMethod, self._damage);
end

-------------------------------------
-- Types
-------------------------------------

export type MeleeWeaponBuilder = WeaponBuilder.WeaponBuilder & typeof(setmetatable(
    {} :: {},
    MeleeWeaponBuilder
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(MeleeWeaponBuilder) :: typeof(MeleeWeaponBuilder);