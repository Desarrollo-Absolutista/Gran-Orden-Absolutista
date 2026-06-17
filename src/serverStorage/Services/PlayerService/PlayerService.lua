--!strict
--@author Kriko_YT
--@date 2026/06/17
--@version 1.0

-------------------------------------
-- Constants
-------------------------------------

-------------------------------------
-- Roblox Services
-------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage");

-------------------------------------
-- Dependencies
-------------------------------------

local packages = ReplicatedStorage.Packages;
local packets = ReplicatedStorage.Packets;

local t = require(packages.t);

local PlayerPacket = require(packets.Player.PlayerPacket);

-------------------------------------
-- Variables
-------------------------------------

local PlayerService = {};
local isServiceInitialized: boolean = false;

local players = setmetatable({} :: {[Player]: boolean}, {__mode = "k"});


-------------------------------------
-- Methods
-------------------------------------

--[[
    Initializes the service
]]
function PlayerService.init(self: PlayerService): ()
    if isServiceInitialized then
        warn("PlayerService is already initialized!");
        return;
    end
    
    isServiceInitialized = true;

    self:_DetectWhenClientGetsReady();
end

--[[
    Connects the event to detect the clients according they are getting ready for the game
    @error The client who sent the ready signal is not being detected!
]]
function PlayerService._DetectWhenClientGetsReady(self: PlayerService): ()
    PlayerPacket.packets.SetClientReady.listen(function(_, player: Player?)
        assert(player ~= nil, "The client who sent the ready signal is not being detected!");

        players[player] = true;
    end)
end

--[[
    Checks if the given client has loaded already
    @param client Player's client to check
    @return True if the client was fully loaded, false otherwise
]]
function PlayerService.IsClientLoaded(self: PlayerService, client: Player): boolean
    return players[client] == true;
end

--[[
    Stops the current thread until the given player's client is fully loaded
    @param client Player's client to wait for
    @param maximumTime Maximum time to wait for the client. If this is not set, it can wait forever
]]
function PlayerService.WaitForClientToLoad(self: PlayerService, client: Player, maximumTime: number?): ()
    local shouldHaveMaximumTime = t.number(maximumTime);
    
    local startingTime = tick();

    while not self:IsClientLoaded(client) do
        if shouldHaveMaximumTime then
            local timePassedBy = tick() - startingTime;

            if timePassedBy >= maximumTime :: number then
                break;
            end
        end

        task.wait();
    end
end

--[[
    Runs the given method for every client that is fully loaded
    @param method Method to run for each ready client
]]
function PlayerService.forEachReadyClient(self: PlayerService, method: (player: Player) -> ())
    for player, isReady in next, players do
        if isReady ~= true then
            continue;
        end

        method(player);
    end
end

--[[
    Sets the ready clients list
    @return Whether the service is initialized
]]
function PlayerService.IsServiceInitialized(self: PlayerService): boolean
    return isServiceInitialized;
end

-------------------------------------
-- Type
-------------------------------------

export type PlayerService = typeof(PlayerService) & {}; 

-------------------------------------
-- Return
-------------------------------------

return table.freeze(PlayerService) :: PlayerService;