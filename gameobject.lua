local Tools = require 'fabricate.tools'

local GameObject = Tools:Class()

function GameObject:init(world, shape, x, y)
	self.x = x
	self.y = y
	self.world = world
	self.shape = shape
	shape.gameobject = self
	self.activeCollisions = {}

	self.resolves = true

	return self
end

function GameObject:onCollideStart(other)
	if not self.activeCollisions[other] then
		self.activeCollisions[other] = true
		if self.handleTouch then
			if self.active then
				self:handleTouch(other)
			end
		end
	end
end

function GameObject:onCollideEnd(other)
	self.activeCollisions[other] = nil
end

return GameObject