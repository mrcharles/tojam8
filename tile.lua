local Tools = require 'fabricate.tools'

local Tile = Tools:Class()

local validFields = Tools:dict(
	"color",
	"walkable",
	"border",
	"collisionEvent",
	"door",
	"class"
)

function Tile:init(type, desc)

	self.type = type

	for k,v in pairs(desc) do
		assert(validFields:has(k), string.format("invalid tile parameter '%s'", k))
		self[k] = v
	end

	return self
end

function Tile:drawAt(x,y,size)
	if self.color then
		local x,y = (x-1) * size, (y-1) * size

		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill",x,y,size,size)
	end
end

return Tile