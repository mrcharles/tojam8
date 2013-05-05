Gamestate = require 'hump.gamestate'

local Tools = require 'fabricate.tools'
local Map = require 'fabricate.map'
local Button = require "fabricate.button"
local Building = require 'building'
local Player = require 'player'
local Dialog = require 'dialog'
local QuestManager = require 'questmanager'

local title = Gamestate.new()
local game = Gamestate.new()

gameover = Gamestate.new()

--debugDraw = true
 
function title:init()
	self.titlefont = love.graphics.newFont("assets/SpecialElite.ttf", 72)
	self.buttonfont = love.graphics.newFont("assets/SpecialElite.ttf", 48)

	self.newgamebutton = Button("New Game", self.buttonfont, 700, 400, "right", {normal = {0,0,0}, hover = {50,50,50}}, "return")
	self.newgamebutton.pressaction = function(button)
		Gamestate.switch(game)
	end
end

function title:update(dt)

end

function title:enter()
	love.graphics.setBackgroundColor(255,255,255)
	self.newgamebutton:register()

end

function title:leave()
	self.newgamebutton:unregister()
end

function title:quit()

end

function title:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(self.titlefont)
	love.graphics.push()
	local jitter = 3
	love.graphics.translate( math.random(-jitter,jitter), math.random(-jitter,jitter))
	love.graphics.printf("The Office Event", 50,150, 800, "left")

	love.graphics.pop()
	Button:draw()
end

function game:init() --called only once

end

function game:leaveFloor()
	self.world:removeEntity(self.player)
	self.world:leave()
	self.world = nil
end

function game:enterFloor(level, dir)
	self.currentfloor = level
	self.world = self.building:getFloorWorld(level)
	self.player:setPos(0,0)
	print("dir",dir)
	self.world:enter(self.player, {-10,-15, 20,30}, dir)

	if self.player.level == level then -- initiate main quest
		QuestManager:mainQuest(level, self.player)
	end

	self.world:setFocus(self.player)

	self.world.changeLevel = function( world, dir )
			if self.currentfloor + dir <= self.player.level then
				self:leaveFloor()
				self:enterFloor(self.currentfloor + dir, dir)
			end
		end


end

function game:enter(prev)
	self.building = Building:new(24,24, 4, "office")
	self.player = Player:new()

	self:enterFloor(1, 0)

end

function game:leave()
	self:leaveFloor()
	self.building = nil
	self.player = nil
end

function game:update(dt)
	local player = self.player

	local speed = 200
	local player = self.player

	player:setKeys(	love.keyboard.isDown("w"),
					love.keyboard.isDown("a"),
					love.keyboard.isDown("s"),
					love.keyboard.isDown("d") )

	-- if love.keyboard.isDown("down") then
	-- 	self.world.camera.zoom = self.world.camera.zoom * 0.99
	-- elseif love.keyboard.isDown("up") then
	-- 	self.world.camera.zoom = self.world.camera.zoom * 1.01
	-- end

	Dialog:update(dt)
	self.world:update(dt)
end

function game:draw()
	self.world:draw()

	Dialog:draw()
	Button:draw()
end

function gameover:init()
	self.titlefont = love.graphics.newFont("assets/SpecialElite.ttf", 72)
	self.buttonfont = love.graphics.newFont("assets/SpecialElite.ttf", 48)

	self.newgamebutton = Button("Well, shit.", self.buttonfont, 700, 400, "right", {normal = {0,0,0}, hover = {50,50,50}}, "return")
	self.newgamebutton.pressaction = function(button)
		Gamestate.switch(title)
	end
end

function gameover:enter(_, msg)
	love.graphics.setBackgroundColor(255,255,255)
	self.newgamebutton:register()
	self.msg = msg
end

function gameover:leave()
	self.newgamebutton:unregister()
end

function gameover:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(self.titlefont)
	love.graphics.push()
	local jitter = 3
	love.graphics.translate( math.random(-jitter,jitter), math.random(-jitter,jitter))
	love.graphics.printf(self.msg, 50,150, 800, "left")

	love.graphics.pop()
	Button:draw()
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(title)
end

function love.mousepressed(x,y,btn)


	Button:handlepress(x,y)
end

function love.keyreleased(key)
	Button:handlekey(key)
end

function love.mousereleased(x,y,btn)

	Button:handlerelease(x,y)
end

function love.update(dt)

end

function love.draw()

end
