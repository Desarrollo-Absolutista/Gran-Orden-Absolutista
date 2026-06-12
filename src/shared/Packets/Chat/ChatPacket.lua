--!strict
--@author Kriko_YT
--@date 2026/06/06
--@version 1.0

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packages = ReplicatedStorage.Packages;

local ByteNetMax = require(packages.ByteNetMax);

-------------------------------------
-- Return
-------------------------------------

return ByteNetMax.defineNamespace("ChatService", function()
	return {
		structs = {},
		namespace = {},
		
		packets = {
			SendMessage = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
					message = ByteNetMax.string,
				},
			},

			SendMessageToChat = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
					chatType = ByteNetMax.uint8,
					message = ByteNetMax.string,
					messageColor = ByteNetMax.optional(ByteNetMax.color3),
					imageId = ByteNetMax.optional(ByteNetMax.uint16),
				},
			},

			ShowMessageBubble = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
					playerWhoSentTheMessage = ByteNetMax.playerName,
					message = ByteNetMax.string,
				},
			},
		},
		
		queries = {},
	}
end);
