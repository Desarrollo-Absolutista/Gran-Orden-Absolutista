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

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packages = ReplicatedStorage.Packages;

local Trove = require(packages.Trove);

local Tool = require("../Tool");
local ToolType = require("../ToolType");

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
    @param name Tool's name
	@param imageId Tool's image's id
	@param mass number The mass/weight of the tool (absolute value used)
	@param model Tool's model
	@param toolType Tool type
    @param actionCooldown Cooldown for clicking action
	@param equipMethod Optional function that runs when tool is equipped
	@param unequipMethod Optional function that runs when tool is unequipped
    @param damage Damage that a player will receive after being attacked by this weapon
    @return A new instance of Weapon
]]
function Weapon.new(name: string, imageId: number, mass: number, model: Model | BasePart, toolType: ToolType.ToolTypeValues, actionCooldown: number, equipMethod: (() -> ())?, unequipMethod: (() -> ())?, damage: number): Weapon
    local self = Tool.new(name, imageId, mass, model, toolType, actionCooldown, equipMethod, unequipMethod) :: Weapon
    setmetatable(self, Weapon);

    self._trove = Trove.new();

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

export type Weapon = Tool.Tool & typeof(setmetatable(
    {} :: {
        _trove: Trove.Trove,

        _damage: number
    },
    Weapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Weapon) :: typeof(Weapon);