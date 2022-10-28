--[[
	Remember -- A "Caster" represents an entire gun (or whatever is launching your projectiles), *NOT* the individual bullets.
	Make the caster once, then use the caster to fire your bullets. Do not make a caster for each bullet.
--]]

shared.FastCastVisualize = false
shared.FastCastDebug = false

local FastCast = {}
FastCast.__index = FastCast
FastCast.__type = "FastCast"

FastCast.HighFidelityBehavior = {
	Default = 1,
	Always = 3
}

local ActiveCast = require(script.ActiveCast)
local Signal = require(game:GetService("ReplicatedStorage").Signal)

-- This will inject all types into this context.
local TypeDefs = require(script.TypeDefinitions)
type CanPierceFunction = TypeDefs.CanPierceFunction
type GenericTable = TypeDefs.GenericTable
type Caster = TypeDefs.Caster
type FastCastBehavior = TypeDefs.FastCastBehavior
type CastTrajectory = TypeDefs.CastTrajectory
type CastStateInfo = TypeDefs.CastStateInfo
type CastRayInfo = TypeDefs.CastRayInfo
type ActiveCast = TypeDefs.ActiveCast

ActiveCast.Initalize(FastCast)


--[[
		Exports
--]]


local registeredBehaviors = {}

function FastCast.new()
	local self = setmetatable({}, FastCast)
	self.LengthChanged = Signal.new("LengthChanged")
	self.RayHit = Signal.new("RayHit")
	self.RayPierced = Signal.new("RayPierced")
	self.CastTerminating = Signal.new("CastTerminating")
	return self
end

function FastCast:Destroy()
	self.LengthChanged:Destroy()
	self.RayHit:Destroy()
	self.RayPierced:Destroy()
	self.CastTerminating:Destroy()
	setmetatable(self, nil)
end

function FastCast:NewBehavior(name): FastCastBehavior
	local behavior = {
		RaycastParams = nil,
		Acceleration = Vector3.new(),
		MaxDistance = 1000,
		CanPierceFunction = nil,
		HighFidelityBehavior = FastCast.HighFidelityBehavior.Default,
		HighFidelitySegmentSize = 0.5,
		CosmeticBulletTemplate = nil,
		CosmeticBulletProvider = nil,
		CosmeticBulletContainer = nil,
		AutoIgnoreContainer = true
	}
	
	registeredBehaviors[name] = behavior
	return behavior
end

function FastCast:GetBehavior(name): FastCastBehavior
	assert(name, "Missing behavior name")
	return registeredBehaviors[name]
end


--do -- Behavior precreation
--	local ActiveObjects = workspace.ActiveObjects
	
	
--	local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--	local EntitiesService = Knit.GetService("EntitiesService")
--	local PlayerService = Knit.GetService("PlayerService")
	
--	local function fireDamageHitSignal(cast)
--		PlayerService.Client.DamageHitSignal:Fire(cast.UserData.Weapon.PlayerClass.PlayerObject)
--	end
	
--	local function DefaultCanPierceFunction(cast, raycastResult)
--		if raycastResult.Instance:IsDescendantOf(ActiveObjects) then
--			return true
--		end
		
--		local hitPart = raycastResult.Instance
		
--		local isEntity = EntitiesService:IsEntity(hitPart)
--		if isEntity then
--			local isPierceable = EntitiesService:IsPierceable(hitPart)
			
--			local hitPoint = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
--			if EntitiesService:Hit(hitPart, raycastResult.Position) then
--				fireDamageHitSignal(cast)
--			end
			
--			return isPierceable
--		end
		
--		return false
--	end
	
--	local PartCache = require(script.Parent.PartCache)
--	local ZERO_VECTOR3 = Vector3.new()
	
--	local DefaultRaycastParamsIgnoreWater = RaycastParams.new()
--	DefaultRaycastParamsIgnoreWater.IgnoreWater = true
--	DefaultRaycastParamsIgnoreWater.FilterType = Enum.RaycastFilterType.Blacklist
--	DefaultRaycastParamsIgnoreWater.FilterDescendantsInstances = {}
	
--	local TestBullet = FastCast:NewBehavior("Bullet")
--	TestBullet.RaycastParams = DefaultRaycastParamsIgnoreWater
--	TestBullet.Speed = 1000
--	TestBullet.MaxDistance = 1000
--	TestBullet.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default
--	TestBullet.CosmeticBulletProvider = PartCache:GetCache("Bullet")
--	TestBullet.CosmeticBulletContainer = ActiveObjects
--	TestBullet.Acceleration = ZERO_VECTOR3
--	TestBullet.Spread = 1
--	TestBullet.AutoIgnoreContainer = false
--	TestBullet.CanPierceFunction = DefaultCanPierceFunction
	
--	local TestGrenade = FastCast:NewBehavior("Grenade")
--	TestGrenade.RaycastParams = DefaultRaycastParamsIgnoreWater
--	TestGrenade.Speed = 130
--	TestGrenade.MaxDistance = 500
--	TestGrenade.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default
--	TestGrenade.CosmeticBulletProvider = PartCache:GetCache("Grenade")
--	TestGrenade.CosmeticBulletContainer = ActiveObjects
--	TestGrenade.Acceleration = Vector3.new(0, -workspace.Gravity, 0)
--	TestGrenade.Spread = 1
--	TestGrenade.AutoIgnoreContainer = false
--	TestGrenade.CanPierceFunction = DefaultCanPierceFunction
--end

function FastCast:Fire(weapon, origin: Vector3, direction: Vector3, castDataPacketName: string): ActiveCast
	local castDataPacket = assert(FastCast:GetBehavior(castDataPacketName),
		string.format("Missing behavior with name \"%s\"", castDataPacketName))
	
	local velocity = castDataPacket.Speed
	local spread = castDataPacket.Spread * (weapon.Spread or 1)
	
	direction = Vector3.new(
		direction.X + (math.random() * spread) / 1000,
		direction.Y + (math.random() * spread) / 1000,
		direction.Z + (math.random() * spread) / 1000
	)
	
	return ActiveCast.new(self, weapon, origin, direction, velocity, castDataPacket)
end

return FastCast