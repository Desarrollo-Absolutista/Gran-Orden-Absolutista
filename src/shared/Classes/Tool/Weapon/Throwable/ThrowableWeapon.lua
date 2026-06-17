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

local ThrowableWeapon = {};
ThrowableWeapon.__index = ThrowableWeapon;
setmetatable(ThrowableWeapon, {__index = Weapon});

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ThrowableWeapon
    @param name Tool's name
	@param imageId Tool's image's id
	@param mass number The mass/weight of the tool (absolute value used)
	@param model Tool's model
	@param toolType Tool type
    @param actionCooldown Cooldown for clicking action
	@param equipMethod Optional function that runs when tool is equipped
	@param unequipMethod Optional function that runs when tool is unequipped
    @param damage Damage that a player will receive after being attacked by this weapon
    @return A new instance of ThrowableWeapon
]]
function ThrowableWeapon.new(name: string, imageId: number, mass: number, model: Model | BasePart, toolType: ToolType.ToolTypeValues, actionCooldown: number, equipMethod: (() -> ())?, unequipMethod: (() -> ())?, damage: number): ThrowableWeapon
    local self = Weapon.new(name, imageId, mass, model, toolType, actionCooldown, equipMethod, unequipMethod, damage) :: ThrowableWeapon;
    setmetatable(self, ThrowableWeapon);

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type ThrowableWeapon = Weapon.Weapon & typeof(setmetatable(
    {} :: {},
    ThrowableWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ThrowableWeapon) :: typeof(ThrowableWeapon);