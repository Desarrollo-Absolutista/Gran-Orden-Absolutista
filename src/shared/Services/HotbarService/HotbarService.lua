--!strict
--@author Kriko_YT
--@date 2026/06/09
--@version 1.2

-------------------------------------
-- Constants
-------------------------------------

local ROBLOX_IMAGE_STRING: string = "rbxassetid://%i";

local SLOT_NAME: string = "Slot#%i";

local COOLDOWN_TO_CHANGE_HOTBAR: number = 0.1;
local CHANGE_HOTBAR_ACTION_NAME: string = "HotbarScroll";

local SPACE_BETWEEN_HOTBARS: number = 0.5;
local CHANGE_HOTBAR_TWEEN_INFORMATION: TweenInfo = TweenInfo.new(0.25);

local DISTANCE_TO_MOVE_OFF_TO_START_MOVING_SLOTS: number = 20;
local MAXIMUM_DISTANCE_TO_DETECT_SLOTS_WHEN_SWAPING: number = 100;
local MOVE_IMAGE_TO_SLOOT_TWEEN_INFORMATION: TweenInfo = TweenInfo.new(0.25);

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
local packages = ReplicatedStorage.Packages;
local configurations = ReplicatedStorage.Configurations;

local ToolType = require(classes.Tool.ToolType);
local ToolFactory = require(classes.Tool.ToolFactory);
local Tool = require(classes.Tool.Tool);

local HotbarPacket = require(packets.Hotbar.HotbarPacket);

local Promise = require(packages.Promise);

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

local mouse = localPlayer:GetMouse();

local assets = ReplicatedStorage.Assets.HotbarService;
local slot = assets.Slot :: HotbarServiceTypes.HotbarSlot;

local hotbarSlots: {[ToolType.ToolTypeValues]: {HotbarServiceTypes.HotbarSlot}} = {};
local hotbarTools: {[ToolType.ToolTypeValues]: {[HotbarServiceTypes.HotbarSlot]: Tool.Tool}} = {};
local hotbarConnectedEvents: {RBXScriptConnection} = {};

local activeHotbar: ToolType.ToolTypeValues = ToolType.Tools;

local buttonOverall: TextButton;
local overallButtonEvent: RBXScriptConnection? = nil;

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
    self:_SetUpBackgroundUiForSwaping();
    self:_ConnectKeyboardEvent();
    self:_ConnectEventToSetATool();
    self:_ConnectHatbarChangerEvent();
end

--[[
    Sets up the background's swaping 
]]
function HotbarService._SetUpBackgroundUiForSwaping(self: HotbarService): ()
    local screen = Instance.new("ScreenGui");
    screen.Name = "SwapBackground";
    screen.DisplayOrder = 99999;
    screen.IgnoreGuiInset = true;
    screen.Parent = playerGui;

    buttonOverall= Instance.new("TextButton");
    buttonOverall.Size = UDim2.fromScale(1, 1);
    buttonOverall.BackgroundTransparency = 0.999;
    buttonOverall.ZIndex = screen.DisplayOrder;
    buttonOverall.Text = "";
    buttonOverall.Visible = false;
    buttonOverall.Parent = screen;
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

        local parentFrame = self:_CreateSlotsParentFrame();
        parentFrame.Name = enumName;

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
    Creates the frame where all the slots from a specific hotbar will be placed
    @return Parent frame for all these slots
]]
function HotbarService._CreateSlotsParentFrame(self: HotbarService): Frame
    local parentFrame = Instance.new("Frame");
    parentFrame.BackgroundTransparency = 1;
    parentFrame.Size = UDim2.fromScale(1, 1);
    parentFrame.Visible = true;
    parentFrame.Position = UDim2.fromScale(0, -1);
    parentFrame.Parent = hotbarUi.Frame;

    local uiListLayout = Instance.new("UIListLayout");
    uiListLayout.Padding = UDim.new(0.02, 0);
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
    uiListLayout.Parent = parentFrame;

    return parentFrame;
end

--[[
    Equips or unequips the tool equipped in the given slot in the active hotbar
    @param slot Slot in the active hotbar which contains the tool to equip/unequip
]]
function HotbarService._EquipOrUnequipToolAccordingToSlot(self: HotbarService, slot: HotbarServiceTypes.HotbarSlot): ()
    local slots = hotbarTools[activeHotbar];
    if slots == nil then
        return;
    end

    local tool: Tool.Tool? = hotbarTools[activeHotbar][slot];

    if tool == nil then
        return;
    end

    if tool:IsEquipped() then
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
    frame.Position = UDim2.fromScale(0, direction + math.sign(direction) * SPACE_BETWEEN_HOTBARS);
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
            self:_EnableSlotEvents(slot);
        end
    end)
end

--[[
    Enables the events for the specific slot
    @param slot Slot whose evets will be connected
]]
function HotbarService._EnableSlotEvents(self: HotbarService, slot: HotbarServiceTypes.HotbarSlot): ()
    local pressingButtonPromise: typeof(Promise.new())? = nil;

    table.insert(hotbarConnectedEvents, slot.Detector.MouseButton1Down:Connect(function()
        local startingPosition = vector.create(mouse.X, mouse.Y);

        pressingButtonPromise = Promise.new(function(resolve: () -> ())
            repeat
                task.wait();
            until vector.magnitude(startingPosition - vector.create(mouse.X, mouse.Y)) >= DISTANCE_TO_MOVE_OFF_TO_START_MOVING_SLOTS;

            resolve();
        end)
        :andThen(function()
            self:_EnableSwapingToolsInHotbar(slot);
        end)
    end))

    table.insert(hotbarConnectedEvents, slot.Detector.MouseButton1Up:Connect(function()
        if pressingButtonPromise then
            pressingButtonPromise:cancel();
        end

        self:_EquipOrUnequipToolAccordingToSlot(slot);
    end))
