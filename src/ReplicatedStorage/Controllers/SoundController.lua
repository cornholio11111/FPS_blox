local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage:WaitForChild("Dictionaries"):WaitForChild("Sounds"))
local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)

local SoundHandler = Knit.CreateController({
	Name = "Sound",
})

local idList = {}
function SoundHandler:RegisterSound(id, soundId)
	idList[id] = soundId
end

local LocalPlayer = game:GetService("Players").LocalPlayer
function SoundHandler:Play(id, core)
	local soundId = assert(idList[id], string.format("unregistered effect id \"%s\"", tostring(id)))
	local distance = LocalPlayer:DistanceFromCharacter(core.Position)
	local sound = Instance.new("Sound", core)
	sound.SoundId = soundId
	sound:Play()
	sound.Ended:wait()
	core:Destroy()
end

SoundHandler:RegisterSound(Sounds.ExplosionBarrel, "rbxassetid://7043920403")
SoundHandler:RegisterSound(Sounds.Shoot, "rbxassetid://5631260448")

return SoundHandler