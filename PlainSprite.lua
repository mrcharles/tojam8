local Base = require 'base'
local Tools = require 'fabricate.tools'
local Vector = require "hump.vector"
--require "spritemanager"

local SpriteManager = require 'spritemanager'
local Entity = require 'entity'
local PlainSprite = Tools:Class(Entity)

function PlainSprite:init(strData, strAnimation)
--	print(type(strAnimation))
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

	return self
end

function PlainSprite:setPosition(pos)
	self.position = pos
end

function PlainSprite:setAnimation(animation)
	self.baseLayer:setAnimation(animation, true)
end

function PlainSprite:update(dt)
	self.baseLayer.sprData.image:setFilter("nearest", "nearest")

	self.baseLayer.x = self.position.x
	self.baseLayer.y = self.position.y

	self.baseLayer:update(dt)
end

function PlainSprite:draw()
	self.baseLayer:draw()
end

return PlainSprite
