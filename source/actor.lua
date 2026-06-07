--[[
	Actor.lua

	Actorクラスは、ゲーム内のすべての動くオブジェクトの基本クラスです。
	位置、速度、移動方法などを管理します。
--]]
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite

class("Actor").extends(sprite)
-- コンストラクタ.
function Actor:init(x, y, w, h)
	Actor.super.init(self)
	local image = gfx.image.new(w, h, gfx.kColorBlack)
	self:setImage(image)
	self:moveTo(x, y)
	self:add()
	self.vx = 0
	self.vy = 0
	print("Actor created at (" .. x .. ", " .. y .. ") with size (" .. w .. ", " .. h .. ")")
end
-- 移動.
function Actor:move(dx, dy, bClip)
	if bClip == false then
		return self:moveBy(dx, dy)
	end

	-- 画面外に出ないように移動.
	local newX = self.x + dx
	local newY = self.y + dy
	local w2 = self.width * 0.5
	local h2 = self.height * 0.5
	newX = math.max(w2, math.min(newX, pd.display.getWidth() - w2))
	newY = math.max(h2, math.min(newY, pd.display.getHeight() - h2))
	self:moveBy(newX-self.x, newY-self.y)
end

-- 画面外に出ているかどうかを判定する関数.
function Actor:isOffScreen()
	local w2 = self.width * 0.5
	local h2 = self.height * 0.5
	return self.x + w2 < 0 or self.x - w2 > pd.display.getWidth() or
		   self.y + h2 < 0 or self.y - h2 > pd.display.getHeight()
end
