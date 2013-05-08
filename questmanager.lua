local Tools = require 'fabricate.tools'
local Dialog = require 'dialog'
local Quest = require 'quest'
local NPC = require 'npc'

local QuestManager = Tools:Class()


local questions = 
{
	{
		text = "A coworker and your boss disagree, WHO IS RIGHT?",
		answers = {
			{ "Coworker", "wrong", "poor"},
			{ "Boss", "right", "success"},
			{ "You", "fired"},
		},
		indecision = "reprimand",
	},
	{
		text = "What is a valid use of work computers?",
		answers = {
			{ "Streaming", "wrong", "poor"},
			{ "Working", "right", "success"},
			{ "Porn", "fired"},
		},
		indecision = "reprimand",
	},
	{
		text = "Where do you eat your lunch?",
		answers = {
			{ "Out", "wrong", "poor"},
			{ "At my desk", "right", "success"},
		},
		indecision = "reprimand",
	},
	{
		text = "Are you available to work on weekends?",
		answers = {
			{ "No", "wrong", "poor"},
			{ "Yes", "right", "success"},
		},
		indecision = "reprimand",
	},
	{
		text = "What phone do you use for work?",
		answers = {
			{ "iPhone", "wrong", "poor"},
			{ "Android", "wrong", "poor"},
			{ "Blackberry", "right", "success"},
		},
		indecision = "reprimand",
	},
	{
		text = "Which of these days can you take off?",
		answers = {
			{ "Christmas", "wrong", "poor"},
			{ "New Year's", "wrong", "poor"},
			{ "Labour Day", "fireddayoff"},
			{ "Birthday", "wrong", "poor"},
			{ "I work nonstop", "right", "success"},
		},
		indecision = "reprimand",
	},

}

local playerMainStrings = 
{
	"Movin' up in the world",
	"Time to hit the stairs",
	"I'm blowing this joint"
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
	{
		text = "Gotta introduce myself to the secretary",
		time = 30,
		warn = 10,
		needspeople = {"secretary"},
		steps = {
					{"touch", "person"}
				},
		failresult = "failbegin"

	},
	{
		text = "Gotta work my ass off, and then meet the manager",
		time = 60,
		warn = 10,
		needspeople = {"manager"},
		steps = {
					{"competency", 150, 10, "Time to brag!"},
					{"touch", "person"}
				},
		failresult = "slacker"
	},
	{
		text = "Gotta work my ass off, and then meet the manager",
		time = 180,
		warn = 10,
		needspeople = {"manager"},
		steps = {
					{"competency", 250, 10, "Time to brag!"},
					{"touch", "person"}
				},
		failresult = "slacker"
	},
}

local questmap = {
	secretary = {"copy", "copyreturn", "waterplant", "question"},
	janitor = {"waterplant","throwout"},
	worker = {"copy", "copyreturn", "sendemail"},
	manager = {"sendemail", "checkresponse", "question"},
	boss = {"checkresponse", "question"},
	it = {"resetprinter"},
}

local quests = 
{
	copy = {
		text = "Go copy this form!",
		time = 35,
		needspeople = nil,
		steps = {
					{"touch", "printer"},
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	sendemail = {
		text = "Go send an email!",
		time = 20,
		needspeople = nil,
		steps = {
					{"touch", "computer"},
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	copyreturn = {
		text = "Go make a copy for me!",
		time = 50,
		needspeople = { "originator" },
		steps = {
					{"touch", "printer", 3, "Gotta return this."},
					{"touch", "person"}
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	checkresponse = {
		text = "Check if so and so emailed.",
		time = 30,
		needspeople = { "originator" },
		steps = {
					{"touch", "computer", 3, "Back to the manager"},
					{"touch", "person"}
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	waterplant = {
		text = "Go water a plant!",
		time = 90,
		steps = {
					{"touch", "plant" }
				},
		--completeresult = "",
		failresult = "failquest",
	},		
	throwout = {
		text = "Throw this out!",
		time = 60,
		steps = {
					{"touch", "garbage" }
				},
		--completeresult = "",
		failresult = "minorfailquest",
	},		
	resetprinter = {
		text = "Go reset the printer!",
		time = 20,
		needspeople = nil,
		steps = {
					{"touch", "printer"},
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
		"getFired", {"You're Fired!"}
	},
	fireddayoff = {
		"getFired", {"Correct, you won't be working on labour day."}
	},
	reprimand = {
		"changeCompetency", {15}
	},
	failquest = {
		"changeCompetency", {-10},
	},
	minorfailquest = {
		"changeCompetency", {-5},
	},
	failbegin = {
		"getFired", {"Failed at your first task."}
	},
	slacker = {
		"getFired", {"You useless slacker!"}
	}

}

function QuestManager:init()

	return self
end

function QuestManager:assignQuest(player, npc)
	if npc.cooldown then
		return
	end

	if self:generateQuest(player,npc) then
		player.world.pausetime = 3
	end

end

function QuestManager:mainQuest(level, player)
	local q = mainquests[ level ]
	if not q or level <= player.assignedquest then return end

	print("player's level is ",player.level)
	player.assignedquest = level
	player:say(q.text)
	player.world.pausetime = 3

	function onComplete()
		self:handleResult(player, q.completeresult)
		player:say( playerMainStrings[ math.random( #playerMainStrings) ], 7)
		player.completedquest = player.level
		player.level = player.level + 1
		player.nextlevelenabled = true
	end

	function onFail()
		self:handleResult(player, q.failresult)
		-- player:say( playerFailStrings[ math.random(#playerFailStrings)] )
		-- npc:say( npcStrings.fail[ math.random(#npcStrings.fail)] )
	end

	local targets
	if q.needspeople then
		targets = {}

		for i,person in ipairs(q.needspeople) do
			if person == "originator" then
				table.insert(targets, npc)
			else
				-- find a dude that matches
				local world = player.world
				local entities = Tools:shuffle(world.entities, true)
				for i,dude in ipairs(world.entities) do
					print("want",person,"checking i",i,dude.class)
					if dude:isA(NPC) and dude.class == person then
						print("FOUND")
						dude.questnpc = true
						table.insert(targets, dude)
						break
					end
				end
			end
		end
	end

	player:addQuest( Quest:new(q.time, q.steps, targets, onComplete, onFail), true)
end


function QuestManager:generateQuest(player,npc)
	local questids = questmap[ npc.class ]

	local qid = questids[math.random(#questids)]

	if qid == "question" then
		self:askQuestion(player,npc)
		return 
	end

	local q = quests[qid]


	assert( q, string.format("failed to find a quest for class '%s' and id '%s'", npc.class, qid))

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

	return true
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
--		print("got choice",choice)
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

	return q.text, handler, 2.5, unpack(texts)
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