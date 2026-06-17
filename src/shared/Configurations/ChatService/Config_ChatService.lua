--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- List
-------------------------------------

local Config: Config = {
	maximumMessagesAmount = 500,
	maximumCharactersInMessage = 250,

	messageTextColor = Color3.new(0, 0, 0),
	messageWithTooManyCharactersColor = Color3.new(1, 0, 0),

	bubbleMessageTimelife = 15,

	typeMessageKeys = {Enum.KeyCode.Slash, Enum.KeyCode.KeypadDivide},
};

-------------------------------------
-- Types
-------------------------------------

export type Config = { [string]: any };

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Config) :: Config;
