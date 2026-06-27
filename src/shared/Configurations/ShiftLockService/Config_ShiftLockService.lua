--!strict
--@author Kriko_YT
--@date 2026/06/27
--@version 1.0

-------------------------------------
-- List
-------------------------------------

local Config_ShiftLockService: Config_ShiftLockService = {
    EnableRobloxShiftLock = false;
};

-------------------------------------
-- Types
-------------------------------------

export type Config_ShiftLockService = {[string]: any};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Config_ShiftLockService) :: Config_ShiftLockService;