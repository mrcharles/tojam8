local Tools = require 'fabricate.tools'
local Map = require 'fabricate.map'

local Floor = Tools:Class()

local spacedesc = {
	entrance = {
		walkable = true,
		color = { 255,255,255 }
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
		color = { 0,0,0},
	},
	window = {
		walkable = false,
		color = { 0, 255, 128 }
	}

}

local ruleset = {
	lobby = {
		gen = {
			split = { "wall", 1 },
			spaces = {
				{
					type = "entrance",
					minsize = 0.5,			
				},
				gen = {
					split = { "hall", 1, 2 }
				}
			}
		}

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


	--self:generate()

	return self
end

local function sizeIndexers()
	if math.random() < 0.5 then
		return 1,2
	else
		return 2,1
	end
end

function Floor:stampSpace(type, x, y, size)
	local desc = spacedesc[type]

	local map = self.map
	for i=x,x+size[1]-1 do
		for j=y,y+size[2]-1 do
			map:set(i,j, {walkable = desc.walkable, color = desc.color})
		end
	end
end

function Floor:genSpace(gen, x, y, size )

	local newspaces = {}
	if gen.split then -- subdivide
		local spaces = gen.spaces
		if gen.split[1] == "wall" then
			for i=1,math.random(gen.split[2], gen.split[3]) do
				if spaces[i] then -- guaranteed room
					local s1, s2 = sizeIndexers()
					local min,max = math.floor(spaces[i].minsize*size[i1]) or 1, size[i1]

					local newsize = {}
					newsize[i1] = math.random(min,max)
					newsize[i2] = size[i2]

				end
			end
		end
	end
end

function Floor:generate()
	local rules = ruleset[self.metatype]
	local gen = rules.gen
	local spaces = rules.spaces


	self:genSpace(gen, 1, 1, {self.width, self.height})


end

return Floor