local Tools = require 'fabricate.tools'
local Button = require 'fabricate.button'

local Dialog = {}

local indent = 25
local border = 5
local height = 400
local textmargin = indent + border + 10
local buttonspace = 50

local buttonoffset = 200
local buttonindent = 20

local timeroffset = 140
local timerindent = 50
local timerborder = 5
local timerheight = 30


function Dialog:show(text, handler, timelimit, ...)
	assert( self.text == nil, "cannot show two dialogs at once")

	if self.font == nil then
		self.font = love.graphics.newFont("assets/OpenSans-Regular.ttf", 24)
	end

	self.text = text
	self.handler = handler
	self.timeleft = timelimit
	self.timelimit = timelimit
	self.options = {...}

	self.buttons = {}

	local i = 1

	local list = {
		"1) ",
		"2) ",
		"3) ",
		"4) ",
		"5) ",
		"6) ",
		"7) ",
	}

	--print(#self.options)
	for i=1,#self.options do
		local button = Button(list[i] .. self.options[i], self.font, textmargin + buttonindent, textmargin + buttonoffset + buttonspace * (i-1), "left", {normal = {0,0,0}, hover = {50,50,50}}, tostring(i))
		local option = i
		button.pressaction = function(button)
			self.handler(option)
			self:close()
		end
		table.insert(self.buttons, button)
		i = i + 1
	end
end

function Dialog:close()
	self.text = nil
	for i,b in ipairs(self.buttons) do
		b:unregister()
	end
	self.buttons = nil
	self.options = nil
	self.timeleft = nil
end

function Dialog:update(dt)
	if self.timeleft then 
		self.timeleft = self.timeleft - dt

		if self.timeleft <= 0 then
			self.handler()
			self:close()
		end
	end
end

function Dialog:draw()

	if self.text then
		--draw frame
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", indent,indent, love.graphics.getWidth() - indent*2, height)

		love.graphics.setColor(235,235,235)
		love.graphics.rectangle("fill", indent + border,indent + border, love.graphics.getWidth() - (indent+border)*2, height - border*2)

		love.graphics.setFont(self.font)
		love.graphics.setColor(0,0,0)

		love.graphics.printf(self.text, textmargin, textmargin, love.graphics.getWidth() - textmargin * 2, "left")

		if self.timeleft then
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", textmargin + timerindent, textmargin + timeroffset, love.graphics.getWidth() - (textmargin + timerindent)*2, timerheight)
			love.graphics.setColor(235,235,235)

			local timerwidth = love.graphics.getWidth() - (textmargin + timerindent + timerborder)*2
			love.graphics.rectangle("fill", textmargin + timerindent + timerborder, textmargin + timeroffset + timerborder, timerwidth, timerheight - timerborder*2)

			local pct = self.timeleft / self.timelimit

			love.graphics.setColor(50,50,255)
			love.graphics.rectangle("fill", textmargin + timerindent + timerborder, textmargin + timeroffset + timerborder, timerwidth * pct, timerheight - timerborder*2)
		end
	end
end

return Dialog