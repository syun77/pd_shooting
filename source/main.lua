---@diagnostic disable
import "CoreLibs/graphics"
import "CoreLibs/object" -- classを使うために必要.
import "CoreLibs/sprites" -- spriteを使うために必要.
import "actor"
import "actor_manager"
import "game_context"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite
local vec2 <const> = pd.geometry.vector2D

-- 敵の種類.
local eEnemyType = {
	Normal = 1,
	Boss = 255,
}

-- Playerクラスの定義.
class("Player").extends(Actor)
-- コンストラクタ.
function Player:init(x, y)
	Player.super.init(self, x, y, 16, 16)
	self.shots = nil -- ショットを管理するActorManagerへの参照.
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
	if pd.buttonJustPressed(pd.kButtonA) then
		self:shoot()
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

-- 敵の定義.
class("Enemy").extends(Actor)
function Enemy:init(x, y)
	Enemy.super.init(self, x, y, 32, 32)
	self.bullets = GameContext.getInstance().bulletManager -- 弾を管理するActorManagerへの参照.
	self.hp = 3 -- 敵のHP.
	self.timer = 0
	print("Enemy created at (" .. x .. ", " .. y .. ")")
end
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
function Enemy:update()
	Enemy.super.update(self)
	self.timer += 1
	if self.timer % 30 == 0 then
		self:bullet(270 + math.random(-10, 10), 5) -- 毎秒1発、下方向に弾を撃つ.
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
