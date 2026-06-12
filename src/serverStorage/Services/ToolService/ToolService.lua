--!strict
--@author Kriko_YT
--@date 2026/06/11
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

local TOOL_FOLDER_NAME: string = "ToolsFolder";

local CFRAME_HANDLE_OFFSET_ATTRIBUTE_NAME: string = "Offset";

-------------------------------------
-- Roblox Services
-------------------------------------

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packets = ReplicatedStorage.Packets;
local sharedServices = ReplicatedStorage.Services;

local ToolsPacket = require(packets.Tools.ToolsPacket);

local SharedToolService = require(sharedServices.ToolService.ToolService);

-------------------------------------
-- Variables
-------------------------------------

local ToolService = {};
local isServiceInitialized: boolean = false;

local playersToolFolder = setmetatable({} , {__mode = "k"});

-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function ToolService.init(self: ToolService): ()
    if isServiceInitialized then
        warn("ToolService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    local parentFolder = self:_SetUpEquipedToolsFolder();
    
    self:_ConnectPlayerAddedEvent(parentFolder);
    self:_ListenClientEquipingTool(parentFolder);
    self:_ListenClientUnequipingTool(parentFolder);
end

--[[
    Welds the given tool model to the given character
    @param model Model to weld to the character
    @param character Player's character
    @error The tool has no handle!
]]
function ToolService._WeldToolToCharacter(self: ToolService, model: Model | BasePart, character: Model): ()
    local handle: BasePart? = nil do
        if model:IsA("BasePart") then
            handle = model;
        else
            handle = model:FindFirstChild("Handle") :: BasePart?;
        end
    end
    assert(handle ~= nil, "The tool has no handle!");

    local rightHand = character:WaitForChild("RightHand") :: BasePart;

    handle.CFrame = rightHand.CFrame * (handle:GetAttribute(CFRAME_HANDLE_OFFSET_ATTRIBUTE_NAME) :: CFrame? or CFrame.identity);

    local weldConstraint = Instance.new("WeldConstraint");
    weldConstraint.Part0 = rightHand;
    weldConstraint.Part1 = handle;
    weldConstraint.Parent = handle;
end

--[[
    Creates the folder that will contain every player's equiped tool
    @return Folder with all equiped tools
]]
---@inline
function ToolService._SetUpEquipedToolsFolder(self: ToolService): Folder
    local folder = Instance.new("Folder");
    folder.Name = TOOL_FOLDER_NAME;
    folder.Parent = workspace;

    return folder;
end

--[[
    Connects the events that creates the player's equiped tool folder
    @param parentFolder Parent folder
]]
function ToolService._ConnectPlayerAddedEvent(self: ToolService, parentFolder: Folder): ()
    Players.PlayerAdded:Connect(function(player: Player)
        local folder = Instance.new("Folder");
        folder.Name = player.Name;
        folder.Parent = parentFolder;

        playersToolFolder[player] = folder;
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        local individualFolder = playersToolFolder[player];

        if individualFolder then
            individualFolder:Destroy();
        end
    end)
end

--[[
    Listens when a player equips a tool
    @param parentFolder Parent folder
]]
function ToolService._ListenClientEquipingTool(self: ToolService, parentFolder: Folder): ()
    ToolsPacket.packets.Equip.listen(function(data, player: Player?)
        assert(player ~= nil, "The client is not recognized!");

        local character = player.Character;
        assert(character ~= nil, "The client's character was not found!");

        local individualFolder = playersToolFolder[player];
        if not individualFolder then
            return;
        end

        local model = SharedToolService:GetModelByTypeAndName(data.toolName, data.toolType);
        assert(model ~= nil, "The model was not found!");

        local newModel = model:Clone();
        newModel.Parent = individualFolder;

        self:_WeldToolToCharacter(newModel, character);
    end)
end

--[[
    Listens when a player unequips a tool
    @param parentFolder Parent folder
]]
function ToolService._ListenClientUnequipingTool(self: ToolService, parentFolder: Folder): ()
    ToolsPacket.packets.Unequip.listen(function(_, player: Player?)
        assert(player ~= nil, "The client was not found! It is not possible to remove a tool thta an unknown player has equiped!");

        local individualFolder = playersToolFolder[player];

        if individualFolder then
            individualFolder:ClearAllChildren();
        end
    end)
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function ToolService.IsServiceInitialized(self: ToolService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type ToolService = typeof(ToolService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ToolService) :: ToolService;