local Tools = require 'fabricate.tools'
local Entity = require 'entity'
local Base = require 'base'
local QuestManager = require 'questmanager'
local PaletteSprite = require 'PaletteSprite'
local TextBubble = require 'textbubble'
local NPC = require 'npc'

local Player = Tools:Class(Entity)

local questx, questy = 20, 20
local questheight, widthpersec = 30, 50
local questspace = 10

--	love.graphics.draw(image, 0,0,0,scale,scale,offsetx,offsety)

function Player:init()
	Entity.init(self)

	self.causesCollisionEvents = true
	self.competency = 100

	self.sprite = PaletteSprite:new("player.sprite", "idle_right")
	
	self.paletteIndex = math.random(8) - 1
	self.sprite.effect:setPaletteIndex(self.paletteIndex)

	self.quests = {}

	return self

end

function Player:setKeys(w,a,s,d)
	self.moveleft = a
	self.moveright = d
	self.moveup = w
	self.movedown = s
end

function Player:changeCompetency(delta)
	self.competency = self.competency + delta

	if self.competency <= 0 then
		self:getFired()
	end

end

function Player:getFired()
	Gamestate.switch(gameover, "You're Fired!")
end

function Player:addQuest(quests)
	table.insert(self.quests, quests)

	table.sort( self.quests, function(a,b) return a.timeleft > b.timeleft end)
end

function Player:say(text)
	self.bubble = TextBubble:new(0,-25, text)
	self.bubbletime = 1
end

function Player:logic(dt)
	local speed = 200

	if self.bubble then
		self.bubbletime = self.bubbletime - dt
		if self.bubbletime <= 0 then
			self.bubble = nil
			self.bubbletime = nil
		end
	end

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

	for i,quest in ipairs(self.quests) do
		quest:update(dt)
	end

	--remove dead quests

	local i = 1

	while i <= #self.quests do 
		if self.quests[i].complete then
			table.remove(self.quests, i)
		else
			i = i + 1
		end
	end

	--zoom

	local height = questy + #self.quests * (questheight + questspace)

	if height > 600 then
		self.zoom = 600 / height

		self.world.camera.zoom = self.zoom
	else
		self.zoom = 1
		self.world.camera.zoom = 1
	end

	self.sprite:update(dt)
end

function Player:handleTouch(other)
	for i,q in ipairs(self.quests) do
		q:testResolve(other)
	end

	if not self.busy and other:isA(NPC) and not other.busy then
		QuestManager:assignQuest(self,other)
	end	
end

function Player:draw()
	love.graphics.push()
	Base.preDraw(self)

	love.graphics.translate(0,13)
	self.sprite:draw()
	love.graphics.setPixelEffect()

	love.graphics.pop()
end

function Player:drawWorldUI()
	love.graphics.push()
	Entity.preDraw(self)

	if self.bubble then
		self.bubble:draw()

	end

	love.graphics.pop()
end

function Player:drawUI()

	--sort quests by time left

	local x, y = questx, questy

	for i,q in ipairs(self.quests) do
		
		love.graphics.setColor( 0, 0, 255 )
		love.graphics.rectangle("fill", x, y, q.timeleft * widthpersec, questheight * self.zoom) 

		love.graphics.setColor( 0, 0, 0 )
		love.graphics.rectangle("line", x, y, q.timeleft * widthpersec, questheight * self.zoom) 
		y = y + (questheight + questspace) * self.zoom
	end

end

return Player