--!strict
--@author Kriko_YT
--@date 2026/06/09
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local SLOT_NAME = "Slot#%i";

local COOLDOWN_TO_CHANGE_HOTBAR: number = 0.1;
local CHANGE_HOTBAR_ACTION_NAME: string = "HotbarScroll";

local CHANGE_HOTBAR_TWEEN_INFORMATION: TweenInfo = TweenInfo.new(0.25);

-------------------------------------
-- Roblox Services
-------------------------------------

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local StarterGui = game:GetService("StarterGui");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

-------------------------------------
-- Dependencies
-------------------------------------

local classes = ReplicatedStorage.Classes;
local packets = ReplicatedStorage.Packets;
local services = ReplicatedStorage.Services;
local configurations = ReplicatedStorage.Configurations;

local ToolType = require(classes.Tool.ToolType);
local ToolFactory = require(classes.Tool.ToolFactory);
local Tool = require(classes.Tool.Tool);

local HotbarPacket = require(packets.Hotbar.HotbarPacket);

local ToolService = require(services.ToolService.ToolService);

local Config = require(configurations.HotbarService.Config_HotbarService);

local HotbarScrollDirection = require("./HotbarScrollDirection");
local HotbarServiceTypes = require("./HotbarServiceTypes");

-------------------------------------
-- Variables
-------------------------------------

local HotbarService = {};
local isServiceInitialized: boolean = false;

local localPlayer = Players.LocalPlayer :: Player;
local playerGui = localPlayer:WaitForChild("PlayerGui");
local hotbarUi = playerGui:WaitForChild("Hotbar") :: HotbarServiceTypes.HotbarUi;

local assets = ReplicatedStorage.Assets.HotbarService;
local slot = assets.Slot :: HotbarServiceTypes.HotbarSlot;

local hotbarSlots: {[ToolType.ToolTypeValues]: {HotbarServiceTypes.HotbarSlot}} = {};
local hotbarTools: {[ToolType.ToolTypeValues]: {[HotbarServiceTypes.HotbarSlot]: Tool.Tool}} = {};

local activeHotbar: ToolType.ToolTypeValues = ToolType.Tools;

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function HotbarService.init(self: HotbarService): ()
    if RunService:IsServer() then
		warn("HotbarService can only be initialized on the client!");
		return;
	end  

    if isServiceInitialized then
        warn("HotbarService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false);

    self:_SetUpUi();
    self:_ConnectKeyboardEvent();
    self:_ConnectEventToSetATool();
    self:_ConnectHatbarChangerEvent();
end

--[[
    Creates the whole UI
]]
function HotbarService._SetUpUi(self: HotbarService): ()
    local startingTime = os.clock();

    for enumName, enumValue in next, ToolType do
        if os.clock() - startingTime > 0.1 then
            task.wait();
            startingTime = os.clock();
        end

        hotbarSlots[enumValue] = table.create(Config.slotsPerHotbar);

        local parentFrame = Instance.new("Frame");
        parentFrame.Name = enumName;
        parentFrame.BackgroundTransparency = 1;
        parentFrame.Size = UDim2.fromScale(1, 1);
        parentFrame.Visible = false;
        parentFrame.Position = UDim2.fromScale(0, -1);
        parentFrame.Parent = hotbarUi.Frame;

        local uiListLayout = Instance.new("UIListLayout");
        uiListLayout.Padding = UDim.new(0.02, 0);
        uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
        uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
        uiListLayout.Parent = parentFrame;

        for slotIndex = 1, Config.slotsPerHotbar do
            local newSlot = slot:Clone();
            newSlot.Name = string.format(SLOT_NAME, slotIndex);
            newSlot.Number.Text = tostring(slotIndex);
            newSlot.Parent = parentFrame;

            table.insert(hotbarSlots[enumValue], newSlot);
        end
    end

    self:_EnableCurrentHotbar(HotbarScrollDirection.Down);
end

--[[
    Disables every slot in the active hotbar
]]
---@inline
function HotbarService._DisableCurrentHotbar(self: HotbarService, direction: HotbarScrollDirection.HotbarScrollDirectionValues): ()
    local frame = hotbarSlots[activeHotbar][1].Parent :: Frame;

    local tween = TweenService:Create(
        frame,
        CHANGE_HOTBAR_TWEEN_INFORMATION,
        {
            Position = UDim2.fromScale(0, direction)
        }
    );
    tween:Play();
    tween.Completed:Connect(function()
        tween:Destroy();
        frame.Visible = false;
    end)
end

--[[
    Equips or unequips the tool equiped in the given slot in the active hotbar
    @param slot Slot in the active hotbar which contains the tool to equip/unequip
]]
function HotbarService._EquipOrUnequipToolAccordingToSlot(self: HotbarService, slot: HotbarServiceTypes.HotbarSlot): ()
    local tool: Tool.Tool? = hotbarTools[activeHotbar][slot];

    if tool == nil then
        return;
    end

    if tool:IsEquiped() then
        tool:Unequip();
    else
        tool:Equip();
    end
end

--[[
    Enables every slot in the active hotbar
]]
---@inline
function HotbarService._EnableCurrentHotbar(self: HotbarService, direction: HotbarScrollDirection.HotbarScrollDirectionValues): ()
    local frame = hotbarSlots[activeHotbar][1].Parent :: Frame;
    frame.Position = UDim2.fromScale(0, direction);
    frame.Visible = true;

    local tween = TweenService:Create(
        frame,
        CHANGE_HOTBAR_TWEEN_INFORMATION,
        {
            Position = UDim2.fromScale(0, 0)
        }
    );
    tween:Play();
    tween.Completed:Connect(function()
        tween:Destroy();
        
        for _, slot: HotbarServiceTypes.HotbarSlot in ipairs(hotbarSlots[activeHotbar]) do
            slot.Detector.MouseButton1Up:Connect(function()
                self:_EquipOrUnequipToolAccordingToSlot(slot);
            end)
        end
    end)
end

--[[
    Connects the input event
]]
---@inline
function HotbarService._ConnectKeyboardEvent(self: HotbarService): ()
    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent then
            return;
        end

        local number: number? = self:_ConvertFromKeyCodeToNumber(input.KeyCode);
        if number == nil or number == 0 then
            return;
        end

        local slotFound: HotbarServiceTypes.HotbarSlot? = self:_GetSlotInActiveHotbarByItsSlotIndex(number);
        if slotFound == nil then
            return;
        end

        self:_EquipOrUnequipToolAccordingToSlot(slotFound);
    end)
