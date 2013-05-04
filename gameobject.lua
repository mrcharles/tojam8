local Tools = require 'fabricate.tools'

local GameObject = Tools:Class()

function GameObject:init(world, shape, color, drawparams)
	self.world = world
	self.shape = shape
	self.color = color
	self.drawparams = drawparams

	return self
end

function GameObject:draw()

end

return GameObject