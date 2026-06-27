--!strict
--@author Kriko_YT
--@date 2026/06/27
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

export type CharacterPart = BasePart & {
    LocalTransparencyModifier: number;
}

export type CharacterR6 = Model & {
    LeftArm: CharacterPart,
    RightArm: CharacterPart,
    LeftLeg: CharacterPart,
    RightLeg: CharacterPart,
    Torso: CharacterPart,
    Head: CharacterPart,
    HumanoidRootPart: CharacterPart,

    Humanoid: Humanoid & {
        Animator: Animator
    }
}

export type CharacterR15 = Model & {
    LeftUpperArm: CharacterPart,
    LeftLowerArm: CharacterPart,
    LeftHand: CharacterPart,
    LeftUpperLeg: CharacterPart,
    LeftLowerLeg: CharacterPart,
    LeftFoot: CharacterPart,
    RightUpperLeg: CharacterPart,
    RightLowerLeg: CharacterPart,
    RightFoot: CharacterPart,
    RightUpperArm: CharacterPart,
    RightLowerArm: CharacterPart,
    RightHand: CharacterPart,
    UpperTorso: CharacterPart,
    LowerTorso: CharacterPart,
    Head: CharacterPart,
    HumanoidRootPart: CharacterPart,

    Humanoid: Humanoid & {
        Animator: Animator,

        BodyDepthScale: NumberValue,
        BodyHeightScale: NumberValue,
        BodyProportionScale: NumberValue,
        BodyTypeScale: NumberValue,
        BodyWidthScale: NumberValue,
        HeadScale: NumberValue
    }
}

export type Character = CharacterR6 | CharacterR15

-------------------------------------
-- Return
-------------------------------------

return nil;