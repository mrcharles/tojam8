local Tools = require 'fabricate.tools'
local Map = require 'fabricate.map'
local Room = require 'room'
local Tile = require 'tile'

local Floor = Tools:Class()

local debugGen = true
local oldPrint = print
function print(...)
	if debugGen then
		oldPrint(...)
	end
end

local spacedesc = {
	entrance = {
		walkable = true,
		color = { 200,200,200 }
	},
	wall = {
		walkable = false,
		color = { 80,80,80 },
	},
	hall = {
		walkable = true,
		color = { 180,180,180 },
	},
	outerwall = {
		walkable = false,
		border = true,
		color = { 0,0,0},
	},
	window = {
		walkable = false,
		color = { 0, 255, 128 }
	},
	mail = {
		walkable = true,
		color = {128, 128, 255}
	},
	garbage = {
		walkable = true,
		color = {0, 128, 0}
	},
	elevator = {
		walkable = true,
		color = {128, 128, 0}
	},
	office = {
		walkable = true,
		color = {128, 128, 128}
	},
	printer = {
		walkable = true,
		color = {128, 128, 255}
	},
	breakroom = {
		walkable = true,
		color = {128, 255, 128}
	},
	manager = {
		walkable = true,
		color = {255, 255, 192}
	},
	door = {
		door = true,
		walkable = true, 
		color = {0,0,180}
	}

}

local levels = {
	lobby = {
		dir = "y",
		{
			room = "entrance",
			size = 0.7,
		},
		{
			dir = "x",
			{
				room = "mail",
				size = 0.2,
				doors = { "right" },
			},
			{
				room = "hall",
				size = 0.15,
			},
			{
				room = "elevator",
				size = 0.2,
				doors = { "right", "left" },
			},
			{
				room = "hall",
				size = 0.15,
			},
			{ 
				room = "garbage",
				doors = {"left", "top"}
			}
		}
	},
	ceo = {
		dir = "x",
		{	
			size = 0.2,
			dir = "y",
			{
				room = "elevator",
				size = 0.2,
				doors = {"right"},
			},
			{
				room = "office",
				size = 0.3,
				doors = {"right"},
			},
			{
				room = "printer",
				size = 0.2,
				doors = {"right", "bottom"},
			},
			{
				room = "breakroom",
				doors = {"right"},
			}
		},
		{
			room = "hall",
			size = 0.2,
		},
		{	
			size = 0.2,
			dir = "y",
			{
				room = "manager",
				size = 0.3,
				doors = {"right", "left"},
			},
			{
				room = "hall",
				size = 0.2,
				--doors = {"right"},
			},
			{
				room = "office",
				size = 0.2,
				doors = {"top"},
			},
			{
				room = "office",
				doors = {"right", "left"},
			},
		},
		{
			room = "hall",
			size = 0.2,
		},
		{
			dir = "y",
			{
				room = "office",
				size = 0.3,
				doors = {"left"},
			},
			{
				room = "office",
				size = 0.2,
				doors = {"left"},
			},
			{
				room = "office",
				size = 0.2,
				doors = {"top"},
			},
			{
				room = "office",
				doors = {"left"},
			},
		},

	}
}

function Floor:init(width,height,metatype,type)
	self.map = Map:new(width,height)

	self.type = type
	self.metatype = metatype

	self.width = width
	self.height = height

	--stamp outer walls
	self:stampSpace("outerwall", 1, 1, { 1, height }) -- left wall
	self:stampSpace("outerwall", 1, 1, { width, 1 }) -- top wall
	self:stampSpace("outerwall", width, 1, { 1, height }) -- right wall
	self:stampSpace("outerwall", 1, height, { width, 1 }) -- bottom wall


	self:generate()

	return self
end

local function sizeIndexers()
	if math.random() < 0.5 then
		return 1,2
	else
		return 2,1
	end
end

