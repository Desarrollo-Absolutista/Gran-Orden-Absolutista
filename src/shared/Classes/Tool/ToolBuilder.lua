--!strict
--@author Kriko_YT
--@date 2026/06/10
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

local t = require(packages.t);

local ToolType = require("./ToolType");
local Tool = require("./Tool");

-------------------------------------
-- Variables
-------------------------------------

local ToolBuilder = {};
ToolBuilder.__index = ToolBuilder;

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ToolBuilder
    @return A new instance of ToolBuilder
]]
function ToolBuilder.new(): ToolBuilder
    local self = setmetatable({}, ToolBuilder) :: ToolBuilder;

    self._imageId = 0;
    self._name = "Tool";

    self._mass = 0;

    self._type = nil;

    self._equipMethod = nil;
    self._unequipMethod = nil;

    self._model = nil;

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Sets the name to the tool
    @param name Tool's name
    @return The current ToolBuilder
]]
function ToolBuilder.SetName(self: ToolBuilder, name: string): ToolBuilder
    self._name = name;
    return self;
end

--[[
    Sets the image to the tool
    @param imageId Tool's image
    @return The current ToolBuilder
]]
function ToolBuilder.SetImage(self: ToolBuilder, imageId: number): ToolBuilder
    self._imageId = imageId;
    return self;
end

--[[
    Sets the mass to the tool
    @param mass Tool's mass
    @return The current ToolBuilder
]]
function ToolBuilder.SetMass(self: ToolBuilder, mass: number): ToolBuilder
    self._mass = math.abs(mass);
    return self;
end

--[[
    Sets the model to the tool
    @param model Tool's model
    @return The current ToolBuilder
]]
function ToolBuilder.SetModel(self: ToolBuilder, model: Model | BasePart): ToolBuilder
    self._model = model;
    return self;
end

--[[
    Sets the type to the tool
    @param toolType Tool's type
    @return The current ToolBuilder
    @error Unknown type
]]
function ToolBuilder.SetType(self: ToolBuilder, toolType: ToolType.ToolTypeValues | string): ToolBuilder
    if t.string(toolType) then
        local couldBeChanged = false;

        for index in next, ToolType do
            if string.upper(index) ~= string.upper(toolType :: string) then
                continue;
            end

            couldBeChanged = true;
            toolType = ToolType[index];

            break;
        end

        assert(couldBeChanged, "The given type is unknown!");
    end

    self._type = toolType :: ToolType.ToolTypeValues;
    return self;
end

--[[
    Sets the equip method to the tool
    @param equipMethod Tool's equip method
    @return The current ToolBuilder
]]
function ToolBuilder.SetEquipMethod(self: ToolBuilder, equipMethod: () -> ()): ToolBuilder
    self._equipMethod = equipMethod;
    return self;
end

--[[
    Sets the unequip method to the tool
    @param unequipMethod Tool's unequip method
    @return The current ToolBuilder
]]
function ToolBuilder.SetUnequipMethod(self: ToolBuilder, unequipMethod: () -> ()): ToolBuilder
    self._unequipMethod = unequipMethod;
    return self;
end

--[[
    Builds the tool with the given parameters
    @return A new tool with the set parameters
    @error Cannot create a tool with no model!
]]
function ToolBuilder.Build(self: ToolBuilder): Tool.Tool
    assert(self._model ~= nil, "Cannot create a tool with no model!");
    assert(self._type ~= nil, "Cannot create a tool without its type!");

    return Tool.new(self._name, self._imageId, self._mass, self._model, self._type, self._equipMethod, self._unequipMethod);
end

-------------------------------------
-- Types
-------------------------------------

export type ToolBuilder = typeof(setmetatable(
    {} :: {
        _name: string,
		_imageId: number,

		_mass: number,

		_equipMethod: (() -> ())?,
		_unequipMethod: (() -> ())?,

        _type: ToolType.ToolTypeValues?,

		_model: (Model | BasePart)?,
    },
    ToolBuilder
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolBuilder) :: typeof(ToolBuilder);