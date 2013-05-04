local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'

local StairsUp = Tools:Class(GameObject)

function StairsUp:init(world, shape)
	GameObject.init(self,world,shape)

	self.resolves = false

	return self
end

function StairsUp:handleTouch(other)
	print("GOING UP!")
end

return StairsUp