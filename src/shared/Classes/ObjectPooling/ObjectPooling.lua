--!strict
--@author Kriko_YT
--@date 2026/06/08
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

local Signal = require(packages.Signal);
local Trove = require(packages.Trove);
local t = require(packages.t);

-------------------------------------
-- Variables
-------------------------------------

local ObjectPooling = {};
ObjectPooling.__index = ObjectPooling;

-------------------------------------
-- Constructors
-------------------------------------

--[[
    Creates a new instance of ObjectPooling

    ```lua
    local ObjectPooling = require("./ObjectPooling");

    local onPool = function(object)
        object.Parent = workspace;
    end)

    local onUnpool = function(object, parent)
        object.Parent = parent;
    end

    local myPool = ObjectPooling.new(script.Instance, 10, "PoolTest", onPool, onUnpool);
    ```
    ---
    
    @param instance Instance to be pooling and unpooling
    @param defaultPoolAmount The default amount of instances ready to be pool
    @param onPoolMethod Method to run when a new instance was pooled. Receives the proper instance as argument
    @param onUnpoolMethod Method to run when a new instance was unpooled. Receives the proper instance as argument
    @param lifetime Pooled instance's lifetime before they get unpooled automatically, Set it to nil if the instance is not desired to be automatically unpooled
    @return A new instance of ObjectPooling
]]
function ObjectPooling.new<T>(instance: T, defaultPoolAmount: number, name: string, onPoolMethod: ((T) -> ())?, onUnpoolMethod: ((T, Instance) -> ())?, lifetime: number?): ObjectPooling<T>
    local self = setmetatable({}, ObjectPooling) :: ObjectPooling<T>;

    self._trove = Trove.new();

    self._name = name;

    self._unpooledInstanceParent = Instance.new("Folder", script);
    self._unpooledInstanceParent.Name = self._name;

    self._instancesToPool = {};
    self._instancesToUnpool = {};

    self._instance = instance;

    self._onPoolMethod = onPoolMethod;
    self._onUnpoolMethod = onUnpoolMethod;

    self.InstancePooled = self._trove:Add(Signal.new());
    self.InstanceUnpooled = self._trove:Add(Signal.new());

    self._lifetime = lifetime;

    self:_SetDefaultObjects(defaultPoolAmount);

    return self;
end

-------------------------------------
-- Methods
-------------------------------------

--[[
    Creates a copy of the instance
    @return The copy if the instance, nil if the method to copy it does not exist
]]
---@inline
function ObjectPooling._CreateNewInstance<T>(self: ObjectPooling<T>): T?
    local newInstance: T? = nil;
    
    if (self._instance).Clone then
        newInstance = self._trove:Add(self._instance:Clone());
    end

    return newInstance;
end

--[[
    Generates all the default instances
    @param defaultPoolAmount 
    @error Cannot create a copy of the element
]]
function ObjectPooling._SetDefaultObjects<T>(self: ObjectPooling<T>, defaultPoolAmount: number): ()
    for _ = 1, defaultPoolAmount do
        local newInstance = self:_CreateNewInstance();
        assert(newInstance ~= nil, "Cannot create a copy of the element!");

        table.insert(self._instancesToPool, newInstance);
    end
end

--[[
    Pools a new instance
    @error Could not create a new instance to cover the lacking instances to pool!
]]
function ObjectPooling.Pool<T>(self: ObjectPooling<T>): T
    local objectToPool = table.remove(self._instancesToPool, 1) :: T?;

    if objectToPool == nil then
        objectToPool = self:_CreateNewInstance();
    end

    assert(objectToPool ~= nil, "Could not create a new instance to cover the lacking instances to pool!");

    table.insert(self._instancesToUnpool, objectToPool);

    self.InstancePooled:Fire(objectToPool);

    local thread: thread? = nil;
    if self._onPoolMethod then
        thread = task.defer(self._onPoolMethod, objectToPool :: T);
    end

    if t.number(self._lifetime) then
        task.delay(self._lifetime, function()
            if thread then
                task.cancel(thread);
            end

            self:UnpoolInstance(objectToPool);
        end)
    end

    return objectToPool :: T;
end

--[[
    Unpools the first pooled instance that was pooled 
]]
function ObjectPooling.Unpool<T>(self: ObjectPooling<T>): ()
    local unpooledInstance = self._instancesToUnpool[1] :: T?

    if unpooledInstance == nil then
        warn("There are no pooled instances");
        return;
    end

    self:UnpoolInstance(unpooledInstance);
end

--[[
    Unpools all the pooled instances
]]
function ObjectPooling.UnpoolAll<T>(self: ObjectPooling<T>): ()
    local instancesToUnpool = table.clone(self._instancesToUnpool);

    for _, unpooledInstance in ipairs(instancesToUnpool) do
        self:UnpoolInstance(unpooledInstance);
    end
end

--[[
    Unpools the given instance
    @param instance Instance to unpool
    @error The given instance was not pooled so far
]]
function ObjectPooling.UnpoolInstance<T>(self: ObjectPooling<T>, instance: T): ()
    local instanceIndex = table.find(self._instancesToUnpool, instance);

    assert(instanceIndex ~= nil, "The given instance was not pooled so far!");

    table.remove(self._instancesToUnpool, instanceIndex);
    table.insert(self._instancesToPool, instance);

    self.InstanceUnpooled:Fire(instance, self._unpooledInstanceParent);

    if self._onUnpoolMethod then
        self._onUnpoolMethod(instance, self._unpooledInstanceParent);
    end
end

--[[
    Obtains the object pooling's name
    @return Object pooling's name
]]
function ObjectPooling.GetName<T>(self: ObjectPooling<T>): string
    return self._unpooledInstanceParent.Name;
end

--[[
    Sets a new name to the object pooling
    @param name The object pooling's new name
]]
function ObjectPooling.SetName<T>(self: ObjectPooling<T>, name: string): ()
    self._unpooledInstanceParent.Name = name
end

--[[
    Destroyes the ObjectPooling instance
]]
function ObjectPooling.Destroy<T>(self: ObjectPooling<T>): ()
    self._trove:Destroy();
end

-------------------------------------
-- Types
-------------------------------------

export type ObjectPooling<T> = typeof(setmetatable(
    {} :: {
        _trove: Trove.Trove,

        _name: string,
        
        _unpooledInstanceParent: Folder,

        _instancesToPool: {T},
        _instancesToUnpool: {T},

        _instance: T,

        _onPoolMethod: ((T) -> ())?,
        _onUnpoolMethod: ((T, Instance) -> ())?,

        InstancePooled: Signal.Signal,
        InstanceUnpooled: Signal.Signal,

        _lifetime: number?
    },
    ObjectPooling
));

-------------------------------------
-- Return
-------------------------------------

return table.freeze(ObjectPooling) :: typeof(ObjectPooling);