--!strict
--@author Kriko_YT
--@date 2026/06/11
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

return ByteNetMax.defineNamespace("Tools", function()
	return {
        structs = {},
        namespace = {},
		
		packets = {
			Equip = ByteNetMax.definePacket
			{
				value = ByteNetMax.struct
				{
					toolName = ByteNetMax.string,
                    toolType = ByteNetMax.int8,
				},
			},

            Unequip = ByteNetMax.definePacket
            {
				value = ByteNetMax.struct
				{
					
				},
			},
		},
        
		queries = {},
	}
end);
