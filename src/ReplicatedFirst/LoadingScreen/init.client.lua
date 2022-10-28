-- IndieFlare / cornholio11111

script.Parent:RemoveDefaultLoadingScreen()

local TS = game:GetService("TweenService")
local tinfo = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
PlayerGui:SetTopbarTransparency(0)

local GUI = script.LoadingScreen:Clone()
GUI.Parent = PlayerGui

local currentAssets = 0
local maxAssets = 4151

local give = false
local give2 = false
local give3 = false

local frame = GUI:WaitForChild("LoadingScreen")
local info = frame:WaitForChild("Info")
local loadedAssetsLabel = info.LoadedAssets
local assetsLeftLabel = info.AssetsLeft

while currentAssets < maxAssets do
	loadedAssetsLabel.Text = "Assets Loaded: "..currentAssets
	assetsLeftLabel.Text = "Assets Left: "..(maxAssets-currentAssets)
	
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	
	if currentAssets >= 50 and give == false then
		currentAssets += math.round(math.random(900, 2000))
		give = true
	elseif currentAssets >= 1200 and give2 == false then
		currentAssets += math.round(math.random(900, 2000))
		give2 = true
	elseif currentAssets >= 2200 and give3 == false then
		currentAssets += math.round(math.random(990, 2000))
		give3 = true
	end
	
	if currentAssets >= maxAssets and game:IsLoaded() then
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		PlayerGui:SetTopbarTransparency(1)
		GUI:Destroy()
		break
	elseif currentAssets <= maxAssets then
		currentAssets += 1
	end
	
	task.wait(math.random(0, 0.05))
end

if currentAssets >= maxAssets then
	print("Fixing Loading Bug!")
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	PlayerGui:SetTopbarTransparency(1)
	GUI:Destroy()
end