if not game:IsLoaded() then
	game.Loaded:Wait();
end
task.wait(2);


local ReplicatedStorage = game:GetService("ReplicatedStorage");

require(ReplicatedStorage.Services.ProximityPromptService.ProximityPromptService):init();
require(ReplicatedStorage.Services.ChatService.ChatService):init();
require(ReplicatedStorage.Services.HotbarService.HotbarService):init();
require(ReplicatedStorage.Services.ToolService.ToolService):init();

print("Services initializated");