--!strict
--@author Kriko_YT
--@date 2026/06/13
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

-------------------------------------
-- Variables
-------------------------------------

local ToolAbstractFactory = {};
ToolAbstractFactory.__index = ToolAbstractFactory;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Creates a new tool according to the given model
    @param toolModel Model reference for the new tool
    @error This method was not implemented in this factory class!
]]
function ToolAbstractFactory.CreateToolByModel(self: ToolAbstractFactory, toolModel: Model)
    error("This method was not implemented in this factory class!", 2);
end

-------------------------------------
-- Types
-------------------------------------

export type ToolAbstractFactory = typeof(setmetatable(
    {} :: {},
    ToolAbstractFactory
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolAbstractFactory) :: typeof(ToolAbstractFactory);