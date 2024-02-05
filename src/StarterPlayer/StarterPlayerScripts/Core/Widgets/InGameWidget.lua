local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local GameData = ReplicatedModules.Data.GameData

local RemoteService = ReplicatedModules.Services.RemoteService
local UpdateInGameGraphicsEvent = RemoteService:GetRemote("UpdateInGameGraphicsEvent", "RemoteEvent", false)


local Interface = LocalPlayer:WaitForChild('PlayerGui')
local InGameWidget = Interface:WaitForChild('InGame')

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

Module.ChoosingRandomHunter = false
Module.hunterName = ""

function Module.UpdateWidget()
    
end

function Module.UpdateInGameGui(timeOfBomb, currentHunter)
    InGameWidget.HunterText.Visible = false
    InGameWidget.CountdownText.Visible = false
    InGameWidget.EmptyBar.HunterText.Text = "Current Hunter:"

    Module.hunter = currentHunter

    InGameWidget.EmptyBar.Visible = true
    InGameWidget.EmptyBar.HunterText.HunterValue.Text = currentHunter.Name

    if timeOfBomb == GameData.TotalTimeForBombToExplode then
        InGameWidget.EmptyBar.Clipping.Size = UDim2.new(1, 0, 1, 0)
        InGameWidget.EmptyBar.Clipping.Top.Size = UDim2.new(1, 0, 1, 0)
        return
    end

    local function resizeBombBar(sizeRatio, clipping, top)
        clipping.Size = UDim2.new(sizeRatio, clipping.Size.X.Offset, clipping.Size.Y.Scale, clipping.Size.Y.Offset)
        top.Size = UDim2.new((sizeRatio > 0 and 1 / sizeRatio) or 0, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset) -- Extra check in place just to avoid doing 1 / 0 (which is undefined)
    end

    local xScale = timeOfBomb / GameData.TotalTimeForBombToExplode

    resizeBombBar(xScale, InGameWidget.EmptyBar.Clipping, InGameWidget.EmptyBar.Clipping.Top)

    if currentHunter.UserId == LocalPlayer.UserId then
        InGameWidget.EmptyBar.HunterText.Text = "You are the hunter!"
        InGameWidget.EmptyBar.HunterText.HunterValue.Text = ""

        SystemsContainer.Gameplay.TagPlayersInRadius.CheckingForPlayers = true
    else
        SystemsContainer.Gameplay.TagPlayersInRadius.CheckingForPlayers = false
    end
end

function Module.StartLastCountdown(number)
    InGameWidget.HunterText.Visible = false
    InGameWidget.CountdownText.Visible = true

    InGameWidget.CountdownText.Text = "Game starting in " .. number .. " seconds!"


    if not (tonumber(number) == 0) then return end

    InGameWidget.CountdownText.Visible = false
end

function Module.ChooseRandomHunter()
    InGameWidget.HunterText.Visible = true
    InGameWidget.EmptyBar.Visible = false
    local HunterText = InGameWidget.HunterText.HunterValue :: TextLabel

    -- Loop through all players and set the HunterText to a random player's name every 0.5 seconds while ChoosingRandomHunter is true
    local players = Players:GetPlayers()
    while Module.ChoosingRandomHunter do
        local randomPlayer = players[math.random(1, #players)]
        HunterText.Text = randomPlayer.Name
        local RandomColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        HunterText.TextColor3 = RandomColor
        task.wait(0.5)
    end

    -- Set the HunterText to the chosen hunter's name
    HunterText.Text = Module.hunter.Name

    -- Enable checking for players in radius just for the hunter
    if Module.hunter.UserId == LocalPlayer.UserId then
        SystemsContainer.Gameplay.TagPlayersInRadius.CheckingForPlayers = true
    else
        SystemsContainer.Gameplay.TagPlayersInRadius.CheckingForPlayers = false
    end
end

function Module.OpenWidget(...)
    if Module.Open then
        return
    end

    local args = {...}
    local chooseRandomHunter = args[1]

    InGameWidget.Enabled = true

    if chooseRandomHunter then
        Module.ChooseRandomHunter()
    end

    
    Module.Open = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    InGameWidget.Enabled = false
    Module.Open = false

    InGameWidget.EmptyBar.Visible = false

    Module.ChoosingRandomHunter = false
    Module.hunterName = ""

    Module.WidgetTrove:Destroy()
end

function Module.Start()
    UpdateInGameGraphicsEvent.OnClientEvent:Connect(function(event, ...)
        if event == "stopChoosingHunter" then
            Module.ChoosingRandomHunter = false

            local args = {...}
            Module.hunter = args[1]
        end

        if event == "startChoosingHunter" then
            Module.ChoosingRandomHunter = true
            Module.OpenWidget(true)
        end

        if event == "updateLastCountdown" then
            local args = {...}
            local number = args[1]
            Module.StartLastCountdown(number)
        end

        if event == "UpdateInGameGui" then
            local args = {...}
            local timeOfBomb = args[1]
            local currentHunter = args[2]
            Module.UpdateInGameGui(timeOfBomb, currentHunter)
        end
    end)

end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module