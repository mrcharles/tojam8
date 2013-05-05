local Tools = require 'fabricate.tools'
local Vector = require 'hump.vector'
local TextBubble = require 'textbubble'
local Entity = require 'entity'
local PaletteSprite = require 'PaletteSprite'

local NPC = Tools:Class(Entity)

function NPC:init(class)
	Entity.init(self)

	self.class = class

	self.randIndex = math.random(5) - 1
	self.sprite = PaletteSprite:new("npc.sprite", "characters_000"..self.randIndex.."_Layer")
	
	self.paletteIndex = math.random(8) - 1
	self.sprite.effect:setPaletteIndex(self.paletteIndex)

	return self
end

function NPC:say(text)
	self.bubble = TextBubble:new(0,-25, text)
	self.bubbletime = 2
end

function NPC:logic(dt)
	--random movement

	if self.busy then return end

	if self.bubble then
		self.bubbletime = self.bubbletime - dt
		if self.bubbletime <= 0 then
			self.bubble = nil
			self.bubbletime = nil
		end
	end

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
	love.graphics.translate(0,13)
	self.sprite:draw()

	love.graphics.pop()

	
end

function NPC:drawWorldUI()
	love.graphics.push()
	Entity.preDraw(self)

	if self.bubble then
		self.bubble:draw()

	end

	love.graphics.pop()
end

return NPC