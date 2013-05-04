local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'

local StairsDown = Tools:Class(GameObject)

function StairsDown:init(world, shape)
	GameObject.init(self,world,shape)

	self.resolves = true

	return self
end

function StairsDown:handleTouch(other)
	print("GOING DOWN!")
	self.world:changeLevel(-1)
	--self.world:switch
end

return StairsDown