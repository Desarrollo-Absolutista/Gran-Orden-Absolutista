--!strict
--@author Kriko_YT
--@date 2026/06/08
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");

-------------------------------------
-- Dependencies
-------------------------------------

local packages = ReplicatedStorage.Packages;
local packets = ReplicatedStorage.Packets;

local Signal = require(packages.Signal);
local Trove = require(packages.Trove);

local ToolsPacket = require(packets.Tools.ToolsPacket);

local ToolType = require("./ToolType");

-------------------------------------
-- Variables
-------------------------------------

local Tool = {};
Tool.__index = Tool;

local equipedTool: Tool? = nil;

-------------------------------------
-- Constructors
-------------------------------------

--[[
	Creates a new instance of Tool
	@param name Tool's name
	@param imageId Tool's image's id
	@param mass number The mass/weight of the tool (absolute value used)
	@param model Tool's model
	@param toolType Tool type
    @param actionCooldown Cooldown for clicking action
	@param equipMethod Optional function that runs when tool is equipped
	@param unequipMethod Optional function that runs when tool is unequipped
	@return A new Tool instance
]]
function Tool.new(name: string, imageId: number, mass: number, model: Model | BasePart, toolType: ToolType.ToolTypeValues, actionCooldown: number, equipMethod: (() -> ())?, unequipMethod: (() -> ())?): Tool
	assert(RunService:IsClient(), "This class can only be instantianted from client-side!");

	local self = setmetatable({}, Tool) :: Tool;

	self._trove = Trove.new();

	self._name = name;
	self._imageId = imageId;

	self._mass = math.abs(mass);

	self._type = toolType;

	self._equipMethod = equipMethod;
	self._unequipMethod = unequipMethod;

	self._isEquiped = false;

	self._actionCooldown = actionCooldown;
	self._canDoCooldownAction = true;

	self.Equiped = self._trove:Add(Signal.new());
	self.Unequiped = self._trove:Add(Signal.new());

	self._model = model;

	return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
	Equips the tool
]]
function Tool.Equip(self: Tool): ()
	if equipedTool then
		equipedTool:Unequip()
	end
	equipedTool = self;

	ToolsPacket.packets.Equip.send
	{
		toolName = self._name,
		toolType = self._type
	}

	self.Equiped:Fire();
	self._isEquiped = true;

	if self._equipMethod then
		self._equipMethod();
	end
end

--[[
	Unequips the tool
]]
function Tool.Unequip(self: Tool): ()
	self.Unequiped:Fire();
	
	ToolsPacket.packets.Unequip.send();
	self._isEquiped = false;

	if self._unequipMethod then
		self._unequipMethod();
	end
end

--[[
	Checks if the tool is equipped
	@return True if the tool is equipped, false otherwise
]]
function Tool.IsEquiped(self: Tool): boolean
	return self._isEquiped;
end

--[[
	Gets the tool's name
	@return The tool's name
]]
function Tool.GetName(self: Tool): string
	return self._name;
end

--[[
	Gets the tool's image's id
	@return The tool's image's id
]]
function Tool.GetImageId(self: Tool): number
	return self._imageId;
end

--[[
	Gets the tool's mass
	@return The tool's mass
]]
function Tool.GetMass(self: Tool): number
	return self._mass;
end

--[[
	Gets the tool type
	@return The tool type
]]
function Tool.GetType(self: Tool): ToolType.ToolTypeValues
	return self._type;
end

--[[
	Gets the tool equiped
	@return The tool equiped. Nil if the player has no tools equiped
]]
function Tool.GetToolEquiped(): Tool?
	return equipedTool;
end

-------------------------------------
-- Types
-------------------------------------

export type Tool = typeof(setmetatable(
	{} :: {
		_trove: Trove.Trove,

		_name: string,
		_imageId: number,

		_mass: number,

		_type: ToolType.ToolTypeValues,

		_equipMethod: (() -> ())?,
		_unequipMethod: (() -> ())?,

		_isEquiped: boolean,

		_actionCooldown: number,
		_canDoCooldownAction: boolean,

		Equiped: Signal.Signal,
		Unequiped: Signal.Signal,

		_model: Model | BasePart,
	},
	Tool
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Tool) :: typeof(Tool);