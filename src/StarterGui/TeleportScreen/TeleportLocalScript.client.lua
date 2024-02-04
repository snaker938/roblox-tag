-- local tweenService = game:GetService("TweenService")
-- local tweenInfo = TweenInfo.new(1)
-- local tween1 = tweenService:Create(game.Lighting.Blur, tweenInfo, {["Size"] = 24})
-- local tween2 = tweenService:Create(game.Lighting.Blur, tweenInfo, {["Size"] = 0})


-- game.ReplicatedStorage.TeleportEvent.OnClientEvent:Connect(function()
-- 	tween1:Play()
-- 	script.Parent.Enabled = true
-- 	game.Players.LocalPlayer.PlayerGui.LoadCharacter.Enabled = false
-- 	game.Players.LocalPlayer.PlayerGui.CharacterCreation.Enabled = false
-- 	task.wait(10)
-- 	script.Parent.Enabled = false
-- 	tween2:Play()
-- 	game.Players.LocalPlayer.PlayerGui.LoadCharacter.Enabled = true
-- 	game.Players.LocalPlayer.PlayerGui.CharacterCreation.Enabled = true
-- end)