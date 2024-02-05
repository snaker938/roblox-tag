local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local WaitingWidget = Interface:WaitForChild('Waiting')

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    
end

function Module.OpenWidget()
    if Module.Open then
        return
    end

    WaitingWidget.Enabled = true
    
    Module.Open = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    WaitingWidget.Enabled = false
    Module.Open = false
    Module.WidgetTrove:Destroy()
end

function Module.Start()
    
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module