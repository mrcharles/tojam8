local Tools = require 'fabricate.tools'
local PlainSprite = require 'PlainSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local Printer = Tools:Class(GameObject)

function Printer:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "printer"

	self.sprite = PlainSprite:new("specialtiles.sprite", "printer")
	
	return self
end

function Printer:handleTouch(other)
	if other:isA(Player) then
		other:handleTouch(self)
	end
end

function Printer:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return Printer