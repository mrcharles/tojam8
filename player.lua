local Tools = require 'fabricate.tools'
local Entity = require 'entity'

local Player = Tools:Class(Entity)


--	love.graphics.draw(image, 0,0,0,scale,scale,offsetx,offsety)

function Player:init()
	Entity.init(self)

	self.causesCollisionEvents = true

	return self

end



return Player