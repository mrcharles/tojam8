local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local StairsDown = Tools:Class(GameObject)

function StairsDown:init(world, shape, x, y)
	GameObject.init(self,world,shape,x,y)

	self.resolves = false

	self.sprite = PaletteSprite:new("specialtiles.sprite", "stairwell_down")

	return self
end

function StairsDown:handleTouch(other)
	print("GOING DOWN!")
	if other:isA(Player) then
		self.world:changeLevel(-1)
	end
	--self.world:switch
end

function StairsDown:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return StairsDown