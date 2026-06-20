---@diagnostic disable
--[[
	bullet.lua

	Bulletクラスは、ゲーム内の敵が発射する弾を表すクラスです。
	Actorクラスを継承し、弾特有の動きや当たり判定を実装します。
--]]
import "CoreLibs/object"
import "actor"
import "game_context"

-- 敵弾の定義.
class("Bullet").extends(Actor)
-- コンストラクタ.
function Bullet:init(x, y)
	Bullet.super.init(self, x, y, 4, 4)
	-- print("Bullet created at (" .. x .. ", " .. y .. ")")
end
-- 更新.
function Bullet:update()
	Bullet.super.update(self)
	-- 加速度を速度に加算して移動.
	self.vx += self.ax
	self.vy += self.ay
	self:move(self.vx, self.vy, false) -- 画面外に出ても移動
	if self:isOffScreen() then
		self:despawn() -- 画面外に出たら管理情報ごと削除.
	end
end
