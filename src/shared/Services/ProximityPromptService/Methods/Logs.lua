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
	ChatService:SendMessageToChat(ChatType.Logs, "Have you ever tried to become one yourself? It looks you'd be great at it", Color3.new(0.545098, 0.133333, 0.8), 104040296001510);
end