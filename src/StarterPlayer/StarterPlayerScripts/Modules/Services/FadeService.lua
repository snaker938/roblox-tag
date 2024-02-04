local SystemsContainer = {}

local Module = {}

function Module.Fade(BlackScreenHolder, startGUI, endGUI, timeOfFade)
	local TweenService = game:GetService("TweenService")
	startGUI.Enabled = false
	local BlackScreen = BlackScreenHolder:WaitForChild("BlackScreen")
	
	BlackScreenHolder.Enabled = true
	local fade = TweenService:Create(BlackScreen, TweenInfo.new(timeOfFade, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
	fade:Play()
	fade.Completed:Connect(function()
		BlackScreenHolder.Enabled = false
		endGUI.Enabled = true
		BlackScreen.BackgroundTransparency = 0
		fade:Destroy()
	end)
end

function Module.Start()
    
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end


return Module