end

--[[
    Gives the previous tool type according to the active one
    @return The previous hotbar according to the active one, nil if it was not recognized
    @error The current active hotbar was not recognized!
]]
function HotbarService._GetPreviousToolType(self: HotbarService): ToolType.ToolTypeValues?
    if activeHotbar == ToolType.Weapons then
        return ToolType.Tools;
    end
   
    if activeHotbar == ToolType.Ammunition then
        return ToolType.Weapons;
    end

    if activeHotbar == ToolType.Consumables then
        return ToolType.Ammunition;
    end

    if activeHotbar == ToolType.Tools then
        return ToolType.Consumables;
    end

    error("The current active hotbar was not recognized!");
    return nil;
end

--[[
    Gives the next tool type according to the active one
    @return The next hotbar according to the active one, nil if it was not recognized
    @error The current active hotbar was not recognized!
]]
function HotbarService._GetNextToolType(self: HotbarService): ToolType.ToolTypeValues?
    if activeHotbar == ToolType.Weapons then
        return ToolType.Ammunition;
    end
   
    if activeHotbar == ToolType.Ammunition then
        return ToolType.Consumables;
    end

    if activeHotbar == ToolType.Consumables then
        return ToolType.Tools;
    end

    if activeHotbar == ToolType.Tools then
        return ToolType.Weapons;
    end

    error("The current active hotbar was not recognized!");
    return nil;
end

--[[
    Converts the given input into a number. This would change Enum.KeyCode.Zero into 0, Enum.KeyCode.One into 1, and so on
    @param keyCode Key input to convert
    @return The number that would correspond. Nil if it would not correspond to any number
]]
---@inline
function HotbarService._ConvertFromKeyCodeToNumber(self: HotbarService, keyCode: Enum.KeyCode): number?
    local number =  keyCode.Value - Enum.KeyCode.Zero.Value;

    if number >= 0 and number < 10 then
        return number;
    end

    return nil;
end

--[[
    Obtains the slot instance in the active hotbar which corresponds to the given index
    @param index Slot's index to look for
    @return The slot in the active hotbar with the given index. Nil if it was not found
]]
function HotbarService._GetSlotInActiveHotbarByItsSlotIndex(self: HotbarService, index: number): HotbarServiceTypes.HotbarSlot?
    local slotFound: HotbarServiceTypes.HotbarSlot? = nil;

    for _, slot in next, hotbarSlots[activeHotbar] do
        if slot.Name ~= string.format(SLOT_NAME, index) then
            continue;
        end

        slotFound = slot;
        break;
    end

    return slotFound;
