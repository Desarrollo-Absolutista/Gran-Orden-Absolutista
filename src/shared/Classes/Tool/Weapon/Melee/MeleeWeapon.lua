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
local ToolType = require("../../ToolType");

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
    @param name Tool's name
	@param imageId Tool's image's id
	@param mass number The mass/weight of the tool (absolute value used)
	@param model Tool's model
	@param toolType Tool type
	@param equipMethod Optional function that runs when tool is equipped
	@param unequipMethod Optional function that runs when tool is unequipped
    @param damage Damage that a player will receive after being attacked by this weapon
    @return A new instance of MeleeWeapon
]]
function MeleeWeapon.new(
    name: string, imageId: number, mass: number, model: Model | BasePart, toolType: ToolType.ToolTypeValues,
	equipMethod: (() -> ())?, unequipMethod: (() -> ())?,
    damage: number
): MeleeWeapon
    local self = Weapon.new(name, imageId, mass, model, toolType, equipMethod, unequipMethod, damage) :: MeleeWeapon
    setmetatable(self, MeleeWeapon);

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type MeleeWeapon = Weapon.Weapon & typeof(setmetatable(
    {} :: {},
    MeleeWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(MeleeWeapon) :: typeof(MeleeWeapon);