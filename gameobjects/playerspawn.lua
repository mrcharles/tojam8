local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'

local PlayerSpawn = Tools:Class(GameObject)

function PlayerSpawn:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )

	self.resolves = false

	return self
end

return PlayerSpawn