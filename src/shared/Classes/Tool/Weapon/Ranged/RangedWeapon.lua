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
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local services = ReplicatedStorage.Services;

local ShiftLockService = require(services.ShiftLockService.ShiftLockService);

local Weapon = require("../Weapon");
local ToolType = require("../../ToolType");

-------------------------------------
-- Variables
-------------------------------------

local RangedWeapon = {};
RangedWeapon.__index = RangedWeapon;
setmetatable(RangedWeapon, {__index = Weapon});

local player = Players.LocalPlayer :: Player;
local mouse: Mouse = player:GetMouse();

local camera = workspace.CurrentCamera;

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
    setmetatable(self, RangedWeapon);

    self._isReloading = false;

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
	Equips the tool
]]
function RangedWeapon.Equip(self: RangedWeapon)
    self:_EquipGeneralMethod();
    ShiftLockService:EnableShiftLock();

    table.insert(self._toolEvents, self._trove:Add(mouse.Button1Down:Connect(function()
        
    end)))

    table.insert(self._toolEvents, self._trove:Add(mouse.Button1Up:Connect(function()
        
    end)))

    table.insert(self._toolEvents, self._trove:Add(mouse.Button2Down:Connect(function()
        
    end)))

    table.insert(self._toolEvents, self._trove:Add(mouse.Button2Up:Connect(function()
        
    end)))
end

--[[
	Unequips the tool
]]
function RangedWeapon.Unequip(self: RangedWeapon)
    self:_UnequipGeneralMethod();
    ShiftLockService:DisableShiftLock();

    for _, event in ipairs(self._toolEvents) do
        event:Disconnect()
    end
    table.clear(self._toolEvents);
end

function RangedWeapon.Shoot(self: RangedWeapon)
    if self._isReloading then
        return;
    end

    local direction = self:_ComputeDirection();
end

function RangedWeapon._ComputeDirection(self: RangedWeapon): vector

end

-------------------------------------
-- Types
-------------------------------------

export type RangedWeapon = Weapon.Weapon & typeof(setmetatable(
    {} :: {
        _isReloading: boolean
    },
    RangedWeapon
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(RangedWeapon) :: typeof(RangedWeapon);