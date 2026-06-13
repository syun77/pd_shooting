---@diagnostic disable
import "CoreLibs/object"
import "actor"

local pd <const> = playdate
local vec2 <const> = pd.geometry.vector2D

local SHOT_INTERVAL <const> = 2 -- ショットの発射間隔（フレーム数）.

-- Playerクラスの定義.
class("Player").extends(Actor)

-- コンストラクタ.
function Player:init(x, y)
	Player.super.init(self, x, y, 16, 16)
	self.shots = nil -- ショットを管理するActorManagerへの参照.
	self.shotTimer = 0 -- ショットの発射間隔を管理するタイマー.
	-- Player.super.setCenter(self, 0.5, 0.5) -- 中心をスプライトの中央に設定.
	print("Player created at (" .. x .. ", " .. y .. ")")
end

-- 弾を撃つ.
function Player:shoot()
	if self.shots == nil then
		return
	end

	local shot = self.shots:create(self.x, self.y)
	shot:setVelocity(90, 10) -- 上方向に速度を設定.
end

-- 更新.
function Player:update()
	Player.super.update(self) -- Actorのupdateを呼び出す.
	if self.shotTimer > 0 then
		-- ショットの発射間隔を管理するタイマーを減らす.
		self.shotTimer -= 1
	elseif pd.buttonIsPressed(pd.kButtonA) then
		self:shoot()
		self.shotTimer = SHOT_INTERVAL -- タイマーをリセット.
	end

	-- 十字キーで移動.
	self.vx = 0
	self.vy = 0
	local v = vec2.new(0, 0)
	local moveSpeed = 5 -- 移動速度.
	if pd.buttonIsPressed(pd.kButtonLeft) then
		v.x = -1
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		v.x = 1
	end
	if pd.buttonIsPressed(pd.kButtonUp) then
		v.y = -1
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		v.y = 1
	end
	if v.x == 0 and v.y == 0 then
		return
	end
	v:normalize()
	v *= moveSpeed
	self:move(v.x, v.y, true) -- 斜め移動でも同速になるように正規化して移動.
end
