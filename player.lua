local Tools = require 'fabricate.tools'
local Entity = require 'entity'
local Base = require 'base'
local QuestManager = require 'questmanager'
local PaletteSprite = require 'PaletteSprite'

local Player = Tools:Class(Entity)

--	love.graphics.draw(image, 0,0,0,scale,scale,offsetx,offsety)

function Player:init()
	Entity.init(self)

	self.causesCollisionEvents = true

	self.sprite = PaletteSprite:new("player.sprite", "idle_right")

	self.paletteIndex = math.random(8) - 1
	self.sprite.effect:setPaletteIndex(self.paletteIndex)

	return self

end

function Player:setKeys(w,a,s,d)
	self.moveleft = a
	self.moveright = d
	self.moveup = w
	self.movedown = s
end

function Player:logic(dt)
	local speed = 200

	if self.busy then return end

	if self.moveleft then
		self:move(-speed * dt, 0)
	end
	if self.moveright then
		self:move(speed * dt, 0)
	end
	if self.moveup then
		self:move(0, -speed * dt)
	end
	if self.movedown then
		self:move(0, speed * dt)
	end

	self.sprite:update(dt)
end

function Player:handleTouch(other)
	if not self.busy and not other.busy then
		QuestManager:assignQuest(self,other)
	end	
end

function Player:draw()
	love.graphics.push()
	Base.preDraw(self)
	self.sprite:draw()
	love.graphics.pop()
end


return Player