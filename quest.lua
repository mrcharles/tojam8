local Tools = require 'fabricate.tools'
local GameObject = require 'gameobject'
local NPC = require 'npc'

local Quest = Tools:Class()

function Quest:init(time, steps, targets, completionFunc, failFunc)
	self.timeleft = time
	self.steps = Tools:copy(steps)
	self.targets = targets
	self.currentstep = 1
	self.completionFunc = completionFunc
	self.failFunc = failFunc

	return self
end

function Quest:testResolve(other)
	if self.complete then return end
	
	local step = self.steps[self.currentstep]
	if step[1] ~= "touch" then 
		return
	end

	if other:isA(GameObject) then
		print("gob")
		if step[2] == other.type then 
			self:completeStep()
			return
		end
	elseif other:isA(NPC) then
		if step[2] == "person" and self.targets and other == self.targets[1] then
			self:completeStep()
		end
	end
end

function Quest:update(dt)
	if self.timeleft > 0 then
		self.timeleft = self.timeleft - dt

		if self.timeleft <= 0 then
			self.complete = true
			self.failFunc()
		end
	end
end


function Quest:completeStep()
	local step = self.steps[self.currentstep]

	if step[2] == "person" then
		table.remove(self.targets, 1)
	end

	if step[3] then
		self.timeleft = self.timeleft + step[3]
	end

	self.currentstep = self.currentstep + 1
	if self.currentstep > #self.steps then
		self.complete = true
		if self.completionFunc then
			self.completionFunc()
		end
	end
end

return Quest