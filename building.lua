local Tools = require 'fabricate.tools'
local Floor = require 'floor'
local World = require 'world'

local Building = Tools:Class()

local metatypes = {
	"office",
	--"cafeteria",
	--"conference",
}

function Building:init(width, height, floors, type)
	self.floors = {}
	for i=1,floors do
		local metatype = (i == 1 and "lobby") or (i == floors and "ceo") or metatypes[ math.random(#metatypes) ]
		print(width,height,metatype,type)
		table.insert(self.floors, Floor:new(width, height, metatype, type) )		
	end	
	self.worlds = {}
	return self
end

function Building:getFloorWorld(floor)
	local world = self.worlds[floor] or World:new(self.floors[floor], 32)
	world.building = self

	self.worlds[floor] = world

	return world
end

return Building