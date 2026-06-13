---@diagnostic disable
import "CoreLibs/graphics"
import "CoreLibs/object" -- classを使うために必要.
import "CoreLibs/sprites" -- spriteを使うために必要.
import "actor"
import "player"
import "actor_manager"
import "enemy"
import "game_context"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite

-- 敵の種類.
local eEnemyType = {
	Normal = 1,
	Boss = 255,
}

-- ショットの定義.
class("Shot").extends(Actor)
function Shot:init(x, y)
	Shot.super.init(self, x, y, 4, 4)
	print("Shot created at (" .. x .. ", " .. y .. ")")
end
function Shot:update()
	Shot.super.update(self)
	self:move(self.vx, self.vy, false) -- 画面外に出ても移動.
	if self:isOffScreen() then
		self:despawn() -- 画面外に出たら管理情報ごと削除.
	end
end

-- 敵弾の定義.
class("Bullet").extends(Actor)
-- コンストラクタ.
function Bullet:init(x, y)
	Bullet.super.init(self, x, y, 4, 4)
	print("Bullet created at (" .. x .. ", " .. y .. ")")
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

-- ボスの定義.
class("Boss").extends(Enemy)
function Boss:init(x, y)
	Boss.super.init(self, x, y, 48, 48)
	self.hp = 20 -- ボスのHP.
	print("Boss created at (" .. x .. ", " .. y .. ")")
end

local gameContext = GameContext.getInstance()
gameContext:setup(eEnemyType)

function pd.update()
    gfx.clear()
	sprite.update() -- すべてのスプライトを更新と描画.

	gameContext.shotManager:forEach(function(shot)
		gameContext.enemyManager:forEach(function(enemy)
			if shot:isCollidingCircle(enemy) then
				print("Hit!")
				shot:despawn() -- 当たったショットを削除.
				enemy:damage(1) -- 敵にダメージを与える.
			end
		end)
	end)
	
	local boss = gameContext.enemyManager:findFirst(function(enemy)
		return enemy.type == eEnemyType.Boss
	end)
	-- ボスのHPを画面に表示.
	if boss then
		gfx.drawText("Boss HP: " .. boss.hp, 10, 10)
	end
	-- ショットの数を画面に表示.
	gfx.drawText("shot: " .. gameContext.shotManager:getCount(), 10, 30)
	-- 敵弾の数を画面に表示.
	gfx.drawText("bullet: " .. gameContext.bulletManager:getCount(), 10, 50)
end
