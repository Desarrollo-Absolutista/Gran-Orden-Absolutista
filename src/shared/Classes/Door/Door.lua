--!strict
--@author Kriko_YT
--@date 2026/07/10
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

local services = ReplicatedStorage.Services;
local config = ReplicatedStorage.Configurations;

local ProximityPromptService = require(services.ProximityPromptService.ProximityPromptService);

local ProximityPromptServiceConfig = require(config.ProximityPromptService.Config_ProximityPromptService);

local DoorStatus = require("./DoorStatus");

-------------------------------------
-- Variables
-------------------------------------

local Door = {};
Door.__index = Door;

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of Door
    @return A new instance of Door
]]
function Door.new(model: BasePart | Model): Door
    local self = setmetatable({}, Door) :: Door;

    self._model = model;
    self._status = "Closed";

    self._doorXSize = model:IsA("Model") and model:GetExtentsSize().X or (model :: BasePart).Size.X;
    self._closedCFrame = model:GetPivot();


    model:SetAttribute("MaxDistance", 50);
    model:SetAttribute("Static", false);

    local proximityPrompt = ProximityPromptService:AddProximityPrompt(model :: BasePart);
    proximityPrompt:SetAllKeysMethods
    {{
        keys = ProximityPromptServiceConfig.keys[1],
        methodMessage = "Toggle",
        method = function()
            self:Toggle();
        end
    }};
    proximityPrompt:SetInstance(model);
    
    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Opens or closes the door
]]
function Door.Toggle(self: Door): ()
    if self._status == "Closed" then
        self:Open();
    else
        self:Close();
    end
end

--[[
    Opens the door
    @error This method was not implemented!
]]
function Door.Open(self: Door): ()
    error("This method was not implemented!");
end

--[[
    Closes the door
    @error This method was not implemented!
]]
function Door.Close(self: Door): ()
    error("This method was not implemented!");
end

-------------------------------------
-- Types
-------------------------------------

export type Door = typeof(setmetatable(
    {} :: {
        _model: BasePart | Model,
        _status: DoorStatus.Status,

        _doorXSize: number,
        _closedCFrame: CFrame,
    },
    Door
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Door) :: typeof(Door);