---@diagnostic disable
import "CoreLibs/graphics"
import "CoreLibs/object" -- classを使うために必要.
import "CoreLibs/sprites" -- spriteを使うために必要.
import "actor"
import "actor_manager"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite

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
	-- Player.super.setCenter(self, 0.5, 0.5) -- 中心をスプライトの中央に設定.
	print("Player created at (" .. x .. ", " .. y .. ")")
end
-- 更新.
function Player:update()
	Player.super.update(self) -- Actorのupdateを呼び出す.

	-- 十字キーで移動.
	self.vx = 0
	self.vy = 0
	local dx = 0
	local dy = 0
	local moveSpeed = 5
	if pd.buttonIsPressed(pd.kButtonLeft) then
		dx = -1
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		dx = 1
	end
	if pd.buttonIsPressed(pd.kButtonUp) then
		dy = -1
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		dy = 1
	end
	if dx == 0 and dy == 0 then
		return
	end

	local len = math.sqrt(dx * dx + dy * dy)
	self:move((dx / len) * moveSpeed, (dy / len) * moveSpeed, true) -- 斜め移動でも同速になるように正規化して移動.
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
	self.hp = 3 -- 敵のHP.
	print("Enemy created at (" .. x .. ", " .. y .. ")")
end
function Enemy:update()
	Enemy.super.update(self)
	-- ここでは特に何もしない.
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
-- ボスの定義.
class("Boss").extends(Enemy)
function Boss:init(x, y)
	Boss.super.init(self, x, y, 48, 48)
	self.hp = 20 -- ボスのHP.
	print("Boss created at (" .. x .. ", " .. y .. ")")
end

local player = Player(200, 200)
local shotManager = ActorManager(Shot)
local enemyManager = ActorManager(Enemy)
local boss = Boss(200, 20)
boss:setType(eEnemyType.Boss)
enemyManager:add(boss)	-- ボスは直接追加.

function pd.update()
    gfx.clear()
	sprite.update() -- すべてのスプライトを更新と描画.

    if pd.buttonJustPressed(pd.kButtonA) then
		-- ショットを撃ちます.
		local shot = shotManager:create(player.x, player.y)
		shot:setVelocity(90, 7) -- 上方向に速度を設定.
    end

	shotManager:forEach(function(shot)
		enemyManager:forEach(function(enemy)
			if shot:isCollidingCircle(enemy) then
				print("Hit!")
				shot:despawn() -- 当たったショットを削除.
				enemy:damage(1) -- 敵にダメージを与える.
			end
		end)
	end)
	
	local bosses = enemyManager:findAll(function(enemy)
		return enemy.type == eEnemyType.Boss
	end)
	-- ボスのHPを画面に表示.
	if #bosses > 0 then
		gfx.drawText("Boss HP: " .. bosses[1].hp, 10, 10)
	end
	-- ショットの数を画面に表示.
	gfx.drawText("shot: " .. shotManager:getCount(), 10, 30)
end
