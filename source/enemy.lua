---@diagnostic disable
--[[
	Enemy.lua

	Enemyクラスは、ゲーム内の敵キャラクターを表すクラスです。
	Actorクラスを継承し、敵特有の動きや攻撃パターンを実装します。
--]]
import "CoreLibs/object"
import "actor"
import "game_context"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite

-- 敵の種類.
-- グローバルスコープに配置します.
eEnemyType = {
	Stinger = 1, -- 高速狙い撃ち弾.
	Side = 2, -- 両脇から横方向に弾を撃つ.
	Ring = 3, -- 周囲にリング状に弾を撃つ.
	Boss = 255,
}

-- 遅延弾発射情報.
class ("DelayedBatteryInfo").extends()
function DelayedBatteryInfo:init(angle, speed, delay, ax, ay)
	self.angle = angle
	self.speed = speed
	self.delay = delay
	self.ax = ax or 0
	self.ay = ay or 0
end
function DelayedBatteryInfo:elapsed()
	self.delay -= 1
	if self.delay <= 0 then
		return true -- 発射可能.
	end
	return false
end

-- 敵クラスの定義.
class("Enemy").extends(Actor)

-- コンストラクタ.
function Enemy:init(x, y, type)
	self.type = type
	local size = self:getSize()
	Enemy.super.init(self, x, y, size, size)
	self.bullets = GameContext.getInstance().bulletManager -- 弾を管理するActorManagerへの参照.
	self.hp = 3 -- 敵のHP.
	self.timer = 0
	self.step = 0 -- 攻撃パターンの段階管理用変数.
	self.lifetime = self:getLifetime() -- 生存時間.
	self.batteries = {} -- 遅延弾発射の情報を格納するテーブル.
	print("Enemy created at (" .. x .. ", " .. y .. ")")
end

-- 消滅.
function Enemy:destroy()
	self:despawn() -- 管理情報ごと削除.
end

-- 弾を撃つ.
--- @param angle number 角度（度）
--- @param speed number 速度
--- @param delay? integer 遅延時間（フレーム数）
--- @param ax? number 加速度X
--- @param ay? number 加速度Y
function Enemy:bullet(angle, speed, delay, ax, ay)
	if self.bullets == nil then
		return
	end
	-- デフォルト引数を設定.
	if delay == nil then delay = 0 end
	if ax == nil then ax = 0 end
	if ay == nil then ay = 0 end

	if delay > 0 then
		-- 遅延発射なのでリストに追加するだけ.
		self:_addBattery(angle, speed, delay, ax, ay)
		return
	end

	-- そのまま発射可能.
	local bullet = self.bullets:create(self.x, self.y)
	bullet:setVelocity(angle, speed)
	bullet.ax = ax
	bullet.ay = ay
end

-- 更新.
function Enemy:update()
	Enemy.super.update(self)
	self.lifetime -= 1
	if self.lifetime <= 0 then
		self:despawn() -- 生存時間が尽きたら管理情報ごと削除.
		return
	end

	self:_updateMovement() -- 敵の動きの更新.
	if self:isOffScreen() then
		self:despawn() -- 画面外に出たら管理情報ごと削除.
		return
	end

	self:_updateAttackPattern() -- 敵の攻撃パターンの更新.
	self:_updateBatteries() -- 遅延弾発射の更新.
end

-- 敵にダメージを与える関数.
function Enemy:damage(amount)
	self.hp = self.hp - amount
	print("Enemy damaged! HP: " .. self.hp)
	if self.hp <= 0 then
		self:destroy() -- HPが0以下になったら削除.
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

-- サイズを取得.
function Enemy:getSize()
	if self.type == eEnemyType.Ring then
		return 8
	elseif self.type == eEnemyType.Boss then
		return 48
	end
	return 16
end

-- 生存時間を取得.
function Enemy:getLifetime()
	if self.type == eEnemyType.Ring then
	elseif self.type == eEnemyType.Boss then
		return math.huge -- ボスは無限に生存する.
	end
	return 30 * 10 -- 10秒間生存（30FPS想定）.
