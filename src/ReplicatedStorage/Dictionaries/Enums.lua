local EnumList = require(game:GetService("ReplicatedStorage"):WaitForChild("EnumList"))

local Enums = {
	FireMode = EnumList.new("FireMode", {
		"Auto",
		"Triple",
		"Double",
		"Single"
	}),

	AmmoType = EnumList.new("AmmoType", {
		"Basic",
		"Power",
	})
}

setmetatable(Enums, {
	__index = function(_, i)
		error(string.format("%q is not a valid member of Enums", tostring(i)))
	end
})

return Enums