local soundIdToName = {
	"ExplosionBarrel",
	"Shoot"
}

setmetatable(soundIdToName, {
	__index = function(_, i)
		error(string.format("%q is not a valid member of soundIdToName", tostring(i)))
	end
})

local soundNameToId = setmetatable({}, {
	__index = function(_, i)
		error(string.format("%q is not a valid member of soundNameToId", tostring(i)))
	end
})

for id, name in ipairs(soundIdToName) do
	soundNameToId[name] = id
end

local Sound = setmetatable({
	IdToName = soundIdToName,
	NameToId = soundNameToId,
}, {
	__index = soundNameToId
})

return Sound
