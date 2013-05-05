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
			{ "Coworker", "wrong", "poor"},
			{ "Boss", "right", "success"},
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

local npcStrings = {
	poor = {
		"Oof",
		"You won't go far",
		"Bad attitude",
	},
	fail = 
	{
		"What a moron",
		"Useless",
		"Someone should fire that idiot"
	},
	success = 
	{
		"Thanks!",
		"Good work!",
		"Not bad"
	}
}

local mainquests = {
	lobby = {

	},
}

local quests = 
{
	{
		text = "Go copy this form!",
		time = 6,
		needspeople = nil,
		steps = {
					{"touch", "printer"},
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	{
		text = "Go copy this form for me!",
		time = 10,
		needspeople = { "originator" },
		steps = {
					{"touch", "printer", "3"},
					{"touch", "person"}
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

	if math.random() < 0.3 then 
		self:askQuestion(player,npc)
	else
		self:generateQuest(player,npc)
	end

end

function QuestManager:generateQuest(player,npc)
	local q = quests[ math.random(#quests)]

	npc:say(q.text)

	function onComplete()
		self:handleResult(player, q.completeresult)
		npc:say( npcStrings.success[ math.random( #npcStrings.success) ])
	end

	function onFail()
		self:handleResult(player, q.failresult)
		player:say( playerFailStrings[ math.random(#playerFailStrings)] )
		npc:say( npcStrings.fail[ math.random(#npcStrings.fail)] )
	end

	npc.cooldown = 10

	local targets
	if q.needspeople then
		targets = {}

		for i,person in ipairs(q.needspeople) do
			if person == "originator" then
				table.insert(targets, npc)
			end
		end
	end

	player:addQuest( Quest:new(q.time, q.steps, targets, onComplete, onFail))
end

function QuestManager:doQuip(npc, type)
	if type then
		npc:say( npcStrings[type][ math.random(#npcStrings[type])] )
	end
end


function QuestManager:generateQuestion(player, npc)
	local q = questions[ math.random(#questions) ]

	local options = Tools:shuffle(q.answers)

	local function handler(choice)
		print("got choice",choice)
		if choice then
			self:handleResult(player, options[choice][2])
			self:doQuip(npc, options[choice][3])
		else
			self:handleResult(player, q.indecision)
			self:doQuip(npc, "fail")
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