local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RunService = game:GetService("RunService")

local RemoteService = ReplicatedModules.Services.RemoteService
local UpdateInGameGraphicsEvent = RemoteService:GetRemote("UpdateInGameGraphicsEvent", "RemoteEvent", false)
local TagPlayersInRadiusEvent = RemoteService:GetRemote("TagPlayersInRadiusEvent", "RemoteEvent", false)

local GameData = ReplicatedModules.Data.GameData

local GameOverEvent = RemoteService:GetRemote("GameOverEvent", "RemoteEvent", false)
local DisableCheckingEvent = RemoteService:GetRemote("DisableCheckingEvent", "RemoteEvent", false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.InGamePlayers = {}
Module.Hunter = nil
Module.InGame = false

Module.LastTagTime = os.clock()

Module.CurrentTimeForBomb = 0

function Module.UpdateInGameGui()
    while Module.InGame do
        Module.CurrentTimeForBomb = 0
        -- Update the InGameGui for all clients every second until the bomb explodes
        while Module.CurrentTimeForBomb < GameData.TotalTimeForBombToExplode do
            task.wait(1)
            Module.CurrentTimeForBomb = Module.CurrentTimeForBomb + 1
            UpdateInGameGraphicsEvent:FireAllClients("UpdateInGameGui", Module.CurrentTimeForBomb, Module.Hunter)
        end

        -- If the bomb has exploded, kill the current hunter, and set the hunter to the nearest player
        
        -- Get the nearest player to the bomb
        local nearestPlayer = nil
        local nearestDistance = 100000
        for _, player in pairs(Module.InGamePlayers) do
            if player.UserId == Module.Hunter.UserId then
                continue
            end
    
            local distance = Module.Hunter:DistanceFromCharacter(player.Character:FindFirstChild("HumanoidRootPart", true).CFrame.Position)

            if distance < nearestDistance then
                nearestPlayer = player
                nearestDistance = distance
            end
        end

        -- Kill the current hunter
        local result = Module.DestroyPlayers({Module.Hunter})

        if result then
            return
        end

        Module.Hunter = nearestPlayer
    end
end


function Module.DestroyPlayers(entities)
    print("Destroying players!")
    for _, entity in pairs(entities) do
        print(entity.Name .. " was destroyed!")
        local SpawnLocation = game.Workspace.SpawnRoom.EndSpawn
        entity.Character:PivotTo(SpawnLocation.CFrame)
    
        -- Remove the player from the InGamePlayers table
        for i, player in ipairs(Module.InGamePlayers) do
            if player == entity then
                table.remove(Module.InGamePlayers, i)
            end
        end
    end

    if #Module.InGamePlayers == 1 then
        -- print(Module.InGamePlayers[1].Name .. " has won the game!")
        DisableCheckingEvent:FireAllClients()

        -- Teleport all players to the lobby
        for _, player in pairs(Module.InGamePlayers) do
            local SpawnLocation = game.Workspace.SpawnRoom.EndSpawn
            player.Character:PivotTo(SpawnLocation.CFrame)
        end

        -- Display Game Over Screen
        GameOverEvent:FireAllClients(Module.InGamePlayers[1].Name)

        -- Wait 5 seconds before starting the game again
        task.wait(5)
        SystemsContainer.WaitingHandler.StartGameAgain()
        return true
    else
        return false
    end
end

function Module.TagPlayers(localPlayer, entities)
    if not Module.InGame then
        return
    end

    if not (localPlayer.UserId == Module.Hunter.UserId) then
        return
    end

    print(localPlayer.Name .. " tagged " .. entities[1].Name)

    if #entities == 0 then
        return
    end

    if os.clock() - Module.LastTagTime < GameData.TagCoolDown then
        print("Cannot tag for another " .. GameData.TagCoolDown - (os.clock() - Module.LastTagTime) .. " seconds!")
        return
    end

    Module.LastTagTime = os.clock()

    -- Make the nearest player the hunter
    local nearestPlayer = nil
    local nearestDistance = 100000
    for _, player in pairs(entities) do
        if player.UserId == localPlayer.UserId then
            continue
        end

        local distance = localPlayer:DistanceFromCharacter(player.Character:FindFirstChild("HumanoidRootPart", true).CFrame.Position)

        if distance < nearestDistance then
            nearestPlayer = player
            nearestDistance = distance
        end
    end

    -- Make the nearest player the hunter
    if nearestPlayer then
        Module.Hunter = nearestPlayer
    end
end

function Module.SpawnPlayers()
    Module.Hunter = nil
    Module.CurrentTimeForBomb = 0

    -- Get SpawnPoints
    local SpawnPoints = game.Workspace:WaitForChild("SpawnPoints"):GetChildren()


    -- Choose a random spawn point for each player
    local players = game.Players:GetPlayers()

    -- Spawn each player at their spawn point
    for i, player in ipairs(players) do
        local spawnPoint = SpawnPoints[i]
    
        player.Character:PivotTo(spawnPoint.CFrame)
    end

    UpdateInGameGraphicsEvent:FireAllClients("startChoosingHunter")

    -- Choose random hunter
    local randomHunter = players[math.random(1, #players)]
    Module.Hunter = randomHunter

    task.wait(7)

    UpdateInGameGraphicsEvent:FireAllClients("stopChoosingHunter", randomHunter)

    task.wait(4)

    -- Do the last 3 second countdown
    for i = 3, 0, -1 do
        UpdateInGameGraphicsEvent:FireAllClients("updateLastCountdown", i)
        task.wait(1)
    end

    Module.InGamePlayers = players
    Module.InGame = true

    Module.UpdateInGameGui()
end

function Module.Start()
    TagPlayersInRadiusEvent.OnServerEvent:Connect(function(player, entities)
        Module.TagPlayers(player, entities)
    end)
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module