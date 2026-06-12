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
	ChatService:SendMessageToChat(ChatType.Awards, "CONGRATULATIONS! You just became an important part of the crew! Be careful though, one never knows what can happen around them", Color3.new(0, 0.8, 0), 1133551146);
end