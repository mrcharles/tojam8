local Tools = require 'fabricate.tools'

local GameObject = Tools:Class()

function GameObject:init(world, shape)
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
			print("touch")
			self:handleTouch(other)
		end
	end
end

function GameObject:onCollideEnd(other)
	self.activeCollisions[other] = nil
end

return GameObject