end

--[[
    Changes the active hotbar
    @param newHotbar The hotbar to enable
]]
function HotbarService._ChangeActiveHotbar(self: HotbarService, newHotbar: ToolType.ToolTypeValues, direction: HotbarScrollDirection.HotbarScrollDirectionValues): ()
    if activeHotbar == newHotbar then
        return;
    end

    self:_DisableCurrentHotbar(direction == HotbarScrollDirection.Up and HotbarScrollDirection.Down or HotbarScrollDirection.Up);

    activeHotbar = newHotbar;

    self:_EnableCurrentHotbar(direction);
end

--[[
    Goes to the next hotbar
]]
function HotbarService._GoToNextHotbar(self: HotbarService): ()
    local newHotbar = self:_GetNextToolType();
    if newHotbar then
        self:_ChangeActiveHotbar(newHotbar, HotbarScrollDirection.Up);
    end
end

--[[
    Goes to the previous hotbar
]]
function HotbarService._GoToPrevioustHotbar(self: HotbarService): ()
    local newHotbar = self:_GetPreviousToolType();
    if newHotbar then
        self:_ChangeActiveHotbar(newHotbar, HotbarScrollDirection.Down);
    end
end

--[[
    Connects the hotbar changer event
]]
function HotbarService._ConnectHatbarChangerEvent(self: HotbarService): ()
    local lastChangeTime: number = 0;

    local function changeOnTime(): boolean
        if tick() - lastChangeTime < COOLDOWN_TO_CHANGE_HOTBAR then
            return false;
        end
        
        lastChangeTime = tick();
        return true;
    end

    local function handleMouseWheel(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): Enum.ContextActionResult?
        if inputState ~= Enum.UserInputState.Change then
            return;
        end

        if not changeOnTime() then
            return;
        end

        if inputObject.Position.Z > 0 then
            self:_GoToNextHotbar();
        else
            self:_GoToPrevioustHotbar();
        end

        return Enum.ContextActionResult.Sink;
    end

    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent then
            return;
        end

        if table.find(Config.keyToChangeHotbar, input.KeyCode) == nil then
            return;
        end

        ContextActionService:BindAction(CHANGE_HOTBAR_ACTION_NAME, handleMouseWheel, false, Enum.UserInputType.MouseWheel);
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent then
            return;
        end

        if table.find(Config.keyToChangeHotbar, input.KeyCode) == nil then
            return;
        end

        ContextActionService:UnbindAction(CHANGE_HOTBAR_ACTION_NAME);
    end)
end

--[[
    [Deprecated] Checks if any key set to change the hotbar is being pressed at the moment
    @return True if any of these keys is baing pressed, false otherwise
]]
@[deprecated {
    reason = "Never used"
}]
function HotbarService._IsAnyKeyToChangeTheHotbarDown(self: HotbarService): boolean
    local isAnyDown = false;

    for _, key: Enum.KeyCode in ipairs(Config.keyToChangeHotbar) do
        isAnyDown = UserInputService:IsKeyDown(key);
        
        if isAnyDown then
            break;
        end
    end

    return isAnyDown;
end

--[[
    Sets the given tool to the hotbar
    @error The given tool type does not exist!
    @error The hotbar's full!
    @error Could not create any tool!
]]
function HotbarService._ConnectEventToSetATool(self: HotbarService): ()
    HotbarPacket.packets.SetToolToHotbar.listen(function(data)
        assert(ToolService:DoesToolTypeExist(data.toolType), "The given tool type does not exist!");

        if hotbarTools[data.toolType] == nil then
            hotbarTools[data.toolType] = {};
        end

        local amountOfToolsInHotbar = 0 do
            for _ in next, hotbarTools[data.toolType] do
                amountOfToolsInHotbar += 1;
            end
        end

        assert(amountOfToolsInHotbar < Config.slotsPerHotbar, "The hotbar's full!");

        local tool = ToolFactory.new():CreateToolByNameAndType(data.toolName, data.toolType);
        assert(tool ~= nil, "Could not create any tool!");

        local slotFrame = hotbarSlots[data.toolType][amountOfToolsInHotbar + 1];

        hotbarTools[data.toolType][slotFrame] = tool;

        slotFrame.ToolName.Text = tool:GetName();
        slotFrame.ImageLabel.Image = `rbxassetid://{tool:GetImageId()}`;
    end)
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function HotbarService.IsServiceInitialized(self: HotbarService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type HotbarService = typeof(HotbarService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(HotbarService) :: HotbarService;