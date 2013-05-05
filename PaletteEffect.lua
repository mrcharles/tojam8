local Tools = require 'fabricate.tools'

--require "hump.vector"


local PaletteEffect = Tools:Class()

function PaletteEffect:init(strData)
	self.index = 0

	local src = [[
		extern number index;
		extern Image sampler;

		vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			vec4 sample = Texel(tex, tc);

			if(sample.a == 0.0f)
				discard;

			float newIndex = index + 0.5f;

			if(Texel(sampler, vec2(0.5f/16.0f, 0.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 0.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 1.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 1.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 2.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 2.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 3.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 3.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 4.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 4.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 5.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 5.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 6.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 6.5f/8.0f));
			}
			else if(Texel(sampler, vec2(0.5f/16.0f, 7.5f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(newIndex/16.0f, 7.5f/8.0f));
			}
			else
			{
				color = sample;
			}

			return color;
		}
	]]

	-- print("what is strData? ")
	-- PaletteEffect.strData = strData
	-- print(strData)
	-- print(type(strData))
	-- self.strData = strData
	-- self.strData = self.strData .. "boo"

	self.image = love.graphics.newImage("assets/sprites/".. strData .."_palette.png")
	self.image:setFilter("nearest", "nearest")

	self.effect = love.graphics.newPixelEffect(src)
	self.effect:send('sampler', self.image)
	self.effect:send('index', self.index)

	return self
end

function PaletteEffect:setEffect()
	self.effect:send('index', self.index)
	self.effect:send('sampler', self.image)
	love.graphics.setPixelEffect(self.effect)
end

function PaletteEffect:clearEffect()
	love.graphics.setPixelEffect()
end

t = 0
function PaletteEffect:update(dt)
	t = t + dt
	self.effect:send('index', self.index)
	self.effect:send('sampler', self.image)
end

function PaletteEffect:setPaletteIndex(index)
	self.index = index
end

return PaletteEffect
