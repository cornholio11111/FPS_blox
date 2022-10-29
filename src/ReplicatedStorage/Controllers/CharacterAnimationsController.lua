-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerServices = game:GetService('ServerStorage')

local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Animations = Assets:WaitForChild("Animations")

local AnimationsController = Knit.CreateController({
	Name = "CharacterAnimations",
	Animator = nil,
	LoadedAnimations = {},
})

function AnimationsController:ClearLoadedAnimations()
	table.clear(self.LoadedAnimations)
end

function AnimationsController:SetAnimator(selfAnimator)
	AnimationsController.Animator = selfAnimator
end

function AnimationsController:AddAnimation(Animation)
	assert(self.Animator, "Animator doesn't exist")
	if not table.find(AnimationsController.LoadedAnimations, Animation.Name) then
		self.LoadedAnimations[Animation.Name] = self.Animator:LoadAnimation(Animation)
	end
end

function AnimationsController:PlayAnimation(animationName, loop)
	local Animation = assert(self.LoadedAnimations[animationName],
		string.format("invalid animation name \"%s\"", animationName))
	Animation.Looped = loop
	Animation:Play()
end


function AnimationsController:StopAnimation(animationName)
	local Animation = assert(self.LoadedAnimations[animationName],
		string.format("invalid animation name \"%s\"", animationName))
	Animation:Stop()
end

function AnimationsController:StopAllAnimations()
	for _, Animation in pairs(self.LoadedAnimations) do
		Animation:Stop()
	end
end


function AnimationsController:StopAllAnimationsAndPlay(animationPlayName, loop)
	for _, Animation in pairs(self.LoadedAnimations) do
		Animation:Stop()
	end

	local PlayAnimation = assert(self.LoadedAnimations[animationPlayName],
		string.format("invalid animation name \"%s\"", animationPlayName))
	PlayAnimation.Looped = loop
	PlayAnimation:Play()
end

function AnimationsController:LoadAllAnimations()
	table.clear(self.LoadedAnimations)
	for _, AnimationInstance in pairs(Animations:GetDescendants()) do -- Load All Animations
		if AnimationInstance:IsA("Animation") then
			AnimationsController:AddAnimation(AnimationInstance)
		end
	end
end

return AnimationsController