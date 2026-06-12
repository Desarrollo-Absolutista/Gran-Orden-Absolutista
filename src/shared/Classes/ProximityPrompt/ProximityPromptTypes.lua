--!strict
--@author Kriko_YT
--@date 2026/06/04
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

export type EventMethod = (Instance?) -> ();

export type KeybindData = {
	keys: {Enum.KeyCode},
	methodMessage: string,
	method: EventMethod
};

export type KeyPromptUi = Frame & {
	Key: TextLabel,
	TextLabel: TextLabel
};

-------------------------------------
-- Return
-------------------------------------

return nil;
