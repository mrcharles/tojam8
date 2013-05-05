local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local Printer = Tools:Class(GameObject)

function Printer:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "computer"

	self.sprite = PaletteSprite:new("specialtiles.sprite", "computer")

	return self
end

function Printer:handleTouch(other)
	print("touched computer")

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