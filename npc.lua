local Tools = require 'fabricate.tools'
local Vector = require 'hump.vector'

local Entity = require 'entity'

local NPC = Tools:Class(Entity)

function NPC:init(class)
	Entity.init(self)

	self.class = class

	return self
end

function NPC:logic(dt)
	--random movement

	if self.busy then return end

	if self.cooldown then 
		self.cooldown = self.cooldown - dt
		if self.cooldown <= 0 then
			self.cooldown = nil
		end
	end

	if not self.movetime then
		self.movetime = 1 + math.random() * 2
		self.dir = Vector( math.random() * 2 - 1, math.random() * 2 - 1 )
		self.speed = 50 + math.random() * 70
	else

		self.movetime = self.movetime - dt

		if self.movetime > 0 then 
			local delta = self.dir * self.speed * dt
			self:move(delta.x, delta.y)
		else
			self.movetime = nil
		end
	end

end

function NPC:draw()
	love.graphics.push()
	Entity.preDraw(self)

	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill", -10, -15, 20, 30)

	love.graphics.pop()
end

return NPC