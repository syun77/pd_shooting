---@diagnostic disable
--[[
	boss.lua

	Bossクラスは、ゲーム内のボスキャラクターを表すクラスです。
	Enemyクラスを継承し、ボス特有の動きや攻撃パターンを実装します。
--]]
import "CoreLibs/object"
import "actor"
import "enemy"

local pd <const> = playdate
local vec2 <const> = pd.geometry.vector2D

-- ボスの定義.
class("Boss").extends(Enemy)
function Boss:init(x, y, enemies)
	Boss.super.init(self, x, y, eEnemyType.Boss) -- Enemyのコンストラクタを呼び出す.
	self.enemies = enemies -- 敵を管理するActorManagerへの参照.
	self.hp = 20 -- ボスのHP.
	self.timer = 0 -- 攻撃パターンのタイマー.
	print("Boss created at (" .. x .. ", " .. y .. ")")
end

-- 更新.
function Boss:update()
	Boss.super.update(self)
	self.timer += 1
	if self.timer == 30 then
		self:spawnEnemy(eEnemyType.Stinger, 270-45, 5) -- Stingerをスポーン.
		self:spawnEnemy(eEnemyType.Stinger, 270+45, 5) -- Stingerをスポーン.
	elseif self.timer == 180 then
		self:spawnEnemy(eEnemyType.Side, 180, 5) -- Sideをスポーン.
		self:spawnEnemy(eEnemyType.Side, 0, 5) -- Sideをスポーン.
	elseif self.timer == 400 then
		for i = 0, 16 do
			local angle = i * 22.5
			self:spawnEnemy(eEnemyType.Ring, angle, 4.5) -- Ringをスポーン.
		end
	end
end

-- 敵の生成.
function Boss:spawnEnemy(type, angle, speed)
	if self.enemies == nil then
		return
	end
	local enemy = self.enemies:create(self.x, self.y, type)
	enemy:setVelocity(angle, speed)
	print("Boss spawned enemy of type " .. type .. " at (" .. enemy.x .. ", " .. enemy.y .. ") with velocity (" .. enemy.vx .. ", " .. enemy.vy .. ")")
end