end

--[[
    Disables every slot in the active hotbar
]]
---@inline
function HotbarService._DisableCurrentHotbar(self: HotbarService, direction: HotbarScrollDirection.HotbarScrollDirectionValues): ()
    local frame = hotbarSlots[activeHotbar][1].Parent :: Frame;

    for _, event in ipairs(hotbarConnectedEvents) do
        event:Disconnect();
    end
    table.clear(hotbarConnectedEvents);

    local tween = TweenService:Create(
        frame,
        CHANGE_HOTBAR_TWEEN_INFORMATION,
        {
            Position = UDim2.fromScale(0, direction + math.sign(direction) * SPACE_BETWEEN_HOTBARS)
        }
    );
    tween:Play();
    tween.Completed:Connect(function()
        tween:Destroy();
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
        slotFrame.ImageLabel.Image = string.format(ROBLOX_IMAGE_STRING, tool:GetImageId());
    end)
end

--[[
    Connects the event to swap tools from hotbar
]]
function HotbarService._EnableSwapingToolsInHotbar(self: HotbarService, slot: HotbarServiceTypes.HotbarSlot): ()
    if hotbarTools[activeHotbar][slot] then
        hotbarTools[activeHotbar][slot]:Unequip();
    end

    local toolName = slot.ToolName.Text;
    
    local newImage = slot.ImageLabel:Clone();
    newImage.Parent = hotbarUi;
    newImage.Position = UDim2.fromOffset(slot.ImageLabel.AbsolutePosition.X, slot.ImageLabel.AbsolutePosition.Y);
    newImage.Size = UDim2.fromOffset(slot.ImageLabel.AbsoluteSize.X, slot.ImageLabel.AbsoluteSize.Y);
    newImage.ZIndex = 9999;

    buttonOverall.Visible = true;
    slot.ToolName.Text = "";
    slot.ImageLabel.Image = "";

    local mouseMoveEvent = mouse.Move:Connect(function()
        newImage.Position = UDim2.fromOffset(mouse.X, mouse.Y);
    end)

    overallButtonEvent = buttonOverall.MouseButton1Up:Connect(function()
        if overallButtonEvent then
            overallButtonEvent:Disconnect();
            overallButtonEvent = nil;
        end
        mouseMoveEvent:Disconnect();

        local imageVectorPosition = vector.create(newImage.AbsolutePosition.X, newImage.AbsolutePosition.Y);
        local slotToPlace = (self:_GetClosestSlot(imageVectorPosition) or slot) :: HotbarServiceTypes.HotbarSlot;
        
        local tween = TweenService:Create(
            newImage,
            MOVE_IMAGE_TO_SLOOT_TWEEN_INFORMATION,
            {
                Size = UDim2.fromOffset(slot.AbsoluteSize.X, slot.AbsoluteSize.Y);
                Position = UDim2.fromOffset(
                    slotToPlace.AbsolutePosition.X + slotToPlace.AbsoluteSize.X * 0.5,
                    slotToPlace.AbsolutePosition.Y + slotToPlace.AbsoluteSize.Y * 0.5
                );
            }
        );

        tween:Play();
        tween.Completed:Wait();
        tween:Destroy();

        slotToPlace.ImageLabel.Image = newImage.Image;
        slotToPlace.ToolName.Text = toolName;

        newImage:Destroy();

        buttonOverall.Visible = false;

        if slotToPlace:GetFullName() ~= slot:GetFullName() then
            local newSlotData = hotbarTools[activeHotbar][slotToPlace];
            hotbarTools[activeHotbar][slotToPlace] = hotbarTools[activeHotbar][slot];
            hotbarTools[activeHotbar][slot] = newSlotData;

            slot.ImageLabel.Image = newSlotData and string.format(ROBLOX_IMAGE_STRING, newSlotData:GetImageId()) or "";
            slot.ToolName.Text = newSlotData and newSlotData:GetName() or "";
        end
    end)
end

--[[
    Obtains the closest slot from the active hotbar to the given position
    @param position Position to get the distance from
    @return The closest slot to the given position. Nil if it was not found
]]
function HotbarService._GetClosestSlot(self: HotbarService, position: vector): HotbarServiceTypes.HotbarSlot?
    local slotToPlace: HotbarServiceTypes.HotbarSlot? = nil
    local slotDistance: number = math.huge;

    for _, slot in ipairs(hotbarSlots[activeHotbar]) do
        local slotPosition = vector.create(slot.AbsolutePosition.X, slot.AbsolutePosition.Y);
        local distance = vector.magnitude(slotPosition - position);

        if slotDistance > distance and distance <= MAXIMUM_DISTANCE_TO_DETECT_SLOTS_WHEN_SWAPING then
            slotDistance = distance;
            slotToPlace = slot;
        end
    end

    return slotToPlace;
end

--[[
    Checks if the given tool is within a hotbar
    @param toolType Type of the tool to look for
    @param toolName Name of the tool to look for
    @return True if the tool is within a hotbar, false otherwise
]]
function HotbarService.HasToolInHotbar(self: HotbarService, toolType: ToolType.ToolTypeValues, toolName: string): boolean
    local found = false;
    local toolTypeArray = hotbarTools[toolType];
    
    if toolTypeArray ~= nil then
        for _, tool: Tool.Tool in toolTypeArray :: {any} do
            if tool:GetName() ~= toolName then
                continue;
            end
    
            found = true;
            break;
        end
    end

    return found;
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