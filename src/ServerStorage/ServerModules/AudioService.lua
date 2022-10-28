local Packages = game:GetService("ReplicatedStorage").Packages
local Knit = require(Packages.Knit)

local Players = game:GetService("Players")

local AudioService = Knit.CreateService {
	Name = "AudioService", 
	Client = {
		PlayAudio = Knit.CreateSignal(),
	}
}

function AudioService:KnitInit()
	self.Client.PlayAudio:Connect(function(Player, Audio, SoundClip, ParentPos)
		local Parent = Instance.new("Part")
		Parent.Position = ParentPos + Vector3.new(0, 3, 0)
		Parent.Anchored = true
		Parent.CanCollide = false
		Parent.CanQuery = false
		Parent.CanTouch = false
		Parent.Transparency = 1
		Parent.Parent = workspace.ActiveObjects
		
		local Sound
		
		if SoundClip == true then
			Sound = Audio:Clone()
		else
			Sound = Instance.new("Sound")
			Sound.SoundId = Audio
			Sound.Volume = .2
		end
		
		if ParentPos ~= nil then
			Sound.Parent = Parent
		else
			Sound.Parent = workspace
		end
		
		Sound:Play()
		task.wait(Sound.TimeLength)
		Parent:Destroy()
	end)

end	

function AudioService:KnitStart()

	warn('[DEBUG] Loaded Service: ViewModelService')
end

return AudioService