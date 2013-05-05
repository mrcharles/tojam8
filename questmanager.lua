local Tools = require 'fabricate.tools'
local Dialog = require 'dialog'
local Quest = require 'quest'

local QuestManager = Tools:Class()


local questions = 
{
	{
		tag = "interview",
		text = "A coworker and your boss disagree, WHO IS RIGHT?",
		answers = {
			{ "Coworker", "wrong"},
			{ "Boss", "right"},
			{ "You", "fired"},
		},
		indecision = "reprimand",
	},

}

local playerFailStrings = 
{
	"Oops",
	"Botched that one",
	"Not gonna look good",
	"Why am I still employed?"
}

local quests = 
{
	{
		text = "Go copy this form!",
		time = 10,
		needspeople = 0,
		steps = {
					{"touch", "printer", 3},
				},
		--completeresult = "",
		failresult = "failquest",
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
	failquest = {
		"changeCompetency", {-10},
	}

}

function QuestManager:init()

	return self
end

function QuestManager:assignQuest(player, npc)
	if npc.cooldown then
		return
	end

	--self:askQuestion(player,npc)
	self:generateQuest(player,npc)

end

function QuestManager:generateQuest(player,npc)
	local q = quests[ math.random(#quests)]

	npc:say(q.text)

	function onComplete()
		self:handleResult(player, q.completeresult)
	end

	function onFail()
		self:handleResult(player, q.failresult)
		player:say( playerFailStrings[ math.random(#playerFailStrings)] )
	end

	npc.cooldown = 20

	player:addQuest( Quest:new(q.time, q.steps, nil, onComplete, onFail))
end

function QuestManager:generateQuestion(player, npc)
	local q = questions[ math.random(#questions) ]

	local options = Tools:shuffle(q.answers)

	local function handler(choice)
		print("got choice",choice)
		if choice then
			self:handleResult(player, options[choice][2])
		else
			self:handleResult(player, q.indecision)
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

function QuestManager:handleResult(player, result)
	if result == nil then return end

	local action = assert(results[result], string.format("invalid result '%s'", result))

	player[action[1]](player, unpack(action[2] or {}) )

end
function QuestManager:askQuestion(player, npc)
	player.busy = true
	npc.busy = true

	Dialog:show(self:generateQuestion(player,npc))
end

return QuestManager