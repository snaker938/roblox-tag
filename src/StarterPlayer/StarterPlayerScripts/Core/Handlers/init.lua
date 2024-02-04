local HandlerCache = {}

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.GetHandler(handlerName)
    return HandlerCache[handlerName]
end

function Module.IsHandling(handlerName)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end
    return cachedModule.Handling
end

function Module.StartHandler(handlerName, ...)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end
    cachedModule.StartHandling(...)
end

function Module.EndHandler(handlerName, ...)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end
    cachedModule.EndHandling(...)
end

function Module.EndAllHandling(ingoreHandlerList)
    -- Ends all the handlers except the ones in the ignore list
    for handlerName, HandlerModule in pairs(HandlerCache) do
        if table.find(ingoreHandlerList, handlerName) then
            continue
        end
        HandlerModule.EndHandling()
    end
end

function Module.Start()
    for _, HandlerModule in pairs(HandlerCache) do
        HandlerModule.EndHandling()
    end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems

    print("------------ INITIALISING HANDLERS ------------")

    for _, HandlerModule in pairs(script:GetDescendants()) do
        if not HandlerModule:IsA("ModuleScript") then
            continue
        end

        print("Initialising handler: " .. HandlerModule.Name)
        local Cached = require(HandlerModule)
        Cached.Init(Module, SystemsContainer)
        HandlerCache[HandlerModule.Name] = Cached
    end

    print("------------ INITIALISED HANDLERS ------------")
end

return Module