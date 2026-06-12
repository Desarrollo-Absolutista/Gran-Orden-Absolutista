--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local DEFAULT_CHAT_MESSAGE_COLOR: Color3 = Color3.new(1, 1, 1);

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local TextChatService = game:GetService("TextChatService");
local TextService = game:GetService("TextService");
local StarterGui = game:GetService("StarterGui");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;
local configurations = ReplicatedStorage.Configurations;

local ChatPacket = require(packets.Chat.ChatPacket);

local ChatType = require("./ChatType");
local ChatServiceTypes = require("./ChatServiceTypes");

local Config = require(configurations.ChatService.Config_ChatService);

-------------------------------------
-- Variables
-------------------------------------

local ChatService = {};
local isServiceInitialized: boolean = false;

local totalMessagesAmount = 0;
local messagesAmount: {[ChatType.ChatTypeValues]: number} = {};
local messagesList: {[ChatType.ChatTypeValues]: {ChatServiceTypes.ChatMessage}} = {};

local assets = ReplicatedStorage.Assets.ChatService;
local chatMessageFrame = assets.ChatMessage :: ChatServiceTypes.ChatMessage;

local localPlayer = Players.LocalPlayer :: Player;
local playerGui = localPlayer:WaitForChild("PlayerGui");
local chatUi = playerGui:WaitForChild("Chat") :: ChatServiceTypes.ChatUi;
local chatBackground = chatUi.ChatBackground;
local messagesScroll = chatBackground.MessagesScroll;
local messageToSend = chatBackground.MessageToSend;

local textBoundsParams: GetTextBoundsParams = Instance.new("GetTextBoundsParams");

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ChatService.init(self: ChatService): ()
	if RunService:IsServer() then
		warn("ChatService can only be initialized on the client!");
		return;
	end

	if isServiceInitialized then
		warn("ChatService is already initialized!");
		return;
	end

	isServiceInitialized = true;

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false);

	self:_ConnectMessageBox();
	self:_ConfigureNativeBubbleChat();
	self:_SendMessageWhenPlayerHasMessage();
	self:_ShowBubbleMessageWhenSomeoneNearbyTexted();
	self:_ReceiveMessagesFromServerToChat();
end

--[[
    Configures Roblox's native bubble chat settings
]]
---@inline
function ChatService._ConfigureNativeBubbleChat(self: ChatService): ()
	local bubbleChatConfiguration = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration");
	if bubbleChatConfiguration == nil then
		bubbleChatConfiguration = Instance.new("BubbleChatConfiguration" :: string);
		bubbleChatConfiguration.Parent = TextChatService;
	end

	bubbleChatConfiguration.BubbleDuration = Config.bubbleMessageTimelife :: number;
end

--[[
    Sends a message to the specified chat
    @param chatType The chat to send the mesage to
    @param message The message to send
    @param imageId The image id to send
    @param color The color of the message
]]
function ChatService.SendMessageToChat(self: ChatService, chatType: ChatType.ChatTypeValues, message: string, messageColor: Color3?, imageId: number?): ()
	self:_ClearChat();

	local newMessage = chatMessageFrame:Clone();
	newMessage.Message.Text = message;
	newMessage.Message.TextColor3 = messageColor or DEFAULT_CHAT_MESSAGE_COLOR;
	newMessage.MessageImage.Image = `rbxassetid://{imageId or 0}`;
	newMessage.LayoutOrder = chatType;
	newMessage.Parent = messagesScroll;

	textBoundsParams.Text = message;
	textBoundsParams.Font = newMessage.Message.FontFace;
	textBoundsParams.Size = newMessage.Message.TextSize;
	textBoundsParams.Width = newMessage.Message.AbsoluteSize.X;

	local uiSizeConstraint = Instance.new("UISizeConstraint");
	uiSizeConstraint.MaxSize = newMessage.AbsoluteSize;
	uiSizeConstraint.Parent = newMessage.MessageImage;

	local textSize = TextService:GetTextBoundsAsync(textBoundsParams);

	newMessage.Size = UDim2.new(newMessage.Size.X.Scale, newMessage.Size.X.Offset, 0, textSize.Y);

	self:_AddChatData(chatType, newMessage);
