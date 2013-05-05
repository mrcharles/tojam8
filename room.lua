local Tools = require 'fabricate.tools'
local Tile = require 'tile'
local NPC = require 'npc'

local Room = Tools:Class()

local objects = {
	stairsUp = {
		walkable = true,
		color = {30,30,30},
		class = "StairsUp",
	},
	stairsDown = {
		walkable = true,
		color = {80,30,30},
		class = "StairsDown",
	},
	playerSpawn = {
		walkable = true,
		color = {255,0,0},
		class = "PlayerSpawn"
	},
	plant = {
		walkable = false,
		color = {0,255,0},
		class = "Plant"
	},
	printer = {
		walkable = false,
		color = {50,40, 255},
		class = "Printer"
	},
	computer = {
		walkable = false,
		color = {0,0,0},
		class = "Computer"
	},
	garbage = {
		walkable = false,
		color = {0,0,0},
		class = "Garbage"
	}
}

local people = {

}

local descs = {
	elevator = {
		requiredObjects = {"stairsUp", "stairsDown"},
		clutterDensity = 0.1,
		clutter = {"plant"},
		--uniqueObjects = {"thing"},
		--uniqueChance = 0.1
	},
	entrance = {
		requiredObjects = {"playerSpawn"},
		clutterDensity = 0.01,
		clutter = {"plant"},
		peopleDensity = 0.04,
		requiredPeople = {"secretary"},
		people = {"secretary", "janitor"}
	},
	mail = {
		requiredObjects = {"printer"},
		clutterDensity = 0,
	},
	hall = {
		clutterDensity = 0.1,
		clutter = {"plant"},
		peopleDensity = 0.02,
		people = {"janitor", "worker"}
	},
	office = {
		clutterDensity = 0.1,
		requiredObjects = {"computer"},
		clutter = {"plant", "printer"},
		peopleDensity = 0.1,
		requiredPeople = {"worker"},
		people = {"secretary", "worker", "it"}
	},
	manager = {
		clutterDensity = 0.01,
		clutter = {"plant", "printer", "computer"},
		peopleDensity = 0.01,
		requiredPeople = {"manager"},
		--people = {"secretary", "worker", "it"}
	},
	garbage = {
		clutterDensity = 0.1,
		requireObjects = {"garbage"},
		clutter = {"garbage","plant"},
		peopleDensity = 0.1,
		people = {"janitor"},
	}

}

function Room:init(map, x, y, w, h, type)
	self.map = map
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.type = type

	return self
end

function Room:placeObject(obj, required)

	local map = self.map

	local objdesc = objects[obj]
	if objdesc == nil then
		print("trying to place nonexistent object:", obj)
		return
	end

	function validator(tx,ty, tile)
		if not tile or tile.door or
			(tx >= self.x and ty >= self.y and 
			tx < self.x + self.width and
			ty < self.y + self.width) then
			return true
		end
	end

	local placed = false
	while true do 
		local x, y = self.x + math.random(self.width)-1, self.y + math.random(self.height)-1
		local fail = false

		function iterator(tx,ty, tile)
			if tile and tile.type ~= self.type then
				fail = true
				return true
			end
		end

		map:iterateNeighbours8Way(x,y,iterator, validator)

		if not fail then
			map:set(x,y, Tile:new(obj, objdesc))
			placed = true
			break
		else
			if not required then
				break
			end
		end
	end

	return placed
end

function Room:validateObject(obj, level, maxlevel)
	if obj == "stairsUp" then
		if level == maxlevel then
			return false
		end
	elseif obj == "stairsDown" then
		if level == 1 then
			return false
		end
	end

	return true
end

function Room:populate(level, maxlevel)
	local desc = descs[self.type]

	if desc then
		local count = 0
		local max = math.floor((self.width*self.height) * desc.clutterDensity)

		if desc.requiredObjects then
			for i,obj in ipairs(desc.requiredObjects) do
				if self:validateObject(obj,level,maxlevel) then
					self:placeObject(obj, true)
					count = count + 1
				end
			end
		end

		while count < max do
			local obj = desc.clutter[ math.random(#desc.clutter) ]
			if self:validateObject(obj,level,maxlevel) and self:placeObject(obj) then
				count = count + 1
			end
		end

	end

end

function Room:spawnPeople(world)
	local desc = descs[self.type]

	if not desc or not desc.peopleDensity then
		return 
	end

	local count = 0
	local max = math.floor((self.width*self.height) * desc.peopleDensity)
	
	if desc.requiredPeople then
		for i,person in ipairs(desc.requiredPeople) do
			local dude = NPC:new(person)

			local x, y = self.x + math.random(self.width)-1, self.y + math.random(self.height)-1

			x = x * world.tilesize
			y = y * world.tilesize

			dude:setPos(x,y)

			world:addEntity(dude, {-10,-15, 20,30})

			count = count + 1
			
		end
	end

	while count < max do 
		local class = desc.people[ math.random(#desc.people) ]
		local dude = NPC:new(class)

		local x, y = self.x + math.random(self.width)-1, self.y + math.random(self.height)-1

		x = x * world.tilesize
		y = y * world.tilesize

		dude:setPos(x,y)


		world:addEntity(dude, {-10,-15, 20,30})

		count = count + 1
	end
end

return Room