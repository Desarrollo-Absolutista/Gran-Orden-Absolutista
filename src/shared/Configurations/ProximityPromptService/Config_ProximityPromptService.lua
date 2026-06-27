--!strict
--@author Kriko_YT
--@date 2026/06/04
--@version 1.0

-------------------------------------
-- List
-------------------------------------

local Config: Config = {
	maximumRadiusLimit = 100,

	keys = {
		{Enum.KeyCode.F},
		{Enum.KeyCode.G},
		{Enum.KeyCode.H},
		{Enum.KeyCode.J},
	},

	defaultOnFocusMethod = function(instance: Instance?)
		if instance == nil then
			return;
		end

		if not instance:IsA("BasePart") then
			return;
		end

		(instance :: BasePart).BrickColor = BrickColor.Green();
	end,

	defaultOnUnfocusMethod = function(instance: Instance?)
		if instance == nil then
			return;
		end

		if not instance:IsA("BasePart") then
			return;
		end

		(instance :: BasePart).BrickColor = BrickColor.Red();
	end,
};

-------------------------------------
-- Types
-------------------------------------

export type Config = {[string]: any};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Config) :: Config;
