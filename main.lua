Gamestate = require 'hump.gamestate'

local Tools = require 'fabricate.tools'
local Map = require 'fabricate.map'
local Button = require "fabricate.button"
local Building = require 'building'
local Entity = require 'entity'

local title = Gamestate.new()
local game = Gamestate.new()

debugDraw = true
 
function title:init()
	self.titlefont = love.graphics.newFont("assets/SpecialElite.ttf", 72)
	self.buttonfont = love.graphics.newFont("assets/SpecialElite.ttf", 48)

	self.newgamebutton = Button("New Game", self.buttonfont, 700, 400, "right", {normal = {0,0,0}, hover = {50,50,50}})
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

end

function game:init() --called only once

end

function game:enter()
	self.building = Building:new(16,16, 1, "office")
	self.world = self.building:getFloorWorld(1)
	self.player = Entity:new()

	self.world:addEntity(self.player, {-15,-15, 30,30})

	self.player:setPos(100,100)
end

function game:update(dt)
	local speed = 200
	local player = self.player
	if love.keyboard.isDown("a") then
		player:move(-speed * dt, 0)
	end
	if love.keyboard.isDown("d") then
		player:move(speed * dt, 0)
	end
	if love.keyboard.isDown("w") then
		player:move(0, -speed * dt)
	end
	if love.keyboard.isDown("s") then
		player:move(0, speed * dt)
	end


	self.world:update(dt)
end

function game:draw()
	self.world:draw()
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(title)
end

function love.mousepressed(x,y,btn)


	Button:handlepress(x,y)
end

function love.mousereleased(x,y,btn)

	Button:handlerelease(x,y)
end

function love.update(dt)

end

function love.draw()

	Button:draw()

end
