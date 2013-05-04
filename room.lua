local Tools = require 'fabricate.tools'
local Tile = require 'tile'
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
	plant = {
		walkable = false,
		color = {0,255,0},
	}
}

local descs = {
	elevator = {
		requiredObjects = {"stairsUp", "stairsDown"},
		clutterDensity = 0.1,
		clutter = {"plant"},
		--uniqueObjects = {"thing"},
		--uniqueChance = 0.1
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

return Room