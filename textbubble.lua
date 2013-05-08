local Tools = require 'fabricate.tools'

local TextBubble = Tools:Class()

local font

function TextBubble:init(x,y,text)
	self.x = x
	self.y = y
	self.text = text

	if font == nil then
		font = love.graphics.newFont("assets/OpenSans-Regular.ttf", 16)
	end
	--get sizes

	local height = font:getHeight()
	local width = font:getWidth(text) + 1 -- without adding one, text in the result rect may wrap

	self.rect = Tools:rect(x-width/2, x + width/2, y, y - height)

	return self
end

function TextBubble:draw()

	local r = self.rect
	--r:draw("line")
	--love.graphics.scale(1 + scale)
	local cx, cy = r:center()
	local ox, oy = r:halfsize()

	love.graphics.setColor(0,0,0)
	r:draw("fill", 5)
	
	love.graphics.polygon("fill", cx, cy + oy + 5, cx, cy + oy + 20, cx + 12, cy + oy + 5)

	love.graphics.setColor(235,235,235)
	r:draw("fill", 3)

	love.graphics.polygon("fill", cx + 2, cy + oy + 3, cx + 2, cy + oy + 14, cx + 10, cy + oy + 3)


	love.graphics.setColor(0,0,0)
	love.graphics.setFont(font)
	love.graphics.print(self.text, math.floor(cx), math.floor(cy), 0, 1,1, math.floor(ox),math.floor(oy))--r.width, self.align)

end

return TextBubble
