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
	ChatService:SendMessageToChat(ChatType.Actions, "You just killed the leader of a squad... Be careful, I don't think his crew would be happy to see you again over there...", Color3.new(0.8, 0, 0), 6319951708);
end