local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local GameData = ReplicatedModules.Data.GameData

local RemoteService = ReplicatedModules.Services.RemoteService
local UpdateWaitingGraphicsEvent = RemoteService:GetRemote("UpdateWaitingGraphicsEvent", "RemoteEvent", false)

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local WaitingWidget = Interface:WaitForChild('PreGameWaiting')

local CountdownText = WaitingWidget.CountdownText :: TextLabel
local MorePeopleText = WaitingWidget.MorePeopleText :: TextLabel

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}


Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    MorePeopleText.Visible = true
    MorePeopleText.Text = "Waiting for " .. GameData.numPeopleToStart - #Players:GetPlayers() .. " more players to join..."
end

function Module.UpdateCountdown(number)
    CountdownText.Visible = true
    MorePeopleText.Visible = false

   
    CountdownText.Text = "Game starting in " .. number .. " seconds!"
 
    if not (tonumber(number) == 0) then return end

    CountdownText.Visible = false
    Module.CloseWidget()
end



function Module.OpenWidget()
    if Module.Open then
        return
    end

    WaitingWidget.Enabled = true

    Module.UpdateWidget()
    
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
    UpdateWaitingGraphicsEvent.OnClientEvent:Connect(function(event, number)
        if event == "UpdateCountdown" then
            Module.UpdateCountdown(number)
        end
    end)
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module