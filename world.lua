local Tools = require 'fabricate.tools'
local Vector = require 'hump.vector'
local Camera = require 'hump.camera'
HC = require 'hardoncollider'

local function on_collide(dt, shape_a, shape_b, dx, dy)
	local world = shape_b.world

	if world and shape_b.collisionEvent then -- if shape_b is world then it's static most likely
		local collisions = world.activeCollisionEvents[shape_b] or {}
		
		if not collisions[shape_a] then
			collisions[shape_a] = shape_b.collisionEvent
			world.activeCollisionEvents[shape_b] = collisions
			--shape_a.entity:collisionEvent(shape_b.collisionEvent, shape_b)
		end

		return
	end

	if shape_a.entity then
		local e = shape_a.entity
		e:move(dx,dy)
	end
end

local function on_separate(dt, shape_a, shape_b, dx, dy)
	local world = shape_a.world

end

local World = Tools:Class()


function World:init(level, tilesize)
    self.Collider = HC(100, on_collide, on_separate)
    self.parts = {}
    self.entities = {}
    self.camera = Camera()
    self.tilesize = tilesize
    
    self.activeCollisionEvents = {}

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
	return self
end

function World:addRectangle(t,l,w,h,tile)
	local parts = self.parts

	local piece
	if not tile.walkable or tile.collisionEvent ~= nil then
		piece = { f = "rectangle", color = tile.color, params = {"fill", t,l,w,h}, shape = self.Collider:addRectangle(t,l,w,h)}
		self.Collider:setPassive(piece.shape)
		piece.shape.world = self

		if tile.collisionEvent then
			--self.Collider:setGhost(piece.shape)
			piece.shape.collisionEvent = tile.collisionEvent
		end
	else
		piece = { f = "rectangle", color = tile.color, params = {"fill", t,l,w,h} }
	end

	table.insert( parts, piece)
end

function World:addEntity(e, phys)
	table.insert(self.entities, e)

	if phys and not e.shape then
		local scale = e.scale or 1
		local x,y,w,h = unpack(phys)
		e.shape = self.Collider:addRectangle(x*scale, y*scale, w*scale, h*scale)
		e.shape.entity = e
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

			if p.shape then
				love.graphics.setColor(255,0,0)
				p.shape:draw()
			end
		end
	end

	for i,e in ipairs(self.entities) do

		e:draw()
	end

	self.camera:detach()
end

return World