--!strict
--@author Kriko_YT
--@date 2026/06/17
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

return ByteNetMax.defineNamespace("Player", function()
	return {
        structs = {},
        namespace = {},
		
		packets = {
			SetClientReady = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
				},
			},

			ActivateRobloxShiftLock = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
					enable = ByteNetMax.bool
				}
			}
		},
        
		queries = {},
	}
end);
