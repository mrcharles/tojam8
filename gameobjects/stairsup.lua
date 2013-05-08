local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'
local StairsUp = Tools:Class(GameObject)

function StairsUp:init(world, shape, x, y )
	GameObject.init(self,world,shape, x, y)

	self.resolves = false

	self.sprite = PaletteSprite:new("specialtiles.sprite", "stairwell_up")

	return self
end

function StairsUp:handleTouch(other)
	print("GOING UP!")
	if other:isA(Player) then
		other.nextlevelenabled = nil
		self.world:changeLevel(1)
	end
	--self.world:switch
end

function StairsUp:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return StairsUp