local Tools = require 'fabricate.tools'
local Entity = require 'entity'

local Player = Tools:Class(Entity)

function Player:init()
	Entity.init(self)

	self.causesCollisionEvents = true

	return self

end

return Player