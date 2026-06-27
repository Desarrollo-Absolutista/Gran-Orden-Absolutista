--!strict
--@author Kriko_YT
--@date 2026/06/27
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local SHIFTLOCK_CAMERA_OFFSET: Vector3 = Vector3.xAxis * 2
local RENDER_STEP_NAME: string = "ShiftLock";

-------------------------------------
-- Roblox Services
-------------------------------------

local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

-------------------------------------
-- Variables
-------------------------------------

local ShiftLockService = {};
local isServiceInitialized: boolean = false;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ShiftLockService.init(self: ShiftLockService): ()
    if isServiceInitialized then
        warn("ShiftLockService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;
end

--[[
	Calculates the looking angle
	@return The looking angle
]]
function ShiftLockService._GetLookingAngle(self: ShiftLockService): number
	local camera = workspace.CurrentCamera;
	if camera == nil then
		return 0;
	end

	local lookingTowards = camera.CFrame.LookVector;

	return math.atan2(-lookingTowards.X, -lookingTowards.Z);
end

--[[
	Activates the "forced" shift lock
	@param humanoid: Player's humanoid affected
]]
function ShiftLockService.EnableShiftLock(self: ShiftLockService): ()
	assert(RunService:IsClient(), "This method can only be ran on client-side!")

	local player = Players.LocalPlayer :: Player;
	
	RunService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Character.Value, function()
		local character = player.Character;
		if character == nil then
			return;
		end

		local humanoid = character:WaitForChild("Humanoid") :: Humanoid;

		local rootPart : Part = humanoid.RootPart :: Part
		
		humanoid.CameraOffset = SHIFTLOCK_CAMERA_OFFSET
		humanoid.AutoRotate = false
		
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter;

		local cframePosition = CFrame.new(rootPart.Position);
		local cframeRotation = CFrame.fromAxisAngle(Vector3.yAxis, self:_GetLookingAngle());
		
		rootPart.CFrame = cframePosition * cframeRotation;
	end)
end

--[[
	Desactivates the "forced" shift lock
	@param humanoid: Player"s humanoid affected
]]
function ShiftLockService.DisableShiftLock(self: ShiftLockService)
    assert(RunService:IsClient(), "This method can only be ran on client-side!");

	local player = Players.LocalPlayer :: Player;
	local character = player.Character or player.CharacterAdded:Wait();
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid;

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	
	humanoid.CameraOffset = Vector3.zero
	humanoid.AutoRotate = true
	
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end


--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ShiftLockService.IsServiceInitialized(self: ShiftLockService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ShiftLockService = typeof(ShiftLockService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ShiftLockService) :: ShiftLockService;