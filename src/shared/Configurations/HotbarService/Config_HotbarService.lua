--!strict
--@author Kriko_YT
--@date 2026/06/09
--@version 1.0

-------------------------------------
-- List
-------------------------------------

local Config_HotbarService: Config_HotbarService = {
    slotsPerHotbar = 4,

    keyToChangeHotbar = {
        Enum.KeyCode.LeftControl,
        Enum.KeyCode.RightControl
    }
};

-------------------------------------
-- Types
-------------------------------------

export type Config_HotbarService = {[string]: any};

-------------------------------------
-- Return
-------------------------------------

return table.freeze(Config_HotbarService) :: Config_HotbarService;