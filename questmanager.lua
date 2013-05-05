local Tools = require 'fabricate.tools'
local Dialog = require 'dialog'

local QuestManager = Tools:Class()

function QuestManager:init()

	return self
end

function QuestManager:assignQuest(player, npc)
	if npc.cooldown then
		return
	end

	player.busy = true
	npc.busy = true

	function handler(choice)
		player.busy = false
		npc.busy = false
		npc.cooldown = 10
	end

	Dialog:show("A Problem comes up and a co worker and your boss disagree, who is right?", handler, "Coworker", "You", "Your boss")

end

return QuestManager