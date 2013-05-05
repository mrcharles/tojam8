local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local Computer = Tools:Class(GameObject)

function Computer:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "printer"

	self.sprite = PaletteSprite:new("specialtiles.sprite", "computer")

	return self
end

function Cpmputer:handleTouch(other)
	print("touched Cpmputer")

	if other:isA(Player) then
		other:handleTouch(self)
	end
end

function Cpmputer:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return Cpmputer