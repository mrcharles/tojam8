local Tools = require 'fabricate.tools'
local Button = require 'fabricate.button'

local Dialog = Tools:Class()

local indent = 25
local border = 5
local height = 400
local textmargin = indent + border + 10
local buttonspace = 50

local buttonoffset = 200
local buttonindent = 20

function Dialog:show(text, handler, ...)
	assert( self.text == nil, "cannot show two dialogs at once")

	if self.font == nil then
		self.font = love.graphics.newFont("assets/OpenSans-Regular.ttf", 24)
	end

	self.text = text
	self.handler = handler
	self.options = {...}

	self.buttons = {}

	local i = 1

	local list = {
		"A) ",
		"B) ",
		"C) ",
		"D) ",
		"E) ",
		"F) ",
		"G) ",
	}

	print(#self.options)
	for i=1,#self.options do
		local button = Button(list[i] .. self.options[i], self.font, textmargin + buttonindent, textmargin + buttonoffset + buttonspace * (i-1), "left", {normal = {0,0,0}, hover = {50,50,50}})
		button.pressaction = function(button)
			self.handler(i)
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
	end
end

return Dialog