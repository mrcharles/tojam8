local Tools = require 'fabricate.tools'
local Vector = require 'hump.vector'

local Base = Tools:Class()

function Base:init()
	self.pos = Vector(0,0)
	return self
end

function Base:setPos(x,y)
	if self.shape then
		--get offset
		local offset = self.pos - Vector(self.shape:center())
		self.pos = Vector(x,y)
		self.shape:moveTo( x + offset.x, y + offset.y)
	else
		self.pos = Vector(x,y)
	end
end

function Base:move(x,y)
	self.lastmove = Vector(x,y)
	self.pos = self.pos + Vector(x,y)

	if self.shape then
		self.shape:move(x,y)
	end
end

function Base:update(dt)
	if self.physics then
		self:physics(dt)
	end
	if self.logic then
		self:logic(dt)
	end
end

function Base:preDraw()
	if debugDraw then
		if self.shape then
			love.graphics.setColor(255,0,0)
			self.shape:draw("line")
		end

	end
	love.graphics.translate(self.pos.x, self.pos.y)
end

return Base