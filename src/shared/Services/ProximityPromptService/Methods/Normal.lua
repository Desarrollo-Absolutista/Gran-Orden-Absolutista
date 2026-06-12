--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local services = ReplicatedStorage.Services;

local ChatService = require(services.ChatService.ChatService);
local ChatType = require(services.ChatService.ChatType);

-------------------------------------
-- Variables
-------------------------------------

-------------------------------------
-- Methods
-------------------------------------

-------------------------------------
-- Return
-------------------------------------

return function(instance: Instance?): ()
	ChatService:SendMessageToChat(ChatType.Normal, "OMG", Color3.new(0, 0, 0.8), 104040296001510);
end