end

--[[
    Receives messages from the server and displays them in the chat
]]
---@inline
function ChatService._ReceiveMessagesFromServerToChat(self: ChatService): ()
	ChatPacket.packets.SendMessageToChat.listen(function(data)
		self:SendMessageToChat(data.chatType, data.message, data.messageColor, data.imageId);
	end);
end

--[[
    Checks if the message has too many characters
    @param message The message to check
    @return True if the message has too many characters, false otherwise
]]
---@inline
function ChatService._HasMessageTooManyCharacters(self: ChatService, message: string): boolean
	return (utf8.len(message) or 0) > Config.maximumCharactersInMessage :: number;
end

--[[
    Connects the message box events
]]
---@inline
function ChatService._ConnectMessageBox(self: ChatService): ()
	messageToSend:GetPropertyChangedSignal("Text"):Connect(function()
		messageToSend.TextColor3 = (
			self:_HasMessageTooManyCharacters(messageToSend.Text) and Config.messageWithTooManyCharactersColor
			or Config.messageTextColor
		) :: Color3;
	end);

	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return;
		end

		if table.find(Config.typeMessageKeys :: { Enum.KeyCode }, input.KeyCode) ~= nil then
			messageToSend:CaptureFocus();
		end
	end);
end

--[[
    Sends the player's message
]]
---@inline
function ChatService._SendMessageWhenPlayerHasMessage(self: ChatService): ()
	messageToSend.FocusLost:Connect(function()
		if #messageToSend.Text == 0 then
			return;
		end

		if self:_HasMessageTooManyCharacters(messageToSend.Text) then
			return;
		end

		ChatPacket.packets.SendMessage.send({
			message = messageToSend.Text,
		});
		messageToSend.Text = "";
	end);
end

--[[
    Shows the bubble message when someone nearby has sent a message
]]
---@inline
function ChatService._ShowBubbleMessageWhenSomeoneNearbyTexted(self: ChatService): ()
	ChatPacket.packets.ShowMessageBubble.listen(function(data)
		local sender = Players:FindFirstChild(data.playerWhoSentTheMessage) :: Player?;
		assert(sender ~= nil, "The player who sent a message nearby was not found!");

		local character = sender.Character;
		if character == nil then
			return;
		end

		TextChatService:DisplayBubble(character, data.message);
	end);
end

--[[
    Adds the chat data to the list
    @param chatType The chat type to add the chat data to
    @param message The message to add
]]
function ChatService._AddChatData(self: ChatService, chatType: ChatType.ChatTypeValues, message: ChatServiceTypes.ChatMessage): ()
	if messagesList[chatType] == nil then
		messagesList[chatType] = {};
	end
	table.insert(messagesList[chatType], message);

	if messagesAmount[chatType] == nil then
		messagesAmount[chatType] = 1;
	else
		messagesAmount[chatType] += 1;
	end
	totalMessagesAmount += 1;
end

--[[
    Returns the chat with the most messages
    @return The chat type with the most messages
]]
function ChatService._GetChatWithTheMostMessages(self: ChatService): ChatType.ChatTypeValues
	local totalMessagesAmount = -1;
	local chatTypeResult: ChatType.ChatTypeValues;

	for chatType, amount in next, messagesAmount do
		if amount < totalMessagesAmount then
			continue;
		end

		chatTypeResult = chatType;
		totalMessagesAmount = amount;
	end

	return chatTypeResult;
end

--[[
    Clears the chat
]]
function ChatService._ClearChat(self: ChatService): ()
	if totalMessagesAmount < Config.maximumMessagesAmount :: number then
		return;
	end

	local chatType = self:_GetChatWithTheMostMessages();

	local frame = table.remove(messagesList[chatType], 1) :: ChatServiceTypes.ChatMessage;
	frame:Destroy();

	messagesAmount[chatType] -= 1;
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ChatService.IsServiceInitialized(self: ChatService): boolean
	return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ChatService = typeof(ChatService) & {}

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ChatService) :: ChatService;