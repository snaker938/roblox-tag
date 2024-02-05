local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local RemoteService = ReplicatedModules.Services.RemoteService
local GameOverEvent = RemoteService:GetRemote("GameOverEvent", "RemoteEvent", false)

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local GameOverWidget = Interface:WaitForChild('GameOver')

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.Winner = nil

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    local WinnerText = GameOverWidget.WinnerText :: TextLabel

    WinnerText.Text = Module.Winner .. " has won the game!"
end

function Module.OpenWidget()
    if Module.Open then
        return
    end

    Module.UpdateWidget()

    GameOverWidget.Enabled = true
    
    Module.Open = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    GameOverWidget.Enabled = false
    Module.Winner = nil
    
    Module.Open = false
    Module.WidgetTrove:Destroy()
end

function Module.Start()
    GameOverEvent.OnClientEvent:Connect(function(winner)
        print(winner .. " has won the game!")
        Module.Winner = winner

        -- Toggle all other widgets
        WidgetControllerModule.ToggleAllWidgets(false, {"GameOverWidget"})

        Module.OpenWidget()
    end)
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module