local Tools = require 'fabricate.tools'
local PaletteSprite = require 'PaletteSprite'
local GameObject = require 'gameobject'
local Player = require 'player'

local Plant = Tools:Class(GameObject)

function Plant:init(world, shape, x, y)
	GameObject.init(self,world,shape, x,y )
	self.type = "plant"

	local frames = {
		"plant1",
		"plant2",
		"plant3"
	}
	self.sprite = PaletteSprite:new("specialtiles.sprite", frames[math.random(#frames)])
	
	return self
end

function Plant:handleTouch(other)
	if other:isA(Player) then
		print('touch plant')
		other:handleTouch(self)
	end
end

function Plant:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	self.sprite:draw()

	love.graphics.pop()

end

return Plant