end

-- 更新 > 移動.
function Enemy:_updateMovement()
	if self.type == eEnemyType.Stinger then
		self.vx *= 0.9 -- 徐々に減速.
		self.vy *= 0.9
	elseif self.type == eEnemyType.Side then
		if self.timer < 60 then
			self.vx *= 0.93 -- 徐々に減速.
			self.vy *= 0.93
		elseif self.timer == 60 then
			if self.x < pd.display.getWidth() / 2 then
				self.timer += 10 -- 発射タイミングをずらします.
			end
		else
			self.vx = 0 -- 60フレーム経過したら止まる.
			self.vy = 3 -- 下方向に移動.
		end
	else
		self.vx *= 0.9 -- 徐々に減速.
		self.vy *= 0.9
	end
	self:move(self.vx, self.vy, false) -- 画面外に出ても移動.
end
-- 更新 > 攻撃パターン.
function Enemy:_updateAttackPattern()
	self.timer += 1
	local aim = self:getAim()

	if self.type == eEnemyType.Stinger then
		-- 高速狙い撃ち弾.
		if self.timer % 30 == 0 then
			for i = 0, 5 do
				local delay = i * 2
				self:bullet(aim, 11, delay) -- 毎秒1発、プレイヤーに向かって弾を撃つ.
			end
			self.step += 1
			if self.step >= 3 then
				self.lifetime = 20 -- 3回攻撃したら消える.
			end
		end
	elseif self.type == eEnemyType.Side then
		-- 両脇から横方向に弾を撃つ.
		if self.timer < 60 then
			return -- 最初の60フレームは攻撃しない.
		end
		local angle = 0
		if self.x > pd.display.getWidth() / 2 then
			-- 画面左側にいる場合は右方向に撃つ.
			angle = 180
		end
		if self.timer % 20 == 0 then
			for i = 0, 3 do
				local delay = i * 2
				self:bullet(angle, 5, delay) -- 毎秒1発、横方向に弾を撃つ.
			end
		end
	elseif self.type == eEnemyType.Ring then
		-- 周囲にリング状に弾を撃つ.
		if self.timer % 30 == 0 then
			local spd = 3 + self.step * 2 -- 少しずつ速くする.
			self:bullet(aim, spd) -- 中心の角度に向かって1発撃つ.
			self.step += 1
			if self.step >= 5 then
				self.lifetime = 20 -- 5回攻撃したら消える.
			end
		end
	elseif self.type == eEnemyType.Boss then
		-- ボスは何もしない.
	end
end

-- N-Wayショットを撃つ.
--- @param n integer 弾の数
--- @param angle number 中心の角度（度）
--- @param speed number 速度
--- @param spread number 弾の広がり角度（度）
--- @param delay? integer 遅延時間（フレーム数）
function Enemy:_nWay(n, angle, speed, spread, delay)
	if self.bullets == nil then
		return
	end
	local d = spread / n
	local a = angle - (d * 0.5 * (n - 1))
	for i = 0, n - 1 do
		self:bullet(a, speed, delay)
		a += d
	end
end

-- 遅延弾発射の情報を追加する.
--- @param angle number 角度（度）
--- @param speed number 速度
--- @param delay integer 遅延時間（フレーム数）
--- @param ax number 加速度X
--- @param ay number 加速度Y
function Enemy:_addBattery(angle, speed, delay, ax, ay)
	table.insert(self.batteries, DelayedBatteryInfo(angle, speed, delay, ax, ay))
end

-- 遅延弾発射の更新.
function Enemy:_updateBatteries()
	for i = #self.batteries, 1, -1 do
		local battery = self.batteries[i]
		if battery:elapsed() then
			self:bullet(battery.angle, battery.speed, 0, battery.ax, battery.ay)
			table.remove(self.batteries, i) -- 発射したらリストから削除.
		end
	end
end
