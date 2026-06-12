--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Roblox Services
-------------------------------------

-------------------------------------
-- Dependencies
-------------------------------------

-------------------------------------
-- Types
-------------------------------------

export type ChatMessage = Frame & {
	Message: TextLabel,
	MessageImage: ImageLabel,
};

export type ChatUi = ScreenGui & {
	ChatBackground: Frame & {
		MessagesScroll: ScrollingFrame & {
			UIListLayout: UIListLayout,
		},
		MessageToSend: TextBox,
	},
};

-------------------------------------
-- Return
-------------------------------------

return nil;
