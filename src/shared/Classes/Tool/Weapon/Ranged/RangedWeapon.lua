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

local RangedWeapon = {};
RangedWeapon.__index = RangedWeapon;
setmetatable(RangedWeapon, {__index = Weapon});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of RangedWeapon
    @param name Tool's name
	@param imageId Tool's image's id
	@param mass number The mass/weight of the tool (absolute value used)
	@param model Tool's model
	@param toolType Tool type
    @param actionCooldown Cooldown for clicking action
	@param equipMethod Optional function that runs when tool is equipped
	@param unequipMethod Optional function that runs when tool is unequipped
    @param damage Damage that a player will receive after being attacked by this weapon
    @return A new instance of RangedWeapon
]]
function RangedWeapon.new(name: string, imageId: number, mass: number, model: Model | BasePart, toolType: ToolType.ToolTypeValues, actionCooldown: number, equipMethod: (() -> ())?, unequipMethod: (() -> ())?, damage: number): RangedWeapon
    local self = Weapon.new(name, imageId, mass, model, toolType, actionCooldown, equipMethod, unequipMethod, damage) :: RangedWeapon;
    setmetatable(self, RangedWeapon)

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type RangedWeapon = Weapon.Weapon & typeof(setmetatable(
    {} :: {},
    RangedWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(RangedWeapon) :: typeof(RangedWeapon);