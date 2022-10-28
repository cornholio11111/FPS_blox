local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)

local ParticleController = Knit.CreateController({
	Name = "ParticleController",
})

function ParticleController:CreateParticle(TextureID, TextureSpeed, TextureAmount, TextureSize, TextureLifeTime, Parent, waitTimer)
	local Particle = Instance.new("ParticleEmitter")
	Particle.Texture = TextureID
	Particle.Speed = TextureSpeed
	Particle.Rate = TextureAmount
	Particle.Size = TextureSize
	Particle.Lifetime = TextureLifeTime
	Particle.Parent = Parent
	task.wait(waitTimer)
	Particle:Destroy()
end

function ParticleController.CreateMuzzleFlash(Parent, waitTimer)
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Name = "Muzzle"
	BillboardGui.Brightness = 15
	BillboardGui.Enabled = true
	BillboardGui.Size = UDim2.new(1,0,1,0)
	
	local ImageLabelFlare = Instance.new"ImageLabel"
	ImageLabelFlare.Name = "Flare"
	ImageLabelFlare.Size = UDim2.new(0,20,0,20)
	ImageLabelFlare.BackgroundTransparency = 1
	ImageLabelFlare.Position = UDim2.new(0.5,-10,0.5,-10)
	ImageLabelFlare.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabelFlare.Image = "http://www.roblox.com/asset/?id=172125333"
	ImageLabelFlare.Parent = BillboardGui
	ImageLabelFlare.Visible = true
	
	local ImageLabelSpark = Instance.new"ImageLabel"
	ImageLabelSpark.Name = "Spark"
	ImageLabelSpark.ZIndex = 2
	ImageLabelSpark.Visible = true
	ImageLabelSpark.Size = UDim2.new(0,200,0,200)
	ImageLabelSpark.BackgroundTransparency = 1
	ImageLabelSpark.Position = UDim2.new(0.5,-100,0.5,-100)
	ImageLabelSpark.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabelSpark.Image = "http://www.roblox.com/asset/?id=172138011"
	ImageLabelSpark.Parent = BillboardGui
	
	local MuzzleLight = Instance.new("PointLight")
	MuzzleLight.Name = "MuzzleLight"
	MuzzleLight.Shadows = true
	MuzzleLight.Color = Color3.fromRGB(255,191,101)
	MuzzleLight.Brightness = .5
	MuzzleLight.Range = 20
	MuzzleLight.Parent = Parent

	BillboardGui.Parent = Parent
	task.wait(waitTimer)
	Parent:ClearAllChildren()
end

function ParticleController:KnitInit()
	warn('[DEBUG] Loaded Controller: ParticleController')
end

return ParticleController