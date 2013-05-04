local Tools = require 'fabricate.tools'

local Tile = Tools:Class()

local validFields = Tools:dict(
	"color",
	"walkable",
	"border",
	"collisionEvent",
	"door"
)

function Tile:init(type, desc)

	self.type = type

	for k,v in pairs(desc) do
		assert(validFields:has(k), string.format("invalid tile parameter %s", k))
		self[k] = v
	end

	return self
end

return Tile