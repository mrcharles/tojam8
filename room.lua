local Tools = require 'fabricate.tools'
local Tile = require 'tile'
local Room = Tools:Class()


local objects = {
	stairsUp = {
		walkable = true,
		color = {30,30,30},
		collisionEvent = "stairsUp",
	},
	plant = {
		walkable = false,
		color = {0,255,0},
	}
}

local descs = {
	elevator = {
		requiredObjects = {"stairsUp"},
		clutterDensity = 0.2,
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

	print("room is",self.type,self.x,self.y,self.width,self.height)

	if objdesc == nil then
		print("trying to place nonexistent object:", obj)
		return
	end

	function validator(tx,ty, tile)
		print(tx,ty)
		if not tile or
			(tx >= self.x and ty >= self.y and 
			tx < self.x + self.width and
			ty < self.y + self.width) then
			print("...ok")
			return true
		end
	end



	while true do 
		local x, y = self.x + math.random(self.width)-1, self.y + math.random(self.height)-1
		local fail = false
		print("trying to place",obj,"at",x,y)
		function iterator(tx,ty, tile)
			if tile and tile.type ~= self.type then
				fail = true
				return true
			end
		end

		map:iterateNeighbours8Way(x,y,iterator, validator)

		if not fail then
			map:set(x,y, Tile:new(obj, objdesc))
			break
		else
			if not required then
				break
			end
		end
	end


end

function Room:populate()
	local desc = descs[self.type]

	if desc then
		local count = 0
		local max = math.floor((self.width*self.height) * desc.clutterDensity)

		if desc.requiredObjects then
			for i,obj in ipairs(desc.requiredObjects) do
				self:placeObject(obj, true)
				count = count + 1
			end
		end

		-- while count < max do

		-- end

	end

end

return Room