local Players = game:GetService("Players")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.Start()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module