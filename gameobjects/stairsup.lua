local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'

local StairsUp = Tools:Class(GameObject)

function StairsUp:init(world, shape)
	GameObject.init(self,world,shape)

	self.resolves = true

	return self
end

function StairsUp:handleTouch(other)
	print("GOING UP!")
	self.world:changeLevel(1)
	--self.world:switch
end

return StairsUp