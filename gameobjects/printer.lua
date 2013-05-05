local Tools = require 'fabricate.tools'

local GameObject = require 'gameobject'
local Player = require 'player'

local Printer = Tools:Class(GameObject)

function Printer:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "printer"
	return self
end

function Printer:handleTouch(other)
	print("touched printer")

	if other:isA(Player) then
		other:handleTouch(self)
	end
end

function Printer:draw()
	love.graphics.setColor(0,0,0)

	love.graphics.rectangle("fill", self.x, self.y, 32,32)
end

return Printer