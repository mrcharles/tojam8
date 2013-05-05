local Tools = require 'fabricate.tools'
local Dialog = require 'dialog'

local QuestManager = Tools:Class()

local questions = 
{
	{
		text = "A coworker and your boss disagree, WHO IS RIGHT?",
		answers = {
			{ "Coworker", "wrong"},
			{ "Boss", "right"},
			{ "You", "fired"},
		},
		indecision = "reprimand",
	},

}

local results = 
{
	right = {
		"changeCompetency", {10}
	},
	wrong = {
		"changeCompetency", {-10}
	},
	fired = {
		"getFired"
	},
	reprimand = {
		"changeCompetency", {15}
	},

}

function QuestManager:init()

	return self
end

function QuestManager:assignQuest(player, npc)
	if npc.cooldown then
		return
	end

	self:askQuestion(player,npc)

end

function QuestManager:generateQuestion(player, npc)
	local q = questions[ math.random(#questions) ]

	local options = Tools:shuffle(q.answers)

	local function handler(choice)
		if choice then
			self:handleResult(options[choice])
		else
			self:handleResult(q.indecision)
		end
		player.busy = nil
		npc.busy = nil
		npc.cooldown = 10
	end

	local texts = {}

	for i,opt in ipairs(options) do
		table.insert(texts, opt[1])
	end

	return q.text, handler, 1.5, unpack(texts)
end

function QuestManager:handleResult(result)

end
function QuestManager:askQuestion(player, npc)
	player.busy = true
	npc.busy = true

	Dialog:show(self:generateQuestion(player,npc))
end

return QuestManager