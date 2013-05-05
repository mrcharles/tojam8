local Tools = require 'fabricate.tools'
local Vector = require 'hump.vector'
local Camera = require 'hump.camera'

local Player = require 'player'
local NPC = require 'npc'

HC = require 'hardoncollider'

local function on_collide(dt, shape_a, shape_b, dx, dy)
	local gob = shape_b.gameobject
	local entity1 = shape_a.entity
	local entity2 = shape_b.entity

	if gob and entity1 then 

		gob:onCollideStart(entity1)

		if not gob.resolves then
			return
		end
	end

	if entity1 and not entity2 then
		entity1:move(dx,dy)
	elseif entity2 and not entity1 then
		entity2:move(-dx,-dy)
	elseif entity1 and entity2 then
		entity1:move( dx/2, dy/2)
		entity2:move( -dx/2, -dy/2)

		local player, npc
		if entity1:isA(Player) then
			player = entity1
		elseif entity2:isA(Player) then
			player = entity2
		end

		if entity1:isA(NPC) then
			npc = entity1
		elseif entity2:isA(NPC) then
			npc = entity2
		end

		if player and npc then
			player:handleTouch(npc)
		end
	end
end

local function on_separate(dt, shape_a, shape_b, dx, dy)
	local gob = shape_b.gameobject
	local entity = shape_a.entity

	if gob and entity then 
		gob:onCollideEnd(entity)	
	end
end

local World = Tools:Class()

local GameObjectsClasses = {
	StairsUp = require 'gameobjects.stairsup',
	StairsDown = require 'gameobjects.stairsdown',
	PlayerSpawn = require 'gameobjects.playerspawn',
	Printer = require 'gameobjects.printer',
}

function World:init(level, tilesize)
    self.Collider = HC(100, on_collide, on_separate)
    self.parts = {}
    self.entities = {}
    self.camera = Camera()
    self.tilesize = tilesize
    self.gameobjects = {}
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local ww = tilesize * level.width
    local wh = tilesize * level.height

    -- self.cambounds = { 	minx = w/2 - ww/2, 
    -- 					maxx = ww  w/2 ,
    -- 					miny = h/2,
    -- 					maxy = level.height * h - h/2 }

    self.camera.x = ww/2
    self.camera.y = wh/2

    function addTile(x,y,tile)
    	if tile then
    		self:addRectangle( (x-1) * tilesize, (y-1) * tilesize, tilesize, tilesize, tile)
    	end
    end

    self.level = level
    level.map:iterate(addTile)

    level:populateEntities(self)

	return self
end

function World:enter(player, collision, dir)
	self:addEntity(player, collision)

	print("entering with dir ",dir)
	--find spawn or stairs up

	if dir == 0 then -- spawn
		for i,gob in ipairs(self.gameobjects) do
			if gob:isA(GameObjectsClasses.PlayerSpawn) then
				local x,y = gob.shape:center()
				player:setPos(x,y)
				break 
			end
		end
	elseif dir == 1 then -- stairsdown
		for i,gob in ipairs(self.gameobjects) do
			if gob:isA(GameObjectsClasses.StairsDown) then
				local x,y = gob.shape:center()
				player:setPos(x,y)
				break 
			end
		end
	elseif dir == -1 then -- stairsup
		for i,gob in ipairs(self.gameobjects) do
			if gob:isA(GameObjectsClasses.StairsUp) then
				local x,y = gob.shape:center()
				player:setPos(x,y)
				break 
			end
		end
	end

	--pump physics
	self.Collider:update(0.01)

	for i,gob in ipairs(self.gameobjects) do
		gob.active = true
	end

end

function World:leave()
	--cleanup on exit
	for i,gob in ipairs(self.gameobjects) do
		gob.activeCollisions = {}
		gob.active = nil
	end

end

function World:addRectangle(t,l,w,h,tile)
	local parts = self.parts

	if not tile.walkable or tile.class ~= nil then
		local shape = self.Collider:addRectangle(t,l,w,h)

		self.Collider:setPassive(shape)
		--shape.world = self
		table.insert(parts, shape)
		if tile.class then
			--print("tile class",tile.class)

			table.insert(self.gameobjects, GameObjectsClasses[tile.class]:new(self,shape, l + w/2, t + h))
		end
	else
		--piece = { f = "rectangle", color = tile.color, params = {"fill", t,l,w,h} }
	end
end

function World:addEntity(e, phys)
	table.insert(self.entities, e)

	if phys and not e.shape then
		local scale = e.scale or 1
		local x,y,w,h = unpack(phys)
		e.shape = self.Collider:addRectangle(e.pos.x + x*scale, e.pos.y + y*scale, w*scale, h*scale)
		e.shape.entity = e
		e.world = self
	end
end

function World:removeEntity(e)
	for i,entity in ipairs(self.entities) do
		if entity == e then
			if e.shape then
				self.Collider:remove(e.shape)
				e.shape.entity = nil
				e.shape = nil
			end
			e.world = nil
			table.remove(self.entities,i)
			return
		end
	end
end

function World:setFocus(entity)
	self.focus = entity
end

function clamp(min,max,val)
	if val < min then
		return min
	elseif val > max then
		return max
	else
		return val
	end
end

function World:update(dt)
    for i,e in ipairs(self.entities) do
    	e:update(dt)
    end
    self.Collider:update(dt)

    --camera update
    if self.focus then
	    local cam = self.camera
	    local bounds = self.cambounds
	    if bounds then
	    	cam.x = clamp(bounds.minx, bounds.maxx, self.focus.pos.x)
	    	cam.y = clamp(bounds.miny, bounds.maxy, self.focus.pos.y)
	    else
	    	cam.x = self.focus.pos.x
	    	cam.y = self.focus.pos.y
	    end
	end

end

function World:draw()
	self.camera:attach()

	--draw the level

	self.level:draw(self.tilesize)

	if debugDraw then
		for i,p in ipairs(self.parts) do
			-- love.graphics.setColor(p.color)
			-- love.graphics[p.f](unpack(p.params))

				love.graphics.setColor(255,0,0)
				p:draw()
		end
	end

	for i,e in ipairs(self.entities) do

		e:draw()
	end

	for i,e in ipairs(self.entities) do

		if e.drawWorldUI then
			e:drawWorldUI()
		end
	end


	self.camera:detach()

	for i,e in ipairs(self.entities) do

		if e.drawUI then
			e:drawUI()
		end
	end
end

return World