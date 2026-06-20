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
	self.timer = 0 -- 攻撃パターンのタイマー.
	self.step = 0
	print("Boss created at (" .. x .. ", " .. y .. ")")
end

-- 更新.
function Boss:update()
	Boss.super.update(self)
	self.timer += 1
	if self.timer == 30 then
		self:spawnEnemy(eEnemyType.Stinger, 270-60, 5) -- Stingerをスポーン.
		self:spawnEnemy(eEnemyType.Stinger, 270+60, 5) -- Stingerをスポーン.
	elseif self.timer == 180 then
		self:spawnEnemy(eEnemyType.Side, 180, 5) -- Sideをスポーン.
		self:spawnEnemy(eEnemyType.Side, 0, 5) -- Sideをスポーン.
	elseif self.timer == 400 then
		for i = 0, 16 do
			local angle = i * 22.5
			self:spawnEnemy(eEnemyType.Ring, angle, 4.5) -- Ringをスポーン.
		end
	elseif self.timer == 900 then
		self:spawnEnemy(eEnemyType.Winder, 270-110, 5.5) -- Winderをスポーン.
		self:spawnEnemy(eEnemyType.Winder, 270+110, 5.5) -- Winderをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270-70, 5) -- Tripodをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270+80, 5) -- Tripodをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270-110, 5) -- Tripodをスポーン.
	elseif 1200 < self.timer and self.timer < 1500 then
		if self.timer % 30 == 0 then
			local d = 1
			if self.step % 2 == 0 then
				d = -1
			end
			local aim = self:getAim()
			local angle = 40 - self.step * 1
			local spd = 2 + self.step * 0.2
			self:spawnEnemy(eEnemyType.Curve, aim+(d*angle), spd) -- Curveをスポーン.
			self.step += 1
		end
	elseif self.timer == 1700 then
		self:spawnEnemy(eEnemyType.Stinger2, 270-90, 5) -- Stinger2をスポーン.
		self:spawnEnemy(eEnemyType.Stinger2, 270+90, 5) -- Stinger2をスポーン.
	elseif self.timer == 1800 then
		self:spawnEnemy(eEnemyType.Rolling, 270-90, 5) -- Rollingをスポーン.
		self:spawnEnemy(eEnemyType.Rolling, 270+90, 5) -- Rollingをスポーン.
		for i = 0, 16 do
			local angle = i * 22.5
			self:spawnEnemy(eEnemyType.Ring, angle, 4.5) -- Ringをスポーン.
		end
	elseif self.timer == 2000 then
		self:spawnEnemy(eEnemyType.Winder, 270-110, 5.5) -- Winderをスポーン.
		self:spawnEnemy(eEnemyType.Winder, 270+110, 5.5) -- Winderをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270-70, 5) -- Tripodをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270+80, 5) -- Tripodをスポーン.
		self:spawnEnemy(eEnemyType.Tripod, 270-110, 5) -- Tripodをスポーン.
	elseif self.timer == 2100 then
		self:spawnEnemy(eEnemyType.Stinger, 270-60, 5) -- Stingerをスポーン.
		self:spawnEnemy(eEnemyType.Stinger, 270+60, 5) -- Stingerをスポーン.
	elseif self.timer == 2300 then
		self:spawnEnemy(eEnemyType.Side, 180, 5) -- Sideをスポーン.
		self:spawnEnemy(eEnemyType.Side, 0, 5) -- Sideをスポーン.
	elseif self.timer == 2350 then
		self:spawnEnemy(eEnemyType.Winder, 270-110, 5.5) -- Winderをスポーン.
		self:spawnEnemy(eEnemyType.Winder, 270+110, 5.5) -- Winderをスポーン.
	elseif self.timer == 2400 then
		self:spawnEnemy(eEnemyType.Side, 180, 5) -- Sideをスポーン.
		self:spawnEnemy(eEnemyType.Side, 0, 5) -- Sideをスポーン.
	elseif self.timer == 2500 then
		self:spawnEnemy(eEnemyType.Side, 180, 5) -- Sideをスポーン.
		self:spawnEnemy(eEnemyType.Side, 0, 5) -- Sideをスポーン.
	end

	if self.timer == 1400 then
		self:spawnEnemy(eEnemyType.Rolling, 270-90, 5) -- Rollingをスポーン.
		self:spawnEnemy(eEnemyType.Rolling, 270+90, 5) -- Rollingをスポーン.
	end

	if self.timer % 200 == 0 then
		-- 2秒ごとにTripodを生成.
		local d = 1
		if math.random() < 0.5 then
			d = -1
		end
		local angle = 270 + (90 + 30 * math.random()) * d
		self:spawnEnemy(eEnemyType.Tripod, angle, 5) -- Tripodをスポーン.
	end
end

-- 敵の生成.
function Boss:spawnEnemy(type, angle, speed)
	if self.enemies == nil then
		return
	end
	local enemy = self.enemies:create(self.x, self.y, type)
	enemy:setVelocity(angle, speed)
	-- print("Boss spawned enemy of type " .. type .. " at (" .. enemy.x .. ", " .. enemy.y .. ") with velocity (" .. enemy.vx .. ", " .. enemy.vy .. ")")
end
