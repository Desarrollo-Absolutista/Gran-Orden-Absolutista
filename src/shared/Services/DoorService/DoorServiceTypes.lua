--!strict
--@author Kriko_YT
--@date 2026/07/10
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

export type SingleDoor = BasePart | Model;

export type DoubleDoor = Model & {
    Left: SingleDoor,
    Right: SingleDoor
};

export type Door = SingleDoor | DoubleDoor;

-------------------------------------
-- Return
-------------------------------------

return nil;