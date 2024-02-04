local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.RunFunctionOnce(func)
    local executed = false
    return function(...)
        if not executed then
            executed = true
            return func(...)
        end
    end
end

function Module.Start()
    
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module