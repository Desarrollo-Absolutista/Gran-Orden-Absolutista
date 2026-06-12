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

local classes = ReplicatedStorage.Classes;

local ToolType = require(classes.Tool.ToolType);

-------------------------------------
-- Variables
-------------------------------------

local ToolService = {};
local isServiceInitialized: boolean = false;

local assets = ReplicatedStorage.Assets;
local toolsFolder = assets.Tools;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ToolService.init(self: ToolService): ()
    if isServiceInitialized then
        warn("ToolService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;
end

--[[
    Obtains the tool's model by its name and type
    @param toolName Tool's name
    @param toolType Tool's type
    @return The tool's model. Nil if it was not found
]]
function ToolService.GetModelByTypeAndName(self: ToolService, toolName: string, toolType: ToolType.ToolTypeValues): Model?
    local typeName = self:ConvertToolTypeIntoString(toolType);
    assert(typeName ~= nil, "The type does not exist!");

    local toolTypeFolder = toolsFolder:FindFirstChild(typeName);
    assert(toolType ~= nil, "The given type does not correspond to any folder!");

    local toolModel = toolTypeFolder:FindFirstChild(toolName);
    assert(toolModel ~= nil, `{toolName} does not correspond to any instance in {toolTypeFolder:GetFullName()}`);

    return toolModel;
end

--[[
    Converts the given tool type into a string
    @param toolType Tool tupe to convert into a string
    @retutn The tool type converted. Nil if the given type does not exist
]]
function ToolService.ConvertToolTypeIntoString(self: ToolService, toolType: ToolType.ToolTypeValues): string?
    local stringType: string? = nil;
    
    for typeName, value in next, ToolType do
        if value ~= toolType then
            continue;
        end

        stringType = typeName;
        break;
    end

    return stringType;
end

--[[
    Checks if the given tool type does exist
    @param toolType Tool type to check if exists
    @return True if the given tool type exists, false otherwise
]]
function ToolService.DoesToolTypeExist(self: ToolService, toolType: ToolType.ToolTypeValues): boolean
    return self:ConvertToolTypeIntoString(toolType) ~= nil;
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ToolService.IsServiceInitialized(self: ToolService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ToolService = typeof(ToolService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolService) :: ToolService;