function Floor:stampSpace(type, x, y, size, dir, doors)
	local desc = assert(spacedesc[type], string.format("unfound space type '%s'",type))

	print("stamping space:",type,x,y,"size",size[1],size[2],dir)
	local map = self.map
	for i=x,x+size[1]-1 do
		for j=y,y+size[2]-1 do
			local ok = true
			local t = map:get(i,j)
			if t and type == "wall" and (t.door or t.type == "hall") then
				ok = false
			end

			if ok then
				map:set(i,j, Tile:new(type, desc))
			end
		end
	end

	if doors then
		local doordesc = spacedesc["door"]
		for i,door in ipairs(doors) do
			if door == "left" then
				local x,y = x-1, y + math.random(1, size[2]-1)
				map:set(x,y, Tile:new("door", doordesc))
			elseif door == "right" then
				print( size[2] )
				local x,y = x + size[1], y + math.random(1, size[2]-1)
				map:set(x,y, Tile:new("door", doordesc))
			elseif door == "top" then
				local x,y = x + math.random(1, size[1]-1), y - 1 
				map:set(x,y, Tile:new("door", doordesc))
			elseif door == "bottom" then
				local x,y = x + math.random(1, size[1]-1), y + size[1]
				map:set(x,y, Tile:new("door", doordesc))
			end
			
		end
	end

	if type == "hall" then -- need to stamp out the ends of the hall, assuming they are not borders. 
		if dir == "x" then -- knock out edge on y
			-- top first
			if y - 1 > 0 then
				for i=1,size[1] do
					local tile = map:get(x + i - 1, y-1)
					if not tile or not tile.border then
						map:set(x + i - 1, y-1, Tile:new(type, desc))
					end
				end
			end
			local dy = y + size[2]
			if dy < map.height then
				for i=1,size[1] do
					local tile = map:get(x + i - 1, dy)
					if not tile or not tile.border then
						map:set(x + i - 1, dy, Tile:new(type, desc))
					end
				end
			end
		elseif dir == "y" then  -- knock out edge on x
			-- left first
			if x - 1 > 0 then
				for i=1,size[2] do
					local tile = map:get(x-1, y+i-1)
					if not tile or not tile.border then
						print("hall extension at",x-1,y+i-1)
						map:set(x-1, y+i-1, Tile:new(type, desc))
					end
				end
			end
			local dx = x + size[1]
			if dx < map.width then
				for i=1,size[2] do
					local tile = map:get(dx, y+i-1)
					if not tile or not tile.border then
						print("hall extension at",dx,y+i-1)
						map:set(dx, y+i-1, Tile:new(type, desc))
					end
				end
			end
		end
	end
end

function Floor:genSpace(gen, startx, starty, range )

	local map = self.map
	local rooms = {}
	local x,y = startx, starty

	print("gen", startx, starty, range[1], range[2])
	if gen.dir == "y" then -- down
		for i,space in ipairs(gen) do
			local size = (space.size and math.floor(range[2] * space.size)) or range[2] - (y - starty)

			if space.room then
				table.insert( rooms, Room:new(map, x, y, range[1], size, space.room ))
				--stamp the room
				self:stampSpace(space.room, x, y, { range[1], size}, "y", space.doors)
			else
				self:genSpace(space, x, y, { range[1], size })
				--self:stampSpace("garbage", x, y, { range[1], range[2]-(y-starty)})
			end

			y = y + size

			if space.size then
				--put a wall
				self:stampSpace("wall", x, y, { range[1], 1 })
				y = y + 1
			end
		end
	elseif gen.dir == "x" then -- across
		for i,space in ipairs(gen) do
			local size = (space.size and math.floor(range[1] * space.size)) or range[1] - (x - startx)

			if space.room then
				table.insert( rooms, Room:new(map, x, y, size, range[2], space.room ))
				--stamp the room
				self:stampSpace(space.room, x, y, { size, range[2]}, "x", space.doors)
			else
				self:genSpace(space, x, y, { size, range[2]})
				--self:stampSpace("garbage", x, y, { range[1], range[2]-(y-starty)})
			end

			x = x + size

			if space.size then
				--put a wall 
				self:stampSpace("wall", x, y, { 1, range[2]})
				x = x + 1
			end
		end
	end

	self.rooms = self.rooms or {}

	for i,room in ipairs(rooms) do
		table.insert(self.rooms, room)
	end

end

function Floor:generate()
	local level = assert(levels[self.metatype], string.format("no level found for metatype '%s'",self.metatype))
	

	--just gen the non-outer wall space
	self:genSpace(level, 2, 2, {self.width-2, self.height-2})

	self:populateRooms()

end

function Floor:populateRooms()

	for i,room in ipairs(self.rooms) do
		room:populate()
	end
end

function Floor:draw(size)
	function drawTile(x,y,t)
		if t then
			t:drawAt(x,y,size)
		end
	end

	self.map:iterate(drawTile)
end

return Floor