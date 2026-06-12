--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local ChatType: ChatType = {
	Actions = 0,
	Logs = 1,
	Awards = 2,
	Normal = 3
};

setmetatable(ChatType, {
	__index = function()
		error("Cannot index nil value!");
	end,
	
	__newindex = function()
		error("Cannot create new indices in an enum!");
	end
});

-------------------------------------
-- Types
-------------------------------------

export type ChatTypeValues = number;

export type ChatType = {
	Actions: ChatTypeValues,
	Logs: ChatTypeValues,
	Awards: ChatTypeValues,
	Normal: ChatTypeValues,
};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ChatType);
