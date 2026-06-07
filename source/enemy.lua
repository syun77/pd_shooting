---@diagnostic disable
--[[
	Enemy.lua

	Enemyクラスは、ゲーム内の敵キャラクターを表すクラスです。
	Actorクラスを継承し、敵特有の動きや攻撃パターンを実装します。
--]]
import "CoreLibs/object"
import "actor"
import "game_context"

class("Enemy").extends(Actor)

-- コンストラクタ.
function Enemy:init(x, y)
	Enemy.super.init(self, x, y, 32, 32)
	self.bullets = GameContext.getInstance().bulletManager -- 弾を管理するActorManagerへの参照.
	self.hp = 3 -- 敵のHP.
	self.timer = 0
	print("Enemy created at (" .. x .. ", " .. y .. ")")
end

-- 弾を撃つ.
function Enemy:bullet(angle, speed, ax, ay)
	if self.bullets == nil then
		return
	end
	if ax == nil then ax = 0 end
	if ay == nil then ay = 0 end

	local bullet = self.bullets:create(self.x, self.y)
	bullet:setVelocity(angle, speed)
	bullet.ax = ax
	bullet.ay = ay
end

-- 更新.
function Enemy:update()
	Enemy.super.update(self)
	self.timer += 1
	if self.timer % 30 == 0 then
		self:bullet(self:getAim(), 5) -- 毎秒1発、プレイヤーに向かって弾を撃つ.
	end
end

-- 敵種別を設定.
function Enemy:setType(type)
	self.type = type
end

-- 敵にダメージを与える関数.
function Enemy:damage(amount)
	self.hp = self.hp - amount
	print("Enemy damaged! HP: " .. self.hp)
	if self.hp <= 0 then
		self:despawn() -- HPが0以下になったら削除.
	end
end

-- プレイヤーへの狙い撃ち角度を取得する.
function Enemy:getAim()
	local player = GameContext.getInstance().player
	if player == nil then
		return 270 -- プレイヤーがいない場合は下方向に撃つ.
	end
	local dx = player.x - self.x
	local dy = player.y - self.y
	local angle = math.atan2(-dy, dx) * 180 / math.pi -- atan2の引数は(y, x)の順で、yは反転させる.
	return angle
end
