if not game:IsLoaded() then
	game.Loaded:Wait();
end
task.wait(2);

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Behaviour
-------------------------------------

require(ReplicatedStorage.Services.DoorService.DoorService):init();
require(ReplicatedStorage.Services.ChatService.ChatService):init();
require(ReplicatedStorage.Services.HotbarService.HotbarService):init();
require(ReplicatedStorage.Services.ToolService.ToolService):init();
require(ReplicatedStorage.Services.ProximityPromptService.ProximityPromptService):init();
require(ReplicatedStorage.Services.PlayerService.PlayerService):init();
require(ReplicatedStorage.Services.ShiftLockService.ShiftLockService):init();

print("Services initializated");