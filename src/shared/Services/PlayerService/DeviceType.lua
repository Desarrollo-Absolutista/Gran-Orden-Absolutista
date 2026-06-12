--!strict
--@author Kriko_YT
--@date 2026/06/05
--@version 1.0

-------------------------------------
-- Enum
-------------------------------------

local DeviceType: DeviceType = {
	Phone = 0,
	Tablet = 1,
	Computer = 2,
	Console = 3,
	VR = 4,
};

setmetatable(DeviceType, {
	__index = function()
		error("Cannot index nil value!");
	end,
	
	__newindex = function()
		error("Cannot create new indices in an enum!");
	end,
});

-------------------------------------
-- Types
-------------------------------------

export type DeviceTypeValues = number;

export type DeviceType = {
	Phone: DeviceTypeValues,
	Tablet: DeviceTypeValues,
	Computer: DeviceTypeValues,
	Console: DeviceTypeValues,
	VR: DeviceTypeValues,
};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(DeviceType);