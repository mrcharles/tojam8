local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'

local Printer = Tools:Class(GameObject)

function Printer:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )

	return self
end

function Printer:handleTouch(other)
	print("touched printer")
end

return Printer