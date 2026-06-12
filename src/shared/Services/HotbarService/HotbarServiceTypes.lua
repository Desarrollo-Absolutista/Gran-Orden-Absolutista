--!strict
--@author Kriko_YT
--@date 2026/06/09
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

export type HotbarUi = ScreenGui & {
    Frame: Frame
}

export type HotbarSlot = Frame & {
    ImageLabel: ImageLabel,
    ToolName: TextLabel,
    Number: TextLabel,
    Detector: TextButton
}

-------------------------------------
-- Return
-------------------------------------

return nil;