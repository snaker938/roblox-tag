local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local GameData = ReplicatedModules.Data.GameData

local RemoteService = ReplicatedModules.Services.RemoteService
local UpdateWaitingGraphicsEvent = RemoteService:GetRemote("UpdateWaitingGraphicsEvent", "RemoteEvent", false)
local ResetGameEvent = RemoteService:GetRemote("ResetGameEvent", "RemoteEvent", false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.StartGameAgain()
    ResetGameEvent:FireAllClients()
    for i = 10, 0, -1 do
        UpdateWaitingGraphicsEvent:FireAllClients("UpdateCountdown", i)
        task.wait(1)
    end
    SystemsContainer.GameHandler.SpawnPlayers()
end

function Module.Start()
    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character:WaitForChild("Humanoid").WalkSpeed = 60
        end)

        local numPlayers = #game.Players:GetPlayers()
        if numPlayers == GameData.numPeopleToStart then

            for i = 10, 0, -1 do
                UpdateWaitingGraphicsEvent:FireAllClients("UpdateCountdown", i)

                if i == 0 then
                    SystemsContainer.GameHandler.SpawnPlayers()
                end

                task.wait(1)
            end
        end
    end)
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module