--!strict
--@author Kriko_YT
--@date 2026/06/10
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local IMAGE_ATTRIBUTE: string = "Image";
local MASS_ATTRIBUTE: string = "Mass";

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local services = ReplicatedStorage.Services;

local ToolService = require(services.ToolService.ToolService);

local ToolType = require("./ToolType");
local ToolBuilder = require("./ToolBuilder");
local Tool = require("./Tool");

-------------------------------------
-- Variables
-------------------------------------

local ToolFactory = {};
ToolFactory.__index = ToolFactory;

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ToolFactory
    @return A new instance of ToolFactory
]]
function ToolFactory.new(): ToolFactory
    local self = setmetatable({}, ToolFactory) :: ToolFactory;
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Creates a new tool according to the given name and type
    @param name Tool's name to look for
    @param toolType Tool's type to look for
    @return The new tool created
    @error The tool must be placed somewhere
]]
function ToolFactory.CreateToolByNameAndType(self: ToolFactory, name: string, toolType: ToolType.ToolTypeValues): Tool.Tool?
    local toolModel = ToolService:GetModelByTypeAndName(name, toolType);
    assert(toolModel ~= nil, "Cannot create a tool with a not found model!");

    return self:CreateToolByModel(toolModel);
end

--[[
    Creates a new tool according to the given model
    @param toolModel Model reference for the new tool
    @return The new tool created
    @error The tool must be placed somewhere
]]
function ToolFactory.CreateToolByModel(self: ToolFactory, toolModel: Model): Tool.Tool?
    assert(toolModel.Parent ~= nil, "The tool must be placed somewhere!");

    return ToolBuilder.new()
        :SetName(toolModel.Name)
        :SetImage(toolModel:GetAttribute(IMAGE_ATTRIBUTE) :: number or 0)
        :SetMass(toolModel:GetAttribute(MASS_ATTRIBUTE) :: number or 0)
        :SetType(toolModel.Parent.Name)
        :SetModel(toolModel)
        :Build();
end

-------------------------------------
-- Types
-------------------------------------

export type ToolFactory = typeof(setmetatable(
    {} :: {},
    ToolFactory
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolFactory) :: typeof(ToolFactory);