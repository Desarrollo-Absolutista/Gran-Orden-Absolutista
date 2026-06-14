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
local ToolAbstractFactory = require("../ToolAbstractFactory");

-------------------------------------
-- Variables
-------------------------------------

local WeaponFactory = {};
WeaponFactory.__index = WeaponFactory;
setmetatable(WeaponFactory, {__index = ToolAbstractFactory});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of WeaponFactory
    @return A new instance of WeaponFactory
]]
function WeaponFactory.new(): WeaponFactory
    return setmetatable({}, WeaponFactory) :: WeaponFactory;
end

--[[
    Creates a new tool according to the given model
    @param toolModel Model reference for the new tool
    @return The new tool created
    @error The tool must be placed somewhere
]]
function WeaponFactory.CreateToolByModel(self: WeaponFactory, model: Model): Weapon.Weapon?
    return nil;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type WeaponFactory = typeof(setmetatable(
    {} :: {},
    WeaponFactory
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(WeaponFactory) :: typeof(WeaponFactory);