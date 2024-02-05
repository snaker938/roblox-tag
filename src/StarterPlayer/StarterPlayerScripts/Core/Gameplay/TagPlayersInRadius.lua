local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local RemoteService = ReplicatedModules.Services.RemoteService


local TagPlayersInRadiusEvent = RemoteService:GetRemote("TagPlayersInRadiusEvent", "RemoteEvent", false)

local DisableCheckingEvent = RemoteService:GetRemote("DisableCheckingEvent", "RemoteEvent", false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.CheckingForPlayers = false

function Module.getPlayersInRadius(radius)
	local entities = {}

    local players = game.Players:GetPlayers()
	
	for _, player in pairs(players) do
        if player == LocalPlayer then
            continue
        end

        local distance = LocalPlayer:DistanceFromCharacter(player.Character:FindFirstChild("HumanoidRootPart", true).CFrame.Position)

        if distance <= radius then
            table.insert(entities, player)
        end
	end

	return entities
end

function Module.Start()
    RunService.Heartbeat:Connect(function()
        if not Module.CheckingForPlayers then
            return
        end
    
        local entities = Module.getPlayersInRadius(25)

        if #entities == 0 then
            return
        end

        TagPlayersInRadiusEvent:FireServer(entities)

        task.wait(1)
    end)

    DisableCheckingEvent.OnClientEvent:Connect(function()
        Module.CheckingForPlayers = false
    end)
end


function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module