--!strict
--@author Kriko_YT
--@date 2026/06/06
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local TextService = game:GetService("TextService");

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;
local services = ReplicatedStorage.Services;
local configurations = ReplicatedStorage.Configurations;

local ChatPacket = require(packets.Chat.ChatPacket);

local Config = require(configurations.ChatService.Config_ChatService);

local ChatType = require(services.ChatService.ChatType);

-------------------------------------
-- Variables
-------------------------------------

local ChatService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
	Initializes the service
]]
function ChatService.init(self: ChatService): ()
	if isServiceInitialized then
		warn("ChatService is already initialized!");
		return;
	end
	
	isServiceInitialized = true;
	
	self:_DetectWhenPlayerSentMessage();
end

--[[
	Obtains the players to show the bubble message
	@param player Player who sent the message
	@return The players to show the bubble message
]]
@native
function ChatService._ObtainPlayersToShowMessageBubble(self: ChatService, senderPlayer: Player): {Player}
	local playersToShowMessage = {senderPlayer};
	local senderCharacter = senderPlayer.Character;
	
	if senderCharacter == nil then
		return {};
	end
	
	local senderPosition = senderCharacter:GetPivot().Position;

	for _, player in ipairs(Players:GetPlayers()) do
		if player == senderPlayer then
			continue;
		end
		
		local character = player.Character;

		if not character then
			continue;
		end

		local characterPosition = character:GetPivot().Position;

		if (characterPosition - senderPosition).Magnitude <= Config.maximumDistanceToSeeBubbleMessage :: number then
			table.insert(playersToShowMessage, player);
		end
	end
	
	return playersToShowMessage;
end

--[[
	Detects when a player sent a message
]]
function ChatService._DetectWhenPlayerSentMessage(self: ChatService): ()
	ChatPacket.packets.SendMessage.listen(function(data, player)
		assert(player ~= nil, "The player who sent the message was not found!");
				
		local senderCharacter = player.Character;
		if senderCharacter == nil then
			return;
		end
		
		local playersToShowMessage = self:_ObtainPlayersToShowMessageBubble(player);
		
		local messageFiltered = TextService:FilterStringAsync(data.message, player.UserId, Enum.TextFilterContext.PublicChat);
		local success, filteredString = pcall(function()
			return messageFiltered:GetNonChatStringForBroadcastAsync();
		end)
		
		if success then
			ChatPacket.packets.ShowMessageBubble.sendToList(
				{
					playerWhoSentTheMessage = player.Name,
					message = filteredString
				},
				playersToShowMessage
			);
		else
			warn("Error while filtering message: " .. tostring(filteredString) .. "!");
		end
	end)
end

--[[
	Sends a message to the given player
	@param client Player to send the message
	@param chatType The type of chat to send this message
	@param message Message to send
	@param messageColor The message's color
	@param imageId Image to go along the message
]]
function ChatService._SendMessageToClient(self: ChatService, client: Player, chatType: ChatType.ChatTypeValues, message: string, messageColor: Color3?, imageId: number?): ()
	ChatPacket.packets.SendMessageToChat.sendTo(
		{
			chatType = chatType,
			message = message,
			messageColor = messageColor,
			imageId = imageId
		},
		client
	)
end

--[[
	Sets the ready clients list
]]
function ChatService.IsServiceInitialized(self: ChatService): boolean
	return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ChatService = typeof(ChatService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ChatService) :: ChatService;
