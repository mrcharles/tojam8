local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local Garbage = Tools:Class(GameObject)

function Garbage:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "garbage"

	self.sprite = PaletteSprite:new("specialtiles.sprite", "trashcan")
	
	return self
end

function Garbage:handleTouch(other)
	print("touched Garbage")

	if other:isA(Player) then
		other:handleTouch(self)
	end
end

function Garbage:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return Garbage