local Tools = require 'fabricate.tools'
local Map = require 'fabricate.map'

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
			split = { "wall", {1} },
			spaces = {
				{
					type = "entrance",
					minsize = 0.4,
					maxsize = 0.8,			
				},
				gen = {
					split = { "hall", {1, 2} }
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
			for i=1,math.random(unpack(gen.split[2])) do
				if spaces[i] then -- guaranteed room
					print("doing space",i)
					local s1, s2 = sizeIndexers()
					local min,max = math.floor(spaces[i].minsize * size[s1]) or 1, math.floor(spaces[i].maxsize * (size[s1]-1)) or size[s1]-1

					local newsize = {}
					newsize[s1] = math.random(min,max)
					newsize[s2] = size[s2]

					self:stampSpace(spaces[i].type, x, y, newsize)

					--now bordering wall
					if s1 == 2 then -- horiz wall
						self:stampSpace("wall", x, y + newsize[2], { newsize[1], 1} )
					else
						self:stampSpace("wall", x + newsize[1], y, { 1, newsize[2]} )
					end
				end
			end
		end
	end
end

function Floor:generate()
	local rules = ruleset[self.metatype]
	local gen = rules.gen
	local spaces = rules.spaces

	--just gen the non-outer wall space
	self:genSpace(gen, 2, 2, {self.width-2, self.height-2})


end

return Floor