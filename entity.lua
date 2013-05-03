local Base = require 'base'
local Tools = require 'fabricate.tools'

local Entity = Tools:Class(Base)

function Entity:init()
	Base.init(self)

	return self
end

function Entity:draw()
	love.graphics.push()
	Base.preDraw(self)

	love.graphics.pop()
end

return Entity