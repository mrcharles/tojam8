local Base = require 'base'
local Tools = require 'fabricate.tools'
local Vector = require "hump.vector"
--require "spritemanager"
local PaletteEffect = require "PaletteEffect"

local SpriteManager = require 'spritemanager'
local Entity = require 'entity'
local PaletteSprite = Tools:Class(Entity)

function PaletteSprite:init(strData, strAnimation)
	print(type(strAnimation))
	Entity.init(self)


	self.position = Vector(0, 0)
	self.baseLayer = {}
	self.effect = {}

	self.baseLayer = SpriteManager.createSprite()
	self.baseLayer.strData = strData
	self.baseLayer.animation = strAnimation
	self.baseLayer:setData(self.baseLayer.strData, self.baseLayer.animation, true)
	self.baseLayer.sprData.image:setFilter("nearest", "nearest")
	self.baseLayer.flipH = false

	self.effect = PaletteEffect:new(strData)
	return self
end

function PaletteSprite:setPosition(pos)
	self.position = pos
end

function PaletteSprite:setAnimation(animation)
	self.baseLayer:setAnimation(animation, true)
end

function PaletteSprite:update(dt)
	self.effect:update(dt)

	self.baseLayer.x = self.position.x
	self.baseLayer.y = self.position.y

	self.baseLayer:update(dt)
end

function PaletteSprite:draw()
	self.effect:setEffect()
	self.baseLayer:draw()
	self.effect:clearEffect()
end

return PaletteSprite
